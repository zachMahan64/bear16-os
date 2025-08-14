# UNIT_TESTS/T_DISK_IO.ASM
# PURELY FOR TESTING/DEBUGGING PURPOSES

@include "util/disk_io.asm"
@include "util/misc.asm"

.data
test_testing_string:
    .string "TESTING STRING"
    .const TESTING_STRING_LEN = 15
.text
test_start:
    # TEST DISK WRITING!
    mov t0, 0
    romcpy t0, test_testing_string, TESTING_STRING_LEN
    mov a0, 0 # ptr to data
    mov a1, TESTING_STRING_LEN # length
    mov a2, 0 # disk addr low
    mov s10, 0 # disk addr high
    call util_busy_disk_write

    # TEST DISK READING
    mov a0, 32 # dest in ram
    mov a1, TESTING_STRING_LEN # length
    mov a2, 0 # disk addr low
    mov s10, 0 # disk addr high
    call util_busy_disk_read

    mov a0, 2 # line
    mov a1, 0 # idx
    mov a2, 32 # char*
    call blit_strl_ram

    inc a0
    call blit_strl_ram

    # STALL AT THE END OF EXEC
    call util_stall_esc

    hlt
