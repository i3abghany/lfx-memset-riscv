# lfx-memset-riscv

This repository contains my solution for the [Newlib Optimization RISC-V Mentorship](https://riscv.org/job/newlib-optimization-risc-v-mentorship/).

## Overview

The `memset_aligned` function defined in `memset.S` optimizes for the case where size is a multiple of 4 by setting 4 bytes at a time.

- Static code size is optimized by using a minimal number of instructions, and using compressed instruction (RISC-V C extension) where possible.
- `Zbkb` (Bit manipulation for Cryptography) extension instructions (`packh` and `packw`) are used to broadcast the byte value to a 32-bit word.
- The code adapts for `__riscv_misaligned_avoid` by first setting the misaligned bytes one by one, and then setting the aligned bytes 4 bytes at a time.
- Extensive functional testing of the implementation is done in `main.c` and emulated in the Spike RISC-V simulation.
- Some basic dynamic analysis is done using QEMU cache plugin.
- Dockerfile is provided for building, running, and testing the implementation in a containerized environment.

## Analysis

Here, I provide a brief analysis of the implementation.

### Static code size

Since newlib is commonly used on smaller devices, code size is a significant concern. The proposed implementation extensively uses compressed instructions (only 3 out of 15 instructions are not compressed). The following is the assembled version of the implementation produced by the RISC-V GCC toolchain, which amounts for 36 bytes of code size.

```asm
000000000001030c <memset_aligned>:
   1030c:	00367693          	andi	a3,a2,3
   10310:	8e15                	sub	a2,a2,a3
   10312:	08b5f5b3          	packh	a1,a1,a1
   10316:	08b5c5bb          	packw	a1,a1,a1
   1031a:	c689                	beqz	a3,10324 <memset_aligned+0x18>
   1031c:	890c                	sb	a1,0(a0)
   1031e:	16fd                	addi	a3,a3,-1
   10320:	0505                	addi	a0,a0,1
   10322:	feed                	bnez	a3,1031c <memset_aligned+0x10>
   10324:	c609                	beqz	a2,1032e <memset_aligned+0x22>
   10326:	c10c                	sw	a1,0(a0)
   10328:	1671                	addi	a2,a2,-4
   1032a:	0511                	addi	a0,a0,4
   1032c:	fe65                	bnez	a2,10324 <memset_aligned+0x18>
   1032e:	8082                	ret
```

### Dynamic Instruction Count

The QEMU cache plugin is used to count the number of executed instructions to compare the naive implementation to the optimized implementation. The following is the output of the QEMU cache plugin.

```bash
# run the naive implementation
$ make CFLAGS=-DNAIVE_IMPL exe
$ qemu-riscv64 -plugin /path/to/qemu/src/build/contrib/plugins/libcache.so -d plugin -D naive.log exe
$ head -n 2 naive.log

core #, data accesses, data misses, dmiss rate, insn accesses, insn misses, imiss rate
0       58479784       121             0.0002%  381302854      131             0.0000%
                                                ~~~~~~~~~

# run the optimized implementation
$ make clean; make exe
$ qemu-riscv64 -plugin /path/to/qemu/src/build/contrib/plugins/libcache.so -d plugin -D optimized.log exe
$ head -n 2 optimized.log

core #, data accesses, data misses, dmiss rate, insn accesses, insn misses, imiss rate
0       74199208       121             0.0002%  438910014      131             0.0000%
                                                ~~~~~~~~~
```

The optimized implementation executes 13% less instructions compared to the naive implementation.

## Build

Prerequisites:

- RISC-V GCC toolchain
- Spike RISC-V simulator
- RISC-V Proxy Kernel (pk)

```bash
$ sudo apt update
$ sudo apt install -y wget git build-essential

$ wget https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2024.03.01/riscv64-elf-ubuntu-22.04-gcc-nightly-2024.03.01-nightly.tar.gz
$ mkdir -p /home/$USER/opt/cross
$ tar -xvf riscv64-elf-ubuntu-22.04-gcc-nightly-2024.03.01-nightly.tar.gz -C /home/$USER/opt/cross --strip-components=1

# install spike prerequisites
$ sudo apt -y install device-tree-compiler libboost-regex-dev libboost-system-dev
$ git clone https://github.com/riscv-software-src/riscv-isa-sim.git spike
$ pushd spike
$ mkdir build && cd build && ../configure --prefix=/home/$USER/opt/cross
$ make -j$(nproc)
$ sudo make install
$ popd

# install pk

$ git clone https://github.com/riscv-software-src/riscv-pk
$ pushd riscv-pk
$ export PATH=$PATH:/home/$USER/opt/cross/bin
$ mkdir build && cd build && ../configure --prefix=/home/$USER/opt/cross --host=riscv64-unknown-elf
$ make -j$(nproc)
$ sudo make install
$ popd

# build the project
$ make exe

# run testing
$ make run
```

## Docker Build

To use docker to build and run the project, use the following commands.

```bash
$ docker build -t lfx-memset-riscv .
$ docker run -it lfx-memset-riscv
```

## Author

[Mahmoud Abumandour](i3abghany.github.io)
