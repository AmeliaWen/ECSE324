.global _start
_start:
	.equ HEX_0_3, 0xff200020
	.equ HEX_4_5, 0xff200030
	.equ PB_BASE, 0xff200050
	.equ PB_EDGE, 0xff20005c
	.equ PB_INT, 0xff200058
	.equ SW_MEMORY, 0xFF200040
	.equ LED_MEMORY, 0xFF200000
	mov r0, #2
	mov r1, #2
	mov r2, #0
	mov r3, #0
	mov r4, #0
	mov r6, #0
	mov r7, #0
	mov r8, #0
	mov r9, #0
	//mov r0, #0x00000030
	//push {lr}
	//bl HEX_flood_ASM
	//pop {lr}
	mov r0, #0x0000000f
	//push {lr}
	bl HEX_clear_ASM
	//pop {lr}
	//push {lr}
loop: 
	bl read_slider_switches_ASM
	bl write_LEDs_ASM
	cmp r0, #512
	movlt r0, #0x00000030
	bllt HEX_flood_ASM
	bl read_slider_switches_ASM
	bl write_LEDs_ASM
	cmp r0, #512
	movge r0, #0x0000003f
	blge HEX_clear_ASM
	//add r9, r8, #0
	//bl PB_clear_edgecp_ASM
	//mov r12, #15
	//bl enable_PB_INT_ASM
	//bl read_PB_edgecp_ASM
	//add r0, r8, #0
	//bl HEX_clear_ASM
	//mov r12, #15
	//sub r12, r12, r8
	//cmp r8, r9
	//mov r12, #0
	//bl read_PB_data_ASM
	//cmp r8, r9
	//sublt r12, r8, r9
	
	//cmp r0, #512
	//movlt r0, #0x00000030
	//bllt HEX_flood_ASM
	//movge r0, #0x0000003f
	//blge HEX_clear_ASM
	
	//add r0, r8, #0
	bl PB_edgecap_is_pressed_ASM
	//bl read_PB_edgecp_ASM
	cmp r0, #1
	push {r3}
	//bleq read_PB_edgecp_ASM
	//bleq read_PB_edgecp_ASM
	bleq read_slider_switches_ASM
	bleq write_LEDs_ASM
	pop {r3}
	bleq HEX_write_ASM
	bleq PB_clear_edgecp_ASM
	moveq r0, #0
	b loop
read_slider_switches_ASM:
	//push {r1}
    LDR R3, =SW_MEMORY
    LDR R0, [R3]
	//pop {r1}
    BX  LR
write_LEDs_ASM:
	//push {r1}
    LDR R3, =LED_MEMORY
    STR R0, [R3]
	//pop {r1}
    BX  LR
HEX_clear_ASM: 
	push {R1-r7}
	ldr r1, =HEX_0_3
	ldr r2, =HEX_4_5
	mov r3, #1
	//mov r5, #0
//clear_loop: 
	//cmp r5, #5
	//beq clear_done
	//tst r0, r3
	//bne clear 
	//b end_clear
	//and r4, r0, #1
	//cmp r4, #1
	//bleq clear
	//lsr r0, r0, #1
	//add r3, r3, #1
	//b clear_loop
clear: 
	//CMP R5, #3			//checking if in hex0 base or hex 4 base
				//MOVGT R1, R2		//give R1 hexbase4 so above code works
				LDR R7, [R1]
				TST R0, #1
				ANDNE R7, R7, #0xFFFFFF00
				STRNE R7, [R1]	
				TST R0, #2						
				ANDNE R7, R7, #0xFFFF00FF
				STRNE R7, [R1]	
				TST R0, #4					
				ANDNE R7, R7, #0xFF00FFFF
				STRNE R7, [R1]	
				TST R0, #8					
				ANDNE R7, R7, #0x00FFFFFF
				STRNE R7, [R1]	
				TST R0, #16
				LDRNE R7, [R2]
				ANDNE R7, R7, #0xFFFFFF00
				STRNE R7, [R2]
				TST R0, #32	
				LDRNE R7, [R2]
				ANDNE R7, R7, #0xFFFF00FF  			
                STRNE R7, [R2]	
	//push {r5, r6}
	//cmp r3, #3 
	//subgt r3, r3, #4
	/*ldr r2, [r1]
	ldr r5, =CLEAR_N
	lsl r6, r3, #2
	ldr r5, [r5, r6]
	and r2, r2, r5
	str r2, [r1]
	pop {r5, r6}
	bx lr*/
