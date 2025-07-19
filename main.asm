# MAIN.ASM
# BEAR16_OS ENTRY POINT
# REG CONV: Overload s10 to a3 & s9 to a4, {s0 = index ptr, s1 = line ptr} -> for cursor
@include "os_core.asm" # core systems
@include "console.asm" # console (implements OS)
.text
start:
    call init_os
    call console_main
    hlt
