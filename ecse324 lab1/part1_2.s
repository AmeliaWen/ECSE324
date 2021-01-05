.global _start
_start:
	mov R0, #1
	mov R1, #168
	mov R2, #100
	MOV R6, #2
	push {r3-lr} // store all register values that are not used outside the recursive program on the stack 
	bl recur
	pop {r3-lr} // restore the prev register values 
	b end
recur: 
	cmp r2, #0 // compare base case 
	bgt sqrt 
	bx LR 
sqrt: 
	mul r5, r0, r0 
	sub r5, r5, r1
	mul r5, r5, r0
	ASR R5, R5, #10 // r5 = (xi*xi-a)*xi >>k
	CMP R5, R6 
	BGT CONDA
	CMP R5, #-2
	BLT CONDB 
	b SUBST
CONDA: 
	MOV R5, #2
	B SUBST
CONDB: 
	MOV R5, #-2
	B SUBST
SUBST:
	SUB R0, R0, R5
	SUB R2, R2, #1
	B recur
end:
	b end 
	

	
	