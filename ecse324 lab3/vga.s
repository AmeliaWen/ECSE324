.global _start
.equ PIXEL_buffer, 0xC8000000
	.equ CHARACTER_buffer, 0xC9000000
_start:
        bl      draw_test_screen
end:
        b       end

@ TODO: Insert VGA driver functions here.
VGA_clear_pixelbuff_ASM:
	PUSH {R0-R8,LR}
	MOV R0, #300 			
	ADD R0, R0, #19				
	MOV R1, #239			
	MOV R8, R1				
	LDR R2, =PIXEL_buffer	
	MOV R3, #0		
LOOP_OUTER:
		CMP R0, #0
		BLT END_CLEAR 		
		MOV R1, R8			
LOOP_INNER:
		CMP R1, #0			
		SUBLT R0, R0, #1		
		BLT LOOP_OUTER	
		mov r2, r3
		bl VGA_draw_point_ASM	
		SUB R1, R1, #1 		
		B LOOP_INNER
END_CLEAR: 
	POP {R0-R8,LR}			
	BX LR 					

VGA_write_char_ASM:

	PUSH {R0-R5, LR}			
	LDR R5, =CHARACTER_buffer	

	CMP R0, #79				
	BGT END_WRITE_CHAR
	CMP R0, #0
	BLT END_WRITE_CHAR
	CMP R1, #59				
	BGT END_WRITE_CHAR
	CMP R1, #0
	BLT END_WRITE_CHAR

	MOV R4, R1			
	lsl R4, #7			
	ORR R4, R5			
	ORR R4, R0 			
	STRB R2, [R4]		
END_WRITE_CHAR:
	POP {R0-R5, LR}		
	BX LR	 			
VGA_clear_charbuff_ASM:
	
	PUSH {R0-R8,LR}				
	MOV R0, #79 				
	MOV R1, #59					
	MOV R8, R1					
	LDR R2, =CHARACTER_buffer	
	mov r3, #0			

CHAR_LOOP_OUTER:
	CMP R0, #0
	BLT CHAR_END_CLEAR 	
	MOV R1, R8			

CHAR_LOOP_INNER:
	CMP R1, #0			
	SUBLT R0, R0, #1	
	BLT CHAR_LOOP_OUTER		
	mov r2, r3
	bl VGA_write_char_ASM
	B CHAR_LOOP_INNER

CHAR_END_CLEAR: 
	POP {R0-R8,LR}			
	BX LR 					
VGA_draw_point_ASM:

	PUSH {R0-R6, LR}
	LDR R5, =PIXEL_buffer

	MOV R3, #300 			
	ADD R3, R3, #19				
	CMP R0, R3				
	BGT END_DRAW_POINT
	CMP R0, #0 
	BLT END_DRAW_POINT
	CMP R1, #239			
	BGT END_DRAW_POINT
	CMP R1, #0
	BLT END_DRAW_POINT

	MOV R4, R1	
	lsl r4, #10
	ORR R4, R5			
	MOV R6, R0 			
	LSL R6, #1			
	ORR R4, R6 			
	STRH R2, [R4]		

END_DRAW_POINT:
	POP {R0-R6, LR}		
	BX LR				

draw_test_screen:
        push    {r4, r5, r6, r7, r8, r9, r10, lr}
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r6, #0
        ldr     r10, .draw_test_screen_L8
        ldr     r9, .draw_test_screen_L8+4
        ldr     r8, .draw_test_screen_L8+8
        b       .draw_test_screen_L2
.draw_test_screen_L7:
        add     r6, r6, #1
        cmp     r6, #320
        beq     .draw_test_screen_L4
.draw_test_screen_L2:
        smull   r3, r7, r10, r6
        asr     r3, r6, #31
        rsb     r7, r3, r7, asr #2
        lsl     r7, r7, #5
        lsl     r5, r6, #5
        mov     r4, #0
.draw_test_screen_L3:
        smull   r3, r2, r9, r5
        add     r3, r2, r5
        asr     r2, r5, #31
        rsb     r2, r2, r3, asr #9
        orr     r2, r7, r2, lsl #11
        lsl     r3, r4, #5
        smull   r0, r1, r8, r3
        add     r1, r1, r3
        asr     r3, r3, #31
        rsb     r3, r3, r1, asr #7
        orr     r2, r2, r3
        mov     r1, r4
        mov     r0, r6
        bl      VGA_draw_point_ASM
        add     r4, r4, #1
        add     r5, r5, #32
        cmp     r4, #240
        bne     .draw_test_screen_L3
        b       .draw_test_screen_L7
.draw_test_screen_L4:
        mov     r2, #72
        mov     r1, #5
        mov     r0, #20
        bl      VGA_write_char_ASM
        mov     r2, #101
        mov     r1, #5
        mov     r0, #21
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #22
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #23
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #24
        bl      VGA_write_char_ASM
        mov     r2, #32
        mov     r1, #5
        mov     r0, #25
        bl      VGA_write_char_ASM
        mov     r2, #87
        mov     r1, #5
        mov     r0, #26
        bl      VGA_write_char_ASM
        mov     r2, #111
        mov     r1, #5
        mov     r0, #27
        bl      VGA_write_char_ASM
        mov     r2, #114
        mov     r1, #5
        mov     r0, #28
        bl      VGA_write_char_ASM
        mov     r2, #108
        mov     r1, #5
        mov     r0, #29
        bl      VGA_write_char_ASM
        mov     r2, #100
        mov     r1, #5
        mov     r0, #30
        bl      VGA_write_char_ASM
        mov     r2, #33
        mov     r1, #5
        mov     r0, #31
        bl      VGA_write_char_ASM
        pop     {r4, r5, r6, r7, r8, r9, r10, pc}
.draw_test_screen_L8:
        .word   1717986919
        .word   -368140053
        .word   -2004318071
