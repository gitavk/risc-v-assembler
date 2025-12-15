.globl solution
solution: 
# ЕСЛИ ((arr[19] - arr[15] | arr[4] - arr[2] ^ arr[12] | arr[16]) < 510)
# ТО (arr[i] = arr[i - 1] | 48)
# ИНАЧЕ (arr[i] = arr[i] - 72)
  mv a5, a2             # a5 <- a2
  mv a6, a1             # a6 <- a1

  loop:

  ld t0, 16(a1)       # t0 <- arr[2]
  ld t1, 32(a1)       # t1 <- arr[4]
  ld t2, 96(a1)       # t2 <- arr[12]
  ld t3, 120(a1)      # t3 <- arr[15]
  ld t4, 128(a1)      # t4 <- arr[16]
  ld t5, 152(a1)      # t4 <- arr[19]
  sub a3, t5, t3      # a3 <- arr19 - arr15
  sub a4, t1, t0      # a4 <- arr4 - arr2
  xor a4, a4, t2      # a4 <- a4 ^ arr12
  or a3, a3, a4       # a3 <- a3 | a4
  or a3, a3, t4       # a3 <- a3 | t16

                      # a3 is to be compared
  li a4, 510          # a4 <- 510

  blt a3, a4, success_cond

  failed_cond:          # else:
  ld a7, 0(a6)          # a7 <- arr[i]
  addi a7, a7, -72      # a7 = a7 - 72
  sd a7, 0(a6)          # a7 -> arr[i]

  addi a6, a6, 8        # next array element

  j final               

  success_cond:
  beq a6, a1, first_element
  ld a7, -8(a6)         # a7 <- arr[i-1]
  j success_procedure

  first_element:
  li a7, 0

  success_procedure:
  ori a7, a7, 48      # a7 = a7 | 48
  sd a7, 0(a6)        # a7 -> arr[i]
  addi a6, a6, 8      # next array element

  final:
  addi a5, a5, -1       # a5 -= 1
  bgtz a5, loop         # if a5 > 0 repeat loop

  ret 
