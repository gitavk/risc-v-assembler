.globl solution
solution:
# =============================================================================
# Task:
#   Y0 = (X1 ^ (X1 | X1))  -->  simplifies to 0  (X1 ^ X1 = 0 always)
#   Y1 = (X1 & X1) | X1    -->  simplifies to X1
#   Y2..Y7 = 0              (not specified, stay off)
#
# Why the simplifications work:
#   Y0: (X1 | X1) = X1, so X1 ^ X1 = 0 for any value of X1
#   Y1: (X1 & X1) = X1, so X1 | X1 = X1
#
# Register conventions (same as example):
#   a0, a1 - arguments for helper functions
#   s8     - constant 8 (number of buttons/LEDs)
#   s9     - loop counter
#   s10    - bitmask of all 8 button states (bit i = Xi)
#   s11    - bitmask of all 8 LED states   (bit i = Yi)
# =============================================================================

li s8, 2                    # s8 = 2 - total number of buttons and LEDs in this task

# Dummy reads: let button states propagate before the first real read.
li a0, 0
call get_button_status
li a0, 0
call get_button_status

# ---- Start of the active-wait (polling) loop --------------------------------
init:

mv s9, zero                 # s9 = 0 - reset loop counter
mv s10, zero                # s10 = 0 - clear button bitmask
mv s11, zero                # s11 = 0 - clear LED bitmask

# ---- Phase 1: Read all 8 button states into s10 ----------------------------
# We call get_button_status(i) for i = 0..7.
# Each call returns 0 or 1 in a0. We shift that bit to position i
# and OR it into s10, building a bitmask where bit i = state of button i.
loop_bt:

mv a0, s9                   # a0 = button number (0..7)
call get_button_status      # a0 = get_button_status(s9) - returns 0 or 1

sll t0, a0, s9              # t0 = result << s9  (shift bit to correct position)
or s10, s10, t0             # s10 |= t0  (accumulate into bitmask)

addi s9, s9, 1              # s9++ - move to next button
blt s9, s8, loop_bt         # if s9 < 8, read the next button

# ---- Phase 2: Compute LED expressions from button bitmask ------------------

# Y0 = 0 - always off, nothing to compute.
# s11 stays 0 at bit 0.

# Y1 = X1:
# Extract bit 1 from s10 (the state of button 1)
# and place it at bit position 1 in s11.
srli t0, s10, 1             # t0 = s10 >> 1  (move bit 1 into bit 0)
andi t0, t0, 1              # t0 &= 1  (isolate that single bit)
slli t0, t0, 1              # t0 <<= 1  (shift back to bit position 1)
or s11, s11, t0             # s11 |= t0  (store Y1 in the LED bitmask)

# Y2..Y7 = 0 - no action needed, s11 bits 2-7 are already 0.

# ---- Phase 3: Write all 8 LED states from s11 ------------------------------
# We iterate over LEDs 0..7. For each LED we extract the lowest bit of t0
# (which we shift right each iteration) and pass it to set_led_status.
mv s9, zero                 # s9 = 0 - reset loop counter
mv t0, s11                  # t0 = copy of LED bitmask (we'll shift through it)

loop_leds:

mv a0, s9                   # a0 = LED number (0..7)
andi a1, t0, 1              # a1 = lowest bit of t0 (this LED's state)
call set_led_status         # set_led_status(led_number, led_state)
addi s9, s9, 1              # s9++ - next LED
srli t0, t0, 1              # t0 >>= 1  (bring next LED's bit into position 0)
blt s9, s8, loop_leds       # if s9 < 8, set the next LED

# ---- Phase 4: Delay and repeat ---------------------------------------------
call delay                  # wait before the next polling cycle

j init                      # jump back - infinite active-wait loop
