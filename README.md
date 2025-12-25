docker run --rm -it --entrypoint /bin/bash -v .:/code riscvcourse/workshop_risc-v

riscv64-unknown-linux-gnu-gcc -g main.s -nostdlib -static -o prog.x

qemu-riscv64 prog.x

### GDB:
#### run 
qemu-riscv64 -g 1111 ./prog.x &

### connect
riscv64-unknown-linux-gnu-gdb ./prog.x
target remote localhost:1111
