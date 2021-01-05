.global _start
_start:
	mov r0, #0
	ldr r1, [r0, #0x110]
    add r1, r1, #7
    str r1, [r0]
loop:
	b loop
	