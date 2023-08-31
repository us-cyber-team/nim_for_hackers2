
{.passC:"-masm=intel".}
proc main() =
    var i = 1
    for k in 0 .. 10:
        i.inc
    echo i
    
    asm """
        push rbx
        xor rbx, rbx
        xor rax, rax
        mov rbx, qword ptr gs:[0x60]
        mov rax, rbx
        pop rbx
    """
    
    var j = 2
    for k in 0 .. 10:
        j.inc
    echo j

when isMainModule:
    main()