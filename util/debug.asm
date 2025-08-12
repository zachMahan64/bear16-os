# UTIL/DEBUG.ASM
@include "text_processing.asm"
.data
    util_debug_true_str:
        .string "TRUE"
    util_debug_false_str:
        .string "FALSE"
    util_debug_debug_str:
        .string "DEBUG: "
        .const UTIL_DEBUG_STR_LEN = 7
.text
util_debug_print_tf:
    # a0 = TRUE/FALSE (1/0)
    mov t0, a0
    mov a0, 0
    mov a1, 0
    # ^ set up pos args for blit_strl_rom
    gt util_debug_print_tf_true, t0, 0
    mov a2, util_debug_false_str
    call blit_strl_rom
    ret
    util_debug_print_tf_true:
    mov a2, util_debug_true_str
    call blit_strl_rom
    ret

util_debug_print_rom:
    # a0 = char* in rom
    mov a2, a0
    mov a0, 0
    mov a1, 0
    mov s10, TRUE
    call blit_strl_rom
    ret

util_debug_print_ram:
    # a0 = char* in rom
    mov a2, a0
    mov a0, 0
    mov a1, 0
    mov s10, TRUE
    call blit_strl_ram
    ret
