.globl solution
solution:
  # a2 ^ a2 & a2 & a4 | a2 | a4
    and t0, a2, a2
    and t1, t0, a4
    xor t2, a2, t1
    or t3, t2, a2
    or a0, t3, a4
    
    ret
