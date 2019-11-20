#!/bin/sh
export "PATH=.:$PATH"

printf '1..12\n'
printf '# simple tests\n'

tap3 'no expansion' <<'EOF'
atxec echo 1 2 3
>>>
1 2 3
EOF

tap3 'env expansion' <<'EOF'
TWO=2 atxec echo 1 '@$TWO' 3
>>>
1 2 3
EOF

tap3 'file expansion' <<'EOF'
echo 2 >two
atxec echo 1 @two 3
>>>
1 2 3
EOF

tap3 'file expansion - multiple words' <<'EOF'
echo "duo deux" >two
atxec echo 1 @two 3
>>>
1 duo deux 3
EOF

tap3 'file expansion - multiple inserts' <<'EOF'
echo "duo deux" >two
atxec echo 1 @two 3 @two
>>>
1 duo deux 3 duo deux
EOF

tap3 'file expansion - multiple words on multiple lines' <<'EOF'
echo duo >two
echo deux >>two
atxec echo 1 @two 3
>>>
1 duo deux 3
EOF

tap3 'file expansion - multiple words on multiple lines, comments' <<'EOF'
echo duo >two
echo '# ignored' >>two
echo deux >>two
atxec echo 1 @two 3
>>>
1 duo deux 3
EOF

tap3 'file expansion - quoting' <<'EOF'
echo "'two' 'three'" >two
atxec echo 1 @two 3
>>>
1 two three 3
EOF

tap3 'file expansion - quoting spaces' <<'EOF'
echo "'two three'" >two
atxec printf '%s\n' 1 @two 3
>>>
1
two three
3
EOF

tap3 'file expansion - empty file' <<'EOF'
echo >two
atxec printf '%s\n' 1 @two 3
>>>
1
3
EOF

tap3 'file expansion - empty args' <<'EOF'
echo "''" >two
atxec printf '%s\n' 1 @two 3
>>>
1

3
EOF

tap3 'file expansion - quoting quote' <<'EOF'
echo "'quo''te' 'two''quotes''here' 'next''''eachother'" >two
atxec printf '%s\n' 1 @two 3
>>>
1
quo'te
two'quotes'here
next''eachother
3
EOF
