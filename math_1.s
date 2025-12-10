.globl solution
solution:
    # a2 & (a4 | a2)
    # a0 = result
    add a0, x0, a2
    or a0, a0, a4
    and a0, a0, a2
    ret
