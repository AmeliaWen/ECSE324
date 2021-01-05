//part2-2
.global _start
_start:
	.equ HEX_0_3, 0xff200020
	.equ HEX_4_5, 0xff200030
	.equ TIM_P, 0xfffec600
	.equ PB_EDGE, 0xff20005c
	mov r0, #0
	ldr r2, =TIM_P
	mov r1, #6
	//tst r11, #2
	str r1, [r2, #8]
	mov r2, #0
	mov r3, #0
	mov r4, #0
	mov r6, #0
	mov r7, #0
	mov r8, #0
	mov r9, #0
	mov r10, #0
	b loop 
loop:
	bl PB_edgecap_is_pressed_ASM
	tst r0, #1
	bleq ARM_TIM_clear_INT_ASM
	//mov r10, #0
	blne switch
	bl ARM_TIM_read_INT_ASM
	tst r0, #1
	blne count
	tst r0, #1
	//movne r6, #1
	blne ARM_TIM_clear_INT_ASM
	b loop
count:
	push {lr}
	//cmp r5, #15
	add r6, r6, #1
	//cmp r5, #10
	//movgt r5, #0
	//movlt r12, #1
	//cmp r5, #10
	//push {lr}
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
	//push {r5}
	//cmp r5, #10
	//addlt r5, r6, #0
	cmp r7, #10
	addge r4, r4, #1
	cmp r7, #10
	subge r7, #10
	cmp r7, #10
	bge last_digit
	//cmp r5, #100
	//subge r5, r5, #100
	//cmp r5, #100
	//cmpgt r4, #0
	//addeq r3, r3, #1
	//cmp r5, #100
	//bge last_digit
	cmp r5, #10
	addeq r7, r7, #1
	cmp r5, #10
	subge r5, r5, #10
	cmp r5, #10
	bge last_digit
	//cmp r5, #10
	//subge r5, r5, #10
	//cmp r5, #0
	//addeq r7, r7, #1
	//cmp r5, #10
	//bge last_digit
	//bl last_digit
	//pop {lr}
	//add r5, r6, #1
	add r0, r5, #0
	mov r1, #1
	bl HEX_write_ASM
	add r0, r7, #0
	mov r1, #2
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
	mov r1, #0
	//cmp r5, #100
	//m//ov r4, #10
	//udiv r5, r5, r4
	//movlt r5, #100 mod 10
	//mov r3, r5 mod 10
	pop {lr}
	bx lr
switch:
	push {r1,r2,r5, r12, lr}
	ldr r2, =TIM_P
	tst r1, #1
	//blne ARM_TIM_read_INT_ASM
	blne ARM_TIM_config_ASM
	//movne r1, #7
	//strne r1, [r2, #8]
	tst r1, #2
	blne disable_timer
	//movne r1, #6
	//tst r11, #2
	//strne r1, [r2, #8]
	//movne r1, #2
	tst r1, #4
	blne disable_timer
	//movne r1, #6
	//tst r11, #4
	//strne r1, [r2, #8]
	//tst r11, #4
	
	//tst r11, #4
	movne r0, #0
	//tst r11, #4
	movne r1, #63
	//tst r11, #4
	blne HEX_write_ASM
	//tst r11, #4
	//movne r1, #7
	//tst r11, #4
	blne ARM_TIM_config_ASM
	//movne r6, #0
	movne r5, #0
	movne r3, #0
	movne r4, #0
	movne r6, #0
	movne r7, #0
	movne r8, #0
	movne r9, #0
	//strne r1, [r4, #8]
	//blne ARM_TIM_clear_INT_ASM
	pop {r1,r2 ,r5, r12, lr}
	bx lr
disable_timer: 
	push {r1, r2}
	mov r1, #6
	ldr r2, =TIM_P
	str r1, [r2, #8]
	pop {r1, r2}
	bx lr
ARM_TIM_config_ASM:
	push {r1, r2,r4,  lr}
	ldr r4, =TIM_P
	LDR R2, =#500000
	STR R2, [R4]
	mov r1, #7
	str r1, [r4, #8]
	pop {r1, r2,r4,  lr}
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
	//and r2, r2, r8
	cmp r1, #0
	movgt r0, #1
	pop {r3, r2,r12}
	bx lr
/*PB_edgecap_is_pressed_ASM:
	push {r1, r2 , lr}
	ldr r1, =PB_EDGE
	ldr r11, [r1]
	str r11, [r1]
	//and r2, r2, r8
	cmp r11, #0
	movne r10, #1
	pop {r1, r2, lr}
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


WRITE:		   //CMP R12, #16			//checking if in hex0 base or hex 4 base
				//MOVGe R2, R3
				LDR R7, [R2]
				TST R12, #1
				ANDNE R7, R7, #0xFFFFFF00
				ADDNE R7, R7, R6, LSL #0
				STRNE R7, [R2]	
				TST R12, #2						
				ANDNE R7, R7, #0xFFFF00FF 
				ADDNE R7, R7, R6, LSL #8
				STRNE R7, [R2]	
				TST R12, #4					
				ANDNE R7, R7, #0xFF00FFFF	
				ADDNE R7, R7, R6, LSL #16
				STRNE R7, [R2]	
				TST R12, #8					
				ANDNE R7, R7, #0x00FFFFFF
				ADDNE R7, R7, R6, LSL #24
				STRNE R7, [R2]
				
				TST R12, #16
				//MOVNE R2, R3
				LDR R7, [R3]
				ANDNE R7, R7, #0xFFFFFF00	
				ADDNE R7, R7, R6, LSL #0
				STRNE R7, [R3]	
				TST R12, #32
				//MOVNE R2, R3
				ldr r7, [r3]
				ANDNE R7, R7, #0xFFFF00FF
				ADDNE R7, R7, R6, LSL #8
				STRNE R7, [R3]	

				//STR R7, [R2]		//load contents from register of which hexbase is being used




Exit_write:	  POP {R1-r7}
				BX LR*/
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
				STRNE R7, [R3]
				TST R1, #32	
				LDRNE R7, [R3]
				ANDNE R7, R7, #0xFFFF00FF
				ADDNE R7, R7, R6, LSL #8 
				STRNE R7, [R3]

				//STR R7, [R2]		//load contents from register of which hexbase is being used

Exit_write:	  POP {R1-r7}
				BX LR
end:
	b end
	