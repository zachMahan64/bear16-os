# UTIL/CHRONO.ASM
# REG CONV: Overload s10 to a3 & s9 to a4, {s0 = index ptr, s1 = line ptr} -> for cursor
@include "util/constants.asm"
.data
# MEM-MAPPED CLOCK MEM_LOC CONSTANTS
.const FRAMES_MEM_LOC = 6147
.const SECONDS_MEM_LOC = 6148
.const MINUTES_MEM_LOC = 6149
.const HOURS_MEM_LOC = 6150
.const DAYS_MEM_LOC = 6151
.const MONTHS_MEM_LOC = 6152
.const YEARS_MEM_LOC = 6153
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
util_chrono_time_capture: # WIP
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
    ret

# FRAMETIME ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# uint16 frametime
util_chrono_frametime_capture:
# rv = current frametime
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
