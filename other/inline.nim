#[ 
  nim c -d:release --opt:size .\inline.nim 
  compile with cache: --nimcache=cache
]#

# {.passC:"-masm=intel".}
# proc func1(i: int) {.inline.} =
#   asm """
#     nop
#     nop
#     nop
#   """

# {.passC:"-masm=intel".}
# proc func1(i: int) {.codegenDecl: "__attribute__((always_inline)) $# $#$#".} =
#   asm """
#     nop
#     nop
#     nop
#   """

template func1(i: int) =
  asm """
    nop
    nop
    nop
  """

proc main() = 
  var i = 12
  func1(i)
  echo "[+] i: " & $i

when isMainModule:
  main()



