.globl solution
solution: 
  # ЕСЛИ ((arr[5] ^ arr[9] | arr[3] | arr[3] & arr[5]) <= 700)
  # ТО (arr[i] = arr[i - 1] ^ 97)
  # ИНАЧЕ (arr[i] = arr[i] & 59)
  # a1 - array address
  # a2 - number of elements
  mv a5, a2             # a5 <- a2
  mv a6, a1             # a6 <- a1

  loop:

  ld t0, 24(a1)        # t0 <- arr[3]
  ld t1, 40(a1)        # t1 <- arr[5]
  ld t2, 72(a1)        # t2 <- arr[9]
  and a3, t0, t1       # a3 <- arr3 & arr5
  xor a4, t1, t2       # a4 <- arr5 ^ arr9
  or a4, a4, t0        # a4 <- a4 | arr3
  or a3, a4, a3        # a3 <- a4 | a3

                        # a3 is to be compared
  li a4, 700            # a4 <- 700

  bge a4, a3, success_cond  # if a4 >= a3: goto success

  failed_cond:          # else:

  ld a7, 0(a6)          # a7 <- arr[i]
  and a7, a7, 59         # a7 = a7 & 59
  sd a7, 0(a6)          # a7 -> arr[i]

  addi a6, a6, 8          # next array element

  j final               

  success_cond:

  beq a6, a1, first_element
  ld a7, -8(a6)         # a7 <- arr[i-1]
  j success_procedure

  first_element:

  li a7, 0

  success_procedure:

  xori a7, a7, 97     # a7 = a7 ^ 97
  sd a7, 0(a6)        # a7 -> arr[i]
  addi a6, a6, 8      # next array element

  final:

  addi a5, a5, -1       # a5 -= 1
  bgtz a5, loop         # if a5 > 0 repeat loop

  ret 
