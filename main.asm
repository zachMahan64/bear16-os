# MAIN.ASM
# BEAR16_OS ENTRY POINT
# REG CONV: Overload s10 to a3 & s9 to a4, {s0 = index ptr, s1 = line ptr} -> for cursor
@include "os_core.asm" # core systems
@include "console/main.asm" # console (implements OS)
@include "gfx/main.asm" # images
.text
start:
    call os_gfx_login_screen
    call os_init
    call console_main
    hlt
