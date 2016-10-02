filepath='/aaa/bbb/ccc'
ls $filepath | sed "s:^:${filepath}: " | xargs -n 1 lua main.lua c
