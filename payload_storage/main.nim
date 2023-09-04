#[
  nim c -d:release .\main.nim
]#
import std/[strformat, strutils]

#[ Globals ]#
const constBuf: array[4, byte] = [byte 0x90, 0x90, 0x90, 0xcc]
let letBuf: array[4, byte] = [byte 0x90, 0x90, 0x90, 0xcc]
var varBuf: array[4, byte] = [byte 0x90, 0x90, 0x90, 0xcc]
proc textBuf() {.asmNoStackFrame.} =
  asm """
    .byte 0x90, 0x90, 0x90, 0xcc
    ret
  """

proc main() =
  var stackBuf: array[4, byte] = [byte 0x90, 0x90, 0x90, 0xcc]

  echo &"[+] constBuf at: 0x{cast[int](addr constBuf).toHex}"
  echo &"[+] letBuf at: 0x{cast[int](addr letBuf).toHex}"
  echo &"[+] varBuf at: 0x{cast[int](addr varBuf).toHex}"
  echo &"[+] stackBuf at: 0x{cast[int](addr stackBuf).toHex}"
  echo &"[+] textBuf at: 0x{cast[int](textBuf).toHex}"

when isMainModule:
  main()