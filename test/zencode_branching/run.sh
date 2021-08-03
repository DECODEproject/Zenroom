#!/usr/bin/env bash

DEBUG=3

####################
# common script init
if ! test -r ../utils.sh; then
	echo "run executable from its own directory: $0"; exit 1; fi
. ../utils.sh $*
Z="`detect_zenroom_path` `detect_zenroom_conf`"
####################

cat << EOF > leftright.json
{ "left": 10,
  "right": 50 }
EOF

cat << EOF | zexe branch.zen -a leftright.json
Given I have a 'number' named 'left'
and I have a 'number' named 'right'

If number 'left' is less than 'right'
and I verify 'left' is equal to 'left'
When I create the random 'peppino'
Then print string 'right is higher'
and print all data
Endif

If number 'left' is more than 'right'
When I create the random 'peppone'
Then print string 'left is higher'
endif

When I create the random 'fish'
Then print all data
and trace
EOF


cat << EOF > leftright.json
{ "left": 60,
  "right": 50 }
EOF

cat << EOF | zexe branch.zen -a leftright.json
Given I have a 'number' named 'left'
and I have a 'number' named 'right'

If number 'left' is less than 'right'
and I verify 'right' is equal to 'right'
Then print string 'right is higher'
and print string 'and I am right'
endif

If number 'left' is more than 'right'
Then print string 'left is higher'
endif

EOF

