# UTIL/BLIT.ASM
# Note: text-related blitting (strings & chars) are availible in "text_processing.asm"
@include "util/chrono.asm"
@include "text_processing.asm"
.text
blit_byte_tile:
    #a0 = line, a1 = index, a2 = desired tile (works for any flat-data tile), s10 = clobber (TRUE/FALSE)
    mult t0, a0, LINE_SIZE # set line
    blit_byte_row_entrance:
    add t0, t0, a1 # set index
    add t0, t0, FB_LOC #adjust for FB location start in SRAM

    mov t1, a2

    clr t2 # cnt
    blit_byte_tile_loop:
        lbrom t3, t1       #load byte from rom in t3
        eq blit_byte_tile_clobber_false, s10, FALSE
        blit_byte_tile_clobber_false_exit:
        sb t0, t3          #store byte in t3 into addr @ t0
        add t0, t0, LINE_WIDTH_B     # t0 += 32
        inc t1             # next byte in rom
        inc t2             # t2++
        ult blit_byte_tile_loop, t2, 8 # check cnt
    ret
    blit_byte_tile_clobber_false:
        lb t4, t0
        or t3, t3, t4 # bitwise or rom and ram byte
        jmp blit_byte_tile_clobber_false_exit

blit_byte_row:
    #a0 = row (0 - 191), a1 = index, a2 = desired tile (works for any flat-data tile), s10 = clobber (TRUE/FALSE)
    mult t0, a0, LINE_WIDTH_B # set line
    jmp blit_byte_row_entrance # reuse logic (it's the same for the rest of the function)

blit_cursor_line_idx:
# a0 = line
# a1 = idx
    mult t0, a0, LINE_SIZE
    add t1, a1, (LINE_SIZE - LINE_WIDTH_B)
    add t0, t0, t1
    lea t0, FB_LOC, t0 # calculate exact location in framebuffer
    call util_chrono_frametime_capture
    mov t1, rv

    .const CURSOR_BLINK_SPEED_FRAMES = 25

    mod t1, t1, (CURSOR_BLINK_SPEED_FRAMES * 2) # normalize for pure fps
    uge blit_cursor_line_idx_empty, t1, CURSOR_BLINK_SPEED_FRAMES
    blit_cursor_line_idx_full:
    sb t0, 0xFFFF
    ret
    blit_cursor_line_idx_empty:
        sb t0, 0x0000
        ret
blit_cursor:
# follows OS register conventions
    push a0
    push a1
    mov a0, s1
    mov a1, s0
    call blit_cursor_line_idx
    pop a1
    pop a0
    ret
