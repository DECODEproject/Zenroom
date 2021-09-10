-- Warning: problem importing big int

-- I get from the outside the list of unspent transactions
-- I filter the one that have enough BTC
-- e.g. from
-- [
--   {
--     "txid": "5cd1a9c46c2d06d2ae25b2eb5e819eca1850b748336deef580d49e46f852add1",
--     "vout": 1,
--     "address": "mrxDNeNhmXxpNgdcuLqAaHkcn5gPrZHPRh",
--     "label": "",
--     "scriptPubKey": "76a9147d705ebfc54c783c527d66abe48cd532a97fb28c88ac",
--     "amount": 0.00010000,
--     "confirmations": 212,
--     "spendable": true,
--     "solvable": true,
--     "desc": "pkh([7d705ebf]03fe7380f1549462e6f9fff99c2bd0084a2ce568f79f0001f020b4135385394276)#av5c7yvg",
--     "safe": true
--   },
--   {
--     "txid": "b0675436dd79bc101780c4891d2ef342a128c49e7a269ac135a14552b321ecd2",
--     "vout": 1,
--     "address": "mrxDNeNhmXxpNgdcuLqAaHkcn5gPrZHPRh",
--     "label": "",
--     "scriptPubKey": "76a9147d705ebfc54c783c527d66abe48cd532a97fb28c88ac",
--     "amount": 0.00060000,
--     "confirmations": 212,
--     "spendable": true,
--     "solvable": true,
--     "desc": "pkh([7d705ebf]03fe7380f1549462e6f9fff99c2bd0084a2ce568f79f0001f020b4135385394276)#av5c7yvg",
--     "safe": true
--   },
--   {
--     "txid": "b0b4eff88aaedc55b1ff85224cd9e93dad88f867ed093b868060024020e81ad3",
--     "vout": 1,
--     "address": "mrxDNeNhmXxpNgdcuLqAaHkcn5gPrZHPRh",
--     "label": "",
--     "scriptPubKey": "76a9147d705ebfc54c783c527d66abe48cd532a97fb28c88ac",
--     "amount": 0.00083000,
--     "confirmations": 5,
--     "spendable": true,
--     "solvable": true,
--     "desc": "pkh([7d705ebf]03fe7380f1549462e6f9fff99c2bd0084a2ce568f79f0001f020b4135385394276)#av5c7yvg",
--     "safe": true
--   }
-- ]

-- sk: af3ec27d2b92fed349a4f8baabadfa27deed8a29eb795734373e6f3e14ae5c61
-- pk: 02845b2dc1d8cf62e441e98b27ac11bec7dbc799d03f1fd2fad9642e32ce6a96ca
SHA256 = HASH.new('sha256')
function dSha256(msg)
   return SHA256:process(SHA256:process(msg))
end


function opposite(num)
   local res = O.new()
   for i=#num,1,-1 do
      res = res .. num:sub(i,i)
   end
   return res
end

Bech32Chars = "qpzry9x8gf2tvdw0s3jn54khce6mua7l"
BechInverse = {}
for i=1,#Bech32Chars,1 do
   BechInverse[Bech32Chars:sub(i,i)] = i-1
end

-- taken from zencode_ecdh
function compressPublicKey(public)
   local x, y = ECDH.pubxy(public)
   local pfx = fif( BIG.parity(BIG.new(y) ), OCTET.from_hex('03'), OCTET.from_hex('02') )
   local pk = pfx .. x
   return pk
end


