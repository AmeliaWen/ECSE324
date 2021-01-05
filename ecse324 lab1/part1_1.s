.global _start
_start:
	mov R0, #1 //xi 
	mov R1, #168 // a
	mov R2, #100 // cnt
	MOV R3, #0 //counter
	mov r5, #0 // step
LOOP:
	cmp R3, R2
	BGE END // loop ends
	mul r5, r0, r0 
	sub r5, r5, r1
	mul r5, r5, r0 
	ASR R5, R5, #10 // r5 = (xi*xi-a)*xi >>k
	CMP R5, #2 
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
	SUB R0, R0, R5 // xi=xi-step 
	ADD R3, R3, #1 // increment loop counter 
	B LOOP 
END:
	B END 
// result is stored in r0 
	
	