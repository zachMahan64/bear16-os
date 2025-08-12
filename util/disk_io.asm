# UTIL_DISK_IO.ASM

@include "util/debug.asm"

.text

# DISK OPERATIONS
.const NO_OP = 0x00
.const READ_BYTE_OP = 0x01
.const WRITE_BYTE_OP = 0x02
.const READ_WORD_OP = 0x03
.const WRITE_WORD_OP = 0x04
.const RESET_STATUS_OP = 0x05
# DISK FLAGS
.const OVERFLOW_ERROR = 0x01
.const UNKNOWN_OP_ERROR = 0x02
.const READ_DONE = 0x04
.const WRITE_DONE = 0x08
# PTRS TO DISK RESERVED REGIONS IN RAM
.const DISK_ADDR_LO = 6559
.const DISK_ADDR_MID = 6560
.const DISK_ADDR_HI = 6561
.const DISK_DATA = 6562
.const DISK_OP = 6563
.const DISK_STATUS = 6564

util_busy_disk_write:
    # a0 = ptr_to_data, a1 = length, a2 = dest_in_disk (offset), s10 = dest_in_disk (page)
    # LOCALS SET UP ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    .const UTIL_BUSY_DISK_WRITE_DATA_PTR_OFFS = -2
    .const UTIL_BUSY_DISK_WRITE_LEN_OFFS = -4
    .const UTIL_BUSY_DISK_WRITE_DEST_OFFSET_OFFS = -6
    .const UTIL_BUSY_DISK_WRITE_PAGE_OFFS = -8
    .const UTIL_BUSY_DISK_WRITE_LOCAL_VAR_SIZE = 8

    sub sp, sp, UTIL_BUSY_DISK_WRITE_LOCAL_VAR_SIZE # set up frame for locals
    sw fp, UTIL_BUSY_DISK_WRITE_DATA_PTR_OFFS, a0
    sw fp, UTIL_BUSY_DISK_WRITE_LEN_OFFS, a1
    sw fp, UTIL_BUSY_DISK_WRITE_DEST_OFFSET_OFFS, a2
    sw fp, UTIL_BUSY_DISK_WRITE_PAGE_OFFS, s10
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #



    # RESTORE ARGS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    lw a0, fp, UTIL_BUSY_DISK_WRITE_DATA_PTR_OFFS
    lw a1, fp, UTIL_BUSY_DISK_WRITE_LEN_OFFS
    lw a2, fp, UTIL_BUSY_DISK_WRITE_DEST_OFFSET_OFFS
    lw s10, fp, UTIL_BUSY_DISK_WRITE_PAGE_OFFS
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

    ret

