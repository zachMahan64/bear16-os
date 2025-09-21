# GFX/DRAW.ASM

.text

gfx_fpt_to_uint_coord:
    # fixpt a0 = x
    # fixpt a1 = y
    .const GFX_HI_BIT_MASK = 0x8000
    mov t0, a0
    and t1, t0, GFX_HI_BIT_MASK # get high bit
    ne gfx_fpt_to_uint_coord_logical_x, t1, GFX_HI_BIT_MASK
    rsh t0, t0, 8 # to make integer
    or t0, t0, 0xFF00 # for arithmetic rsh
    jmp gfx_fpt_to_uint_coord_shift_done_x
    gfx_fpt_to_uint_coord_logical_x:
    rsh t0, t0, 8 # to make integer
    gfx_fpt_to_uint_coord_shift_done_x:

    add t0, t0, 128 # map to range [0, 255]

    # TODO finish

    hlt
    ret
