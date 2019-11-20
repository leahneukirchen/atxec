#!/bin/sh
export "PATH=.:$PATH"

printf '1..1\n'
printf '# regression tests\n'

tap3 'comments without newline' <<'EOF'
printf '# foo' >two
atxec echo 1 @two 3
>>>
1 3
EOF
