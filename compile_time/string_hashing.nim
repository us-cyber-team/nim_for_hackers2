#[nim c -d:danger  --opt:size --mm:none .\string_hashing.nim]#
import std/[strformat, strutils]


#[ Define a proc with compile time ]#
proc hashStringDjb2(input: string): uint32 {.compileTime.} =
  var 
    hash: uint = 3731
    seed: uint = 7
  for i in input:
    hash = (((hash shl seed) + hash) + cast[uint](ord(i)) and 0xffffffff'u32)
  return cast[uint32](hash) and 0xffffffff'u32

#[ Define a proc for hashing at run time, showing push/pop pragma to disable runtime check ]#
{.push overflowChecks:off.}
proc runtimeHashStringDjb2(input: string): uint32 =
  var 
    hash: uint = 3731
    seed: uint = 7
  for i in input:
    hash = (((hash shl seed) + hash) + cast[uint](ord(i)) and 0xffffffff'u32)
  return cast[uint32](hash) and 0xffffffff'u32
{.pop.}

proc hashStringSdmb(input: string): uint32 =
  var hash: uint32 = 0
  for i in input:
    hash = ord(i).uint32 + (hash shl 6) + (hash shl 16) - hash
  return hash

proc hashStringLoseLose(input: string): uint32 =
  var 
    seed: uint32 = 2
    hash: uint32 = 0
  for i in input:
    hash += ord(i).uint32
    hash *= ord(i).uint32 + seed
  return hash

import random
var rng {.compileTime.} = initRand(0x1337DEADBEEF)  # initRand() does not work at compile time, needs a given seed
const rVal = cast[uint32](rng.rand(uint32.high))
proc hashStringLoseLoseObf(input: string): uint32 =
  var 
    seed: uint32 = 2
    hash: uint32 = 0
  for i in input:
    hash += ord(i).uint32
    hash *= ord(i).uint32 + seed
  return hash xor rVal


proc main() =
  # Hashing string "kernel32.dll" on all
  var djb2 = hashStringDjb2("kernel32.dll")
  echo &"[+] hashStringDbj2: 0x{$djb2.toHex}"
  echo "[+] runTimeHashStringDbj2: 0x" & $(runtimeHashStringDjb2("kernel32.dll")).toHex

  var sdmb_compileTime = static(hashStringSdmb("kernel32.dll"))
  echo &"[+] hashStringSdmb: 0x{$sdmb_compileTime.toHex}"
  echo &"[+] runTimeHashStringDbj2: 0x" & $(hashStringSdmb("kernel32.dll")).toHex

  const loselose = hashStringLoseLose("kernel32.dll")
  echo &"[+] const hashStringLoseLose: 0x{$loselose.toHex}"

  const loseloseObf = hashStringLoseLoseObf("kernel32.dll")
  echo &"[+] const hashStringLoseLoseObf: 0x{$loseloseObf.toHex}"



when isMainModule:
  main()