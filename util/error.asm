# UTIL/ERROR.ASM
# FOR ERROR HANDLING AND MESSAGES

@include "util/debug.asm"
@include "util/misc.asm"
@include "text_processing.asm"
@include "util/constants.asm"
@include "util/chrono.asm"
.text
util_error_system_critical:
    # a0 = rom ptr to error msg
.data
util_error_system_critical_str:
    .string "CRITICAL SYSTEM ERROR\n->PRESS ESC TO EXIT\n\nINFO: "
util_error_system_critical_date_str:
    .string "TIME OF ERROR: "
    .const UTIL_ERROR_SYSTEM_CRITICAL_DATA_STR_LEN = 15 # not counting null term
.text
    sub sp, sp, FB_SIZE # size of framebuffer
    memcpy sp, FB_START, FB_SIZE # save FB onto stack
    push a0 # save error msg ptr to stack
    call util_clr_fb # clear FB
    mov a0, 1 # line
    mov a1, 0
    mov a2, util_error_system_critical_str
    mov s10, FALSE
    call blit_strl_rom
    mov a0, 5
    # a1 = 0
    pop a2 # retrieve error msg ptr from stack
    mov s10, FALSE
    call blit_strl_rom
    # blit time of error
    mov a0, 11
    # a1 = 0
    mov a2, util_error_system_critical_date_str
    call blit_strl_rom
    mov a0, 12
    # a1 = 0
    mov a2, SYS_TIME
    call util_chrono_blit_long_format_date_line_idx
    # wait for escape input to exit error screen
    call util_stall_esc
    mov t0, FB_START
    memcpy t0, sp, FB_SIZE # restore FB
    ret
