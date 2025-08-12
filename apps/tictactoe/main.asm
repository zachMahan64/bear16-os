# TICTACTOE.ASM

@include "text_processing.asm"
@include "os_core.asm"
@include "util/blit.asm"

@include "apps/tictactoe/assets.asm"

.data
tictactoe_title_name_str:
    .string "  TIC-TAC-TOE"
tictactoe_title_edition_str:
    .string "Ultimate Edition"
tictactoe_title_play_prompt_str:
    .string " ENTER to play"
tictactoe_title_esc_prompt_str:
    .string "  ESC to exit"

tictactoe_in_game_title_str:
    .string " TIC-TAC-TOE: Ultimate Edition"

tictactoe_turn_1:
    .string " PLAYER 1's TURN"

tictactoe_turn_2:
    .string " PLAYER 2\'S TURN"


.text
tictactoe_start:
    call tictactoe_init
    call tictactoe_enter_title_page
    call tictactoe_exit
    ret

tictactoe_init:
    call util_clr_fb
    ret
tictactoe_enter_title_page:
    # a0 = line idx, a1 = idx on line
    mov a0, 3
    mov a1, 8
    mov a2, tictactoe_title_name_str
    call blit_strl_rom
    mov a0, 4
    mov a1, 8
    mov a2, tictactoe_title_edition_str
    call blit_strl_rom
    mov a0, 7
    mov a1, 8
    mov a2, tictactoe_title_play_prompt_str
    call blit_strl_rom
    mov a0, 8
    mov a1, 8
    mov a2, tictactoe_title_esc_prompt_str
    call blit_strl_rom
    tictactoe_enter_title_page_loop:
        lb t0, IO_LOC
        eq tictactoe_goto_ret, t0, K_ESC
        eq tictactoe_goto_play, t0, K_ENTER
        jmp tictactoe_enter_title_page_loop
    tictactoe_goto_play:
        lea t1, IO_LOC
        sb t1, 0 # clear
        call tictactoe_play
        jmp tictactoe_enter_title_page # re-enter title page w/o call routine (non-recursive)
    tictactoe_goto_ret:
        lea t1, IO_LOC
        sb t1, 0 # clear
    ret
tictactoe_play:
   # init UI
    call util_clr_fb

    mov a0, 1
    mov a1, 0
    mov a2, tictactoe_in_game_title_str
    call blit_strl_rom

    mov a0, 3
    mov a1, 0
    mov a2, tictactoe_turn_1
    call blit_strl_rom

    # init board
    call tictactoe_blit_board
    # struct Board -> char[9] where each byte can either be 0 (empty), 1 (X), or 2 (O)
    .const TTT_PLAY_BOARD_ARR_OFFS = -9
    .const TTT_PLAY_BOARD_ARR_SIZE = 9
    .const TTT_PLAY_BOARD_ARR_EMPTY = 0
    .const TTT_PLAY_BOARD_ARR_X = 1
    .const TTT_PLAY_BOARD_ARR_O = 2
    mov a0, TTT_PLAY_BOARD_ARR_SIZE
    jal util_sallocz
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

    # --> main loop should go here

    # TESTING/WIP ~~~~~~~~~~~#
    add t0, fp, TTT_PLAY_BOARD_ARR_OFFS
    sb t0, 8, 1 # board[src1] = X
    sb t0, 5, 2
    sb t0, 7, 2
    add a0, fp, TTT_PLAY_BOARD_ARR_OFFS # a0 <- &board
    call ttt_blit_game_state
    #~~~~~~~~~~~~~~~~~~~~~~~~#


    call util_stall_esc # temporary
    call util_clr_fb # clear screen for clean returning to title screen
    # loop this w/ an escape at some point
    ret

