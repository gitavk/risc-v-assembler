.globl main
.text

# Main program:
# 1. Read input string
# 2. Count underscores and calculate replacement digit (count % 8 if count > 6)
# 3. Replace spaces with digit
# 4. Replace "AAAA" with "TTT"
# 5. Replace digits with (digit % 3)
# 6. Write result to stdout

main:
    addi sp, sp, -16      # allocate stack frame
    sd ra, 0(sp)          # save return address

    # Read input from stdin (syscall 63)
    li a7, 63             # a7 <- syscall number (read)
    li a0, 0              # a0 <- file descriptor (stdin)
    la a1, input_buffer   # a1 <- buffer address
    li a2, 1024           # a2 <- max bytes to read
    ecall                 # perform syscall
    mv s0, a0             # s0 <- bytes read (string length)

    # Remove trailing newline if present
    la t0, input_buffer   # t0 <- input_buffer address
    add t0, t0, s0        # t0 <- address of last+1 char
    addi t0, t0, -1       # t0 <- address of last char
    lbu t1, 0(t0)         # t1 <- last character
    li t2, 10             # t2 <- newline character '\n'
    bne t1, t2, no_newline  # if last char != '\n', skip
    addi s0, s0, -1       # s0 <- length - 1 (remove newline)
no_newline:

    # Count underscores in input
    la a0, input_buffer   # a0 <- input buffer address
    mv a1, s0             # a1 <- string length
    call count_underscores  # call function
    mv s1, a0             # s1 <- underscore count

    # Calculate replacement digit: if count > 6 then count % 8, else count
    li t0, 6              # t0 <- 6
    ble s1, t0, skip_mod  # if count <= 6, skip modulo
    li t0, 8              # t0 <- 8
    rem s1, s1, t0        # s1 <- count % 8
skip_mod:

    # Replace spaces with digit (s1)
    la a0, input_buffer   # a0 <- source buffer
    mv a1, s0             # a1 <- length
    la a2, work_buffer    # a2 <- destination buffer
    mv a3, s1             # a3 <- replacement digit
    call replace_spaces   # call function
    mv s0, a0             # s0 <- new length

    # Replace "AAAA" with "TTT"
    la a0, work_buffer    # a0 <- source buffer
    mv a1, s0             # a1 <- length
    la a2, input_buffer   # a2 <- destination buffer
    call replace_aaaa     # call function
    mv s0, a0             # s0 <- new length

    # Replace digits with (digit % 3)
    la a0, input_buffer   # a0 <- buffer to modify
    mv a1, s0             # a1 <- length
    call replace_digits   # call function

    # Write result to stdout (syscall 64)
    li a7, 64             # a7 <- syscall number (write)
    li a0, 1              # a0 <- file descriptor (stdout)
    la a1, input_buffer   # a1 <- buffer address
    mv a2, s0             # a2 <- bytes to write
    ecall                 # perform syscall

    # Restore and exit
    ld ra, 0(sp)          # restore return address
    addi sp, sp, 16       # deallocate stack frame

    # Exit program (syscall 93)
    addi a0, x0, 0        # a0 <- exit code 0
    addi a7, x0, 93       # a7 <- syscall number (exit)
    ecall                 # perform syscall

# count_underscores: Count number of '_' characters in string
# Input: a0 = string address, a1 = string length
# Output: a0 = count of underscores
count_underscores:
    li t0, 0              # t0 <- 0 (counter)
    li t1, '_'            # t1 <- '_' character
count_loop:
    beqz a1, count_done   # if length == 0, done
    lbu t2, 0(a0)         # t2 <- current character
    addi a0, a0, 1        # a0 <- next character address
    addi a1, a1, -1       # a1 <- length - 1
    bne t2, t1, count_loop  # if char != '_', continue loop
    addi t0, t0, 1        # t0 <- counter + 1
    j count_loop          # continue loop
count_done:
    mv a0, t0             # a0 <- counter (return value)
    ret                   # return

# replace_spaces: Replace all space characters with a digit
# Input: a0 = source address, a1 = length, a2 = dest address, a3 = digit value (0-7)
# Output: a0 = new length
replace_spaces:
    li t0, ' '            # t0 <- ' ' (space character)
    li t1, '0'            # t1 <- '0' ASCII
    add t1, t1, a3        # t1 <- '0' + digit (replacement char)
    mv t2, a2             # t2 <- dest pointer
