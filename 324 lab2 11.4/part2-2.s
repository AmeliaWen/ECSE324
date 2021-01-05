
.global _start
_start:
	.equ HEX_0_3, 0xff200020
	.equ HEX_4_5, 0xff200030
	.equ TIM_P, 0xfffec600
	.equ PB_EDGE, 0xff20005c
	mov r0, #0
	ldr r2, =TIM_P
	mov r1, #6
	str r1, [r2, #8]
	mov r2, #0
	mov r3, #0
	mov r4, #0
	mov r6, #0
	mov r7, #0
	mov r8, #0
	mov r9, #0
	mov r10, #0
	mov r0, #0
	mov r1, #63
	bl HEX_write_ASM
	b loop 
loop:
	bl PB_edgecap_is_pressed_ASM
	ldr r2, =TIM_P
	tst r1, #1
	movne r1, #3
	blne ARM_TIM_config_ASM
	blne PB_clear_edgecp_ASM
	movne r1, #1
	tst r1, #2
	blne disable_timer
	tst r1, #4
	blne disable_timer
	movne r0, #0
	movne r1, #63
	blne HEX_write_ASM
	blne disable_timer
	movne r5, #0
	movne r3, #0
	movne r4, #0
	movne r6, #0
	movne r7, #0
	movne r8, #0
	movne r9, #0
count:
	bl ARM_TIM_read_INT_ASM
	tst r0, #1
	beq loop
	bl ARM_TIM_clear_INT_ASM
	add r0, r5, #0
	mov r1, #1
	bl HEX_write_ASM
	add r0, r4, #0
	mov r1, #4
	bl HEX_write_ASM
	add r0, r3, #0
	mov r1, #8
	bl HEX_write_ASM
	add r0, r8, #0
	mov r1, #16
	bl HEX_write_ASM
	add r0, r9, #0
	mov r1, #32
	bl HEX_write_ASM
	add r6, r6, #1
	add r5, r6, #0
last_digit:
	cmp r8, #10
	addge r9, r9, #1
	cmp r8, #10
	subge r8, #10
	cmp r8, #10
	bge last_digit
	cmp r3, #6
	addge r8, r8, #1
	cmp r3, #6
	subge r3, #6
	cmp r3, #6
	bge last_digit
	cmp r4, #10
	addge r3, r3, #1
	cmp r4, #10
	subge r4, #10
	cmp r4, #10
	bge last_digit
	cmp r7, #10
	addge r4, r4, #1
	cmp r7, #10
	subge r7, #10
	cmp r7, #10
	bge last_digit
	add r0, r7, #0
	mov r1, #2
	bl HEX_write_ASM
	cmp r5, #10
	addeq r7, r7, #1
	cmp r5, #10
	subge r5, r5, #10
	cmp r5, #10
	bge last_digit
	
	mov r1, #0
	b loop
disable_timer: 
	push {r1, r2}
	mov r1, #6
	ldr r2, =TIM_P
	str r1, [r2, #8]
	pop {r1, r2}
	bx lr

ARM_TIM_config_ASM:
	push {r2,r4,  lr}
	ldr r4, =TIM_P
	LDR R2, =2000000
	STR R2, [R4]
	//MOV R1, #3 
	str r1, [r4, #8]
	pop {r2,r4,  lr}
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
PB_edgecap_is_pressed_ASM:
	push {r3, r2,r12 }
	ldr r3, =PB_EDGE
	ldr r1, [r3]
	str r1, [r3]
	cmp r1, #0
	movgt r0, #1
	pop {r3, r2,r12}
	bx lr
PB_clear_edgecp_ASM:
	PUSH {R1,r8}
	LDR R1, =PB_EDGE
	mov r8, #0xFFFFFFFF
    STR R8, [R1]
	POP {R1, r8}
    BX  LR
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
	STRNE R7, [R3]
	TST R1, #32	
	LDRNE R7, [R3]
	ANDNE R7, R7, #0xFFFF00FF
	ADDNE R7, R7, R6, LSL #8 
	STRNE R7, [R3]
Exit_write:	  
	POP {R1-r7}
	BX LR
end:
	b end
	