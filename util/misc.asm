# UTIL/MISC.ASM
@include "text_processing.asm"
@include "util/memory.asm"
@include "util/constants.asm"
.text
#CTRL FLOW UTILITIES
util_stall:
    jmp util_stall
    ret

util_stall_esc:
    lb t0, IO_LOC
    ne util_stall_esc, t0, K_ESC # check if esc is pressed
    lea t0, IO_LOC
    sb t0, 0 # clear IO byte
    ret
util_stall_enter:
    lb t0, IO_LOC
    ne util_stall_enter, t0, K_ENTER # check if enter is pressed
    lea t0, IO_LOC
    sb t0, 0 # clear IO byte
    ret

util_iter_loop:
    # a0 = function ptr
    # a1 = times to execute
    .const ITER_LOOP_FNPTR_OFFS = -2
    .const ITER_LOOP_ENDVAL_OFFS = -4
    .const ITER_LOOP_CNT_OFFS = -6
    push a0
    push a1
    push 0 # reserve & bump sp
    util_iter_loop_loop:
        lwrom t0, fp, ITER_LOOP_FNPTR_OFFS
        lwrom t1, fp, ITER_LOOP_ENDVAL_OFFS
        lwrom t2, fp, ITER_LOOP_CNT_OFFS
        uge util_iter_loop_ret, t2, t1
        inc t2
        sw fp, ITER_LOOP_CNT_OFFS, t2
        call t0
    util_iter_loop_ret:
        ret
# FRAMEBUFFER FUNCTIONS
util_clr_fb:
    mov t0, FB_LOC # cnt/ptr
    util_clr_fb_loop:
        sb t0, 0
        inc t0
        lt util_clr_fb_loop, t0, FB_SIZE
    ret
util_clr_fb_by_line_idx:
    # clear fb by line, up to a certain line index
    # a0 = line index to stop at
    mov t0, FB_LOC # cnt/ptr
    mult t1, LINE_SIZE, a0
    util_clr_fb_by_line_idx_loop:
        sb t0, 0
        inc t0
        lt util_clr_fb_by_line_idx_loop, t0, t1
    ret
util_clr_bottom_left_os_bar:
    .const CLR_BOTTOM_LEFT_OS_BAR_OFFS = -2 # cnt/idx
    push 0 #init CLR_BOTTOM_LEFT_OS_BAR_OFFS
    clr t0
    util_clr_bottom_left_os_bar_loop:
        mov a0, 23 # last line
        mov a1, t0
        mov a2, ' ' # clear char
        call blit_cl
        lb t0, fp, CLR_BOTTOM_LEFT_OS_BAR_OFFS # ->
        inc t0                                 # ->
        sb fp, CLR_BOTTOM_LEFT_OS_BAR_OFFS, t0 # -> do cnt ops
        .const CLR_BOTTOM_LEFT_OS_BAR_IDX_RANGE_TO_CLEAR = 12
        ult util_clr_bottom_left_os_bar_loop, t0, CLR_BOTTOM_LEFT_OS_BAR_IDX_RANGE_TO_CLEAR # num idx to clear
    ret
# STRING FUNCTIONS
util_strcomp_ram_rom:
    # a0 = char* in ram
    # a1 = char* in rom
    # -> rv = TRUE/FALSE
    clr t2 # cnt
    util_strcomp_ram_rom_loop:
        lb t0, a0, t2 # load *char w/ cnt as offset
        lbrom t1, a1, t2 # load *char w/ cnt as offset
        ne util_strcomp_ram_rom_ne, t0, t1
        util_strcomp_ram_rom_char_eq:
           ne util_strcomp_ram_rom_char_eq_exit, t0, '\0'
           ne util_strcomp_ram_rom_char_eq_exit, t1, '\0'
           mov rv, TRUE
           ret
        util_strcomp_ram_rom_char_eq_exit:
        inc t2
        jmp util_strcomp_ram_rom_loop
    util_strcomp_ram_rom_ne:
        mov rv, FALSE
        ret
util_strcomp_ram_rom_ignore_case:
    # a0 = char* in ram
    # a1 = char* in rom
    # -> rv = TRUE/FALSE
    clr t2 # cnt
    util_strcomp_ram_rom_ignore_case_loop:
        lb t0, a0, t2 # load *char w/ cnt as offset
        jal util_strcomp_ram_rom_ignore_case_loop_clamp_case_ram
        lbrom t1, a1, t2 # load *char w/ cnt as offset
        jal util_strcomp_ram_rom_ignore_case_loop_clamp_case_rom
        ne util_strcomp_ram_rom_ignore_case_ne, t0, t1
        util_strcomp_ram_rom_ignore_case_char_eq:
           ne util_strcomp_ram_rom_ignore_case_char_eq_exit, t0, '\0'
           ne util_strcomp_ram_rom_ignore_case_char_eq_exit, t1, '\0'
           mov rv, TRUE
           ret
        util_strcomp_ram_rom_ignore_case_char_eq_exit:
        inc t2
        jmp util_strcomp_ram_rom_ignore_case_loop
        util_strcomp_ram_rom_ignore_case_loop_clamp_case_ram:
            ult util_strcomp_ram_rom_ignore_case_loop_clamp_case_ram_skip_clamp, t0, 'A'
            ugt util_strcomp_ram_rom_ignore_case_loop_clamp_case_ram_skip_clamp, t0, 'Z'
            add t0, t0, 32
            util_strcomp_ram_rom_ignore_case_loop_clamp_case_ram_skip_clamp:
            retl
        util_strcomp_ram_rom_ignore_case_loop_clamp_case_rom:
            ult util_strcomp_ram_rom_ignore_case_loop_clamp_case_rom_skip_clamp, t1, 'A'
            ugt util_strcomp_ram_rom_ignore_case_loop_clamp_case_rom_skip_clamp, t1, 'Z'
            add t1, t1, 32
            util_strcomp_ram_rom_ignore_case_loop_clamp_case_rom_skip_clamp:
            retl
    util_strcomp_ram_rom_ignore_case_ne:
        mov rv, FALSE
        ret

util_strlen_ram:
    # a0 = char*
    # ~> rv = string length (not including '\0')
    clr t0 # counter
    util_strlen_ram_loop:
        lb t1, a0, t0 # load *[currentChar + t0/counter]
        eq util_strlen_ram_hit_null_term, t1, '\0'
        inc t0
        jmp util_strlen_ram_loop
    util_strlen_ram_hit_null_term:
        mov rv, t0
        ret
util_strlen_rom:
    # a0 = char* in rom
    # ~> rv = string length (not including '\0')
    clr t0 # counter
    util_strlen_rom_loop:
        lbrom t1, a0, t0 # load *[currentChar + t0/counter]
        eq util_strlen_rom_hit_null_term, t1, '\0'
        inc t0
        jmp util_strlen_rom_loop
    util_strlen_rom_hit_null_term:
        mov rv, t0
        ret
