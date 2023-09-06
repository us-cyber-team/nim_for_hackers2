proc hashSdmb*(input: cstring): uint32 {.inline.} =
  var hash: uint32 = 0
  for i in input:
    hash = ord(i).uint32 + (hash shl 6) + (hash shl 16) - hash
  return hash


