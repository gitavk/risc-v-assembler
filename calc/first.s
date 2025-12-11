.globl solution
solution:
  # a4 | (a2 | (a2 - a4)) * a3 & a4
  sub t0, a2, a4
  or t1, a2, t0
  mul t2, t1, a3
  and t3, t2, a4
  or a0, a4, t3
  
  ret