# BLITTING CONSTANTS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
.const TTT_BOARD_LINE_START = 5
.const TTT_BOARD_IDX_START = 7
.const TTT_BOARD_TILE_THICKNESS = 5
.const TTT_ILINE_DIST = (TTT_BOARD_TILE_THICKNESS + 1)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
tictactoe_blit_board:
    # blitting intersections
    .const TTT_BOARD_LINE_LEN = (TTT_BOARD_TILE_THICKNESS * 3 + 2)

    tictactoe_blit_board_hlines:
        add a0, TTT_BOARD_LINE_START, TTT_BOARD_TILE_THICKNESS
        mov a1, TTT_BOARD_IDX_START
        mov a2, TTT_HLINE
        push 0 # init cnt
        tictactoe_blit_board_hlines_loop:
            call blit_byte_tile
            add a0, a0, TTT_ILINE_DIST
            call blit_byte_tile
            sub a0, a0, TTT_ILINE_DIST
            inc a1
            # cnt manip
            pop t0
            inc t0
            push t0
            ult tictactoe_blit_board_hlines_loop, t0, TTT_BOARD_LINE_LEN
    pop t0 # ->
    push 0 # clear cnt
    tictactoe_blit_board_vlines:
        mov a0, TTT_BOARD_LINE_START
        add a1, TTT_BOARD_IDX_START, TTT_BOARD_TILE_THICKNESS
        mov a2, TTT_VLINE
        push 0 # init cnt
        tictactoe_blit_board_vlines_loop:
            call blit_byte_tile
            add a1, a1, TTT_ILINE_DIST
            call blit_byte_tile
            sub a1, a1, TTT_ILINE_DIST
            inc a0
            # cnt manip
            pop t0
            inc t0
            push t0
            ult tictactoe_blit_board_vlines_loop, t0, TTT_BOARD_LINE_LEN
    ret

ttt_blit_game_state:
    # a0 = ptr to board arr
    sub sp, sp, 4 # reserve for local vars

    .const BLIT_GAME_STATE_CNT_OFFS = -2
    .const BLIT_GAME_STATE_BOARD_PTR_OFFS = -4

    sw fp, BLIT_GAME_STATE_CNT_OFFS, 0 # clr
    sw fp, BLIT_GAME_STATE_BOARD_PTR_OFFS, a0 # save ptr to board
    blit_game_state_loop:
        lw t0, fp, BLIT_GAME_STATE_CNT_OFFS
        lw t2, fp, BLIT_GAME_STATE_BOARD_PTR_OFFS
        lb t1, t2, t0 # boardTileState = [a0 + t0] = board[t0]
        eq blit_game_state_x, t1, TTT_PLAY_BOARD_ARR_X
        eq blit_game_state_o, t1, TTT_PLAY_BOARD_ARR_O
        blit_game_state_did_blit_exit:
        lw t0, fp, BLIT_GAME_STATE_CNT_OFFS
        inc t0
        sw fp, BLIT_GAME_STATE_CNT_OFFS, t0
        ult blit_game_state_loop, t0, 9
    ret
    blit_game_state_x:
        mov a0, t0
        call blit_ttt_x
        jmp blit_game_state_did_blit_exit
    blit_game_state_o:
        mov a0, t0
        call blit_ttt_o
        jmp blit_game_state_did_blit_exit

tictactoe_exit:
    call util_clr_fb
    call os_init_taskbar
    call con_clear
    ret
# helpers
blit_ttt_x:
# for ref: TTT_BOARD_LINE_START = 5
# for ref: TTT_BOARD_IDX_START = 7
# for ref: TTT_ILINE_DIST = 6 (effectively)
    # a0 = place (0-8)
    .const BLIT_TTT_X_NUM_LOCAL_VARS = 3
    sub sp, sp, (BLIT_TTT_X_NUM_LOCAL_VARS * 2) # reserve for local vars

    .const BLIT_TTT_X_LINE_OFFS = -2
    .const BLIT_TTT_X_IDX_OFFS = -4
    .const BLIT_TTT_X_CNT_OFFS = -6

    mod t0, a0, 3
    sb fp, BLIT_TTT_X_IDX_OFFS, t0
    div t0, a0, 3
    sb fp, BLIT_TTT_X_LINE_OFFS, t0

    #init line
    lb t0, fp, BLIT_TTT_X_LINE_OFFS
    mult t0, t0, TTT_ILINE_DIST
    add t0, t0, TTT_BOARD_LINE_START
    sb fp, BLIT_TTT_X_LINE_OFFS, t0

    #init idx
    lb t0, fp, BLIT_TTT_X_IDX_OFFS
    mult t0, t0, TTT_ILINE_DIST
    add t0, t0, TTT_BOARD_IDX_START
    sb fp, BLIT_TTT_X_IDX_OFFS, t0

    #set up tile blitting args
    lb a0, fp, BLIT_TTT_X_LINE_OFFS
    lb a1, fp, BLIT_TTT_X_IDX_OFFS
    mov a2, ttt_x_map_tleft
    mov s10, FALSE
    #set up da counter for da loop
    sw fp, BLIT_TTT_X_CNT_OFFS, 0 # clear cnt
    blit_ttt_x_loop_0:
        call blit_byte_tile
        inc a0
        inc a1
        lw t0, fp, BLIT_TTT_X_CNT_OFFS
        inc t0
        sw fp, BLIT_TTT_X_CNT_OFFS, t0
        ult blit_ttt_x_loop_0, t0, 5

    #set up tile blitting args
    lb a0, fp, BLIT_TTT_X_LINE_OFFS
    add a0, a0, 4 # to blit other side of x (start 4 byte-tiles to the right)
    lb a1, fp, BLIT_TTT_X_IDX_OFFS
    mov a2, ttt_x_map_tright
    mov s10, FALSE
    #set up da counter for da loop
    sw fp, BLIT_TTT_X_CNT_OFFS, 0 # clear cnt
    blit_ttt_x_loop_1:
        call blit_byte_tile
        dec a0
        inc a1
        lw t0, fp, BLIT_TTT_X_CNT_OFFS
        inc t0
        sw fp, BLIT_TTT_X_CNT_OFFS, t0
        ult blit_ttt_x_loop_1, t0, 5
    ret

