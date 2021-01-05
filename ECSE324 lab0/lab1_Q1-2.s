.global _start
_start:
	mov r0, #0x110
	ldr r1, [r0]
    add r1, r1, #7
    str r1, [r0]
	