# TEST.ASM
# PURELY FOR TESTING/DEBUGGING PURPOSES

@include "util/disk_io.asm"
@include "util/misc.asm"

.text
test_start:
    mov t0, 0
    sb t0, 0, 0xFF
    sb t0, 1, 0x0F
    sb t0, 2, 0xFF
    mov a0, 0
    mov a1, 3
    mov a2, 0
    mov s10, 0
    call util_busy_disk_write
    call util_stall_esc

    hlt
