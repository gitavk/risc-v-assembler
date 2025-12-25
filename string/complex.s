.globl main
.text
# 1. Замените все цифры в строке остатками их деления на 5
# 2. Замените каждый пробел на число символов “_” в исходной строке. Если число больше 9, то укажите его остаток от делени я на 12
# 3. Замените все подстроки TTTT на подстроки II
# 4. Перевести все согласные ['B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X ', 'Z'] в верхний регистр


main:
    # считайте строку
    li a7, 63             # syscall number 63 = read
    li a0, 0              # file descriptor 0 = stdin
    la a1, input_buffer   # address of buffer to read into
    li a2, 1024           # maximum bytes to read
    ecall                 # execute syscall
    mv s0, a0             # save length (read returns bytes read in a0)

    # Count underscores in ORIGINAL string (before transformations)
    la a0, input_buffer   # a0 = buffer address
    mv a1, s0             # a1 = length
    call count_underscores
    mv s1, a0             # s1 = underscore count

    # Transformation 1: Replace digits with (digit % 5)
    la a0, input_buffer   # a0 = buffer address
    mv a1, s0             # a1 = length
    call replace_digits_mod5

    # Transformation 2: Replace spaces with N underscores
    la a0, input_buffer   # a0 = source buffer
    mv a1, s0             # a1 = length
    la a2, work_buffer    # a2 = destination buffer
    mv a3, s1             # a3 = N (underscore count)
    call replace_spaces_with_underscores
    mv s0, a0             # s0 = new length

    # Transformation 3: Replace "TTTT" with "II"
    la a0, work_buffer    # a0 = source buffer
    mv a1, s0             # a1 = length
    la a2, input_buffer   # a2 = destination buffer
    call replace_tttt_with_ii
    mv s0, a0             # s0 = new length

    # Transformation 2: Lowercase consonants
    la a0, input_buffer   # a0 = buffer address
    mv a1, s0             # a1 = length
    call uppercase_consonants

    # выведите строку в консоль
    li a7, 64             # syscall number 64 = write
    li a0, 1              # file descriptor 1 = stdout
    la a1, input_buffer   # address of buffer to write from
    mv a2, s0             # number of bytes to write (from s0)
    ecall                 # execute syscall

    # завершение работы программы
    addi a0, x0, 0
    addi a7, x0, 93
    ecall

# replace_digits_mod5: Replace each digit with (digit % 5)
# Input: a0 = buffer address, a1 = length
# Output: none (modifies buffer in-place)
replace_digits_mod5:
    mv t0, a0             # t0 = buffer pointer
    li t1, '0'            # t1 = '0' ASCII (48)
    li t2, '9'            # t2 = '9' ASCII (57)
loop_digits:
    beqz a1, done_digits  # if length == 0, done
    lbu t3, 0(t0)         # t3 = current character

    # Check if character is a digit ('0' <= char <= '9')
    blt t3, t1, not_digit # if char < '0', not a digit
    bgt t3, t2, not_digit # if char > '9', not a digit

    # It's a digit - replace with (digit % 5)
    sub t4, t3, t1        # t4 = digit value (0-9)
    li t5, 5              # t5 = 5
    rem t4, t4, t5        # t4 = digit % 5
    add t4, t4, t1        # t4 = '0' + (digit % 5)
    sb t4, 0(t0)          # store new digit

not_digit:
    addi t0, t0, 1        # advance to next character
    addi a1, a1, -1       # decrement length
    j loop_digits         # continue loop

done_digits:
    ret                   # return

# count_underscores: Count '_' characters in string
# Input: a0 = buffer address, a1 = length
# Output: a0 = count of underscores
count_underscores:
    li t0, 0              # t0 = counter
    li t1, '_'            # t1 = '_' character
count_loop:
    beqz a1, count_done   # if length == 0, done
    lbu t2, 0(a0)         # t2 = current character
    addi a0, a0, 1        # advance pointer
    addi a1, a1, -1       # decrement length
    bne t2, t1, count_loop  # if char != '_', continue
    addi t0, t0, 1        # increment counter
    j count_loop          # continue loop
count_done:
    li t4, 10
    blt t0, t4, single_cnt # if counter < 10, single counter
    li t4, 12
    rem t0, t0, t4
single_cnt:
    mv a0, t0             # return count in a0
    ret                   # return

# replace_spaces_with_number: Replace spaces with number N (can be 2 digits)
# Input: a0 = source, a1 = length, a2 = dest, a3 = N (value 0-13)
# Output: a0 = new length
replace_spaces_with_underscores:
    li t0, ' '            # t0 = space character
    mv t2, a2             # t2 = dest pointer
    mv t5, a3             # t5 = N (save for reuse)
replace_spaces_loop:
    beqz a1, replace_spaces_done  # if length == 0, done
    lbu t3, 0(a0)         # t3 = current character
    addi a0, a0, 1        # advance source pointer
    addi a1, a1, -1       # decrement length

    bne t3, t0, not_space # if not space, copy as-is

    # It's a space - write number N (could be 1 or 2 digits)
    li t4, 10
    blt t5, t4, single_digit  # if N < 10, single digit

    # Two digits: write '1' then '0'+remainder
    li t3, '1'            # first digit is always '1' (for 10-13)
    sb t3, 0(t2)          # write '1'
    addi t2, t2, 1        # advance dest
    li t4, 10
    sub t3, t5, t4        # t3 = N - 10 (gives 0-3)
    li t4, '0'
    add t3, t3, t4        # t3 = '0' + (N-10)
    sb t3, 0(t2)          # write second digit
    addi t2, t2, 1        # advance dest
    j replace_spaces_loop # continue loop

