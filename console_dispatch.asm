#COMMAND DISPATCH TABLE
@include "os_core.asm"
@include "console.asm"
.data
cmd_table:
    # char*, {label to call/fn ptr}
    # [4 bytes per entry]
    .word cmdt_echo, con_echo
    .word cmdt_test, con_test
    .word cmdt_help, con_help
    .word cmdt_hello, con_hello_world
    .word cmdt_clear, con_clear
    .word cmdt_open, con_open
    .word cmdt_hi, con_hi
    .word cmdt_hey, con_hey
    #add more
    .word NULL, con_cmd_not_found # throw an error if we read the table terminator
cmd_table_strings:
    cmdt_echo:
        .string "echo"
    cmdt_test:
        .string "test"
    cmdt_help:
        .string "help"
    cmdt_hello:
        .string "hello"
    cmdt_clear:
        .string "clear"
    cmdt_open:
        .string "open"
    cmdt_hi:
        .string "hi"
    cmdt_hey:
        .string "hey"
.text
# DISPATCHING FUNCTIONS
console_dispatch_main: # currently just echos
    # a0 = ptr to start of line buffer
    push a0 #save ptr to line buffer
    # reuse a0
    call cd_isolate_cmd
    push rv # save ptr to command
    # scope-saved s-register usage
    lea s5, cmd_table #ptr inside table
    pop s6 # get ptr to command
    clr s7 # cnt
    console_dispatch_main_loop: # WIP
        mov a0, s6
        lwrom t1, s5, s7 # dest, srcAddr, srcOffset
        mov a1, t1
        eq console_dispatch_main_jumpt, t1, NULL # if reached null case at const idx -> jump
        call util_strcomp_ram_rom_ignore_case
        eq console_dispatch_main_jumpt, rv, TRUE # elif rv == true -> jump
        add s7, s7, 4 #else jump to next entry
        jmp console_dispatch_main_loop
    console_dispatch_main_ret:
    pop a0 # get ptr to command
    call util_free
    ret
    console_dispatch_main_jumpt:
        add t0, s5, 2  # load ptr to jump addr
        add t0, t0, s7 # "
        lwrom t3, t0      # deference jump addr ptr
        pop a0 # get ptr from line buffer back
        call t3 # call function
        ret
# CMD PARSING
.const CMD_MAX_SIZE = 17 # including '/0'
.const CMD_MAX_SIZE_WO_NULL_TERM = (CMD_MAX_SIZE - 1)
cd_isolate_cmd: #nf
    # a0 = char* to orig buffer
    # ~ rv = char* to cmd
    push a0 # save char* to orig buffer to t0
    mov a0, CMD_MAX_SIZE # allocate
    call util_malloc
    pop t0 #get char* to orig buffer back
    clr t1 # init curr char to zero
    mov t2, rv #ptr to start of cmd from malloc
    clr t3 # cnt, use as offset!
    cd_isolate_cmd_loop:
        lb t1, t0, t3 # load char into t1 w/ offset of t3
        eq cd_isolate_cmd_ret, t1, '\0' # break if we hit a null terminator
        eq cd_isolate_cmd_ret, t1, ' '  # break if we hit a space/' '
        uge cd_isolate_cmd_ret, t3, CMD_MAX_SIZE_WO_NULL_TERM # break if we are >= max size - 1 (save room for \0)
        sb t2, t3, t1 # save char in t1 into addr in t2 w/ offset of t3
        inc t3
        jmp cd_isolate_cmd_loop
    cd_isolate_cmd_ret:
    sb t2, t3, 0   # null terminate
    #reuse rv (ptr to start of cmd from malloc)
    ret
cd_isolate_args: #nf
.const ARGS_MAX_SIZE = 60
    # a0 = ptr to start of cmd buffer
    # ~ rv = ptr to start of newly isolated args buffer
    push a0 # save char* to orig buffer to t0
    mov a0, ARGS_MAX_SIZE # allocate
    call util_malloc
    pop t0 #get char* to orig buffer back
    clr t1 # init curr char to zero
    mov t2, rv #ptr to start of cmd from malloc
    clr t3 # cnt, use as offset!
    cd_isolate_args_loop:
        lb t1, t0, t3 # load char into t1 w/ offset of t3
        eq cd_isolate_args_loop_ret_null, t1, '\0' # return null if we hit a null terminator before a space (no args)
        eq cd_isolate_args_hit_space, t1, ' '  # jump to isolate the args if we hit a space/' '
        inc t3
        jmp cd_isolate_args_loop
        cd_isolate_args_hit_space:
            inc t3
            clr t4
            cd_isolate_args_hit_space_loop:
                lb t1, t0, t3 # t1 <- [t0 + t3] / load char into t1 w/ offset of t3
                sb t2, t4, t1 # [t2 + t4] <- t1
                eq cd_isolate_args_ret, t1, '\0' # return cmd ptr, we done
                ge cd_isolate_args_ret, t3, ARGS_MAX_SIZE # if we overflow for whatev reason, ret args
                inc t3
                inc t4
                jmp cd_isolate_args_hit_space_loop
    cd_isolate_args_ret:
    mov rv, t2 # char* to start of cmd -> rv
    mov s7, t3
    ret
    cd_isolate_args_loop_ret_null:
        mov rv, NULL
        ret
