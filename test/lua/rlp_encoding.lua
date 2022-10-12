local ETH = require('crypto_ethereum')

local function arrayEquals(tbl1, tbl2)
   if #tbl1 ~= #tbl2 then
      return false
   end
   for k, v in pairs(tbl1) do
      if v ~= tbl2[k] then
	 return false
      end
   end
   return true
end

assert(ETH.encodeRLP(O.from_hex('7f')) == O.from_hex('7f'))
assert(ETH.encodeRLP(O.from_hex('ff')) == O.from_hex('81ff'))
-- ATTENTION empty sequence
assert(ETH.encodeRLP(O.empty()) == O.from_hex('80'))
assert(ETH.encodeRLP(O.from_hex('00')) == O.from_hex('00'))
assert(ETH.encodeRLP(O.from_hex('1122334455667788112233445566778811223344556677881122334455667788')) == O.from_hex('a01122334455667788112233445566778811223344556677881122334455667788'))
assert(ETH.encodeRLP(O.from_hex('11223344556677881122334455667788112233445566778811223344556677881122334455667788112233445566778811223344556677881122334455667788')) == O.from_hex('b84011223344556677881122334455667788112233445566778811223344556677881122334455667788112233445566778811223344556677881122334455667788'))
assert(ETH.encodeRLP(O.from_hex('111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444')) == O.from_hex('b90300111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444'))
assert(ETH.encodeRLP({O.from_hex('11223344556677881122334455667788'), O.from_hex('1122334455667788')}) == O.from_hex('da9011223344556677881122334455667788881122334455667788'))

assert(ETH.encodeRLP({O.from_hex('627306090abab3a6e1400e9345bc60c78a8bef57'), O.from_hex('ae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f'), O.from_hex('8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63')}) == O.from_hex('f85794627306090abab3a6e1400e9345bc60c78a8bef57a0ae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162fa08f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63'))
assert(ETH.encodeRLP({O.from_hex('c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3'), O.from_hex('627306090abab3a6e1400e9345bc60c78a8bef57'), O.from_hex('ae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f'), O.from_hex('8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63')}) == O.from_hex('f878a0c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d394627306090abab3a6e1400e9345bc60c78a8bef57a0ae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162fa08f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63'))

assert(ETH.decodeRLP(O.from_hex('7f')) == O.from_hex('7f'))
assert(ETH.decodeRLP(O.from_hex('81ff')) == O.from_hex('ff'))
assert(ETH.decodeRLP(O.from_hex('80')) == O.empty())
assert(O.from_hex('1122334455667788112233445566778811223344556677881122334455667788') == ETH.decodeRLP(O.from_hex('a01122334455667788112233445566778811223344556677881122334455667788')))
assert(O.from_hex('11223344556677881122334455667788112233445566778811223344556677881122334455667788112233445566778811223344556677881122334455667788') == ETH.decodeRLP(O.from_hex('b84011223344556677881122334455667788112233445566778811223344556677881122334455667788112233445566778811223344556677881122334455667788')))
assert(O.from_hex('111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444') == ETH.decodeRLP(O.from_hex('b90300111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444111122223333444411112222333344441111222233334444')))

assert(arrayEquals({O.from_hex('11223344556677881122334455667788'), O.from_hex('1122334455667788')}, ETH.decodeRLP(O.from_hex('da9011223344556677881122334455667788881122334455667788'))))
assert(arrayEquals({O.from_hex('627306090abab3a6e1400e9345bc60c78a8bef57'), O.from_hex('ae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f'), O.from_hex('8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63')}, ETH.decodeRLP(O.from_hex('f85794627306090abab3a6e1400e9345bc60c78a8bef57a0ae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162fa08f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63'))))
assert(arrayEquals({O.from_hex('c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3'), O.from_hex('627306090abab3a6e1400e9345bc60c78a8bef57'), O.from_hex('ae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f'), O.from_hex('8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63')}, ETH.decodeRLP(O.from_hex('f878a0c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d394627306090abab3a6e1400e9345bc60c78a8bef57a0ae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162fa08f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63'))))

