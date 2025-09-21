default:
	b16 -a main.asm build/os.bin
run:
	b16 -ar main.asm build/os.bin
dump:
	b16 -ar main.asm build/os.bin --dump
debug: dump # alias
