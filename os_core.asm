# OS_CORE.ASM
# REG CONV: Overload s10 to a3 & s9 to a4, {s0 = index ptr, s1 = line ptr} -> for cursor
@include "text_processing.asm"
@include "util/chrono.asm"
@include "util/disk_io.asm"
@include "util/mem_manager.asm"
@include "util/misc.asm"
@include "util/math.asm"
@include "util/blit.asm"

.data

month_str_array:
    .string "JAN"
    .string "FEB"
    .string "MAR"
    .string "APR"
    .string "MAY"
    .string "JUN"
    .string "JUL"
    .string "AUG"
    .string "SEP"
    .string "OCT"
    .string "NOV"
    .string "DEC"
welcome_msg:
    .string " Welcome to the Bear16 Console!\n    VERSION 0.0.5, 20250809"

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
# UNIV CONSTANTS
.const TRUE = 1
.const FALSE = 0

os_init:
    call os_init_heap
    call os_init_taskbar
    call os_update
    ret
os_init_taskbar:
    call subr_init_os_draw_bottom_line
    call subr_init_month_year      # initialize dates (static/non updated until restart) -> note: may cause inaccuracies
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
        subr_init_month_year:
            #MON
            mov a0, 23 # line
            mov a1, 17 # index
            lb a2, MONTHS_PTR_MEM_LOC
            mult a2, a2, MONTH_STR_ARRAY_ENTRY_SIZE
            add a2, a2, month_str_array
            call blit_strl_rom
            #YEAR
            mov a0, 23 # line
            mov a1, 11 # index
            lw a2, YEARS_PTR_MEM_LOC
            call blit_4dig_pint
            ret
os_update:
    call os_update_time_display
    ret
    os_update_time_display:
        # SECONDS
        mov a0, 23 # line
        mov a1, 30 # index
        lb a2, SECONDS_PTR_MEM_LOC
        call blit_2dig_pint
        mov a0, 23 # line
        mov a1, 29 # index
        mov a2, ':'
        call blit_cl
        #MINUTES
        mov a0, 23 # line
        mov a1, 27 # index
        lb a2, MINUTES_PTR_MEM_LOC
        call blit_2dig_pint
        mov a0, 23 # line
        mov a1, 26 # index
        mov a2, ':'
        call blit_cl
        #HOURS
        mov a0, 23 # line
        mov a1, 24 # index
        lb a2, HOURS_PTR_MEM_LOC
        call blit_2dig_pint
        mov a0, 23 # line
        mov a1, 23 # index
        mov a2, ','
        call blit_cl
        #DAYS
        mov a0, 23 # line
        mov a1, 21 # index
        lb a2, DAYS_PTR_MEM_LOC
        call blit_2dig_pint
        # DAYS, MONTHS, YEARS generated in init
        ret
os_init_heap:
    # INIT HEAP PTR
    lea t0, TOP_OF_HEAP_PTR
    sw t0, STARTING_HEAP_PTR_VALUE
    # INIT FREE LIST
    call util_init_free_list
    ret
