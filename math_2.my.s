.globl solution
solution:
    # a4 | (a2 | (a2 - a4)) * a3 & a4
    # a0 = result
    sub t0, a2, a4
    or t0, a2, t0
    mul t0, t0, a3
    and a0, t0, a4
    or a0, a4, t0
    ret
