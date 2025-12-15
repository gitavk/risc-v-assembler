.globl solution
solution: 
  # Формула для вычислений будет выведена ниже (arr[i] - элемент массива, считаем что arr[-1] == 0):
  # ЕСЛИ ((arr[1] | arr[4] & arr[8]) > 475)
  # ТО (arr[i] = arr[i - 1] | 32)
  # ИНАЧЕ (arr[i] = arr[i] | 63)
  # a1 - array address
  # a2 - number of elements
  mv a5, a2             # a5 <- a2
  mv a6, a1             # a6 <- a1

  loop:

  ld a3, 32(a1)         # a3 <- arr[4]
  ld a4, 64(a1)         # a4 <- arr[8]
  and a3, a3, a4        # a3 <- a3 & a4
  ld a4, 8(a1)         # a4 <- arr[1]
  or a3, a4, a3        # a3 <- a3 | a4
                        # a3 is to be compared
  li a4, 475            # a4 <- 475

  blt a4, a3, success_cond  # if a4 < a3: goto success

  failed_cond:          # else:

  ld a7, 0(a6)          # a7 <- arr[i]
  or a7, a7, 63         # a7 = a7 | 63
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

  ori a7, a7, 32      # a7 = a7 ^ 32
  sd a7, 0(a6)        # a7 -> arr[i]
  addi a6, a6, 8      # next array element

  final:

  addi a5, a5, -1       # a5 -= 1
  bgtz a5, loop         # if a5 > 0 repeat loop

  ret 
