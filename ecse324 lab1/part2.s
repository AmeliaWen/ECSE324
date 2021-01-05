N:		.word 3
NUMBER:	.word 1,2,3

.global _start
_start:
	LDR R0, =N	
	LDR R1, [R0]		//R1=# of elements
	ADD R2, R0, #4		//pointer to first element in array
	mov r9, #1 //needed for shift
	mov r4, #0 //logn
	mov r6, #0 // store each element of the array 
	mov r7, #0 //counter i 
	mov r3, #0 // square sum for all elements 
loop:
	lsl r6, r9, r4 //r6 = 1<<log2_n
	cmp r6, r1 
	bge calculate
	add r4, r4, #1 
	b loop 
calculate:
	ldr R6, [R2] //r6 is content of 1st element 
	cmp r7, r1 
	bge norm //end loop 
	mul r6, r6, r6 
	add r3, r3, r6 //r3 is the temp 
	add r2, r2, #4 //increment pointer
	add r7, r7, #1 //increment counter
	b calculate 
norm:
	lsr r3, r3, r4
	BL sqrt //call subroutines
	b end 

sqrt:
	push {r9, r8, lr} // callee-save convention
	mov R0, #1 //norm
	mov R2, #100 // cnt
	MOV R8, #0 //counter
	mov r5, #0 // step
sqrtloop:
	cmp R8, R2
	BGE END // loop ends
	mul r5, r0, r0 
	sub r5, r5, r3
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
	ADD R8, R8, #1 // increment loop counter 
	B sqrtloop 
END:
	pop {r9, r8, lr} // callee-save convention
	bx lr
// result is stored in r0 
	
	
	
end : 
	b end

	