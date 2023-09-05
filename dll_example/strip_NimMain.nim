#[
  compile nim dll with: nim c --app=lib --nomain -d:release --threads:off --cpu=amd64 --nimcache=cache --usenimcache --forceBuild:on -d:noRes .\sample.ni
  and then run this with cache in the cwd
]#
import std/[json, os, ospaths, osproc, sequtils, strformat, strutils]

proc retrieveJsonFile(cacheDir: string): string =
  ## Retrieve the jsonfile located in the cachedir, the returned
  ## string path will be given at its relative location
  for i in toSeq(walkDir(cacheDir)).mapIt(it.path):
    if i.contains(".json"): return i
  
proc replaceExport(cacheNode: JsonNode): bool =
  ## Replace `N_LIB_EXPORT` in `@m<fileName>.nim.c` to `N_LIB_PRIVATE`
  var mainCFile = $(cacheNode["compile"][^1][0])
  mainCFile = mainCFile.replace(r"\\", r"\")

  # ugly powershell command because we couldn't open the `mainCFile`?
  var pwshCommand = &"powershell -command \"((Get-Content -path {mainCFile})) -replace 'N_LIB_EXPORT N_CDECL', 'N_LIB_PRIVATE N_CDECL' | Set-Content -Path {mainCFile}\""

  if execShellCmd(pwshCommand) == 0:
    return true
  else:
    # never reaches ...
    echo &"[!] Failed to replace N_LIB_EXPORT with N_LIB_PRIVATE for NimMain"
    return false

proc reCompile(cacheDir: JsonNode): bool =
  ## Recompiles all the C files
  var cmd: string
  for c in cacheDir["compile"]:
    cmd = $(c[1])
    cmd = cmd[1..^2] # remove quotes
    var (_, err) = execCmdEx(cmd)
    if err != 0:
      echo &"[!] Failed to compile {cmd}"
      quit(1)
  return true

proc reLink(cacheDir: JsonNode): bool =
  ## Relinks all the object files
  var cmd: string
  cmd = $(cacheDir["linkcmd"])
  cmd = cmd[1..^2] # remove quotes
  var (output, err) = execCmdEx(cmd)
  return true

proc moveCompiledFile(cacheDir: JsonNode) = 
  var outputFile = $(cacheDir["outputFile"])
  outputFile = outputFile[1..^2]
  var 
    newFilename = outputFile.split(r"\\")[^1].split("_")[0] & ".dll"
    fileLocation = getCurrentDir() & r"\\" & newFilename

  moveFile(outputFile, fileLocation)

proc main() =
  var jsonFile = retrieveJsonFile("./cache")
  echo &"[+] Reading jsonFile: {jsonFile}"

  var cacheNode = parseFile(jsonFile)
  echo &"[+] Modifying @m<main>.nim.c"
  discard replaceExport(cacheNode)

  echo &"[+] Recompiling C files"
  discard reCompile(cacheNode)

  echo &"[+] Relinking O files"
  discard reLink(cacheNode)

  echo &"[+] Moving output file to current dir"
  moveCompiledFile(cacheNode)

when isMainModule:
  main()





















  