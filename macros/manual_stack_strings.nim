#[
   nim c -r -d:release --opt:size --passC:"-mno-sse"
]#

proc main() =    
  var sKernel32: array[13, char] 
  sKernel32[0] = 'K'
  sKernel32[1] = 'E'
  sKernel32[2] = 'R'
  sKernel32[3] = 'N'
  sKernel32[4] = 'E'
  sKernel32[5] = 'L'
  sKernel32[6] = '3'
  sKernel32[7] = '2'
  sKernel32[8] = '.'
  sKernel32[9] = 'd'
  sKernel32[10] = 'l'
  sKernel32[11] = 'l'
  sKernel32[12] = '\0'
  echo "[+] sKernel32: " & sKernel32.repr

when isMainModule:
  main()