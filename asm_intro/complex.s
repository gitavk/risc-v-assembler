.globl solution
solution:
  # (a3 >> (a2 << (-a4))) ^ (a2 - a2) + a3
  # a0 = result
  sub t0, x0, a4
  sll t0, a2, t0
  srl t0, a3, t0
  sub t1, a2, a2
  add t1, t1, a3
  xor a0, t0, t1
  ret
