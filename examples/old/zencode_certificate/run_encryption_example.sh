#!/usr/bin/env zsh

verbose=1
alias zenroom='../../src/zenroom-shared'

scenario="Generate a new keypair"
echo $scenario
cat <<EOF | zenroom | tee alice.keys
ZEN:begin($verbose)
ZEN:parse([[
Scenario 'encryption': $scenario
		 Given that I am known as 'Alice'
		 When I create my new keypair
		 Then print all data
]])
ZEN:run()
EOF

scenario="Split a keypair"
echo $scenario
cat <<EOF | zenroom -k alice.keys | tee alice_public.keys
ZEN:begin($verbose)
ZEN:parse([[
Scenario 'encryption': $scenario
		 Given that I am known as 'Alice'
		 and I have my public key
		 When I export my public key
		 Then print all data
]])
ZEN:run()
EOF

scenario="Generate a new keypair"
echo $scenario
cat <<EOF | zenroom | tee bob.keys
ZEN:begin($verbose)
ZEN:parse([[
Scenario 'encryption': $scenario
		 Given that I am known as 'Bob'
		 When I create my new keypair
		 Then print all data
]])
ZEN:run()
EOF

scenario="Split a keypair"
echo $scenario
cat <<EOF | zenroom -k bob.keys | tee bob_public.keys
ZEN:begin($verbose)
ZEN:parse([[
Scenario 'encryption': $scenario
		 Given that I am known as 'Bob'
		 and I have my public key
		 When I export my public key
		 Then print all data
]])
ZEN:run()
EOF

scenario="Alice saves Bob's public key into her keyring"
echo $scenario
cat <<EOF | zenroom -k alice.keys -a bob_public.keys | tee alice_ring.keys | json_pp
ZEN:begin($verbose)
ZEN:parse([[
Scenario 'encryption': $scenario
		 Given that I am known as 'Alice'
		 and I have my keypair
		 and I have the public key by 'Bob'
		 When I export all keys
		 Then print all data
]])
ZEN:run()
EOF

scenario="Bob saves Alice's public key into his keyring"
echo $scenario
cat <<EOF | zenroom -k bob.keys -a alice_public.keys | tee bob_ring.keys | json_pp
ZEN:begin($verbose)
ZEN:parse([[
Scenario 'encryption': $scenario
		 Given that I am known as 'Bob'
		 and I have my keypair
		 and I have the public key by 'Alice'
		 When I export all keys
		 Then print all data
]])
ZEN:run()
EOF

cat <<EOF > fake_data.json
{"blob":"48656c6c6f20576f726c64"}
EOF

scenario="Alice encrypts a message for Bob"
echo $scenario
cat <<EOF | zenroom -k alice_ring.keys -a fake_data.json | tee alice_to_bob.json
ZEN:begin($verbose)
ZEN:parse([[
Scenario 'encryption': $scenario
		 Given that I am known as 'Alice'
		 and I have my keypair
		 and I have the public key by 'Bob'
		 When I include the text 'Hey Bob: Alice here, copy?'
		 and I include myself as sender
		 and I include the hex data 'blob'
		 and I use 'Bob' key to encrypt the output
		 Then print all data
]])
ZEN:run()
EOF

scenario="Bob decrypts a message from Alice"
echo $scenario
cat <<EOF | zenroom -k bob_ring.keys -a alice_to_bob.json | tee bob_to_alice.json
ZEN:begin($verbose)
ZEN:parse([[
Scenario 'encryption': $scenario
		 Given that I am known as 'Bob'
		 and I have my keypair
		 and I receive an encrypted message 
		 When I decrypt the message
		 Then print all data
]])
ZEN:run()
EOF

