# T_GRAVITY.ASM

@include "apps/gravity/main.asm"
@include "util/misc.asm"
@include "text_processing.asm"

.data
t_gravity_test_str:
    .string "TEST STRING"

.text

t_gravity_start:
    # main logic
    call gravity_main
    # make sure we good
    mov a0, 0
    mov a1, 0
    mov a2, t_gravity_test_str
    call blit_strl_rom
    call util_stall_esc
    ret
