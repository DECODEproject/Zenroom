// The MIT License

// Copyright (c) 2017 Daan Sprenkels <hello@dsprenkels.com>

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#include <string.h>
#include <stdlib.h>

#include "randombytes.h"

#if defined(_WIN32)
/* Windows */
# include <windows.h>
# include <wincrypt.h> /* CryptAcquireContext, CryptGenRandom */
#endif /* defined(_WIN32) */


#if defined(__linux__)
/* Linux */
# define _GNU_SOURCE
# include <assert.h>
# include <errno.h>
# include <fcntl.h>
# include <linux/random.h>
# include <poll.h>
# include <stdint.h>
# include <sys/ioctl.h>
# include <sys/stat.h>
# include <sys/syscall.h>
# include <sys/types.h>
# include <unistd.h>

// We need SSIZE_MAX as the maximum read len from /dev/urandom
# if !defined(SSIZE_MAX)
#  define SSIZE_MAX (SIZE_MAX / 2 - 1)
# endif /* defined(SSIZE_MAX) */

#endif /* defined(__linux__) */


#if defined(__unix__) || (defined(__APPLE__) && defined(__MACH__))
/* Dragonfly, FreeBSD, NetBSD, OpenBSD (has arc4random) */
# include <sys/param.h>
# if defined(BSD)
#  include <stdlib.h>
# endif
#endif


#if defined(_WIN32)
static int randombytes_win32_randombytes(void* buf, const size_t n)
{
	HCRYPTPROV ctx;
	BOOL tmp;

	tmp = CryptAcquireContext(&ctx, NULL, NULL, PROV_RSA_FULL,
	                          CRYPT_VERIFYCONTEXT);
	if (tmp == FALSE) return -1;

	tmp = CryptGenRandom(ctx, n, (BYTE*) buf);
	if (tmp == FALSE) return -1;

	tmp = CryptReleaseContext(ctx, 0);
	if (tmp == FALSE) return -1;

	return 0;
}
#endif /* defined(_WIN32) */


#if defined(__linux__) && defined(SYS_getrandom)
static int randombytes_linux_randombytes_getrandom(void *buf, size_t n)
{
	/* I have thought about using a separate PRF, seeded by getrandom, but
	 * it turns out that the performance of getrandom is good enough
	 * (250 MB/s on my laptop).
	 */
	size_t offset = 0, chunk;
	int ret;
	while (n > 0) {
		/* getrandom does not allow chunks larger than 33554431 */
		chunk = n <= 33554431 ? n : 33554431;
		do {
			ret = syscall(SYS_getrandom, (char *)buf + offset, chunk, 0);
		} while (ret == -1 && errno == EINTR);
		if (ret < 0) return ret;
		offset += ret;
		n -= ret;
	}
	assert(n == 0);
	return 0;
}
#endif /* defined(__linux__) && defined(SYS_getrandom) */


#if defined(__linux__) && !defined(SYS_getrandom)
static int randombytes_linux_get_entropy_avail(int fd)
{
	int ret;
	ioctl(fd, RNDGETENTCNT, &ret);
	return ret;
}


static int randombytes_linux_wait_for_entropy(int device)
{
	/* We will block on /dev/random, because any increase in the OS' entropy
	 * level will unblock the request. I use poll here (as does libsodium),
	 * because we don't *actually* want to read from the device. */
	const int bits = 128;
	struct pollfd pfd;
	int fd, retcode; /* Used as file descriptor *and* poll() return code */

	/* If the device has enough entropy already, we will want to return early */
	if (randombytes_linux_get_entropy_avail(device) >= bits) {
		return 0;
	}

	do {
		fd = open("/dev/random", O_RDONLY);
	} while (fd == -1 && errno == EINTR); /* EAGAIN will not occur */
	if (fd == -1) {
		/* Unrecoverable IO error */
		return -1;
	}

	pfd.fd = fd;
	pfd.events = POLLIN;
	do {
		retcode = poll(&pfd, 1, -1);
	} while ((retcode == -1 && (errno == EINTR || errno == EAGAIN)) ||
	         randombytes_linux_get_entropy_avail(device) < bits);
	if (retcode != 1) {
		do {
			retcode = close(fd);
		} while (retcode == -1 && errno == EINTR);
		return -1;
	}
	retcode = close(fd);
	return retcode;
}


static int randombytes_linux_randombytes_urandom(void *buf, size_t n)
{
	int fd;
	size_t offset = 0, count;
	ssize_t tmp;
	do {
		fd = open("/dev/urandom", O_RDONLY);
	} while (fd == -1 && errno == EINTR);
	if (randombytes_linux_wait_for_entropy(fd) == -1) return -1;

	while (n > 0) {
		count = n <= SSIZE_MAX ? n : SSIZE_MAX;
		tmp = read(fd, (char *)buf + offset, count);
		if (tmp == -1 && (errno == EAGAIN || errno == EINTR)) {
			continue;
		}
		if (tmp == -1) return -1; /* Unrecoverable IO error */
		offset += tmp;
		n -= tmp;
	}
	assert(n == 0);
	return 0;
}
#endif /* defined(__linux__) && !defined(SYS_getrandom) */


#if defined(BSD)
static int randombytes_bsd_randombytes(void *buf, size_t n)
{
	arc4random_buf(buf, n);
	return 0;
}
#endif /* defined(BSD) */


#ifdef __EMSCRIPTEN__
#include <emscripten.h>
int randombytes(void *buf, size_t n) {
	EM_ASM({
			if (Module.getRandomValue === undefined) {
				try {
					var window_ = 'object' === typeof window ? window : self;
					var crypto_ = typeof window_.crypto !== 'undefined' ? window_.crypto : window_.msCrypto;
					var randomValuesStandard = function() {
						var buf = new Uint32Array(1);
						crypto_.getRandomValues(buf);
						return buf[0] >>> 0;
					};
					randomValuesStandard();
					Module.getRandomValue = randomValuesStandard;
				} catch (e) {
					try {
						var crypto = require('crypto');
						var randomValueNodeJS = function() {
							var buf = crypto['randomBytes'](4);
							return (buf[0] << 24 | buf[1] << 16 | buf[2] << 8 | buf[3]) >>> 0;
						};
						randomValueNodeJS();
						Module.getRandomValue = randomValueNodeJS;
					} catch (e) {
						throw 'No secure random number generator found';
					}
				}
			}
		});
	char *bytes = (char*)EM_ASM_INT({
			var randomBytes = _malloc($0);
			Module.getRandomValue(randomBytes);
		}, n);
	memcpy(buf,bytes,n);
	free(bytes);
	return 0;
}
#else

int randombytes(void *buf, size_t n)
{
#if defined(__linux__)
# if defined(SYS_getrandom)
#  pragma message("Using getrandom system call")
	/* Use getrandom system call */
	return randombytes_linux_randombytes_getrandom(buf, n);
# else
#  pragma message("Using /dev/urandom device")
	/* When we have enough entropy, we can read from /dev/urandom */
	return randombytes_linux_randombytes_urandom(buf, n);
# endif
#elif defined(BSD)
# pragma message("Using arc4random system call")
	/* Use arc4random system call */
	return randombytes_bsd_randombytes(buf, n);
#elif defined(_WIN32)
# pragma message("Using Windows cryptographic API")
	/* Use windows API */
	return randombytes_win32_randombytes(buf, n);
#else
# error "randombytes(...) is not supported on this platform"
#endif
}

#endif