blit_ttt_o:
# for ref: TTT_BOARD_LINE_START = 5
# for ref: TTT_BOARD_IDX_START = 7
# for ref: TTT_ILINE_DIST = 6 (effectively)
# for ref: TTT_BOARD_TILE_THICKNESS = 5
    # a0 = place (0-8)
    .const BLIT_TTT_O_NUM_LOCAL_VARS = 3
    sub sp, sp, (BLIT_TTT_O_NUM_LOCAL_VARS * 2) # reserve for local vars

    .const BLIT_TTT_O_LINE_OFFS = -2
    .const BLIT_TTT_O_IDX_OFFS = -4
    .const BLIT_TTT_O_CNT_OFFS = -6

    mod t0, a0, 3
    sb fp, BLIT_TTT_O_IDX_OFFS, t0
    div t0, a0, 3
    sb fp, BLIT_TTT_O_LINE_OFFS, t0

    #init line
    lb t0, fp, BLIT_TTT_O_LINE_OFFS
    mult t0, t0, TTT_ILINE_DIST
    add t0, t0, TTT_BOARD_LINE_START
    sb fp, BLIT_TTT_O_LINE_OFFS, t0

    #init idx
    lb t0, fp, BLIT_TTT_O_IDX_OFFS
    mult t0, t0, TTT_ILINE_DIST
    add t0, t0, TTT_BOARD_IDX_START
    sb fp, BLIT_TTT_O_IDX_OFFS, t0

    #set up tile blitting args
    lb a0, fp, BLIT_TTT_O_LINE_OFFS
    lb a1, fp, BLIT_TTT_O_IDX_OFFS
    mov a2, TTT_HLINE
    mov s10, FALSE

    sw fp, BLIT_TTT_O_CNT_OFFS, 0 # clear cnt

    blit_ttt_o_loop_0:
        inc a1
        call blit_byte_tile
        add a0, a0, (TTT_BOARD_TILE_THICKNESS - 1)
        call blit_byte_tile
        sub a0, a0, (TTT_BOARD_TILE_THICKNESS - 1)

        lw t0, fp, BLIT_TTT_O_CNT_OFFS
        inc t0
        sw fp, BLIT_TTT_O_CNT_OFFS, t0

        ult blit_ttt_o_loop_0, t0, 3

    #set up tile blitting args again
    lb a0, fp, BLIT_TTT_O_LINE_OFFS
    lb a1, fp, BLIT_TTT_O_IDX_OFFS
    mov a2, TTT_VLINE
    mov s10, FALSE

    sw fp, BLIT_TTT_O_CNT_OFFS, 0 # clear cnt
    blit_ttt_o_loop_1:
        inc a0
        call blit_byte_tile
        add a1, a1, (TTT_BOARD_TILE_THICKNESS - 1)
        call blit_byte_tile
        sub a1, a1, (TTT_BOARD_TILE_THICKNESS - 1)

        lw t0, fp, BLIT_TTT_O_CNT_OFFS
        inc t0
        sw fp, BLIT_TTT_O_CNT_OFFS, t0

        ult blit_ttt_o_loop_1, t0, 3

    # restore to get da corners
    lb a0, fp, BLIT_TTT_O_LINE_OFFS
    lb a1, fp, BLIT_TTT_O_IDX_OFFS
    mov a2, TTT_O_TL
    call blit_byte_tile

    add a0, a0, (TTT_BOARD_TILE_THICKNESS - 1)
    mov a2, TTT_O_BL
    call blit_byte_tile

    add a1, a1, (TTT_BOARD_TILE_THICKNESS - 1)
    mov a2, TTT_O_BR
    call blit_byte_tile

    sub a0, a0, (TTT_BOARD_TILE_THICKNESS - 1)
    mov a2, TTT_O_TR
    call blit_byte_tile

    ret



