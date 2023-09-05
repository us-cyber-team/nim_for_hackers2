#[
  nim c -r -d:release --opt:size --passC:"-mno-sse" .\cast_vs_conversion.nim
]#
import winim
import std/[strformat]

var i: uint32 = 0x7fffffff'u32
echo &"[i] i before cast: {i}"
echo &"[i] i after cast:  {cast[uint8](i)}"
echo &"[i] i conversion: {i.uint8}"



