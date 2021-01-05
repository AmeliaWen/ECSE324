.global _start
_start:
	.equ HEX_0_3, 0xff200020
	.equ HEX_4_5, 0xff200030
	.equ TIM_P, 0xfffec600
	mov r0, #0
	mov r3, #0
	bl ARM_TIM_config_ASM
	mov r5, #0
	mov r7, #0
	b loop 
loop:
	bl ARM_TIM_read_INT_ASM
	tst r0, #1
	//movne r0, #0
	blne count
	tst r0, #1
	//movne r6, #1
	blne ARM_TIM_clear_INT_ASM
	b loop
count:
	push {r0, r1, lr}
	cmp r5, #15
	addle r5, r5, #1
	cmp r5, #15
	movgt r5, #0
	mov r1, #1
	add r0, r5, #0
	bl HEX_write_ASM
	pop {r0, r1, lr}
	bx lr
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

	/*
CONFIG_INTERVAL_TIMER:
	LDR R0, =0xff202000
/* set the interval timer period for scrolling the LED displays */
	/*LDR R1, =#100000000
	STR R1, [R0, #0x8]
    LSR     R1, R1, #16
    STR     R1, [R0, #0xC]
    MOV     R1, #0x7
    STR     R1, [R0, #0x4]
    BX      LR
HPS_TIM_config_ASM:
	push {r3-r8, lr}
	add r3, r0, #0
	///and r3, r3, #0xf
	add r5, r1, #0
config:
	and r6, r3, #1
	cmp r6, #0
	ldrne r4, =TIM_0
	blne configure_loop
	subne r3, r3, #1
	and r6, r3, #2
	cmp r6, #0
	ldrne r4, =TIM_1
	blne configure_loop
	subne r3, r3, #2
	and r6, r3, #4
	cmp r6, #0
	ldrne r4, =TIM_2
	blne configure_loop
	subne r3, r3, #4
	and r6, r3, #8
	cmp r6, #0
	ldrne r4, =TIM_3
	blne configure_loop
	subne r3, r3, #8
	pop {r3-r8, lr}
	bx lr
	//b config_end
configure_loop:
	//push {r1}
	mov r8, #0
	str r8, [r4, #8]
	ldr r8, =100000000
	str r8, [r4]
	mov r8, #0b011
	str r8, [r0, #8]
	bx lr
config_loop:
	ldr r6, [r4, #8]
	and r6, r6, #0xFFFFFFFE
	str r6, [r4, #8]
	mov r7, #25
	mul r5, r5, r7
	cmp r0, #2
	lsllt r5, r5, #2
	str r5, [r4]
	//str r2, [r4, #8]
	ldr r5, [r4, #8]
	tst r2, #1
	movne r6,#1
	and r5, r5, #0xfffffffD
	orr r5, r5, r6
	str r5, [r4, #8]
	ldr r5, [r4, #8]
	tst r2, #2
	movne r6,#1
	and r5, r5, #0xfffffffB
	orr r5, r5, r6
	str r5, [r4, #8]
	ldr r5, [r4, #8]
	tst r2, #4
	movne r6,#1
	and r5, r5, #0xfffffffE
	orr r5, r5, r6
	str r5, [r4, #8]
	mov r7, #0
	str r7, [r4, #12]
	bx lr
config_end:
	pop {r3-r8}
	bx lr
HPS_TIM_read_INT_ASM:
	push {r3-r6, lr}
	add r3, r0, #0
	///and r3, r3, #0xf
	add r5, r1, #0
	and r6, r3, #1
	cmp r6, #0
	ldrne r4, =TIM_0
	blne read
	subne r3, r3, #1
	and r6, r3, #2
	cmp r6, #0
	ldrne r4, =TIM_1
	blne read
	subne r3, r3, #2
	and r6, r3, #4
	cmp r6, #0
	ldrne r4, =TIM_2
	blne read
	subne r3, r3, #4
	and r6, r3, #8
	cmp r6, #0
	ldrne r4, =TIM_3
	blne read
	subne r3, r3, #8
	b read_end
read:
	ldr r7, [r4, #12]
	bx lr
read_end:
	pop {r3-r6, lr}
	bx lr
HPS_TIM_clear_INT_ASM:
	push {r3-r6}
	add r3, r0, #0
	///and r3, r3, #0xf
	add r5, r1, #0
	and r6, r3, #1
	cmp r6, #0
	ldrne r4, =TIM_0
	ldrne r6, [r4, #12]
	subne r3, r3, #1
	and r6, r3, #2
	cmp r6, #0
	ldrne r4, =TIM_1
	ldrne r6, [r4, #12]
	subne r3, r3, #2
	and r6, r3, #4
	cmp r6, #0
	ldrne r4, =TIM_2
	ldrne r6, [r4, #12]
	subne r3, r3, #4
	and r6, r3, #8
	cmp r6, #0
	ldrne r4, =TIM_3
	ldrne r6, [r4, #12]
	subne r3, r3, #8
	b clear_end
clear_end:
	pop {r3-r6}
	bx lr*/
