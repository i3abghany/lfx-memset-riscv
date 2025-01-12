run: exe
	spike --isa=rv64gcv_zba_zbb_zbc_zbs_zbkb_zcb pk ./exe

exe: main.c memset.S expect.h
	riscv64-unknown-elf-gcc -march=rv64gcv_zba_zbb_zbc_zbs_zbkb_zcb main.c memset.S -o exe -ggdb -Os

clean:
	rm -f exe

.PHONY: run clean