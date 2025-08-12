# TICTACTOE_ASSETS.ASM

.data
.const TTT_VLINE = (ttt_tset_map_0)
.const TTT_HLINE = (ttt_tset_map_1)
.const TTT_ILINE = (ttt_tset_map_2)
ttt_tset_map_start:
ttt_tset_map_0:
.byte 0b00011000
.byte 0b00011000
.byte 0b00011000
.byte 0b00011000
.byte 0b00011000
.byte 0b00011000
.byte 0b00011000
.byte 0b00011000
ttt_tset_map_1:
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b11111111
.byte 0b11111111
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
ttt_tset_map_2:
.byte 0b00011000
.byte 0b00011000
.byte 0b00011000
.byte 0b11111111
.byte 0b11111111
.byte 0b00011000
.byte 0b00011000
.byte 0b00011000
ttt_tset_map_3:
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
ttt_tset_map_4:
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
ttt_tset_map_5:
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
ttt_tset_map_6:
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
ttt_tset_map_7:
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
ttt_tset_map_end:

ttt_x_map_tleft:
.byte 0b11000000
.byte 0b11100000
.byte 0b01110000
.byte 0b00111000
.byte 0b00011100
.byte 0b00001110
.byte 0b00000111
.byte 0b00000011
ttt_x_map_tright:
.byte 0b00000011
.byte 0b00000111
.byte 0b00001110
.byte 0b00011100
.byte 0b00111000
.byte 0b01110000
.byte 0b11100000
.byte 0b11000000

#circle must be bult from various things ^ like horizontal and vertical lines
.const TTT_O_TL = (ttt_o_map_0)
.const TTT_O_TR = (ttt_o_map_1)
.const TTT_O_BL = (ttt_o_map_2)
.const TTT_O_BR = (ttt_o_map_3)
ttt_o_map_start:
ttt_o_map_0:
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000011
.byte 0b00000111
.byte 0b00001110
.byte 0b00001100
ttt_o_map_1:
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b11000000
.byte 0b11100000
.byte 0b01110000
.byte 0b00110000
ttt_o_map_2:
.byte 0b00001100
.byte 0b00001110
.byte 0b00000111
.byte 0b00000011
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
ttt_o_map_3:
.byte 0b00110000
.byte 0b01110000
.byte 0b11100000
.byte 0b11000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
.byte 0b00000000
ttt_o_map_end: