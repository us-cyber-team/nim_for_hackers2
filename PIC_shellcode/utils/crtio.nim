#[ Source: https://github.com/S3cur3Th1sSh1t/Bitmancer/blob/main/src/Bitmancer/crt/io.nim ]#
import winim
import getmodulehandle, getprocaddress

type
  CFile* = object
    cptr*:       cstring
    cnt*:        SIZE_T
    base*:       cstring
    flag*:       SIZE_T
    file*:       SIZE_T
    charBuf*:    SIZE_T
    bufSize*:    SIZE_T
    tmpFname*:   cstring
  CFilePtr* = ptr CFile ## The type representing a file handle.

# Declaring needed functions
type 
  LoadLibraryA = (proc(lpLibFileName: LPCSTR): HMODULE {.stdcall.})
  itoa         = proc(value: int, buffer: PCHAR, radix: int): PCHAR {.stdcall.}
  ## MSVCRT ----------------------------------------------------------------
  iob_func*    = proc: CFilePtr {.cdecl, gcsafe.}
  fileno*      = proc(f: CFilePtr): SIZE_T {.cdecl, gcsafe.}
  fwrite*      = proc(b: PVOID, size, n: SIZE_T, f: CFilePtr): SIZE_T {.cdecl, gcsafe.}
  set_mode*    = proc(fd, mode: SIZE_T): SIZE_T {.cdecl, gcsafe.}
  fflush*      = proc(stream: CFilePtr): SIZE_T {.cdecl, gcsafe.}

var 
  sKernel32 = "kernel32.dll".cstring
  sLoadLibraryA = "LoadLibraryA".cstring
  siob_func = "__iob_func".cstring
  sfileno = "_fileno".cstring
  sset_mode = "_setmode".cstring
  sfwrite = "fwrite".cstring
  sfflush = "fflush".cstring
  sitoa = "_itoa".cstring

# forward declaration
proc getCrtBase(): HMODULE

# [ other crt functions ]#
proc crt_itoa*(value: int, buffer: PCHAR, radix: int): PCHAR = 
  var pitoa = cast[itoa](custom_GetProcAddress(getCrtBase(), sitoa))
  return pitoa(value, buffer, radix)

#[ stdout writing ]#
proc getiob_func(crtBase: HMODULE): iob_func = return cast[iob_func](custom_GetProcAddress(crtBase, siob_func))
proc getfileno(crtBase: HMODULE): fileno     = return cast[fileno](custom_GetProcAddress(crtBase, sfileno))
proc getset_mode(crtBase: HMODULE): set_mode = return cast[set_mode](custom_GetProcAddress(crtBase, sset_mode))
proc getfwrite(crtBase: HMODULE): fwrite     = return cast[fwrite](custom_getProcAddress(crtBase, sfwrite))
proc getfflush(crtBase: HMODULE): fflush     = return cast[fflush](custom_getProcAddress(crtBase, sfflush))

proc getAndInitStdout(crtBase: HMODULE): CFilePtr =
  let
    piob_func = getiob_func(crtBase)
    pfile_no = getfileno(crtBase)
    pset_mode = getset_mode(crtBase)
  let cstdout = cast[CFilePtr](cast[int](piob_func()) +% 0x30)
  return cstdout


proc writeStream(crtBase: HMODULE, f: CFilePtr, s: cstring) = 
  let
    pfwrite = getfwrite(crtBase)
    pflush = getfflush(crtBase)
  discard pfwrite(s, 1, s.len, f)
  discard pflush(f)

proc getCrtBase(): HMODULE =
  var 
    smsvcrt = "msvcrt.dll".cstring
    hk32 = custom_GetModuleHandle(sKernel32)
    pLoadLibraryA = cast[LoadLibraryA](custom_GetProcAddress(hk32, sLoadLibraryA))
  return pLoadLibraryA(addr smsvcrt[0])

proc rawWriteStdOut*(s: cstring) = 
  let
    crtBase = getCrtBase()
    cstdout = getAndInitStdout(crtBase)
  writeStream(crtBase, cstdout, s)
