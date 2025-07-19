# NOTEPAD.ASM

# REWORK this to have a dynamic cursor, and write purely to buffer & do page blits

@include "text_processing.asm"
@include "os_core.asm"


.data
notepad_esc_to_exit_str:
    .string "ESC to exit|"

.text
notepad_main:
# buffer assumes this memory is reserved for now, in future malloc this
# actually, adjust this cuz bottom two lines reserved for OS display
.const TEXT_PAGE_SIZE = 768 # abs. max, also inexact
.const NUM_PAGES      = 8   # inexact

    # a0 = starting line
    #mov s1, a0 # s1 = line ptr
    #clr s0     # s0 = index ptr
    call notepad_init
    notepad_loop:
    call os_update
    mov a0, s1  # line ptr
    mov a1, s0  # index ptr
    mov a2, '_' # underscore for our cursor
    call blit_cl
    lb s2, IO_LOC            # save inp from IO
    # K_... constants from text_processing.asm
    eq notepad_subr_backspace, s2, K_BACKSPACE # for backspace
    eq notepad_subr_newline, s2, K_ENTER  # for newline
    eq notepad_subr_tab, s2, K_TAB       # for tab
    eq notepad_subr_esc, s2, K_ESC      # for escape
    # ~~~~~~~~~~~~~~~~~~~~~~ # branch divide
    ugt notepad_subr_print_new_char, s2, 0
    jmp notepad_loop
    ret
    notepad_subr_print_new_char:
        # s0 = current char* to print
        mov a0, s1
        mov a1, s0     # a1 = index
        lb a2, IO_LOC # a2 = char
        lb t6, SHIFT_LOC
        ugt notepad_subr_shift, t6, 0 # if shift = true
        notepad_subr_shift_exit:
        call blit_cl # a0, a1, a2 used
        inc s0
        lea t0, IO_LOC # ->
        sb t0, 0       # clear IO memory location
        uge notepad_subr_go_on_newline, s0, LINE_WIDTH_B
        jmp notepad_loop
        notepad_subr_go_on_newline:
            inc s1 # next line!
            clr s0 # set index on line back to zero
            jmp notepad_loop
        notepad_subr_shift:
            ult notepad_snotepad_subr_nonalpha_shift, a2, 97
            ugt notepad_snotepad_subr_nonalpha_shift, a2, 122
            sub a2, a2, 32
            jmp notepad_subr_shift_exit
            notepad_snotepad_subr_nonalpha_shift:
                    lea t7, nonalpha_shift_map
                notepad_snotepad_subr_nonalpha_shift_loop:
                    lbrom t8, t7
                    mov s6, t7 # debug
                    eq notepad_snotepad_subr_nonalpha_shift_hit, a2, t8
                    add t7, t7, 2
                    jmp notepad_snotepad_subr_nonalpha_shift_loop
                    #error if t7 > size of nonalpha shift map
                    jmp notepad_subr_shift_exit
                notepad_snotepad_subr_nonalpha_shift_hit:
                    lbrom a2, t7, 1
                    jmp notepad_subr_shift_exit
        notepad_subr_backspace:
            #clear @ current spot
            mov a0, s1  # line ptr
            mov a1, s0  # index ptr
            mov a2, ' ' # space for blank
            call blit_cl
            dec s0
            eq notepad_snotepad_subr_backline_exit, s1, 0 # clamp if line ptr = 0
            lt notepad_snotepad_subr_backline, s0, 0
            notepad_snotepad_subr_backline_exit:
            lea t0, IO_LOC # ->
            sb t0, 0       # clear IO memory location
            jmp notepad_loop
                notepad_snotepad_subr_backline:
                    dec s1               # go back a line
                    mov s0, 31 # set index ptr to end of last line
                    jmp notepad_snotepad_subr_backline_exit
        notepad_subr_newline:
            mov a0, s1  # line ptr
            mov a1, s0  # index ptr
            mov a2, ' ' # space for blank
            call blit_cl
            lea t0, IO_LOC # ->
            sb t0, 0       # clear IO memory location
            inc s1
            clr s0
            jmp notepad_loop
        notepad_subr_tab:
            mov a0, s1  # line ptr
            mov a1, s0  # index ptr
            mov a2, ' ' # space for blank
            call blit_cl
            add s0, s0, 3 # move forward 2 indices for tab + 1 for going to next char
            lea t0, IO_LOC # ->
            sb t0, 0       # clear IO memory location
            jmp notepad_loop
        notepad_subr_esc:
            lea t0, IO_LOC # ->
            sb t0, 0       # clear IO memory location
            call notepad_exit
            # back to console
            ret

notepad_init:
    call notepad_init_os_bar
    mov a0, 22 # all but bottom two lines
    call util_clr_fb_by_line_idx # clear entire thing besides OS heads-up display at bottom
    mov s1, 0
    mov s0, 0
    ret
notepad_init_os_bar:
    call util_clr_bottom_left_os_bar
    mov a0, 23 # bottom line
    mov a1, 0  # idx
    mov a2, notepad_esc_to_exit_str # char*
    call blit_strl_rom
    ret
notepad_exit:
    call util_clr_bottom_left_os_bar
    call con_clear
    ret