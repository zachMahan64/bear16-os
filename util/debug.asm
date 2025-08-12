# UTIL/DEBUG.ASM
@include "text_processing.asm"
.data
    util_debug_true_str:
        .string "TRUE"
    util_debug_false_str:
        .string "FALSE"
.text
util_debug_print_tf:
    # a0 = TRUE/FALSE (1/0)
    mov a1, 0
    mov a2, 0
    # ^ set up pos args for blit_strl_rom
    ge util_debug_print_tf_true, a0, 0
    mov a0, util_debug_false_str
    call blit_strl_rom
    ret
    util_debug_print_tf_true:
    mov a0, util_debug_true_str
    call blit_strl_rom
    ret
