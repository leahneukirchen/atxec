#!/bin/sh
export "PATH=.:$PATH"

printf '1..3\n'
printf '# errors\n'

tap3 'no arguments' <<'EOF'
atxec
>>>2 /sage/
>>>= 1
EOF

tap3 'not found' <<'EOF'
atxec /doesnotexist
>>>2 /o such file/
>>>= 111
EOF

tap3 'too many arguments' <<'EOF'
atxec $(yes | sed 99999q)
>>>2 /too many/
>>>= 111
EOF
