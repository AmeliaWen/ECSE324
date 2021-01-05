.global _start
.equ PS2_data, 0xFF200100
.equ PIXEL_buffer, 0xC8000000
	.equ CHARACTER_buffer, 0xC9000000
_start:
        bl      input_loop
end:
        b       end

@ TODO: copy VGA driver here.
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


@ TODO: insert PS/2 driver here.
read_PS2_data_ASM:
PUSH {R1-R2, LR}		
	LDR R1, =PS2_data
	LDR R1, [R1]
	mov r2, r1
	lsr r2, #15
	and r2, r2, #1

	CMP R2, #1			
	MOVLT R0, #0		
	BLT END
	
	AND R1, #0xFF 		
	STRB R1, [R0]		
	MOV R0, #1			

END:
	POP {R1-R2, LR}		
	BX LR 				
write_hex_digit:
        push    {r4, lr}
        cmp     r2, #9
        addhi   r2, r2, #55
        addls   r2, r2, #48
        and     r2, r2, #255
        bl      VGA_write_char_ASM
        pop     {r4, pc}
write_byte:
        push    {r4, r5, r6, lr}
        mov     r5, r0
        mov     r6, r1
        mov     r4, r2
        lsr     r2, r2, #4
        bl      write_hex_digit
        and     r2, r4, #15
        mov     r1, r6
        add     r0, r5, #1
        bl      write_hex_digit
        pop     {r4, r5, r6, pc}
input_loop:
        push    {r4, r5, lr}
        sub     sp, sp, #12
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r4, #0
        mov     r5, r4
        b       .input_loop_L9
.input_loop_L13:
        ldrb    r2, [sp, #7]
        mov     r1, r4
        mov     r0, r5
        bl      write_byte
        add     r5, r5, #3
        cmp     r5, #79
        addgt   r4, r4, #1
        movgt   r5, #0
.input_loop_L8:
        cmp     r4, #59
        bgt     .input_loop_L12
.input_loop_L9:
        add     r0, sp, #7
        bl      read_PS2_data_ASM
        cmp     r0, #0
        beq     .input_loop_L8
        b       .input_loop_L13
.input_loop_L12:
        add     sp, sp, #12
        pop     {r4, r5, pc}

