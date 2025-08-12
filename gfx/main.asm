# GFX/MAIN.ASM

@include "os_core.asm"
@include "gfx/assets.asm"
.data

.const FB_SIZE_BYTES = 6144

.text
os_gfx_blit_ffb_img:
    # a0 = image label
    clr t0 # offset
    os_gfx_blit_ffb_img_loop:
        lwrom t1, a0, t0
        lea t2, FB_LOC
        sw t2, t0, t1
        add t0, t0, 2
        ult os_gfx_blit_ffb_img_loop, t0, (FB_SIZE)
    ret
os_gfx_login_screen: # WIP
.data
    os_gfx_login_screen_title:
        .string " BEAR16:"
    os_gfx_login_screen_subtitle:
        .string " A Retro\n Computing\n Platform"
    os_gfx_login_screen_press:
        .string "Press"
    os_gfx_login_screen_enter:
        .string "[ENTER]"
.text
    mov a0, bear_fs_image
    call os_gfx_blit_ffb_img
    mov a0, 1
    mov a1, 1
    mov a2, os_gfx_login_screen_title
    call blit_strl_rom_inv
    mov a0, 2
    mov a1, 1
    mov a2, os_gfx_login_screen_subtitle
    call blit_strl_rom_inv
    mov a0, 11
    mov a1, 26
    mov a2, os_gfx_login_screen_press
    call blit_strl_rom_inv
    mov a0, (11 + 1)
    mov a1, (26 - 1)
    mov a2, os_gfx_login_screen_enter
    call blit_strl_rom_inv
    call util_stall_enter
    call util_clr_fb
    ret
