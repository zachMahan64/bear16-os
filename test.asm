# TEST.ASM
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


    # STALL AT THE END OF EXEC
    call util_stall_esc

    hlt
