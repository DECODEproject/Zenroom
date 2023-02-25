fn main() {
    cc::Build::new()
        .include("../../src")
        .include("../../lib/lua53/src")
        .include("../../lib/milagro-crypto-c/build/include")
        .include("../../lib/milagro-crypto-c/include")
        .include("../../lib/zstd")
        .include("../../lib/blake2")
        .include("../../lib/ed25519-donna")
        .include("../../lib/pqclean")
        .include("../../lib/mimalloc")
// milagro
        .file("../../lib/milagro-crypto-c/src/rand.c")
        .file("../../lib/milagro-crypto-c/src/oct.c")
        .file("../../lib/milagro-crypto-c/src/hash.c")
        .file("../../lib/milagro-crypto-c/src/gcm.c")
        .file("../../lib/milagro-crypto-c/src/ecdh_support.c")
        .file("../../lib/milagro-crypto-c/src/aes.c")
// zenroom
        .file("../../src/base58.c")
        .file("../../src/zen_random.c")
        .file("../../src/zen_qp.c")
        .file("../../src/zen_parse.c")
        .file("../../src/zen_memory.c")
        .file("../../src/zen_io.c")
        .file("../../src/zen_hash.c")
        .file("../../src/zen_fp12.c")
        .file("../../src/zen_float.c")
        .file("../../src/zen_error.c")
        .file("../../src/zen_ed.c")
        .file("../../src/zen_ecp.c")
        .file("../../src/zen_ecp2.c")
        .file("../../src/zen_ecdh.c")
        .file("../../src/zen_config.c")
        .file("../../src/zen_aes.c")
        .file("../../src/segwit_addr.c")
        .file("../../src/rmd160.c")
        .file("../../src/randombytes.c")
        .file("../../src/mutt_sprintf.c")
        .file("../../src/lua_shims.c")
        .file("../../src/lua_modules.c")
        .file("../../src/zen_octet.c")
        .file("../../src/zen_big.c")
        .file("../../src/encoding.c")
        .file("../../src/zenroom.c")
        .file("../../src/lua_functions.c")
        .file("../../src/zen_ecdh_factory.c")
        .file("../../src/lualibs_detected.c")
        .compile("zenroom");
    println!("cargo:rerun-if-changed=../../src/*");
}
