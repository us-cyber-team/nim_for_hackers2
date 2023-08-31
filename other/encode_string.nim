import os

proc singleByteXor(s: var cstring, key: byte) =
  for i in 0 ..< s.len:
    s[i] = cast[char](s[i].byte xor key)

var s = paramStr(1).cstring
singleByteXor(s, 0x7f)
echo s.repr