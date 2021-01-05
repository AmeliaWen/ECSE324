.global _start
_start:
	.equ HEX_0_3, 0xff200020
	.equ HEX_4_5, 0xff200030
	.equ TIM_P, 0xfffec600
	mov r0, #0
	mov r3, #0
	mov r1, #7
	LDR R2, =#200000000
	bl ARM_TIM_config_ASM
	mov r5, #0
	mov r7, #0
	mov r0, #0
	mov r1, #1
	bl HEX_write_ASM
	b loop 
loop:
	bl ARM_TIM_read_INT_ASM
	tst r0, #1
	beq loop 
counter:
	cmp r5, #15
	subgt r5, #16
	cmp r5, #15
	bgt counter
	mov r1, #1
	add r0, r5, #0
	bl HEX_write_ASM
	bl ARM_TIM_clear_INT_ASM
	add r5, r5, #1
	b loop
ARM_TIM_config_ASM:
	push {r0, r2, lr}
	ldr r0, =TIM_P
	LDR R2, =#200000000
	STR R2, [R0]
	mov r1, #7
	str r1, [r0, #8]
	pop {r0, r2, lr}
	bx lr
ARM_TIM_read_INT_ASM:
	push {r4, r7, lr}
	ldr r4, =TIM_P
	ldr r7, [r4, #12]
	tst r7, #1
	movne r0, #1
	tst r7, #1
	moveq r0, #0
	pop {r4, r7, lr}
	bx lr
ARM_TIM_clear_INT_ASM:
	push {r4, r6, lr}
	ldr r4, =TIM_P
	mov r6, #1
	str r6, [r4, #12]
	pop {r4, r6, lr}
	bx lr
HEX_write_ASM:
	push {r1-r7}
	ldr r2, =HEX_0_3
	LDR R3, =HEX_4_5	
	MOV R4, #1			
	MOV R6, #0			
display_to_Hex:
	CMP 	R0, #0		//0
	MOVEQ	R6, #0x3F
	CMP 	R0, #1		//1
	MOVEQ	R6, #0x6
	CMP 	R0, #2		//2
	MOVEQ	R6, #0x5B
	CMP 	R0, #3		//3
	MOVEQ	R6, #0x4F
	CMP 	R0, #4		//4
	MOVEQ	R6, #0x66
	CMP 	R0, #5		//5
	MOVEQ	R6, #0x6D
	CMP 	R0, #6		//6
	MOVEQ	R6, #0x7D
	CMP 	R0, #7		// 7
	MOVEQ	R6, #0x7
	CMP 	R0, #8		// 8
	MOVEQ	R6, #0x7F
	CMP 	R0, #9		// 9
	MOVEQ	R6, #0x67
	CMP 	R0, #10		// A
	MOVEQ	R6, #0x77
	CMP 	R0, #11		// B
	MOVEQ	R6, #0x7C
	CMP 	R0, #12		// C
	MOVEQ	R6, #0x39
	CMP 	R0, #13		// D
	MOVEQ	R6, #0x5E
	CMP 	R0, #14		// E
	MOVEQ	R6, #0x79
	CMP 	R0, #15		// F
	MOVEQ	R6, #0x71
WRITE:			
	LDR R7, [R2]
	TST R1, #1
	ANDNE R7, R7, #0xFFFFFF00
	ADDNE R7, R7, R6, LSL #0
	STRNE R7, [R2]	
	TST R1, #2						
	ANDNE R7, R7, #0xFFFF00FF 
	ADDNE R7, R7, R6, LSL #8
	STRNE R7, [R2]	
	TST R1, #4					
	ANDNE R7, R7, #0xFF00FFFF	
	ADDNE R7, R7, R6, LSL #16
	STRNE R7, [R2]	
	TST R1, #8					
	ANDNE R7, R7, #0x00FFFFFF
	ADDNE R7, R7, R6, LSL #24
	STRNE R7, [R2]	
	TST R1, #16
	LDRNE R7, [R3]
	ANDNE R7, R7, #0xFFFFFF00	
	ADDNE R7, R7, R6, LSL #0	
	STRNE R7, [R2]
	TST R1, #32	
	LDRNE R7, [R3]
	ANDNE R7, R7, #0xFFFF00FF
	ADDNE R7, R7, R6, LSL #8 
	STRNE R7, [R2]
Exit_write:	  
	POP {R1-r7}
	BX LR
	