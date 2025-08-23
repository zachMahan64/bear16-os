# UTIL/CHRONO.ASM
# REG CONV: Overload s10 to a3 & s9 to a4, {s0 = index ptr, s1 = line ptr} -> for cursor
@include "util/constants.asm"
@include"text_processing.asm"
.data
# MEM-MAPPED CLOCK MEM_LOC CONSTANTS
.const TIME_SIZE = 8
# offsets
.const FRAMES_OFFS = 0
.const SECONDS_OFFS = 1
.const MINUTES_OFFS = 2
.const HOURS_OFFS = 3
.const DAYS_OFFS = 4
.const MONTHS_OFFS = 5
.const YEARS_OFFS = 6
# general time struct constants/mem-mappings
.const UTIL_CHRONO_SYS_TIME_MEM_LOC = 6147
.const SYS_TIME = (UTIL_CHRONO_SYS_TIME_MEM_LOC) # alias for easier use
.const FRAMES_MEM_LOC = (UTIL_CHRONO_SYS_TIME_MEM_LOC + FRAMES_OFFS)
.const SECONDS_MEM_LOC = (UTIL_CHRONO_SYS_TIME_MEM_LOC + SECONDS_OFFS)
.const MINUTES_MEM_LOC = (UTIL_CHRONO_SYS_TIME_MEM_LOC + MINUTES_OFFS)
.const HOURS_MEM_LOC = (UTIL_CHRONO_SYS_TIME_MEM_LOC + HOURS_OFFS)
.const DAYS_MEM_LOC = (UTIL_CHRONO_SYS_TIME_MEM_LOC + DAYS_OFFS)
.const MONTHS_MEM_LOC = (UTIL_CHRONO_SYS_TIME_MEM_LOC + MONTHS_OFFS)
.const YEARS_MEM_LOC = (UTIL_CHRONO_SYS_TIME_MEM_LOC + YEARS_OFFS)

# frametime constants
.const CONT_FRAMES_MEM_LOC = 6155
.const CONT_FRAMES_MEM_LOC_LO = 6155
.const CONT_FRAMES_MEM_LOC_HI = 6156
.text
# TIME ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# struct time {
# byte frames
# byte seconds,
# byte minutes,
# byte hours,
# byte days,
# byte months,
# word years
# }
.const UTIL_CHRONO_TIME_SIZE = 8
util_chrono_time_capture:
# a0 = ptr to time to build
    lb t0, FRAMES_MEM_LOC
    sb a0, t0
    lb t0, SECONDS_MEM_LOC
    sb a0, 1, t0
    lb t0, MINUTES_MEM_LOC
    sb a0, 2, t0
    lb t0, HOURS_MEM_LOC
    sb a0, 3, t0
    lb t0, DAYS_MEM_LOC
    sb a0, 4, t0
    lb t0, MONTHS_MEM_LOC
    sb a0, 5, t0
    lw t0, YEARS_MEM_LOC
    sw a0, 6, t0
    ret
util_chrono_time_compare:
# a0 = ptr to LHS time
# a1 = ptr to RHS time
# rv = (<LHS_is_greater>) ? 1 : 0
    ret

# FRAMETIME ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# uint16 frametime
util_chrono_frametime_capture:
# rv = current frametime
    lw rv, CONT_FRAMES_MEM_LOC
    ret

util_chrono_frametime_check_elapsed:
# assumes no more than 65536 frames have elapsed
# a0 = original frametime
# a1 = number of frames to check if elapsed
    lw t0, CONT_FRAMES_MEM_LOC_LO
    sub t1, t0, a0
    uge util_chrono_frametime_check_elapsed_true, t1, a1
    jmp util_chrono_frametime_check_elapsed_false
    util_chrono_frametime_check_elapsed_true:
        mov rv, TRUE
        ret
    util_chrono_frametime_check_elapsed_false:
        mov rv, FALSE
        ret

util_chrono_sleep_frames:
# a0 = frames for which to sleep
    push a0 # to preserve
    push a1 # ^
    mov a1, a0 # put frames into right arg
    call util_chrono_frametime_capture # takes no args btw
    mov a0, rv
    util_chrono_sleep_frames_loop:
        # a0 set ^
        # a1 already set
        call util_chrono_frametime_check_elapsed
        eq util_chrono_sleep_frames_loop, rv, FALSE # loop while elapsed = false
    pop a1 # preserve
    pop a0 # ^
    ret


# BLIT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
util_chrono_blit_date: # alias
util_chrono_blit_long_format_date_line_idx:
# a0 = starting line
# a1 = starting idx
# a2 = time*
    push s2
    mov s2, a2 # hold time*
    dec a1 # for proper alignment
    #YEAR
    # a0 = a0 from call
    # a1 = a1 from call
    lw a2, s2, YEARS_OFFS
    call blit_4dig_pint

    #MON
    add a1, a1, 6
    lb a2, s2, MONTHS_OFFS
    mult a2, a2, MONTH_STR_ARRAY_ENTRY_SIZE
    add a2, a2, month_str_array
    call blit_strl_rom

    #DAYS
    add a1, a1, 4
    lb a2, s2, DAYS_OFFS
    call blit_2dig_pint

    # COMMA
    add a1, a1, 2
    mov a2, ','
    call blit_cl

    #HOURS
    inc a1
    lb a2, s2, HOURS_OFFS
    call blit_2dig_pint

    #MINUTES
    add a1, a1, 3
    lb a2, s2, MINUTES_OFFS
    call blit_2dig_pint

    # COLON
    #mov a0, 23 # line
    #mov a1, 26 # index
    dec a1
    mov a2, ':'
    call blit_cl

    # SECONDS
    add a1, a1, 4
    lb a2, s2, SECONDS_OFFS
    call blit_2dig_pint

    # COLON
    dec a1
    mov a2, ':'
    call blit_cl

    pop s2
    ret

