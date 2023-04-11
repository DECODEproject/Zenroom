--[[
--This file is part of zenroom
--
--Copyright (C) 2021 Dyne.org foundation
--designed, written and maintained by Alberto Lerda
--
--This program is free software: you can redistribute it and/or modify
--it under the terms of the GNU Affero General Public License v3.0
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU Affero General Public License for more details.
--
--Along with this program you should have received a copy of the
--GNU Affero General Public License v3.0
--If not, see http://www.gnu.org/licenses/agpl.txt
--
--]]

local bbs = {}
local hash = HASH.new('sha256')
local hash_len = 32

local hash3 = HASH.new('sha3_256')

-- RFC8017 section 4
-- converts a nonnegative integer to an octet string of a specified length.
local function i2osp(x, x_len)
    return O.new(BIG.new(x)):pad(x_len)
end

-- RFC8017 section 4
-- converts an octet string to a nonnegative integer.
local function os2ip(oct)
    return BIG.new(oct)
end
function bbs.hkdf_extract(salt, ikm)
    return HASH.hmac(hash, salt, ikm)
end

function bbs.hkdf_expand(prk, info, l)

    assert(#prk >= hash_len)
    assert(l <= 255 * hash_len)
    assert(l > 0)

    if type(info) == 'string' then
        info = O.from_string(info)
    end

    n = math.ceil(l/hash_len)

    -- TODO: optimize using something like table.concat for octets
    tprec = HASH.hmac(hash, prk, info .. O.from_hex('01'))
    i = 2
    t = tprec
    while l > #t do
        tprec = HASH.hmac(hash, prk, tprec .. info .. O.from_hex(string.format("%02x", i)))
        t = t .. tprec
        i = i+1
    end

    -- TODO: check that sub is not creating a copy
    return t:sub(1,l)
end

function bbs.keygen(ikm, key_info)
    -- TODO: add warning on curve must be BLS12-381
    local INITSALT = O.from_string("BBS-SIG-KEYGEN-SALT-")

    if not key_info then
        key_info = O.empty()
    elseif type(key_info) == 'string' then
        key_info = O.from_string(key_info)
    end

    -- using BLS381
    -- 254 < log2(r) < 255
    -- ceil((3 * ceil(log2(r))) / 16)
    l = 48
    salt = INITSALT
    sk = INT.new(0)
    while sk == INT.new(0) do
        salt = hash:process(salt)
        prk = bbs.hkdf_extract(salt, ikm .. i2osp(0, 1))
        okm = bbs.hkdf_expand(prk, key_info .. i2osp(l, 2), l)
        sk = os2ip(okm) % ECP.order()
    end

    return sk
end


function bbs.sk2pk(sk)
    return ECP2.generator() * sk
end

function bbs.sign(sk, pk, headers, messages)

end

-- TODO: implement expand_message_xmd with other hash functions? Leave this function inside the bbs table?

-- draft-irtf-cfrg-hash-to-curve-16 section 5.3.1
-- It outputs a uniformly random byte string.
function bbs.expand_message_xmd(msg, DST, len_in_bytes)
    -- msg, DST are OCTETS; len_in_bytes is an integer.

    -- Parameters:
    -- a hash function (SHA-256 or SHA3-256 are appropriate)
    local b_in_bytes = 32 -- = output size of hash IN BITS / 8
    local s_in_bytes = 64 -- ok for SHA-256

    local ell = math.ceil(len_in_bytes / b_in_bytes)
    assert(ell <= 255)
    assert(len_in_bytes <= 65535)
    local DST_len = #DST
    assert( DST_len <= 255)

    local DST_prime = DST .. i2osp(DST_len, 1)
    local Z_pad = i2osp(0, s_in_bytes)
    local l_i_b_str = i2osp(len_in_bytes, 2)
    local msg_prime = Z_pad..msg..l_i_b_str..i2osp(0,1)..DST_prime

    local b_0 = hash:process(msg_prime)
    local b_1 = hash:process(b_0..i2osp(1,1)..DST_prime)
    local uniform_bytes = b_1
    -- b_j assumes the value of b_(i-1) inside the for loop, for i between 2 and ell.
    local b_j = b_1
    for i = 2,ell do
        local b_i = hash:process(O.xor(b_0, b_j)..i2osp(i,1)..DST_prime)
        b_j = b_i
        uniform_bytes = uniform_bytes..b_i
    end
    return uniform_bytes:sub(1,len_in_bytes), DST_prime, msg_prime

end

return bbs
