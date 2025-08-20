# TEST.ASM ENTRY FOR RUNNING UNIT TESTS

@include "unit_tests/t_disk_io.asm"
.text
jmp t_disk_io_start