//end_clear:
	//lsl r3, #1
	//add r5, r5, #1
	//b clear_done
clear_done:
	pop {r1-r7}
	bx lr
HEX_flood_ASM: 
	push {R1-r7}
	ldr r1, =HEX_0_3
	ldr r2, =HEX_4_5
	mov r3, #1
	mov r5, #0
	add r4, r0, #0
	//mov r5, #1
//flood_loop: 
	//cmp r5, #5
	//bgt flood_done
	//tst r4, r3
	//bne flood
	//b end_flood
	//and r4, r0, #1
	//cmp r4, #1
	//bleq flood
	//lsr r0, r0, #1
	//add r3, r3, #1
	//b flood_loop
flood: 
	//push {r5, r6}
	//cmp r5, #3
	//movgt r1, r2
	ldr r7, [r1]
	//cmp r3, #3 
	//subgt r3, r3, #4
	TST R4, #1
	ORRNE R7, R7, #0x000000FF
	STRNE R7, [R1]	
	TST R4, #2						
	ORRNE R7, R7, #0x0000FF00
	STRNE R7, [R1]	
	TST R4, #4					
	ORRNE R7, R7, #0x00FF0000
	STRNE R7, [R1]	
	TST R4, #8					
	ORRNE R7, R7, #0xFF000000
	STRNE R7, [R1]	
	TST R4, #16
	LDRNE R7, [R2]
	ORRNE R7, R7, #0x000000FF
	STRNE R7, [R2]	
	TST R4, #32		
	LDRNE R7, [R2]
	ORRNE R7, R7, #0x0000FF00  
	strne r7, [r2]
	/*ldr r2, [r1]
	ldr r5, =FLOOD_N
	lsl r6, r3, #2
	ldr r5, [r5, r6]
	orr r2, r2, r5
	str r2, [r1]
	pop {r5, r6}
	bx lr*/
//end_flood: 
	//lsl r3, #1
	//add r5, r5, #1
	//b flood_loop
flood_done:
	pop {r1-r7}
	bx lr
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
	
read_PB_data_ASM:
	push {r2}
	ldr r2, =PB_BASE
	ldr r0, [r2]
	pop {r2}
	bx lr
PB_data_is_pressed_ASM:
	push {r1, r2}
	ldr r3, =PB_BASE
	ldr r2, [r1]
	tst r2, r11
	//cmp  r9, r2
	moveq r9, #0
	movne r9, #1
	pop {r1, r2}
	bx lr 
read_PB_edgecp_ASM:
	push {r2}
	ldr r2, =PB_EDGE
	ldr r1, [r2]
	str r1, [r2]
	pop {r2}
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
PB_clear_edgecp_ASM:
	push {r1, r2}
	ldr r1, =PB_EDGE
	//mov r10, #
	mov r2, #1
	str r2, [r1]
	pop {r1, r2}
	bx lr
enable_PB_INT_ASM:
	push {r1, r2}
	ldr r1, =PB_INT
	mov r2, #0x3
	str r2, [r1, #0x8]
	pop {r1, r2}
	bx lr

disable_PB_INT_ASM:
	push {r1, r2}
	ldr r1, =PB_INT
	mov r2, #0x3
	str r2, [r1, #0x8]
	pop {r1, r2}
	bx lr 
end: 
b end

