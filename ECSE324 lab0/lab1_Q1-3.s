.global _start
_start:
	mov r2, #0x110
	ldr r3, [r2]
    add r3, r3, #7
    str r3, [r2]
	