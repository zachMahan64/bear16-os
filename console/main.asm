# CONSOLE/MAIN.ASM (WIP)
# REG CONV: Overload s10 to a3 & s9 to a4, {s0 = index ptr, s1 = line ptr} -> for cursor
@include "os_core.asm"
@include "console/dispatch.asm"
@include "console/open.asm"
@include "gfx/main.asm"

.data
.const CON_STRT_LINE = 3

.const CON_NAME_LEN = 6
.const CON_MAX_LINES = 5
.const TOP_OF_BUFFER_CLAMP_VAL = (CON_MAX_LINES * 32 - CON_NAME_LEN)
.const CON_BUFFER_SIZE = (TOP_OF_BUFFER_CLAMP_VAL) # ~ thisNum/32 = approx num lines not that safe -> increase later, currently overflow works fine just overwrites
                            #   anything that goes over 64 after the next line is mallocd
con_name:
    .string "B16->"
.text
console_main:
    #LOCAL REG CONV: s3 = PTR TO CHAR IN CURRENT BUFFER (virtual cursor)
    .const FIRST_BUF_PTR_OFFS = -2     # (1st push)
    call con_init
    push rv # save FIRST_BUF_PTR
    con_main_loop:
        call os_update
        call con_get_line
        mov a0, rv # rv -> a0 = ptr to start of line buffer
        push rv # save ptr to start of line buffer
        call con_process_line #just echoes right now, no command dispatch (yet)
        pop a0 #retrieve  ptr to start of line buffer into a0
        call util_free # maybe save this in some other data structure for basic archiving instead of freeing
        jmp con_main_loop
    ret

con_init:
    # ~ rv = ptr to first buffer
    call print_welcome_msg
    #init starting line
    mov s1, CON_STRT_LINE
    #mov a0, 0
    call util_get_top_of_heap_ptr
    # reuse rv from the get call
    call os_init
    ret

con_reset_console:
    call util_clr_fb
    call os_init
    call con_init
    ret

con_print_cname:
    mov a0, s1 # line
    mov a1, 0             # index
    mov a2, con_name      # char*
    mov s10, TRUE         # bool updateCursor
    call blit_strl_rom
    ret

