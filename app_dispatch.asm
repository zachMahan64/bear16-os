# APP_DISPATCH.ASM

@include "os_core.asm" #implements interface
# APPS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
@include "apps/notepad.asm"
@include "apps/tictactoe.asm"
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

.data
app_dist:
app_dist_start:
    # char*, {label to call/fn ptr}
    # [4 bytes per entry]
    .word app_dist_notepad, notepad_main
    .word app_dist_tic_tac_toe, tictactoe_start
    #add more
    .word NULL, app_not_found # throw an error if we read the table terminator
app_dist_strings:
    app_dist_notepad:
        .string "notepad"
    app_dist_tic_tac_toe:
        .string "tictactoe"
.text
app_dis_main:
    #
    # scope-saved s-register usage
    lea s5, app_dist_start #ptr inside table
    mov s6, a0 # get ptr to app name
    clr s7 # cnt
    app_dis_main_loop: # WIP
        mov a0, s6
        lwrom t1, s5, s7 # dest, srcAddr, srcOffset
        mov a1, t1
        eq app_dis_main_jumpt, t1, NULL # if reached null case at const idx -> jump
        call util_strcomp_ram_rom
        eq app_dis_main_jumpt, rv, TRUE # elif rv == true -> jump
        add s7, s7, 4 #else jump to next entry
        jmp app_dis_main_loop
    app_dis_main_ret:
    ret
    app_dis_main_jumpt:
        add t0, s5, 2  # load ptr to jump addr
        add t0, t0, s7 # "
        lwrom t3, t0      # deference jump addr ptr
        inc s1
        call t3 # call function
        ret
app_not_found:
.data
    app_not_found_str:
        .string "Error: app not found."
.text
    call check_to_scroll
    inc s1 # increment line
    call con_print_cname
    mov a0, s1 # line
    mov a1, s0 # index
    mov a2, app_not_found_str
    mov s10, TRUE #update cursor
    call blit_strl_rom #blitting a str
    call check_to_scroll
    ret