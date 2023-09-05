import winim
from strutils import toHex

proc custom_GetProcAddress(h: HMODULE, apiName: string): FARPROC =
  var pBase = cast[int](h)  

  var pImgDosHdr = cast[PIMAGE_DOS_HEADER](pBase)
  if pImgDosHdr.e_magic != IMAGE_DOS_SIGNATURE: return cast[FARPROC](NULL)

  var pImgNtHdrs = cast[PIMAGE_NT_HEADERS](pBase + pImgDosHdr.e_lfanew)
  if pImgNtHdrs.Signature != IMAGE_NT_SIGNATURE: return cast[FARPROC](NULL)

  var 
    imgOptHdr: IMAGE_OPTIONAL_HEADER = cast[IMAGE_OPTIONAL_HEADER](pImgNtHdrs.OptionalHeader)
    pImgExportDir: PIMAGE_EXPORT_DIRECTORY = cast[PIMAGE_EXPORT_DIRECTORY](cast[DWORD64](pBase) + cast[DWORD64](imgOptHdr.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress))
  
  var 
    functionNameArray: ptr UncheckedArray[DWORD] = cast[ptr UncheckedArray[DWORD]](cast[ByteAddress](pBase) + pImgExportDir.AddressOfNames)
    functionAddressArray:  ptr UncheckedArray[DWORD] = cast[ptr UncheckedArray[DWORD]](cast[ByteAddress](pBase) + pImgExportDir.AddressOfFunctions)
    functionOrdinalArray: ptr UncheckedArray[WORD] = cast[ptr UncheckedArray[WORD]](cast[ByteAddress](pBase) + pImgExportDir.AddressOfNameOrdinals)

  var i: DWORD = 0
  while i < pImgExportDir.NumberOfFunctions:
    var pFunctionName = $(cast[PCHAR](cast[ByteAddress](pBase) + functionNameArray[i]))
    var pFunctionAddress: PVOID = cast[PVOID](cast[ByteAddress](pBase) + functionAddressArray[functionOrdinalArray[i]])
    if pFunctionName == apiName:
      return cast[FARPROC](pFunctionAddress)
      break
    i.inc

  return cast[FARPROC](NULL)

import dynlib
proc main() = 
  var h = loadLib("user32.dll")
  var MessageBoxA = custom_GetProcAddress(cast[HMODULE](h), "MessageBoxA")
  echo "[+] MessageBoxA:  0x" & cast[int](MessageBoxA).toHex

when isMainModule:
  main() 
  quit()


  import dynlib
  var h = loadLib("user32.dll")
  var pMessageBoxA = symAddr(h, "MessageBoxA")
  echo "[+] pMessageBoxA: 0x" & cast[int](pMessageBoxA).toHex
