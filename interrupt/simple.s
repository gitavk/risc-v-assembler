# ============================================================
# Task: implement an interrupt handler that computes
#       (c | (a - b))
#
# Listener table layout (each row is 10 bytes):
#   Row 0 (header):
#     [0..5]  — unused (6 bytes)
#     [6..9]  — number of rows N, excluding header (4 bytes)
#   Row i (i = 1..N):
#     [0..7]  — handler address (8 bytes, doubleword)
#     [8..9]  — call counter    (2 bytes, halfword)
#
# Arguments a, b, c are labels pointing to signed 64-bit
# values in memory.
# Result is returned in register a0 (64-bit).
# ============================================================

.text

.globl load
.globl unload

# ----------------------------------------------------------
# on_event — interrupt handler
# Step 1: increment our call counter in the table
# Step 2: compute (c | (a - b)), return result in a0
# ----------------------------------------------------------
on_event:

    # === Step 1: update call counter ===
    # We saved our row number in variable "n" during load.
    # Row address = listener_table + n * 10
    # The 2-byte counter sits at offset +8 within that row.

    la a0, listener_table   # a0 <- base address of the table
    la a1, n                # a1 <- address of variable n
    lw a1, 0(a1)            # a1 <- value of n (our row number)
    li a2, 10               # a2 <- 10 (row size in bytes)
    mul a1, a1, a2          # a1 <- n * 10 (byte offset of our row)
    add a1, a1, a0          # a1 <- absolute address of our row
    lh a2, 8(a1)            # a2 <- current call count (halfword at +8)
    addi a2, a2, 1          # a2++
    sh a2, 8(a1)            # store updated counter back

    # === Step 2: compute (c | (a - b)) ===
    # Labels a, b, c hold addresses; we dereference them
    # with ld (load doubleword) to get 64-bit signed values.

    la a0, a
    la a1, b
    la a2, c
    ld a0, 0(a0)            # a0 <- value of a
    ld a1, 0(a1)            # a1 <- value of b
    ld a2, 0(a2)            # a2 <- value of c

    sub a1, a0, a1          # a1 <- a - b
    or  a0, a2, a1          # a0 <- c | (a - b)  — final result

    ret


# ----------------------------------------------------------
# load — register on_event in the listener table
#
# Algorithm:
#   1. Read current row count N from header at offset +6
#   2. Increment N, write it back to header
#   3. Save N into variable "n" so on_event can find its row
#   4. Compute new row address: table_base + N * 10
#   5. Store on_event address (sd — 8 bytes)
#   6. Zero out call counter (sh — 2 bytes)
# ----------------------------------------------------------
load:
    la a5, listener_table   # a5 <- base address of the table
    lw a4, 6(a5)            # a4 <- N (current row count from header)
    addiw a4, a4, 1         # a4 <- N + 1
    sw a4, 6(a5)            # write new count back to header

    la a6, n
    sw a4, 0(a6)            # save our row number into variable n

    li a6, 10               # row size is 10 bytes
    mul a4, a4, a6          # byte offset of our new row
    add a5, a5, a4          # a5 <- address of our new row

    la a4, on_event
    sd a4, 0(a5)            # store handler address (8 bytes)
    sh zero, 8(a5)          # zero out call counter (2 bytes)

    ret


# ----------------------------------------------------------
# unload — remove our handler from the table
#
# Since we always append to the end, removing means
# simply decrementing the row count N by 1.
# ----------------------------------------------------------
unload:
    la a5, listener_table
    lw a4, 6(a5)            # a4 <- N (current row count)
    addiw a4, a4, -1        # a4 <- N - 1
    sw a4, 6(a5)            # write decremented count back

    ret


.data

# Our row number in the table, saved during load
# so on_event can locate its counter.
# .zero 4 allocates 4 zero-initialized bytes (one word).
n: .zero 4
