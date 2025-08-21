# UTIL/ERROR.ASM
# FOR ERROR HANDLING AND MESSAGES

@include "util/debug.asm"
@include "util/misc.asm"
@include "text_processing.asm"
@include "util/constants.asm"
.text
util_error_system_critical:
    # a0 = rom ptr to error msg
.data
util_error_system_critical_str:
    .string "CRITICAL SYSTEM ERROR\n->PRESS ESC TO EXIT\n\nINFO: "
.text
    sub sp, sp, FB_SIZE # size of framebuffer
    memcpy sp, FB_START, FB_SIZE # save FB onto stack
    push a0
    call util_clr_fb # clear FB
    mov a0, 1 # line
    mov a1, 0, # idx
    mov a2, util_error_system_critical_str
    mov s10, FALSE
    call blit_strl_rom
    mov a0, 5
    mov a1, 0
    pop a2
    mov s10, FALSE
    call blit_strl_rom
    call util_stall_esc
    mov t0, FB_START
    memcpy t0, sp, FB_SIZE # restore FB
    ret
