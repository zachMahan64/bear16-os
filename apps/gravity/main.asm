# APPS/GRAVITY/MAIN.ASM

@include "util/misc.asm"
@include "text_processing.asm"
@include "gfx/draw.asm"
@include "util/blit.asm"

.data
gravity_ball_sprite:
.byte 0b00111100
.byte 0b01111110
.byte 0b11111111
.byte 0b11111111
.byte 0b11111111
.byte 0b11111111
.byte 0b01111110
.byte 0b00111100

gravity_title_str:
    .string "GRAVITY SIM"
gravity_line_str:
    .string "------------"
gravity_exit_str:
    .string "|[ESC] exit|"
gravity_drop_str:
    .string "| [D]  drop|"

.text
gravity_main:
    # currently uses a saved register design instead of stack locals (for faster prototyping)
    push s3
    push s4
    push s5
    push s6

    call util_clr_fb # clear screen

    # s3 = last frametime, s4 = this frametime, s5 = curr velocity, s6 = ball y-pos -> turn this into a data struct for modularity
    .const GRAVITY_BALL_STARTING_X_IDX = 16 # perhaps make non-constant to allow ball to be dropped anywhere
    mov s5, 0.0
    mov s6, 16 # set starting y-pos, LOWER VALUE MEANS HIGHER UP IN THE FRAMEBUFFER

    mov a0, 1
    mov a1, 10
    mov a2, gravity_title_str
    call blit_strl_rom

    mov a0, 2
    mov a1, 0
    mov a2, gravity_line_str
    call blit_strl_rom


    mov a0, 3
    mov a1, 0
    mov a2, gravity_exit_str
    call blit_strl_rom

    mov a0, 4
    mov a1, 0
    mov a2, gravity_drop_str
    call blit_strl_rom

    mov a0, 5
    mov a1, 0
    mov a2, gravity_line_str
    call blit_strl_rom

    gravity_main_loop:
        call util_chrono_frametime_capture
        mov s3, rv

        gravity_main_loop_wait_loop:
            # allow esc
            lb t0, IO_LOC
            eq gravity_main_ret, t0, K_ESC
            eq gravity_drop_pressed, t0, 'd'
            eq gravity_drop_pressed, t0, 'D'

            mov a0, s3 # pass in original frametime
            mov a1, 1 # check if 1 frame has elapsed
            call util_chrono_frametime_check_elapsed
            ne gravity_main_loop_wait_loop, rv, TRUE

        # clear last ball loc
        mov a0, s6
        mov a1, GRAVITY_BALL_STARTING_X_IDX
        mov a2, blit_empty_tile
        mov s10, TRUE
        call blit_byte_row

        # position
        mov a0, s6
        mov a1, s5
        call gravity_update_ball_y_pos
        mov s6, rv

        # velocity
        mov s4, s5 # set last velocity
        mov a0, s5
        call gravity_update_ball_velocity
        mov s5, rv

        # draw logic
        mov a0, s6
        mov a1, GRAVITY_BALL_STARTING_X_IDX
        call gravity_draw_ball

        jmp gravity_main_loop

    pop s6
    pop s5
    pop s4
    pop s3
    gravity_main_ret:
    call util_clr_fb
    call con_reset
    ret
    gravity_drop_pressed:
        lea t0, IO_LOC
        sw t0, 0 # clear IO_LOC
        call util_clr_fb
        pop s6
        pop s5
        pop s4
        pop s3
        jmp gravity_main

gravity_draw_ball:
    # a0 = y (pix), a1 = x (idx)
    gt gravity_draw_ball_clamp, a0, (191 - 8)
    # ^ shortcut until fully robust collision detection, currently there's just rudimentary collision for elastic bounces
    gravity_draw_ball_clamp_exit:
    # reuse a0, a1
    mov a2, gravity_ball_sprite
    mov s10, TRUE
    call blit_byte_row
    ret
    gravity_draw_ball_clamp:
        mov a0, (191-8)
        jmp gravity_draw_ball_clamp_exit

gravity_update_ball_velocity:
    # a0 = velocity (fpt)
    # -> rv = new velocity

    # will probably break at excessively high velocities
    sub rv, a0, (.016666 * 20.0) # g * 1/60 * simulation_speed, which is basically a magic number
    ret

gravity_update_ball_y_pos:
    # WARNING: CURRENTLY DOES A REGISTER SIDE EFFECT, CHANGE a1 and a2 to pointers for modularity
    # a0 = starting y pos
    # a1 = last velocity
    # a2 = curr velocity
    # -> rv = new y pos

    ugt gravity_update_ball_y_pos_bounce, s6, (191- 8) # height when ball is at bottom of FB
    gravity_update_ball_y_pos_bounce_exit:

    mult_fpt t0, a1, 1.0 # flip sign?
    mult_fpt t1, a2, 1.0 # ^

    # .5 (last velo + curr velo) = average velo over last frame
    mult_fpt t0, .5, t0
    mult_fpt t1, .5, t0
    add t2, t0, t1

    div_fpt t2, t2, 1.0 # divide by 60 cuz 60 frames per second

    mov t0, t2
    and t1, t0, 0x8000 # get high bit
    ne gravity_update_ball_y_pos_logical, t1, 0x8000
    rsh t0, t0, 8 # to make integer
    or t0, t0, 0xFF00 # for emulated arithmetic rsh
    jmp gravity_update_ball_y_pos_shift_done
    gravity_update_ball_y_pos_logical:
    rsh t0, t0, 8 # to make integer
    gravity_update_ball_y_pos_shift_done:

    sub rv, a0, t0
    ret
    gravity_update_ball_y_pos_bounce:
    gt gravity_update_ball_y_pos_bounce_exit, s5, 0.0
    .const GRAVITY_BALL_ELASTICITY = (-0.98)
    mult_fpt s5, s5, GRAVITY_BALL_ELASTICITY # set velocity
    mov s4, s5  # clear last velocity
    mov rv, a0
    jmp gravity_update_ball_y_pos_bounce_exit