con_get_line:
    call check_to_scroll
    # ALLOCS a new BUFFER, save ptr as a local var and initialize s3 (virtual cursor) to it
    mov a0, CON_BUFFER_SIZE # malloc num bytes
    call util_malloc # reserve buffer memory
    mov s3, rv #get the ptr to the buffer from good ol malloc
    .const BUFFER_START_PTR_OFFS = -2
    push rv # push BUFFER_START_PTR_OFFS -> offset = -2
    call con_print_cname # WIP, later print username
    con_get_line_loop:
    call os_update
    call check_to_scroll
    mov a0, s1  # line ptr
    mov a1, s0  # index ptr
    mov a2, '_' # underscore for our cursor
    call blit_cl
    lb s2, IO_LOC            # save inp from IO
    eq subr_con_backspace, s2, 8 # for backspace
    eq subr_con_newline, s2, 13  # for newline
    eq subr_con_tab, s2, 9       # for tab
    eq con_get_line_loop, s2, 27 # ignore escape
    # ~~~~~~~~~~~~~~~~~~~~~~ # branch divide
    ugt subr_con_print_new_char, s2, 0
    jmp con_get_line_loop
    ret
    subr_con_print_new_char:
        # s0 = current char* to print
        mov a0, s1
        mov a1, s0     # a1 = index
        lb a2, IO_LOC # a2 = char
        lb t6, SHIFT_LOC
        ugt subr_con_shift, t6, 0 # if shift = true
        subr_con_shift_exit:
        #BUFFER WRITE----------------#
        sb s3, a2 # store char

        jmp subr_clamp_cursor
        clamp_norm_char_exit:

        inc s3
        #----------------------------#
        call blit_cl # a0, a1, a2 used
        inc s0
        lea t0, IO_LOC # ->
        sb t0, 0       # clear IO memory location
        uge subr_con_go_on_newline, s0, LINE_WIDTH_B
        jmp con_get_line_loop
        subr_con_go_on_newline:
            inc s1 # next line!
            clr s0 # set index on line back to zero
            jmp con_get_line_loop
        subr_con_shift:
            ult ssubr_con_nonalpha_shift, a2, 97
            ugt ssubr_con_nonalpha_shift, a2, 122
            sub a2, a2, 32
            jmp subr_con_shift_exit
            ssubr_con_nonalpha_shift:
                    lea t7, nonalpha_shift_map
                ssubr_con_nonalpha_shift_loop:
                    lbrom t8, t7
                    eq ssubr_con_nonalpha_shift_hit, a2, t8
                    add t7, t7, 2
                    jmp ssubr_con_nonalpha_shift_loop
                    #error if t7 > size of nonalpha shift map
                    jmp subr_con_shift_exit
                ssubr_con_nonalpha_shift_hit:
                    lbrom a2, t7, 1
                    jmp subr_con_shift_exit
        subr_con_backspace:
            #BUFFER WRITE----------------#
            sb s3, '\0' # pop char
            dec s3
            jmp subr_clamp_cursor
            clamp_backspace_exit:
            #----------------------------#
            #clear @ current spot
            mov a0, s1  # line ptr
            mov a1, s0  # index ptr
            mov a2, ' ' # space for blank
            call blit_cl
            dec s0
            lt ssubr_con_backline, s0, 0
            ssubr_con_backline_exit:
            lea t0, IO_LOC # ->
            sb t0, 0       # clear IO memory location
            jmp con_get_line_loop
                ssubr_con_backline:
                    dec s1               # go back a line
                    mov s0, 31 # set index ptr to end of last line
                    jmp ssubr_con_backline_exit
        subr_con_newline:
        #BUFFER WRITE----------------#
            sb s3, '\0' # ensure null termination
            inc s3
        #----------------------------#
            #clear @ current spot
            mov a0, s1  # line ptr
            mov a1, s0  # index ptr
            mov a2, ' ' # space to delete cursor
            call blit_cl
            lea t0, IO_LOC # ->
            sb t0, 0       # clear IO memory location
            # rv should still point to the start of buffer from the malloc call
            ret # dip outta here
        subr_con_tab:
            #BUFFER WRITE----------------#
            sb s3, '\t' # store char

            jmp subr_clamp_cursor
            clamp_tab_exit:

            inc s3
            #----------------------------#
            mov a0, s1  # line ptr
            mov a1, s0  # index ptr
            mov a2, ' ' # space for blank
            call blit_cl
            add s0, s0, 2 # move forward 2 indices for tab
            lea t0, IO_LOC # ->
            sb t0, 0       # clear IO memory location
            uge subr_con_go_on_newline, s0, LINE_WIDTH_B
            jmp con_get_line_loop
        subr_clamp_cursor:
            #clamp to preserve cname and <2 lines
            lw t0, fp, BUFFER_START_PTR_OFFS # access local var BUFFER_START_PTR_OFFS
            sub t0, s3, t0 # t0 = BUFFER TOP - BUFFER START

            lt subr_clamp_cursor_underflow, t0, 0
            uge subr_clamp_cursor_overflow, t0, TOP_OF_BUFFER_CLAMP_VAL

            lb t1, s3 # load char at top of buffer to determine subr exit
                eq clamp_backspace_exit, s2, 8 # for backspace, check last key press, not top of char buffer
                eq clamp_tab_exit, t1, '9'     # for tab,
                jmp clamp_norm_char_exit
            subr_clamp_cursor_underflow:
                #clear buff
                inc s3

                jmp con_get_line_loop
            subr_clamp_cursor_overflow:
                #clear buff
                lb t1, s3
                eq clamp_tab, t1, 9       # for tab
                    # clear cursor
                    mov a0, s1  # line ptr
                    mov a1, s0  # index ptr
                    mov a2, ' ' # space for blank
                    call blit_cl
                dec s3
                mov s0, 30
                jmp con_get_line_loop
            clamp_tab:
                    #clear cursor
                    mov a0, s1  # line ptr
                    mov a1, s0  # index ptr
                    mov a2, ' ' # space for blank
                    call blit_cl
                dec s3
                dec s1
                mov s0, 31
                jmp clamp_tab_exit
#SCROLLING
.const LINE_REACHED_TO_TRIGGER_SCROLL = 20
#SCROLLING CHECKS
check_to_scroll:
    uge check_to_scroll_do_scroll, s1, LINE_REACHED_TO_TRIGGER_SCROLL #check current cursor line
    ret
    check_to_scroll_do_scroll:
        call con_scroll_once_purely_visual
        dec s1
        ret
check_to_scroll_using_strlen_ram:
    # a0 = char*
    uge check_to_scroll_using_strlen_ram_do_scroll, s1, (LINE_REACHED_TO_TRIGGER_SCROLL - 1) #check current cursor line
    ret
    check_to_scroll_using_strlen_ram_do_scroll:
        #reuse a0
        call con_scroll_purely_visual_using_strlen_ram
        ret
check_to_scroll_using_strlen_rom:
    # a0 = char*
    uge check_to_scroll_using_strlen_rom_do_scroll, s1, LINE_REACHED_TO_TRIGGER_SCROLL #check current cursor line
    ret
    check_to_scroll_using_strlen_rom_do_scroll:
        #reuse a0
        call con_scroll_purely_visual_using_strlen_rom
        dec s1
        ret
#DIRECT SCROLLING FUNCTIONS
.const START_FIRST_LINE_IDX = 256
.const NUM_BYTES_FROM_FIRST_LINE_TO_END_OF_21st = 5376 # LINE WIDTH * NUM LINES = 256 * 21
.const NUM_BYTES_FROM_FIRST_LINE_TO_END_OF_20th = 5120 # LINE WIDTH * NUM LINES = 256 * 20
con_scroll_once_purely_visual:
    lea t0, FB_LOC
    memcpy FB_LOC, START_FIRST_LINE_IDX, NUM_BYTES_FROM_FIRST_LINE_TO_END_OF_21st

    mov t0, NUM_BYTES_FROM_FIRST_LINE_TO_END_OF_21st
    add t1, t0, 256 # end loop val
    con_scroll_once_purely_visual_clear_loop:
        sb t0, 0 # write zero/clear memory
        inc t0 # inc store location
        ult con_scroll_once_purely_visual_clear_loop, t0, t1
    ret
con_scroll_purely_visual_using_strlen_ram:
    #a0 = char*
    # reuse a0
    call util_strlen_ram
    mov t1, rv #get length of string!
    div a1, t1, LINE_WIDTH_B     # LINE_WIDTH_B = 32
    mov a0, con_scroll_once_purely_visual
    # a1 already set
    call util_iter_loop
    ret

con_scroll_purely_visual_using_strlen_rom:
    #a0 = char*
    # reuse a0
    call util_strlen_rom
    mov t1, rv #get length of string!
    div a1, t1, LINE_WIDTH_B     # LINE_WIDTH_B = 32
    mov a0, con_scroll_once_purely_visual
    # a1 already set
    call util_iter_loop
    ret

.data
con_succ_str:
    .string "CONSOLE SUCCESS"
con_err_str:
    .string "CONSOLE ERROR"
.text
con_process_line:
    # a0 = ptr to start of line buffer
    #reuse a0
    call console_dispatch_main
        inc s1
    ret
con_empty:
    call check_to_scroll
    ret

con_success:
    call check_to_scroll
    inc s1 # increment line
    call con_print_cname
    mov a0, s1 # line
    mov a1, s0 # index
    mov a2, con_succ_str
    mov s10, TRUE #update cursor
    call blit_strl_rom #blitting a str
    call check_to_scroll
    ret
