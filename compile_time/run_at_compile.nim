#[ nim c -d:release .\run_at_compile.nim ]#

proc main() =
  static:
    echo "I'm running at compile time"
  
  echo "I'm running at run time"

when isMainModule:
  main()