# OS_CORE.ASM
# REG CONV: Overload s10 to a3 & s9 to a4, {s0 = index ptr, s1 = line ptr} -> for cursor

# include all utils by default
@include "text_processing.asm"
@include "util/chrono.asm"
@include "util/disk_io.asm"
@include "util/memory.asm"
@include "util/misc.asm"
@include "util/math.asm"
@include "util/blit.asm"
@include "util/error.asm"
@include "util/constants.asm"

.data

welcome_msg:
    .string "   Welcome to the Bear16 OS!\n    VERSION 1.1.0, 20250921"

.text
#WELCOME
print_welcome_msg:
    mov a0, 1 # line
    mov a1, 0 # index
    mov a2, welcome_msg
    mov s10, TRUE #update cursor
    call blit_strl_rom #blitting a str
    ret

#OS CORE FUNCTIONS


os_init:
    call os_init_heap
    call os_init_taskbar
    call os_update
    ret
os_init_taskbar:
    call subr_init_os_draw_bottom_line
    ret
    subr_init_os_draw_bottom_line:
        clr s2 # cnt & index
        subr_init_os_draw_bottom_line_loop:
            mov a0, 22
            mov a1, s2
            mov a2, '_'
            call blit_cl
            inc s2
            ult subr_init_os_draw_bottom_line_loop, s2, 32
            ret
os_update:
    #call os_update_time_display
    mov a0, 23
    mov a1, 12
    mov a2, SYS_TIME # current system time
    call util_chrono_blit_long_format_date_line_idx
    ret
os_init_heap:
# INIT HEAP PTR
    lea t0, TOP_OF_HEAP_PTR
    sw t0, STARTING_HEAP_PTR_VALUE
    # INIT FREE LIST
    call util_init_free_list
    ret
os_check_for_sys_errors:
    # STACK OVERFLOW, ETC
    ret
