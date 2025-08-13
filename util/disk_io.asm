# UTIL/DISK_IO.ASM

@include "util/debug.asm"
@include "util/constants.asm"

.text

# DISK OPERATIONS
.const NO_OP = 0x00
.const READ_BYTE_OP = 0x01
.const WRITE_BYTE_OP = 0x02
.const READ_WORD_OP = 0x03
.const WRITE_WORD_OP = 0x04
.const RESET_STATUS_OP = 0x05
# DISK FLAGS
.const READY = 0x00
.const OVERFLOW_ERROR = 0x01
.const UNKNOWN_OP_ERROR = 0x02
.const READ_DONE = 0x04
.const WRITE_DONE = 0x08
# PTRS TO DISK RESERVED REGIONS IN RAM
.const DISK_ADDR_LO = 6559
.const DISK_ADDR_MID = 6560
.const DISK_ADDR_HI = 6561
.const DISK_DATA = 6562
.const DISK_OP = 6564
.const DISK_STATUS = 6565

util_busy_disk_write:
    # a0 = ptr_to_data, a1 = length, a2 = dest_in_disk (offset), s10 = dest_in_disk (page)
    # this function performs byte-alligned copying
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
    lw t0, fp, UTIL_BUSY_DISK_WRITE_DATA_PTR_OFFS
    lw t1, fp, UTIL_BUSY_DISK_WRITE_LEN_OFFS
    lw t2, fp, UTIL_BUSY_DISK_WRITE_DEST_OFFSET_OFFS
    lw t3, fp, UTIL_BUSY_DISK_WRITE_PAGE_OFFS
    clr t4 # byte cnt
    # t5 will hold data
    # t6 & t7 will be scratch
    util_busy_disk_write_loop:
        # set up for disk operation
        lb t5, t0, t4 # data <- [data_ptr + offset_from_cnt]
        mov t6, DISK_ADDR_LO
        sw t6, t2 # [data_offset_loc] <- data_offset
        mov t6, DISK_ADDR_HI
        sb t6, t3 # [data_page_loc] <- data_page

        # set disk operation
        mov t6, DISK_OP
        sb t6, WRITE_BYTE_OP
        util_busy_disk_write_loop_lock:
            lb t6, DISK_STATUS
            # TODO bug: inf loop inside the lock
            # i believe the bug must be that the disk is not giving the WRITE_DONE status
            ne util_busy_disk_write_loop_lock, t6, WRITE_DONE
            mov t6, DISK_STATUS
            sb t6, READY
        inc t4
        lt util_busy_disk_write_loop, t4, t1 # loop while cnt < data length

    mov a0, TRUE # debug
    call util_debug_print_tf # debug

    # RESTORE ARGS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    lw a0, fp, UTIL_BUSY_DISK_WRITE_DATA_PTR_OFFS
    lw a1, fp, UTIL_BUSY_DISK_WRITE_LEN_OFFS
    lw a2, fp, UTIL_BUSY_DISK_WRITE_DEST_OFFSET_OFFS
    lw s10, fp, UTIL_BUSY_DISK_WRITE_PAGE_OFFS
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

    ret

