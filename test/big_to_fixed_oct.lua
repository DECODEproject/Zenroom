assert(BIG.new(1):fixed(4) == O.from_hex('00000001'))
assert(BIG.new(O.from_hex('1122')):fixed(4) == O.from_hex('00001122'))
assert(BIG.new(O.from_hex('112233')):fixed(4, true) == O.from_hex('00112233'))
assert(BIG.new(O.from_hex('11223344')):fixed(4) == O.from_hex('11223344'))
assert(BIG.new(O.from_hex('1122334455')):fixed(4) == O.from_hex('1122334455'))
assert(BIG.new(O.from_hex('1122334455')):fixed(4, true) == O.from_hex('1122334455'))

assert(BIG.new(1):fixed(4, false) == O.from_hex('01000000'))
assert(BIG.new(O.from_hex('1122')):fixed(4, false) == O.from_hex('22110000'))
assert(BIG.new(O.from_hex('112233')):fixed(4, false) == O.from_hex('33221100'))
assert(BIG.new(O.from_hex('11223344')):fixed(4, false) == O.from_hex('44332211'))
assert(BIG.new(O.from_hex('1122334455')):fixed(4, false) == O.from_hex('5544332211'))
