# UNIT_TESTS/T_CHRONO.ASM
@include "os_core.asm"
.text
start:
    .const START_OFFS = -8
    .const END_OFFS = -16
    sub sp, sp, 16
    lea a0, fp, START_OFFS
    call util_chrono_time_capture

    mov a0, 0
    mov a1, 0
    lea a2, fp, START_OFFS
    call util_chrono_blit_date

    call util_chrono_frametime_capture
    mov s2, rv

    poll:
        mov a0, s2
        mov a1, (60 * 5) # 5 seconds
        call util_chrono_frametime_check_elapsed
        eq poll, rv, 0

    lea a0, fp, END_OFFS
    call util_chrono_time_capture

    mov a0, 1
    mov a1, 0
    lea a2, fp, END_OFFS
    call util_chrono_blit_date

    call util_stall_esc
    hlt
