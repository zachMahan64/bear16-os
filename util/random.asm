# UTIL/RANDOM.ASM

@include "util/chrono.asm"

.const UTIL_RANDOM_FRAMETIME_ENTROPY_SRC_MEM_ADDR = 6155

util_random_uint16:
    lw rv, UTIL_RANDOM_FRAMETIME_ENTROPY_SRC_MEM_ADDR # use entropy from system clock's frametimes
    ret
