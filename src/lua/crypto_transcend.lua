--[[
    --This file is part of zenroom
    --
    --Copyright (C) 2024 Dyne.org foundation
    --Written by Denis Roio
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
--]]

local T = { }

-- The length of RSK marks the maximum message length
-- to make sure that its XOR covers the whole message
-- it is limited to 32 because of the AES.ctr limit.
T.RSK_length = 32
T.HASH = HASH.new('sha256') -- do not change

-- TODO: check IV length
-- pad message if smaller than 32
-- find minimum length of k

T.encode_message = function(SS, nonce, cleartext, RSK, IV)
    local len = #cleartext
    -- RSK arg is only used to verify vectors
    local rsk = RSK or OCTET.random(len + 32) -- + hash size
    local iv = IV or T.HASH:process(nonce)
    -- hash result must be 32 bytes to fit as AES.ctr key
    local m = {
        n = nonce,
        k = AES.ctr_encrypt(T.HASH:process(SS), rsk, iv)
            ~ AES.ctr_encrypt(T.HASH:process(SS), nonce, iv),
        p = AES.ctr_encrypt(
            T.HASH:process(rsk),
            T.HASH:process(rsk ~ SS) .. cleartext, iv)
            ~ rsk
    }
    return m
end

T.decode_message = function(SS, ciphertext, IV)
    local iv = IV or T.HASH:process(nonce)
    local rsk = AES.ctr_decrypt(
        T.HASH:process(SS), ciphertext.k
        ~ AES.ctr_encrypt(T.HASH:process(SS), ciphertext.n, iv),
        iv)
    local m = AES.ctr_decrypt(T.HASH:process(rsk),
                              ciphertext.p ~ rsk, iv)
    local mac = T.HASH:process(rsk ~ SS)
    return m:sub(33,#m+32), rsk
end

T.encode_response = function(SS, nonce, rsk, cleartext, IV)
    local r_len = #rsk - 32
    -- response length must be smaller or equal to message len
    assert(#cleartext <= r_len)
    local iv = IV or T.HASH:process(nonce)
    return AES.ctr_encrypt(
        T.HASH:process(SS),
        (T.HASH:process(nonce ~ rsk) .. cleartext:pad(r_len))
        ~ rsk, iv)
end

T.decode_response = function(SS, nonce, rsk, ciphertext, IV)
    local iv = IV or T.HASH:process(nonce)
    local m = AES.ctr_decrypt(
        T.HASH:process(SS), ciphertext, iv) ~ rsk
    local mac = T.HASH:process(nonce ~ rsk)
    return m:sub(33,#m+32), mac
end

return T
