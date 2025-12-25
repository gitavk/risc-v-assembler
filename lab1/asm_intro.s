.globl solution
solution:
  # (a2 * (a4 & (a3 | (a3 - (a4 + (a2 * (a3 & a2)))))))
  and t0, a3, a2
  mul t0, a2, t0
  add t0, a4, t0
  sub t0, a3, t0
  or t0, a3, t0
  and t0, a4, t0
  mul a0, a2, t0
  # a0 = result
  ret

