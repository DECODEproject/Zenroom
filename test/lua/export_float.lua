assert(tostring(F.new(1)) == '1')
assert(tostring(F.new(12)) == '12')
assert(tostring(F.new(123)) == '123')
assert(tostring(F.new(1234)) == '1234')
assert(tostring(F.new(12345)) == '12345')
assert(tostring(F.new(123456)) == '123456')
assert(tostring(F.new(100000000000000000000)) == '1.000000e+20')
assert(tostring(F.new(1.5)) == '1.5')
assert(tostring(F.new(1.500)) == '1.5')
assert(tostring(F.new(1.23456)) == '1.23456')
assert(tostring(F.new(0)) == '0')
assert(tostring(F.new(1.0000)) == '1')
assert(tostring(F.new(1.0005)) == '1.0005')
assert(tostring(F.new(.1)) == '0.1')

assert(O.to_string(F.new(1):octet()) == '1')
assert(O.to_string(F.new(12):octet()) == '12')
assert(O.to_string(F.new(123):octet()) == '123')
assert(O.to_string(F.new(1234):octet()) == '1234')
assert(O.to_string(F.new(12345):octet()) == '12345')
assert(O.to_string(F.new(123456):octet()) == '123456')
assert(O.to_string(F.new(100000000000000000000):octet()) == '1.000000e+20')
assert(O.to_string(F.new(1.5):octet()) == '1.5')
assert(O.to_string(F.new(1.500):octet()) == '1.5')
assert(O.to_string(F.new(1.23456):octet()) == '1.23456')
assert(O.to_string(F.new(0):octet()) == '0')
assert(O.to_string(F.new(1.0000):octet()) == '1')
assert(O.to_string(F.new(1.0005):octet()) == '1.0005')
assert(O.to_string(F.new(.1):octet()) == '0.1')