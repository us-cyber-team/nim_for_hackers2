#[ nim c -d:release .\main.nim ]#

#[ emit example ]#
proc printf_example() =
  {.emit: """
    int cVariable = 100;
  """.}

  var nimVariable = 200
  {.emit: ["""printf("[+] Calling printf with emit: %d\n", cVariable + (int)""", nimVariable, ");"].}

#[ import printf example]#
proc printf(format: cstring) {.importc, varargs, header: "stdio.h".}

proc printf_example2() =
  var 
    format = "[+] Calling printf with importc: %s and %d is an int".cstring
    str1 = "I'm a cstring".cstring
    i: int = 255
  printf(format, str1, i)



proc main() =
  printf_example()
  printf_example2()

when isMainModule:
  main()