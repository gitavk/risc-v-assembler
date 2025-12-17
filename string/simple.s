.globl main
.text

main:
    addi sp, sp, -16
    sd ra, 0(sp)

    li a7, 63
    li a0, 0
    la a1, input_buffer
    li a2, 1024
    ecall
    mv s0, a0

    la t0, input_buffer
    add t0, t0, s0
    addi t0, t0, -1
    lbu t1, 0(t0)
    li t2, 10
    bne t1, t2, no_newline
    addi s0, s0, -1
no_newline:

    la a0, input_buffer
    mv a1, s0
    call count_underscores
    mv s1, a0

    li t0, 6
    ble s1, t0, skip_mod
    li t0, 8
    rem s1, s1, t0
skip_mod:

    la a0, input_buffer
    mv a1, s0
    la a2, work_buffer
    mv a3, s1
    call replace_spaces
    mv s0, a0

    la a0, work_buffer
    mv a1, s0
    la a2, input_buffer
    call replace_aaaa
    mv s0, a0

    la a0, input_buffer
    mv a1, s0
    call replace_digits

    li a7, 64
    li a0, 1
    la a1, input_buffer
    mv a2, s0
    ecall

    ld ra, 0(sp)
    addi sp, sp, 16

    addi a0, x0, 0
    addi a7, x0, 93
    ecall

count_underscores:
    li t0, 0
    li t1, '_'
count_loop:
    beqz a1, count_done
    lbu t2, 0(a0)
    addi a0, a0, 1
    addi a1, a1, -1
    bne t2, t1, count_loop
    addi t0, t0, 1
    j count_loop
count_done:
    mv a0, t0
    ret

replace_spaces:
    li t0, ' '
    li t1, '0'
    add t1, t1, a3
    mv t2, a2
replace_spaces_loop:
    beqz a1, replace_spaces_done
    lbu t3, 0(a0)
    addi a0, a0, 1
    addi a1, a1, -1

    bne t3, t0, not_space
    sb t1, 0(t2)
    addi t2, t2, 1
    j replace_spaces_loop

not_space:
    sb t3, 0(t2)
    addi t2, t2, 1
    j replace_spaces_loop

replace_spaces_done:
    la t3, work_buffer
    sub a0, t2, t3
    ret

replace_aaaa:
    mv t0, a2
    li t1, 'A'
replace_aaaa_loop:
    li t2, 4
    blt a1, t2, copy_rest

    lbu t3, 0(a0)
    bne t3, t1, copy_char
    lbu t3, 1(a0)
    bne t3, t1, copy_char
    lbu t3, 2(a0)
    bne t3, t1, copy_char
    lbu t3, 3(a0)
    bne t3, t1, copy_char

    li t3, 'T'
    sb t3, 0(t0)
    sb t3, 1(t0)
    sb t3, 2(t0)
    addi t0, t0, 3
    addi a0, a0, 4
    addi a1, a1, -4
    j replace_aaaa_loop

copy_char:
    lbu t3, 0(a0)
    sb t3, 0(t0)
    addi t0, t0, 1
    addi a0, a0, 1
    addi a1, a1, -1
    j replace_aaaa_loop

copy_rest:
    beqz a1, replace_aaaa_done
    lbu t3, 0(a0)
    sb t3, 0(t0)
    addi t0, t0, 1
    addi a0, a0, 1
    addi a1, a1, -1
    j copy_rest

replace_aaaa_done:
    sub a0, t0, a2
    ret

replace_digits:
    mv t0, a0
    li t1, '0'
    li t2, '9'
replace_digits_loop:
    beqz a1, replace_digits_done
    lbu t3, 0(t0)

    blt t3, t1, not_digit
    bgt t3, t2, not_digit

    sub t4, t3, t1
    li t5, 3
    rem t4, t4, t5
    add t4, t4, t1
    sb t4, 0(t0)

not_digit:
    addi t0, t0, 1
    addi a1, a1, -1
    j replace_digits_loop

replace_digits_done:
    ret

.data
input_buffer: .space 1024
work_buffer: .space 4096
