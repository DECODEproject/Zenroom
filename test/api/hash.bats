# setup paths for BATS test units
setup() {
    bats_require_minimum_version 1.5.0
    T="$BATS_TEST_DIRNAME"
    TR=`cd "$T"/.. && pwd`
    R=`cd "$TR"/.. && pwd`
    TMP="$BATS_TEST_TMPDIR"
    load "$TR"/test_helper/bats-support/load
    load "$TR"/test_helper/bats-assert/load
    load "$TR"/test_helper/bats-file/load
    ZTMP="$BATS_FILE_TMPDIR"
    cd $ZTMP
    # vectors
    STR448='abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq'
    STR896='abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu'
}

save() {
    >&3 echo " 💾 $1"
    export output=`cat $ZTMP/$1`
}
@test "HASH API :: Compile tests" {
    LDADD="-L$R -lzenroom"
    CFLAGS="$CFLAGS -I$R/src"
    cc ${CFLAGS} -ggdb -o hash_init   $T/hash_init.c ${LDADD}
    cc ${CFLAGS} -ggdb -o hash_update $T/hash_update.c ${LDADD}
    cc ${CFLAGS} -ggdb -o hash_final  $T/hash_final.c ${LDADD}
}

@test "HASH API :: Init SHA512" {
    LD_LIBRARY_PATH=$R ./hash_init sha512 > ctx_sha512
    save ctx_sha512
    assert_output '40000000000000000000000000000000008c9bcf367e6096a3ba7ca8485ae67bb2bf894fe72f36e3cf1361d5f3af54fa5d182e6ad7f520e511f6c3e2b8c68059b6bbd41fbabd9831f79217e1319cde05b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000'
}


@test "HASH API :: Update SHA512" {
    LD_LIBRARY_PATH=$R ./hash_update `cat ctx_sha512` ${STR448} > ctx_sha512_448
    save ctx_sha512_448
    assert_output '4c001000000000000000000000000000008c9bcf367e6096a3ba7ca8485ae67bb2bf894fe72f36e3cf1361d5f3af54fa5d182e6ad7f520e511f6c3e2b8c68059b6bbd41fbabd9831f79217e1319cde05b6564636264636261676665646665646369686766686766656b6a69686a6968676d6c6b6a6c6b6a696f6e6d6c6e6d6c6b71706f6e706f6e6d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000'

    LD_LIBRARY_PATH=$R ./hash_update `cat ctx_sha512` ${STR896} > ctx_sha512_896
    save ctx_sha512_896
    assert_output '48003000000000000000000000000000008c9bcf367e6096a3ba7ca8485ae67bb2bf894fe72f36e3cf1361d5f3af54fa5d182e6ad7f520e511f6c3e2b8c68059b6bbd41fbabd9831f79217e1319cde05b686766656463626169686766656463626a696867666564636b6a6968676665646c6b6a69686766656d6c6b6a696867666e6d6c6b6a6968676f6e6d6c6b6a6968706f6e6d6c6b6a6971706f6e6d6c6b6a7271706f6e6d6c6b737271706f6e6d6c74737271706f6e6d7574737271706f6e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000'
}


@test "HASH API :: Final SHA512" {
    LD_LIBRARY_PATH=$R ./hash_final `cat ctx_sha512_448` > hash_sha512_448
    save hash_sha512_448
    assert_output 'IEqPxt2oLwoM7XvrjgikFlfBbvRosiioJ5vjMacDwzWW/RXBOxsH+aodO+pXeJygMa2Fx6cd1wNU7GMSOMo0RQ=='

    LD_LIBRARY_PATH=$R ./hash_final `cat ctx_sha512_896` > hash_sha512_896
    save hash_sha512_896
    assert_output 'jpWbddrjE9qM9PcoFPwUP493ecbrn3+hcpmurbaIkBhQHSieSQD35DMbmd7EtUM6x9Mp7rbdJlReluVbh0vpCQ=='

}

#####################################
### SHA256

@test "HASH API :: Init SHA256" {
    LD_LIBRARY_PATH=$R ./hash_init sha256 > ctx_sha256
    save ctx_sha256
    assert_output '2000000000000000067e6096a85ae67bb72f36e3c3af54fa57f520e518c68059babd9831f19cde05b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000'
}
@test "HASH API :: Update SHA256" {
    LD_LIBRARY_PATH=$R ./hash_update `cat ctx_sha256` ${STR448} > ctx_sha256_448
    save ctx_sha256_448
    assert_output '2c00100000000000067e6096a85ae67bb72f36e3c3af54fa57f520e518c68059babd9831f19cde05b6463626165646362666564636766656468676665696867666a6968676b6a69686c6b6a696d6c6b6a6e6d6c6b6f6e6d6c706f6e6d71706f6e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000'
    LD_LIBRARY_PATH=$R ./hash_update `cat ctx_sha256` ${STR896} > ctx_sha256_896
    save ctx_sha256_896
    assert_output '28003000000000000db7d194f1e9054fee1a0f6d67bdb0cfc69cdbcdc36450b12e6d4085b70ec2e026c6b6a69706f6e6d6d6c6b6a71706f6e6e6d6c6b7271706f6f6e6d6c73727170706f6e6d7473727171706f6e757473726a6968676e6d6c6b6b6a69686f6e6d6cadabeba88d03410698a672713a627a493781cd98f8c5f7e87806b5c226848a7123c38fde9d2083f1d8e326d6025813ba7df7e3c8062898762b0026e83f4dc300c730c1b4d1e50a432b460fcf2b72065dfd33fa785045b370935bf306ccdf0d9d972649d64da96928dbbc10af8b82e533084cb48b930082b9c3c831e2908842edf3f4fecde1e371a793bf596987e5712f84d6409abb08951185b9526386a71b0d4680b47ecdc77ec6bbb7701f44e1b89cb12fde9a105035735ba9ac5f86d326b10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000'
}

@test "HASH API :: Final SHA256" {
    LD_LIBRARY_PATH=$R ./hash_final `cat ctx_sha256_448` > hash_sha256_448
    save hash_sha256_448
    assert_output 'JI1qYdIGOLjlwCaTDD5gOaM85Flk/yFn9uzt1BnbBsE='
    LD_LIBRARY_PATH=$R ./hash_final `cat ctx_sha256_896` > hash_sha256_896
    save hash_sha256_896
    assert_output 'z1sWp3ivg4ADbOWeewSSNwskmxHo8HpRr6xFA3r+6dE='
}