replace_spaces_loop:
    beqz a1, replace_spaces_done  # if length == 0, done
    lbu t3, 0(a0)         # t3 <- current character
    addi a0, a0, 1        # a0 <- next source address
    addi a1, a1, -1       # a1 <- length - 1

    bne t3, t0, not_space # if char != ' ', copy as-is
    sb t1, 0(t2)          # store replacement digit
    addi t2, t2, 1        # t2 <- next dest address
    j replace_spaces_loop # continue loop

not_space:
    sb t3, 0(t2)          # store original character
    addi t2, t2, 1        # t2 <- next dest address
    j replace_spaces_loop # continue loop

replace_spaces_done:
    la t3, work_buffer    # t3 <- work_buffer address
    sub a0, t2, t3        # a0 <- new length (dest - start)
    ret                   # return

# replace_aaaa: Replace all occurrences of "AAAA" with "TTT"
# Input: a0 = source address, a1 = length, a2 = dest address
# Output: a0 = new length
replace_aaaa:
    mv t0, a2             # t0 <- dest pointer
    li t1, 'A'            # t1 <- 'A' character
replace_aaaa_loop:
    li t2, 4              # t2 <- 4
    blt a1, t2, copy_rest # if remaining < 4, copy rest

    # Check if next 4 characters are "AAAA"
    lbu t3, 0(a0)         # t3 <- char[0]
    bne t3, t1, copy_char # if char[0] != 'A', copy single char
    lbu t3, 1(a0)         # t3 <- char[1]
    bne t3, t1, copy_char # if char[1] != 'A', copy single char
    lbu t3, 2(a0)         # t3 <- char[2]
    bne t3, t1, copy_char # if char[2] != 'A', copy single char
    lbu t3, 3(a0)         # t3 <- char[3]
    bne t3, t1, copy_char # if char[3] != 'A', copy single char

    # Found "AAAA", replace with "TTT"
    li t3, 'T'            # t3 <- 'T' character
    sb t3, 0(t0)          # store 'T'
    sb t3, 1(t0)          # store 'T'
    sb t3, 2(t0)          # store 'T'
    addi t0, t0, 3        # t0 <- dest + 3
    addi a0, a0, 4        # a0 <- source + 4
    addi a1, a1, -4       # a1 <- length - 4
    j replace_aaaa_loop   # continue loop

copy_char:
    lbu t3, 0(a0)         # t3 <- current character
    sb t3, 0(t0)          # store character
    addi t0, t0, 1        # t0 <- next dest address
    addi a0, a0, 1        # a0 <- next source address
    addi a1, a1, -1       # a1 <- length - 1
    j replace_aaaa_loop   # continue loop

copy_rest:
    beqz a1, replace_aaaa_done  # if length == 0, done
    lbu t3, 0(a0)         # t3 <- current character
    sb t3, 0(t0)          # store character
    addi t0, t0, 1        # t0 <- next dest address
    addi a0, a0, 1        # a0 <- next source address
    addi a1, a1, -1       # a1 <- length - 1
    j copy_rest           # continue loop

replace_aaaa_done:
    sub a0, t0, a2        # a0 <- new length (dest - start)
    ret                   # return

# replace_digits: Replace each digit with (digit % 3)
# Input: a0 = buffer address, a1 = length
# Output: none (modifies buffer in-place)
replace_digits:
    mv t0, a0             # t0 <- buffer pointer
    li t1, '0'            # t1 <- '0' ASCII (48)
    li t2, '9'            # t2 <- '9' ASCII (57)
replace_digits_loop:
    beqz a1, replace_digits_done  # if length == 0, done
    lbu t3, 0(t0)         # t3 <- current character

    # Check if character is a digit ('0' <= char <= '9')
    blt t3, t1, not_digit # if char < '0', not a digit
    bgt t3, t2, not_digit # if char > '9', not a digit

    # Replace digit with (digit % 3)
    sub t4, t3, t1        # t4 <- digit value (0-9)
    li t5, 3              # t5 <- 3
    rem t4, t4, t5        # t4 <- digit % 3 (0-2)
    add t4, t4, t1        # t4 <- '0' + (digit % 3)
    sb t4, 0(t0)          # store new digit

not_digit:
    addi t0, t0, 1        # t0 <- next character address
    addi a1, a1, -1       # a1 <- length - 1
    j replace_digits_loop # continue loop

replace_digits_done:
    ret                   # return

.data
input_buffer: .space 1024  # Input/output buffer (1KB)
work_buffer: .space 4096   # Working buffer for transformations (4KB)
