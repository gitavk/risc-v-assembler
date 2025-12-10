CC = riscv64-unknown-linux-gnu-gcc
CFLAGS = -g
ASMFLAGS = -Wa,-alms=main.lst
LDFLAGS = -Wl,-Map=main.map -nostdlib -nostartfiles

.PHONY: all, clean
all: main
main: main.s
  $(CC) $(CFLAGS) $(ASMFLAGS) $(LDFLAGS) $^ -o $@

clean:
  $(RM) main main.o main.lst main.map
