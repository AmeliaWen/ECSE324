.text
N:		.word 5
NUMBER:	.word 4,2, 1, 4, -1
.global _start

_start:
		LDR R0, =N	
		LDR R1, [R0]		//R1=# of elements
		ADD R2, R0, #4		//pointer to first element in array
		LDR R3, [R2]		//value of the fist element
		MOV R4, #0			//I
		MOV R5,#0 //j 
		MOV R7,#0 //tmp
		MOV R8, #0 //*(ptr+j)
		mov R6, #0 //current min index 
OUTER: 
		CMP R4, R1 //i=0;i<n-1;
		BGE END
		ADD R5, R4, #1	// j=i+1
		B INNER
INNER:	
		CMP R5, R1//j, n
		BEQ increment//j=n increment i 
		LDR R7, [R2,R4,LSL#2]//TMP
		ADD R6, R4, #0//cur_min_index
		LDR R8, [R2,R5, LSL#2]//*(PTR+J)
		CMP R7,R8
		BLE SWAP
		ldr R7, [R2,R5, LSL#2] 
		add r6, r5, #0 
		B SWAP
SWAP:  LDR R9, [R2, R4,LSL#2] //temp store *(ptr+i)
        ldr R10, [R2,R6,LSL#2] //temp store *(ptr+curminindex)
        str r9, [R2, R6,LSL#2] //put result into given address 
		str r10, [R2, R4,LSL#2]
		add r5, r5, #1 //increment j 
		B INNER
increment:
	add r4, r4, #1 //i++ then go back to outer loop 
	b OUTER
	
END: B END
