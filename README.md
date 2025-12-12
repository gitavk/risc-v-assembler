docker run --rm -it --entrypoint /bin/bash -v .:/code riscvcourse/workshop_risc-v

riscv64-unknown-linux-gnu-gcc -g main.s -nostdlib -static -o prog.x

qemu-riscv64 prog.x
