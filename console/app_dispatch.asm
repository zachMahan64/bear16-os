
.data
app_dis_start:
    # char*, {label to call/fn ptr}
    # [4 bytes per entry]
    .word app_dis_notepad, notepad_main
    .word app_dis_tic_tac_toe, tictactoe_start
    #add more here!
    .word NULL, app_not_found # throw an error if we read the table terminator

