.globl solution
solution:
  # a4 - a4 - a2 & a3 + (a4 + a4)
  # a0 = result
  add t0, a4, a4
  sub t1, a4, a4
  sub t1, t1, a2
  add t0, a3, t0
  and a0, t1, t0
  ret