halfSecp256k1n = INT.new(hex('7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0'))
-- it is similar to sign eth, s < order/2
-- Warning: it differs from eth for the sign function I call (sign vs sign_hashed)
function signEcdhBc(sk, data) 
  local sig
  sig = nil
  repeat
    sig = ECDH.sign_hashed(sk, data, #data)
  until(INT.new(sig.s) < halfSecp256k1n);

  return sig
end

function readBech32Address(addr)
   local prefix, data, res, byt, countBit,val
   prefix = nil
   if addr:sub(1,4) == 'bcrt' then
      prefix = 4
   elseif addr:sub(1,2) == 'bc' or addr:sub(1,2) == 'tb' then
      prefix = 2
   end
   if not prefix then
      error("Not bech32")
   end
   -- +3 = do not condider separator and version bit
   data = addr:sub(prefix+3, #addr)

   res = O.new()
   byt=0 -- byte accumulator
   countBit = 0 -- how many bits I have put in the accumulator
   for i=1,#data,1 do
      val = BechInverse[data:sub(i,i)]

      -- Add 5 bits to the buffer
      byt = (byt << 5) + val
      countBit = countBit + 5

      if countBit >= 8 then
	 res = res .. INT.new(byt >> (countBit-8)):octet()

	 byt = byt % (1 << (countBit-8))

	 countBit = countBit - 8
      end
   end

   -- TODO: I dont look at the checksum
   
   return res:chop(20)
end

-- Problem: Overflow of BIG integer
-- function decodeBase58Check(value, prefix)
--    local BASE58CHARS = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
--    if not prefix then
--       prefix = O.from_hex('00')
--    end
--    BIG58 = BIG.new(58)
--    local decodedInt
--    decodedInt = BIG.new(0)
--    for i=1, #value, 1 do
--       -- print(string.find(BASE58CHARS, value:sub(i,i))-1)
--       decodedInt = decodedInt * BIG58 + BIG.new(string.find(BASE58CHARS, value:sub(i,i))-1)
--    end
--    -- print(decodedInt)
--    -- local decoded = decodedInt:octet()
--    -- print(decoded:hex())

--    --if decoded:sub(1,1) ~= prefix then
--   --    error("Error in the prefix")
--    --end

--    -- local CODE_LEN
--    -- CODE_LEN = 4

--    -- local errorCode = dSha256(decoded):chop(CODE_LEN)
--    -- decoded = decoded:sub(2, #decoded)

--    -- if errorCode ~= decoded:sub(#decoded-CODE_LEN+1, #decoded) then
--    --   error("Invalid base58 string")
--    -- end

--    -- return decoded:sub(1, #decoded-CODE_LEN)
--    return decodedInt
-- end

-- --print(readBech32Address('bcrt1qnyu4k62dcj0d90f20zrxn07e2pg7rgyf5esn80'):hex())

function encodeCompactSize(n)
   local res, padding, prefix, le -- littleEndian;

   if type(n) ~= "bignum" then
      n = INT.new(n)
   end
   
   padding = 0
   res = O.new()
   if n <= INT.new(252) then
      res = n:octet()
   else
      le = opposite(n:octet())
      prefix = O.new()
      if n <= INT.new('0xffff') then
	 prefix = O.from_hex('fd') 
	 padding = 2
      elseif n <= INT.new('0xffffffff') then
	 prefix = O.from_hex('fe')
	 padding = 4
      elseif n <= INT.new('0xffffffffffffffff') then
	 prefix = O.from_hex('ff')
	 padding = 8
      else
	 padding = #le
      end
      res = prefix .. le
      padding = padding - #le
   end

   if padding > 0 then
      res = res .. O.zero(padding)
   end

   return res
end

function toUInt(num, nbytes)
   if type(num) ~= "bignum" then
      num = INT.new(num)
   end
   num = opposite(num:octet())
   if #num < nbytes then
      num = num .. O.zero(nbytes - #num)
   end
   return num
end

assert(encodeCompactSize(INT.new(1)) == O.from_hex('01'))
assert(encodeCompactSize(INT.new(253)) == O.from_hex('fdfd00'))
assert(encodeCompactSize(INT.new(515)) == O.from_hex('fd0302'))

-- with not coinbase input
function buildRawTransaction(txIn)
   local raw, script
   raw = O.new()

   if tx["witness"] and #tx["witness"]>0 then
      sigwit = true
   else
      sigwit = false
   end

   -- version
   raw = raw .. O.from_hex('02000000')


   if sigwit then
      -- marker + flags
      raw = raw .. O.from_hex('0001')
   end
   
   raw = raw .. encodeCompactSize(INT.new(#tx.txIn))

   -- txIn
   for _, v in pairs(tx.txIn) do
      -- outpoint (hash and index of the transaction)
      raw = raw .. opposite(v.txid) .. toUInt(v.vout, 4)

      -- the script depends on the signature
      script = O.new()

      raw = raw .. encodeCompactSize(#script) .. script
      
      -- Sequence number disabled
      raw = raw .. O.from_hex('ffffffff')
   end

   raw = raw .. encodeCompactSize(INT.new(#tx.txOut))

   -- txOut
   for _, v in pairs(tx.txOut) do
      --raw = raw .. toUInt(v.amount, 8)
      raw = raw .. opposite(v.amount)
      if #v.amount < 8 then
	 raw = raw .. O.zero(8 - #v.amount)
      end
      
      -- fixed script to send bitcoins
      -- OP_DUP OP_HASH160 20byte
      --script = O.from_hex('76a914')

      --script = script .. v.address

      -- OP_EQUALVERIFY OP_CHECKSIG
      --script = script .. O.from_hex('88ac')
      
      -- Bech32
      script = O.from_hex('0014')
      script = script .. readBech32Address(v.address)
      
      raw = raw .. encodeCompactSize(#script) .. script
   end

   if sigwit then
      -- Documentation https://bitcoincore.org/en/segwit_wallet_dev/
      -- The documentation talks about "stack items" but it doesn't specify
      -- which are they, I think that It depends on the type of transaction
      -- (P2SH or P2PKH)

      -- The size of witnesses is not necessary because it is equal to the number of
      -- txin
      --raw = raw .. encodeCompactSize(#tx["witness"])

      for _, v in pairs(tx["witness"]) do
	 -- encode all the stack items for the witness
	 raw = raw .. encodeCompactSize(#v)
	 for _, s in pairs(v) do
	    raw = raw .. encodeCompactSize(#s)
	    raw = raw .. s
	 end
      end
   end

   raw = raw .. O.from_hex('00000000')
   
   return raw
end

function encodeWithPrepend(bytes)
   if tonumber(bytes:sub(1,1):hex(), 16) >= 0x80 then
      bytes = O.from_hex('00') .. bytes
   end

   return bytes
end

function encodeDERSignature(sig)
   local res, tmp;

   res = O.new()

   -- r
   tmp = encodeWithPrepend(sig.r)
   res = res .. O.from_hex('02') .. INT.new(#tmp):octet() .. tmp

   -- s
   tmp = encodeWithPrepend(sig.s)
   res = res .. O.from_hex('02') .. INT.new(#tmp):octet() .. tmp
   
   res = O.from_hex('30') .. INT.new(#res):octet() .. res
   return res
end

-- sender tb1q04c9a079f3urc5nav647frx4x25hlv5vanfgug
sk = O.from_hex('39507b5471b71740675ddfdd0ace08f265e13bb168efce59a7e7d6d6782a8de501ea')
--sk = O.from_hex('7a1afbb80174a41ad288053b246c7f528f5e746332f95f19e360c95bfb1d03bd0188')
pk = ECDH.pubgen(sk)
tx = {
   txIn = {
      {
	 txid= O.from_hex("8cf73380cd054b6936360401b53a9db0cb30e33a7997bfd65fad939579096678"),
	 vout= 0,
      }
   },
   txOut = {
      {
	 amount = O.from_hex('1cee40'), -- this maybe should be a number
	 address = 'tb1q73czlxl7us4s6num5sjlnq6r0yuf8uh5clr2tm'
      }
   }
}


txEnc = buildRawTransaction(tx)
--print("Raw tx")
--print(txEnc:hex())
--sig = signEcdhBc(sk, txEnc .. O.from_hex('01000000'))

-- print(encodeDERSignature(sig):hex())

-- add sighash: 1-byte value indicating what data is hashed (not part of the DER signature)
-- tx["witness"] = {
--    { encodeDERSignature(sig) .. O.from_hex('01'), compressPublicKey(pk) }
-- }
-- print("Raw signed")
-- print(buildRawTransaction(tx):hex())
-- rawsign = buildRawTransaction(tx)


function hashPrevouts(tx)
   local raw
   local H
   H = HASH.new('sha256')

   raw = O.new()

   for _, v in pairs(tx.txIn) do
      raw = raw .. opposite(v.txid) .. toUInt(v.vout, 4)
   end

   return H:process(H:process(raw))
end

function hashSequence(tx)
   local raw
   local H
   local seq
   H = HASH.new('sha256')

   raw = O.new()

   for _, v in pairs(tx.txIn) do
      seq = v['sequence']
      if not seq then
	 -- default value, not enabled
	 seq = O.from_hex('ffffffff')
      end
      raw = raw .. toUInt(seq, 4)
   end
   
   return H:process(H:process(raw))
end

function addressScript(addr)
   if type(addr) == "zenroom.octet" then
      return addr
   end
   -- Only support bech32 address
   return readBech32Address(addr)
end

function hashOutputs(tx)
   local raw
   local H
   local seq
   H = HASH.new('sha256')

   raw = O.new()

   for _, v in pairs(tx.txOut) do 
      raw = raw .. opposite(v.amount)
      if #v.amount < 8 then
	 raw = raw .. O.zero(8 - #v.amount)
      end
      
      if type(v.address) == "zenroom.octet" then
	 raw = raw .. v.address
      else
	 raw = raw .. O.from_hex('160014') .. readBech32Address(v.address)
      end      
   end

   return H:process(H:process(raw))
end
--------------------------
--   test from BIP0143  --
--------------------------
pk = O.from_hex('045476c2e83188368da1ff3e292e7acafcdb3566bb0ad253f62fc70f07aeee6357fd57dee6b46a6b010a3e4a70961ecf44a40e18b279ec9e9fba9c1dbc64896198')
tx = {
   version=1,
   txIn = {
      {
	 txid= O.from_hex("9f96ade4b41d5433f4eda31e1738ec2b36f6e7d1420d94a6af99801a88f7f7ff"),
	 vout= 0,
	 sequence = O.from_hex('ffffffee')
      },
      {
	 txid= O.from_hex("8ac60eb9575db5b2d987e29f301b5b819ea83a5c6579d282d189cc04b8e151ef"),
	 vout= 1,
	 sigwit = true,
	 address = O.from_hex('1d0f172a0ecb48aee1be1f2687d2963ae33f71a1'),
	 amountSpent = O.from_hex('23c34600'),
	 sequence = O.from_hex('ffffffff')
      }
   },
   txOut = {
      {
	 amount = O.from_hex('06b22c20'), -- this maybe should be a number
	 address = O.from_hex('1976a9148280b37df378db99f66f85c95a783a76ac7a6d5988ac') -- I pass directly the script
      },
      {
	 amount = O.from_hex('0d519390'), -- this maybe should be a number
	 address = O.from_hex('1976a9143bde42dbee7e4dbe6a21b2d50ce2f0167faa815988ac') -- I pass directly the script
      }
   },
   nLockTime=17,
   nHashType=O.from_hex('00000001'),
}

assert(hashPrevouts(tx) == O.from_hex('96b827c8483d4e9b96712b6713a7b68d6e8003a781feba36c31143470b4efd37'))
assert(hashSequence(tx) == O.from_hex('52b0a642eea2fb7ae638c36f6252b6750293dbe574a806984b8e4d8548339a3b'))
assert(hashOutputs(tx) == O.from_hex('863ef3e1a92afbfdb97f31ad0fc7683ee943e9abcf2501590ff8f6551f47e5e5'))

-- Double SHA256 of the serialization of:
--      1. nVersion of the transaction (4-byte little endian)
--      2. hashPrevouts (32-byte hash)
--      3. hashSequence (32-byte hash)
--      4. outpoint (32-byte hash + 4-byte little endian) 
--      5. scriptCode of the input (serialized as scripts inside CTxOuts)
--      6. value of the output spent by this input (8-byte little endian)
--      7. nSequence of the input (4-byte little endian)
--      8. hashOutputs (32-byte hash)
--      9. nLocktime of the transaction (4-byte little endian)
--     10. sighash type of the signature (4-byte little endian)
function buildTransactionToSing(tx, i)
   local raw
   raw = O.new()
   --      1. nVersion of the transaction (4-byte little endian)
   raw = raw .. toUInt(tx.version, 4)
   --      2. hashPrevouts (32-byte hash)
   raw = raw .. hashPrevouts(tx)
   --      3. hashSequence (32-byte hash)
   raw = raw .. hashSequence(tx)
   --      4. outpoint (32-byte hash + 4-byte little endian)
   raw = raw .. opposite(tx.txIn[i].txid) .. toUInt(tx.txIn[i].vout, 4)
   --      5. scriptCode of the input (serialized as scripts inside CTxOuts)
   raw = raw .. O.from_hex('1976a914') .. addressScript(tx.txIn[i].address)  .. O.from_hex('88ac')
   --      6. value of the output spent by this input (8-byte little endian)
   raw = raw .. opposite(tx.txIn[i].amountSpent)
   if #tx.txIn[i].amountSpent < 8 then
      raw = raw .. O.zero(8 - #tx.txIn[i].amountSpent)
   end
   --      7. nSequence of the input (4-byte little endian)
   raw = raw .. opposite(tx.txIn[i].sequence)
   --      8. hashOutputs (32-byte hash)
   raw = raw .. hashOutputs(tx)
   --      9. nLocktime of the transaction (4-byte little endian)
   raw = raw .. toUInt(tx.nLockTime, 4)
   --     10. sighash type of the signature (4-byte little endian)
   raw = raw .. toUInt(tx.nHashType, 4)

   return raw
end
H=HASH.new('sha256')

rawTx = buildTransactionToSing(tx, 2)
sigHash = dSha256(rawTx)
assert(rawTx == O.from_hex('0100000096b827c8483d4e9b96712b6713a7b68d6e8003a781feba36c31143470b4efd3752b0a642eea2fb7ae638c36f6252b6750293dbe574a806984b8e4d8548339a3bef51e1b804cc89d182d279655c3aa89e815b1b309fe287d9b2b55d57b90ec68a010000001976a9141d0f172a0ecb48aee1be1f2687d2963ae33f71a188ac0046c32300000000ffffffff863ef3e1a92afbfdb97f31ad0fc7683ee943e9abcf2501590ff8f6551f47e5e51100000001000000'))
assert(sigHash == O.from_hex('c37af31116d1b27caf68aae9e3ac82f1477929014d5b917657d0eb49478cb670'))
sig = {
   r=O.from_hex('3609e17b84f6a7d30c80bfa610b5b4542f32a8a0d5447a12fb1366d7f01cc44a'),
   s=O.from_hex('573a954c4518331561406f90300e8f3358f51928d43c212a8caed02de67eebee')
}

assert(compressPublicKey(pk) == O.from_hex('025476c2e83188368da1ff3e292e7acafcdb3566bb0ad253f62fc70f07aeee6357'))
assert(ECDH.verify_hashed(pk, sigHash, sig, #sigHash))

----------------------------------------
-- Validate witness from bitcoin core --
----------------------------------------
-- sender tb1q04c9a079f3urc5nav647frx4x25hlv5vanfgug
-- dumpprivkey cPW7XRee1yx6sujBWeyZiyg18vhhQk9JaxxPdvwGwYX175YCF48G
sk = O.from_hex('39507b5471b71740675ddfdd0ace08f265e13bb168efce59a7e7d6d6782a8de501ea')
pk = ECDH.pubgen(sk)
tx = {
   version=2,
   txIn = {
      {
	 txid= O.from_hex("8cf73380cd054b6936360401b53a9db0cb30e33a7997bfd65fad939579096678"),
	 vout= 0,
	 sigwit = true,
	 address = "tb1q04c9a079f3urc5nav647frx4x25hlv5vanfgug",
	 amountSpent = O.from_hex('1cf034'),
	 sequence = O.from_hex('ffffffff')
      }
   },
   txOut = {
      {
	 amount = O.from_hex('1cee40'),--O.from_hex('0d519390'), -- this maybe should be a number
	 address = 'tb1q73czlxl7us4s6num5sjlnq6r0yuf8uh5clr2tm' -- I pass directly the script
      }
   },
   nLockTime=0,
   nHashType=O.from_hex('00000001')
}
assert(buildRawTransaction(tx) == O.from_hex('0200000001786609799593ad5fd6bf97793ae330cbb09d3ab501043636694b05cd8033f78c0000000000ffffffff0140ee1c0000000000160014f4702f9bfee42b0d4f9ba425f98343793893f2f400000000'))
-- SIgned raw transaction
-- 02000000000101786609799593ad5fd6bf97793ae330cbb09d3ab501043636694b05cd8033f78c0000000000ffffffff0140ee1c0000000000160014f4702f9bfee42b0d4f9ba425f98343793893f2f40247304402205f5cf053cfd97c8c3c30c31f11d5be369e0f551173d6699db1635f27d5f26a0402207f9d02edd76708ee4b7551d6c25a533b3d346378c843b13c5e992fabf8db018e012103fe7380f1549462e6f9fff99c2bd0084a2ce568f79f0001f020b413538539427600000000
rawTx = buildTransactionToSing(tx, 1)
sigHash = dSha256(rawTx)

sig = {
   r=O.from_hex('5f5cf053cfd97c8c3c30c31f11d5be369e0f551173d6699db1635f27d5f26a04'),
   s=O.from_hex('7f9d02edd76708ee4b7551d6c25a533b3d346378c843b13c5e992fabf8db018e')
}
assert(compressPublicKey(pk) == O.from_hex('03fe7380f1549462e6f9fff99c2bd0084a2ce568f79f0001f020b4135385394276'))
assert(ECDH.verify_hashed(pk, sigHash, sig, #sigHash))

---------------------------
-- Generate my siganture --
---------------------------

-- assert(decodeBase58Check('cPW7XRee1yx6sujBWeyZiyg18vhhQk9JaxxPdvwGwYX175YCF48G') == O.from_hex('39507b5471b71740675ddfdd0ace08f265e13bb168efce59a7e7d6d6782a8de501ea'))
sk = O.from_hex('39507b5471b71740675ddfdd0ace08f265e13bb168efce59a7e7d6d6782a8de501ea')
pk = ECDH.pubgen(sk)
tx = {
   version=2,
   txIn = {
      {
	 txid = O.from_hex("8cf73380cd054b6936360401b53a9db0cb30e33a7997bfd65fad939579096678"),
	 vout = 0,
	 sigwit = true,
	 address = "tb1q04c9a079f3urc5nav647frx4x25hlv5vanfgug",
	 amountSpent = O.from_hex('1cf034'),
	 sequence = O.from_hex('ffffffff')
      }
   },
   txOut = {
      {
	 amount = O.from_hex('1cee40'),--O.from_hex('0d519390'), -- this maybe should be a number
	 address = 'tb1q73czlxl7us4s6num5sjlnq6r0yuf8uh5clr2tm' -- I pass directly the script
      }
   },
   nLockTime=0,
   nHashType=O.from_hex('00000001')
}

function buildWitness(tx, sk)
   local pk = compressPublicKey(ECDH.pubgen(sk))
   print(ECDH.pubgen(sk))
   local witness = {}
   for i=1,#tx.txIn,1 do
      if tx.txIn[i].sigwit then
	 local rawTx = buildTransactionToSing(tx, i)
	 local sigHash = dSha256(rawTx)
	 local sig = signEcdhBc(sk, sigHash)
	 witness[i] = {
	    encodeDERSignature(sig) .. O.from_hex('01'),
	    pk
	 }
      else
	 witness[i] = O.zero(1)
      end
   end

   return witness
end
tx.witness = buildWitness(tx, sk)
rawTx = buildRawTransaction(tx)
print(rawTx:hex())

-- test signature (TODO: decode DER signature)
-- tx.witness = nil
-- rawTx = buildTransactionToSing(tx, 1)
-- sigHash = dSha256(rawTx)
-- sig = {
--    r=O.from_hex('54e8e766a0a33ab5c56e4f68d96ad6f88ab16b4e043aa47d1bb1b6c427e02b13'),
--    s=O.from_hex('2ff2a76affd591774746da5fa304e8d033c2933cf49d031d529d1d71632589bd')
-- }
-- print(pk)
-- assert(compressPublicKey(pk) == O.from_hex('03fe7380f1549462e6f9fff99c2bd0084a2ce568f79f0001f020b4135385394276'))
-- assert(ECDH.verify_hashed(pk, sigHash, sig, #sigHash))
