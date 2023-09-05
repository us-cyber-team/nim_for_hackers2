proc antiDebug*(): bool =
  var ret: int
  asm """
    xor rsi, rsi
    xor rax, rax
    mov rsi, qword ptr gs:[0x60]
    mov al, byte ptr [rsi + 0x2]
    :"=r"(`ret`)
  """
  if ret == 1: return true
  else: return false

