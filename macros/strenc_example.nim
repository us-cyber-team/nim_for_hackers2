#[
  nim c -r -d:release --opt:size --passC:"-mno-sse"
]#
import strenc

proc main() =
  var s = "MyCustomeKernel32.dll"
  echo s

when isMainModule:
  main()