# UTIL/ERROR.ASM
# FOR ERROR HANDLING AND MESSAGES

@include "util/debug.asm"
@include "util/misc.asm"
@include "text_processing.asm"
@include "util/constants.asm"
.text
util_error_throw:
    # a0 = rom ptr to error msg
    mov t2, a0
.data
util_error_throw_str:
    .string "CRITICAL SYSTEM ERROR\nPRESS ESC TO EXIT\nINFO: "
.text
    sub sp, sp, FB_SIZE # size of framebuffer
    memcpy sp, FB_START, FB_SIZE # save FB onto stack
    call util_clr_fb # clear FB
    mov a0, 0 # line
    mov a1, 0, # idx
    mov a2, util_error_throw_str
    mov s10, FALSE
    call blit_strl_rom
    mov a0, 3
    mov a1, 0
    mov a2, t2 # TODO THIS IS NOT PRINTING CORRECTLY
    mov s10, FALSE
    call blit_strl_rom
    call util_stall_esc
    mov t0, FB_START
    memcpy t0, sp, FB_SIZE # restore FB
    ret
