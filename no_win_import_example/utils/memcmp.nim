proc toLower*(ch: byte): byte {.inline.} =
  ## Weird coding to get the assembly working correctly
  var ret = ch
  if (ch >= 'A'.byte):
    if (ch <= 'Z'.byte):
      ret = ('a'.byte + (ch - 'A'.byte))
  return ret


proc memcmp*(s1: uint, s2: uint, n: int, charSize: uint): int {.inline.} = 
  ## charSize is the size of the character of the pointer to s2. in getmoduleh, it is comparing a
  ## cstring to a wstring, where in getprocaddr it is comparing two cstrings
  var 
    s1_ptr = cast[ptr byte](s1)
    s2_ptr = cast[ptr byte](s2)
  while s1_ptr[].toLower() == s2_ptr[].toLower():
    if s1_ptr[] == 0:
      return 0
    s1_ptr = cast[ptr byte](cast[uint](s1_ptr) + 1)
    s2_ptr = cast[ptr byte](cast[uint](s2_ptr) + charSize)
  return cast[int](s1_ptr[].toLower() - s2_ptr[].toLower())



