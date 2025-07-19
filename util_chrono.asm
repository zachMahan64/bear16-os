# UTIL_CHRONO.ASM
# REG CONV: Overload s10 to a3 & s9 to a4, {s0 = index ptr, s1 = line ptr} -> for cursor
.data
#CLOCK MEM_LOC CONSTANTS (ALL SUBJ TO CHANGE)
.const FRAMES_MEM_LOC = 6147
.const SECONDS_PTR_MEM_LOC = 6148
.const MINUTES_PTR_MEM_LOC = 6149
.const HOURS_PTR_MEM_LOC = 6150
.const DAYS_PTR_MEM_LOC = 6151
.const MONTHS_PTR_MEM_LOC = 6152
.const YEARS_PTR_MEM_LOC = 6153
.const CONT_FRAMES_MEM_LOC_LO = 6155
.const CONT_FRAMES_MEM_LOC_HI = 6156

.text
util_exec_if_elapsed_frames: # WIP
    # assumes wait frames is always < 65536
    # a0  = function label
    # a1  = start frame
    # a2 = wait frames
    ret


    ret