con_error:
    call check_to_scroll
    inc s1 # increment line
    call con_print_cname
    mov a0, s1 # line
    mov a1, s0 # index
    mov a2, con_err_str
    mov s10, TRUE #update cursor
    call blit_strl_rom #blitting a str
    call check_to_scroll
    ret
con_echo:
    # a0 = ptr to start of line buffer
    call cd_isolate_args
    .const CON_ECHO_NUM_LOCAL_VARS = 1
    sub sp, sp, (CON_ECHO_NUM_LOCAL_VARS * 2)
    .const CON_ECHO_PTR_TO_ARGS_OFFS = -2
    sw fp, CON_ECHO_PTR_TO_ARGS_OFFS, rv # save ptr to args @ offset of -2
    # reuse a0
    inc s1
    call check_to_scroll_using_strlen_ram
    call con_print_cname
    mov a0, s1 # line
    mov a1, s0 # index
    lw a2, fp, CON_ECHO_PTR_TO_ARGS_OFFS
    mov s10, TRUE #update cursor
    eq con_echo_null_args, a2, NULL
    call blit_strl_ram #blitting a str
    lw a2, fp, CON_ECHO_PTR_TO_ARGS_OFFS
    call util_free # free args
    con_echo_null_args:
    dec s1
    call check_to_scroll
    ret
con_test:
    call con_success
    ret
con_cmd_not_found:
.data
con_cmd_not_found_str:
    .string "Error: command not found."
.text
    call check_to_scroll
    inc s1 # increment line
    call con_print_cname
    mov a0, s1 # line
    mov a1, s0 # index
    mov a2, con_cmd_not_found_str
    mov s10, TRUE #update cursor
    call blit_strl_rom #blitting a str
    call check_to_scroll
    ret
con_hello_world:
.data
con_hello_world_str:
    .string "Hello, world!"
.text
    call check_to_scroll
    inc s1 # increment line
    call con_print_cname
    mov a0, s1 # line
    mov a1, s0 # index
    mov a2, con_hello_world_str
    mov s10, TRUE #update cursor
    call blit_strl_rom #blitting a str
    call check_to_scroll
    ret

con_hi:
.data
con_hi_str:
    .string "Hey!"
.text
    call check_to_scroll
    inc s1 # increment line
    call con_print_cname
    mov a0, s1 # line
    mov a1, s0 # index
    mov a2, con_hi_str
    mov s10, TRUE #update cursor
    call blit_strl_rom #blitting a str
    call check_to_scroll
    ret
con_hey:
.data
con_hey_str:
    .string "Wassup?"
.text
    call check_to_scroll
    inc s1 # increment line
    call con_print_cname
    mov a0, s1 # line
    mov a1, s0 # index
    mov a2, con_hey_str
    mov s10, TRUE #update cursor
    call blit_strl_rom #blitting a str
    call check_to_scroll
    ret

con_help:
.data
con_help_str:
    .string "See the bear16 repo on \n     Github for help!"
.text
    mov a0, con_help_str
    call con_scroll_purely_visual_using_strlen_rom
    inc s1 # increment line
    call con_print_cname
    mov a0, s1 # line
    mov a1, s0 # index
    mov a2, con_help_str
    mov s10, TRUE #update cursor
    call blit_strl_rom
    ret
con_clear:
    mov a0, 22 # all but bottom two lines
    call util_clr_fb_by_line_idx # clear entire thing besides OS heads-up display at bottom
    mov s0, 0
    mov s1, 0
    ret

con_open:
    # a0 = ptr to start of line buffer
    dec s1
    call cd_isolate_args
    push rv # save ptr to arg
    mov a0, rv
    call app_dis_main
    # reuse a0
    pop a0
    call util_free # free args
    ret
con_login:
    call os_gfx_login_screen
    call con_reset_console
    ret
