#[ nim c -d:release .\time_ex.nim ]#

type
  TM {.importc: "struct tm", header: "<time.h>".} = object
    tm_min: cint
    tm_hour: cint
  CTime = int64

proc time(arg: ptr CTime): CTime {.importc, header: "<time.h>".}
proc localtime(time: ptr CTime): ptr TM {.importc, header: "<time.h>".}


proc main() =
  var 
    seconds = time(nil)
    tm = localtime(addr seconds)
  echo "[+] Current time: " & $tm.tm_hour & ":" & $tm.tm_min


when isMainModule:
  main()