single_digit:
    li t4, '0'
    add t3, t5, t4        # t3 = '0' + N
    sb t3, 0(t2)          # write single digit
    addi t2, t2, 1        # advance dest
    j replace_spaces_loop # continue loop

not_space:
    sb t3, 0(t2)          # copy original character
    addi t2, t2, 1        # advance dest pointer
    j replace_spaces_loop # continue main loop

replace_spaces_done:
    la t3, work_buffer    # t3 = start of work_buffer
    sub a0, t2, t3        # a0 = new length (dest - start)
    ret                   # return

# Input: a0 = source, a1 = length, a2 = dest
# Output: a0 = new length
replace_tttt_with_ii:
    mv t0, a2             # t0 = dest pointer
    li t1, 'T'            # t1 = 'N' character
replace_nnnn_loop:
    li t2, 4              # t2 = 4
    blt a1, t2, copy_rest # if remaining < 4, copy rest

    # Check if next 4 characters are "TTTT"
    lbu t3, 0(a0)         # t3 = char[0]
    bne t3, t1, copy_char # if char[0] != 'T', copy single char
    lbu t3, 1(a0)         # t3 = char[1]
    bne t3, t1, copy_char # if char[1] != 'T', copy single char
    lbu t3, 2(a0)         # t3 = char[2]
    bne t3, t1, copy_char # if char[2] != 'T', copy single char
    lbu t3, 3(a0)         # t3 = char[3]
    bne t3, t1, copy_char # if char[3] != 'T', copy single char

    # Found "TTTT" - replace with "II"
    li t3, 'I'            # t3 = 'I' character
    sb t3, 0(t0)          # write 'I'
    sb t3, 1(t0)          # write 'I'
    addi t0, t0, 2        # dest += 2
    addi a0, a0, 4        # source += 4
    addi a1, a1, -4       # length -= 4
    j replace_nnnn_loop   # continue loop

copy_char:
    lbu t3, 0(a0)         # t3 = current character
    sb t3, 0(t0)          # write character
    addi t0, t0, 1        # dest += 1
    addi a0, a0, 1        # source += 1
    addi a1, a1, -1       # length -= 1
    j replace_nnnn_loop   # continue loop

copy_rest:
    beqz a1, replace_nnnn_done  # if length == 0, done
    lbu t3, 0(a0)         # t3 = current character
    sb t3, 0(t0)          # write character
    addi t0, t0, 1        # dest += 1
    addi a0, a0, 1        # source += 1
    addi a1, a1, -1       # length -= 1
    j copy_rest           # continue copying

replace_nnnn_done:
    sub a0, t0, a2        # a0 = new length (dest - start)
    ret                   # return

# uppercase: Convert specific lowercase consonants to uppercase
# Only: B,C,D,F,G,H,J,K,L,M,N,P,Q,R,S,T,V,W,X,Z
# Input: a0 = buffer address, a1 = length
# Output: none (modifies buffer in-place)
# Uses lookup table for O(1) check instead of O(n) comparisons
uppercase_consonants:
    mv t0, a0             # t0 = buffer pointer
    la t5, consonant_map  # t5 = address of lookup table
loop_consonants:
    beqz a1, done_consonants  # if length == 0, done
    lbu t1, 0(t0)         # t1 = current character

    # Use character as index into lookup table
    add t2, t5, t1        # t2 = &consonant_map[character]
    lbu t3, 0(t2)         # t3 = consonant_map[character]
    beqz t3, not_consonant  # if 0, not a consonant to convert

    # It's a consonant - convert to uppercase
    addi t1, t1, -32      # subtract 32 to convert to uppercase
    sb t1, 0(t0)          # store lowercase character

not_consonant:
    addi t0, t0, 1        # advance to next character
    addi a1, a1, -1       # decrement length
    j loop_consonants     # continue loop

done_consonants:
    ret                   # return

.data
input_buffer: .space 1024
work_buffer: .space 4096

# Lookup table for consonant conversion (256 bytes, indexed by ASCII value)
# 1 = convert to uppercase, 0 = don't convert
consonant_map:
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  # 0-15
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  # 16-31
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  # 32-47
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  # 48-63
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  # 64-79
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  # 80-95
    .byte 0,0,1,1,1,0,1,1,1,0,1,1,1,1,1,0  # 96-111  (A-O: B,C,D,F,G,H,J,K,L,M,N marked as 1)
    .byte 1,1,1,1,1,0,1,1,1,0,1,0,0,0,0,0  # 112-127 (P-Z: P,Q,R,S,T,V,W,X,Z marked as 1, not Y)
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  # 128-143
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  # 144-159
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  # 160-175
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  # 176-191
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  # 192-207
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  # 208-223
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  # 224-239
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  # 240-255