/*HEX_write_ASM:
	push {r1-r7}
	//ldr r1, [r0]
	ldr r2, =HEX_0_3
	//PUSH {R0-R12,LR}		//convention save states
	LDR R3, =HEX_4_5	//loading memory location for HEX4 and HEX5
	MOV R4, #1			//iterator to compare onehot encoded 
	MOV R6, #0			//number to write on the display
	//MOV R5, #0			//counter for which HEX to display
display_to_Hex:
	
				CMP 	R5, #0		//0
				MOVEQ	R6, #0x3F
	
				CMP 	R5, #1		//1
				MOVEQ	R6, #0x6

				CMP 	R5, #2		//2
				MOVEQ	R6, #0x5B

				CMP 	R5, #3		//3
				MOVEQ	R6, #0x4F

				CMP 	R5, #4		//4
				MOVEQ	R6, #0x66

				CMP 	R5, #5		//5
				MOVEQ	R6, #0x6D

				CMP 	R5, #6		//6
				MOVEQ	R6, #0x7D

				CMP 	R5, #7		// 7
				MOVEQ	R6, #0x7

				CMP 	R5, #8		// 8
				MOVEQ	R6, #0x7F

				CMP 	R5, #9		// 9
				MOVEQ	R6, #0x67

				CMP 	R5, #10		// A
				MOVEQ	R6, #0x77

				CMP 	R5, #11		// B
				MOVEQ	R6, #0x7C

				CMP 	R5, #12		// C
				MOVEQ	R6, #0x39

				CMP 	R5, #13		// D
				MOVEQ	R6, #0x5E
	
				CMP 	R5, #14		// E
				MOVEQ	R6, #0x79

				CMP 	R5, #15		// F
				MOVEQ	R6, #0x71


WRITE:			//CMP R8, #3			//checking if in hex0 base or hex 4 base
				//MOVGT R2, R3		//give R1 hexbase4 so above code works
				LDR R7, [R2]
				TST R12, #1
				ANDNE R7, R7, #0xFFFFFF00
				ADDNE R7, R7, R6, LSL #0		
				TST R12, #2						
				ANDNE R7, R7, #0xFFFF00FF 
				ADDNE R7, R7, R6, LSL #8	
				TST R12, #4					
				ANDNE R7, R7, #0xFF00FFFF	
				ADDNE R7, R7, R6, LSL #16	
				TST R12, #8					
				ANDNE R7, R7, #0x00FFFFFF
				ADDNE R7, R7, R6, LSL #24
				TST R12, #16
				ANDNE R7, R7, #0xFFFFFF00	
				ADDNE R7, R7, R6, LSL #0	
				TST R12, #32						
				ANDNE R7, R7, #0xFFFF00FF
				ADDNE R7, R7, R6, LSL #8  			

				STR R7, [R2]		//load contents from register of which hexbase is being used




Exit_write:	  POP {R1-r7}
				BX LR
end:
	b end*/
HEX_write_ASM:
	push {r1-r7}
	//ldr r1, [r0]
	ldr r2, =HEX_0_3
	//PUSH {R0-R12,LR}		//convention save states
	LDR R3, =HEX_4_5	//loading memory location for HEX4 and HEX5
	MOV R4, #1			//iterator to compare onehot encoded 
	MOV R6, #0			//number to write on the display
	//MOV R5, #0			//counter for which HEX to display
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

WRITE:			//CMP R8, #3			//checking if in hex0 base or hex 4 base
				//MOVGT R2, R3		//give R1 hexbase4 so above code works
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

				//STR R7, [R2]		//load contents from register of which hexbase is being used

Exit_write:	  POP {R1-r7}
				BX LR
	