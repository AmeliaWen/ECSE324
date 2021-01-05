
N:		.word 4
NUMBER:	.word 3, 4, 6, 4
.global _start
_start:
	LDR R0, =N
	LDR R1, [R0] //R1 is the length of array
	ADD R2, R0, #4 //Points to the 1st element of array 
	mov r3, #0 // mean 
	mov r5, #1 //for logic shift 
	mov r4, #0 //logn
	mov r6, #0 
	mov r7, #0 //counter for calculating mean 
	mov r8, #0 //counter for centering output array 
loop:
	lsl r6, r5, r4 
	cmp r6, r1
	bge calculate
	add r4, r4, #1 //calculate log2n
	b loop 
calculate: //calculate mean 
	ldr R6, [R2] 
	cmp r7, r1
	bge mean
	add r3, r3, r6
	add r2, r2, #4 //increase pointer
	add r7, r7, #1 //increase counter
	b calculate
mean:
	asr r3, r3, r4 //r3 stores mean 
	add r2, r0, #4 // restore r2 to point to first element 
	b center
center:
	ldr r6, [r2]
	cmp r8, r1
	bge end
	sub r6, r6, r3
	str r6, [r2] //store result at same location 
	add r2, r2, #4 //increase pointer
	add r8, r8, #1 //increase counter 
	b center
end:
	b end
