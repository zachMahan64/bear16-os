# MATH.ASM

.data
# CONSTANTS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.const MATH_PI       =  3.14159
.const MATH_NPI      = -3.14159
.const MATH_HALF_PI  =  1.57080
.const MATH_HALF_NPI = -1.57080
.const MATH_1P5_PI   =  4.71238
.const MATH_2PI      =  6.28318

.const MATH_E        =  2.71828

# FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.text
math_test:
    mov a0, (.25 * 3.14)
    call math_cos
    call util_stall
    ret
math_sin:
    # sin(a0) -> rv
    # a0 = x rad, rv = result rad
.const MATH_SIN_3_FACTORIAL = 6.0
.const MATH_SIN_5_FACTORIAL = 120.0
    # t_sign = t3
    jmp math_sin_clamp_inp
    math_sin_clamp_inp_exit:
    mov t0, a0      # x -> t0
    mult_fpt t1, t0, t0 # x^2
    mult_fpt t1, t1, t0 # x^3 -> t1
    mult_fpt t2, t1, t0 # x^4
    mult_fpt t2, t2, t0 # x^5 -> t2
    div_fpt t1, t1, MATH_SIN_3_FACTORIAL # (x^3)/(3!)
    div_fpt t2, t2, MATH_SIN_5_FACTORIAL # (x^5)/(5!)
    sub t0, t0, t1
    add rv, t0, t2 # x - (x^3/3!) + (x^5/5!) -> rv
    mult_fpt rv, rv, t3 # multiply rv by t_sign
    ret
    math_sin_clamp_inp:
        mod_fpt a0, a0, MATH_2PI # clamp to [0, 2pi]
        gt math_sin_clamp_inp_gt_pi, a0, MATH_PI
        gt math_sin_clamp_inp_gt_halfpi, a0, MATH_HALF_PI
        mov t3, 1.0 # else set t_sign to positive
        jmp math_sin_clamp_inp_exit
        math_sin_clamp_inp_gt_pi:
            sub a0, MATH_2PI, a0
            mov t3, -1.0 # set t_sign to negative
            jmp math_sin_clamp_inp_exit
        math_sin_clamp_inp_gt_halfpi:
            sub a0, MATH_PI, a0
            mov t3, 1.0 # else set t_sign to positive
            jmp math_sin_clamp_inp_exit


math_cos:
    # cos(a0) -> rv
    # a0 = x rad, rv = result rad
.const MATH_COS_2_FACTORIAL = 2.0
.const MATH_COS_4_FACTORIAL = 24.0
    # t_sign = t3
    jmp math_cos_clamp_inp
    math_cos_clamp_inp_exit:
    mov t0, a0      # x -> t0
    mult_fpt t1, t0, t0 # x^2 -> t1
    mult_fpt t2, t1, t1 # x^4 -> t2
    div_fpt t1, t1, MATH_COS_2_FACTORIAL # (x^2)/(2!)
    div_fpt t2, t2, MATH_COS_4_FACTORIAL # (x^4)/(4!)
    sub t0, 1.0, t1
    add rv, t0, t2 # 1 - (x^2/2!) + (x^4/4!) -> rv
    ret
    math_cos_clamp_inp:
        mod_fpt a0, a0, MATH_2PI # clamp to [0, 2pi]
        gt math_cos_clamp_inp_gt_pi, a0, MATH_PI
        jmp math_cos_clamp_inp_exit
        math_cos_clamp_inp_gt_pi:
            sub a0, a0, MATH_2PI
            jmp math_cos_clamp_inp_exit