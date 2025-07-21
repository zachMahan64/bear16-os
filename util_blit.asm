# UTIL_BLIT.ASM
# Note: text-related blitting (strings & chars) are availible in "text_processing.asm"
blit_byte_tile:
    #a0 = line, a1 = index, a2 = desired tile (works for any flat-data tile), s10 = clobber (TRUE/FALSE)
    mult t0, a0, LINE_SIZE # set line
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