import winim
import memcmp

{.passC:"-masm=intel".}
proc getPEB*(): PPEB {.asmNoStackFrame, inline.} =
  asm """
    push rbx
    xor rbx, rbx
    xor rax, rax
    mov rbx, qword ptr gs:[0x60]
    mov rax, rbx
    pop rbx
    ret
  """

template doWhile(a, b: untyped): untyped =
  b
  while a:
    b


proc custom_GetModuleHandle*(moduleName: cstring): HMODULE =
  let 
    pPeb: PPEB = getPEB()
    pLdr: PPEB_LDR_DATA = pPeb.Ldr
    pListHead: LIST_ENTRY = pPeb.Ldr.InMemoryOrderModuleList
  
  var 
    pDte: PLDR_DATA_TABLE_ENTRY = cast[PLDR_DATA_TABLE_ENTRY](pLdr.InMemoryOrderModuleList.Flink)
    pListNode: PLIST_ENTRY = pListHead.Flink

  doWhile cast[int](pListNode) != cast[int](pListHead):
    if pDte.FullDllName.Length != 0:
      if memcmp(cast[uint](addr moduleName[0]), cast[uint](pDte.FullDllName.Buffer), moduleName.len, 2) == 0:
        return cast[HMODULE](pDte.Reserved2[0])
    pDte = cast[PLDR_DATA_TABLE_ENTRY](pListNode.Flink)
    pListNode = cast[PLIST_ENTRY](pListNode.Flink)
  return cast[HMODULE](0)
