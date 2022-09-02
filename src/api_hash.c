/* This file is part of Zenroom (https://zenroom.dyne.org)
 *
 * Copyright (C) 2022 Dyne.org foundation
 * designed, written and maintained by Denis Roio <jaromil@dyne.org>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 */

// external API function for streaming hash

#include <stdlib.h>
#include <strings.h> // libc

#include <amcl.h>
#include <ecdh_support.h> // AMCL

#include <zen_error.h>
#include <encoding.h> // zenroom

 // first byte is type
#define ZEN_SHA512 '4'

inline void print_ctx_hex(char prefix, void *sh, int len) {
  char *hash_ctx = malloc((len<<1)+2);
  hash_ctx[0] = prefix;
  buf2hex(hash_ctx+1, (const char*)sh, (const size_t)len);
  hash_ctx[(len<<1)+1] = 0x0; // null terminated string
  fprintf(stdout, "%s\n", hash_ctx);
  free(hash_ctx);
}

// returns a fills hash_ctx, which must be pre-allocated externally
int zenroom_hash_init(const char *hash_type) {
  register char prefix = '0';
  // size tests
  register int len = 0; 
  void *sh;
  if(strcasecmp(hash_type, "sha512") == 0) {    
    prefix = ZEN_SHA512;
    len = sizeof(hash512); // amcl struct
    sh = calloc(len, 1);
    // TODO: check what malloc returns
    HASH512_init((hash512*)sh); // amcl init
  } else {
    zerror(NULL, "%s :: invalid hash type: %s", __func__, hash_type);
    return 4; // ERR_INIT
  }
  print_ctx_hex(prefix, sh, len);
  free(sh);
  return 0;
}

// returns hash_ctx updated
int zenroom_hash_update(const char *hash_ctx,
			const char *buffer, const int buffer_size) {
  register char prefix = hash_ctx[0];
  register int len;
  char *sh;
  if(prefix==ZEN_SHA512) {
    len = sizeof(hash512);
    sh = (char*)calloc(len, 1);
    hex2buf(sh, hash_ctx+1);
    register int c;
    for(c=0; c<buffer_size; c++) {
      HASH512_process((hash512*)sh, buffer[c]);
    }
  } else {
    zerror(NULL, "%s :: invalid hash context prefix: %c", __func__, prefix);
    return 3;
  }
  print_ctx_hex(prefix, sh, len);
  free(sh);
  return 0;
}

// returns the hash string base64 encoded
int zenroom_hash_final(const char *hash_ctx) {
  register char prefix = hash_ctx[0];
  register int len;
  char *hash_result;
  octet tmp;
  char *sh;
  if(prefix==ZEN_SHA512) {
    hash_result = malloc(90); // base64 is 88 with padding
    tmp.len = 64;
    tmp.val = (char*)malloc(64);
    // TODO: check malloc result
    len = sizeof(hash512);
    sh = (char*)calloc(len, 1);
    // TODO: check malloc result
    hex2buf(sh, hash_ctx+1);
    HASH512_hash((hash512*)sh, tmp.val);
  } else {
    zerror(NULL, "%s :: invalid hash context prefix: %c", __func__, prefix);
    return 3;
  }
  OCT_tobase64(hash_result,&tmp);
  free(tmp.val);
  fprintf(stdout, "%s\n", hash_result);
  free(hash_result);
  free(sh);
  return 0;
}