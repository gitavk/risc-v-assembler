.globl solution
solution: 
# Формула для вычислений будет выведена ниже (arr[i] - элемент массива, считаем что arr[-1] == 0):
# ЕСЛИ ((arr[3] | arr[6] & arr[3]) > 602)
# ТО (arr[i] = arr[i - 1] & 21)
# ИНАЧЕ (arr[i] = arr[i] ^ 16)
  mv a5, a2             # a5 <- a2
  mv a6, a1             # a6 <- a1

loop:
  ld t0, 24(a1)       # t0 <- arr[3]
  ld t1, 48(a1)       # t1 <- arr[6]
  and a3, t1, t0      # a3 <- arr6 & arr3
  or a3, t0, a3       # a3 <- arr3 | a3

  li a4, 620          # a4 <- 620

  blt a4, a3, success_cond

failed_cond:          # else:
  ld a7, 0(a6)        # a7 <- arr[i]
  xori a7, a7, 16     # a7 = a7 ^ 16
  sd a7, 0(a6)        # a7 -> arr[i]

  addi a6, a6, 8      # next array element

  j final               

success_cond:
  beq a6, a1, first_element
  ld a7, -8(a6)         # a7 <- arr[i-1]
  j success_procedure

first_element:
  li a7, 0

success_procedure:
  and a7, a7, 21      # a7 = a7 & 21
  sd a7, 0(a6)        # a7 -> arr[i]
  addi a6, a6, 8      # next array element

final:
  addi a5, a5, -1       # a5 -= 1
  bgtz a5, loop         # if a5 > 0 repeat loop

  ret 