-- tests from eth site
tests = {
  {
     O.from_string(""),
     "80"
  },
  {
     O.from_hex('00'),
    "00"
  },
  {
     O.from_hex('01'),
    "01"
  },
  {
     O.from_hex('7f'),
    "7f"
  },
  {
     O.from_string("dog"),
    "83646f67"
  },
  {
     O.from_string("Lorem ipsum dolor sit amet, consectetur adipisicing eli"),
    "b74c6f72656d20697073756d20646f6c6f722073697420616d65742c20636f6e7365637465747572206164697069736963696e6720656c69"
  },
  {
     O.from_string("Lorem ipsum dolor sit amet, consectetur adipisicing elit"),
    "b8384c6f72656d20697073756d20646f6c6f722073697420616d65742c20636f6e7365637465747572206164697069736963696e6720656c6974"
  },
  {
     O.from_string("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur mauris magna, suscipit sed vehicula non, iaculis faucibus tortor. Proin suscipit ultricies malesuada. Duis tortor elit, dictum quis tristique eu, ultrices at risus. Morbi a est imperdiet mi ullamcorper aliquet suscipit nec lorem. Aenean quis leo mollis, vulputate elit varius, consequat enim. Nulla ultrices turpis justo, et posuere urna consectetur nec. Proin non convallis metus. Donec tempor ipsum in mauris congue sollicitudin. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Suspendisse convallis sem vel massa faucibus, eget lacinia lacus tempor. Nulla quis ultricies purus. Proin auctor rhoncus nibh condimentum mollis. Aliquam consequat enim at metus luctus, a eleifend purus egestas. Curabitur at nibh metus. Nam bibendum, neque at auctor tristique, lorem libero aliquet arcu, non interdum tellus lectus sit amet eros. Cras rhoncus, metus ac ornare cursus, dolor justo ultrices metus, at ullamcorper volutpat"),
    "b904004c6f72656d20697073756d20646f6c6f722073697420616d65742c20636f6e73656374657475722061646970697363696e6720656c69742e20437572616269747572206d6175726973206d61676e612c20737573636970697420736564207665686963756c61206e6f6e2c20696163756c697320666175636962757320746f72746f722e2050726f696e20737573636970697420756c74726963696573206d616c6573756164612e204475697320746f72746f7220656c69742c2064696374756d2071756973207472697374697175652065752c20756c7472696365732061742072697375732e204d6f72626920612065737420696d70657264696574206d6920756c6c616d636f7270657220616c6971756574207375736369706974206e6563206c6f72656d2e2041656e65616e2071756973206c656f206d6f6c6c69732c2076756c70757461746520656c6974207661726975732c20636f6e73657175617420656e696d2e204e756c6c6120756c74726963657320747572706973206a7573746f2c20657420706f73756572652075726e6120636f6e7365637465747572206e65632e2050726f696e206e6f6e20636f6e76616c6c6973206d657475732e20446f6e65632074656d706f7220697073756d20696e206d617572697320636f6e67756520736f6c6c696369747564696e2e20566573746962756c756d20616e746520697073756d207072696d697320696e206661756369627573206f726369206c756374757320657420756c74726963657320706f737565726520637562696c69612043757261653b2053757370656e646973736520636f6e76616c6c69732073656d2076656c206d617373612066617563696275732c2065676574206c6163696e6961206c616375732074656d706f722e204e756c6c61207175697320756c747269636965732070757275732e2050726f696e20617563746f722072686f6e637573206e69626820636f6e64696d656e74756d206d6f6c6c69732e20416c697175616d20636f6e73657175617420656e696d206174206d65747573206c75637475732c206120656c656966656e6420707572757320656765737461732e20437572616269747572206174206e696268206d657475732e204e616d20626962656e64756d2c206e6571756520617420617563746f72207472697374697175652c206c6f72656d206c696265726f20616c697175657420617263752c206e6f6e20696e74657264756d2074656c6c7573206c65637475732073697420616d65742065726f732e20437261732072686f6e6375732c206d65747573206163206f726e617265206375727375732c20646f6c6f72206a7573746f20756c747269636573206d657475732c20617420756c6c616d636f7270657220766f6c7574706174"
  },
  {
     O.empty(), -- number 0
    "80"
  },
  {
     BIG.new(1):octet(),
   "01"
  },
  {
     BIG.new(16):octet(),
   "10"
  },
  {
     BIG.new(79):octet(),
   "4f"
  },
  {
     BIG.new(127):octet(),
    "7f"
  },
  {
     BIG.new(128):octet(),
    "8180"
  },
  {
     BIG.new(1000):octet(),
    "8203e8"
  },
  {
     BIG.from_decimal("100000"):octet(),
    "830186a0"
  },
  {
     BIG.from_decimal("83729609699884896815286331701780722"):octet(),
    "8f102030405060708090a0b0c0d0e0f2"
  },
  {
     BIG.from_decimal("105315505618206987246253880190783558935785933862974822347068935681"),
    "9c0100020003000400050006000700080009000a000b000c000d000e01"
  },
  {
    {},
    "c0"
  },
  {
    {
       O.from_string("dog"),
       O.from_string("god"),
       O.from_string("cat")
    },
    "cc83646f6783676f6483636174"
  },
  {
    {
       O.from_string("zw"),
      {
	 BIG.new(4):octet()
      },
      BIG.new(1):octet()
    },
    "c6827a77c10401"
  },
  {
    {
       O.from_string("asdf"),
       O.from_string("qwer"),
       O.from_string("zxcv"),
       O.from_string("asdf"),
       O.from_string("qwer"),
       O.from_string("zxcv"),
       O.from_string("asdf"),
       O.from_string("qwer"),
       O.from_string("zxcv"),
       O.from_string("asdf"),
       O.from_string("qwer")
    },
    "f784617364668471776572847a78637684617364668471776572847a78637684617364668471776572847a78637684617364668471776572"
  },
  {
    {
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      }
    },
    "f840cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376"
  },
  {
    {
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      },
      {
	 O.from_string("asdf"),
	 O.from_string("qwer"),
	 O.from_string("zxcv")
      }
    },
    "f90200cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376cf84617364668471776572847a786376"
  },
  {
    {
      {
        {},
        {}
      },
      {}
    },
    "c4c2c0c0c0"
  },
  {
    {
      {},
      {
        {}
      },
      {
        {},
        {
          {}
        }
      }
    },
    "c7c0c1c0c3c0c1c0"
  },
  {
    {
      {
	 O.from_string("key1"),
        O.from_string("val1")
      },
      {
	 O.from_string("key2"),
        O.from_string("val2")
      },
      {
	 O.from_string("key3"),
        O.from_string("val3")
      },
      {
	 O.from_string("key4"),
        O.from_string("val4")
      }
    },
    "ecca846b6579318476616c31ca846b6579328476616c32ca846b6579338476616c33ca846b6579348476616c34"
  },
  {
     BIG.from_decimal("115792089237316195423570985008687907853269984665640564039457584007913129639936"):octet(),
    "a1010000000000000000000000000000000000000000000000000000000000000000"
  }
}

for k, v in pairs(tests) do
   v[2] = O.from_hex(v[2])
   assert(ETH.encodeRLP(v[1]) == v[2])

   assert(ETH.encodeRLP(ETH.decodeRLP(v[2])) == v[2])
   assert(ZEN.serialize(ETH.decodeRLP(v[2])) == ZEN.serialize(v[1]))
end
