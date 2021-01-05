.section .vectors, "ax"
B _start
B SERVICE_UND       // undefined instruction vector
B SERVICE_SVC       // software interrupt vector
B SERVICE_ABT_INST  // aborted prefetch vector
B SERVICE_ABT_DATA  // aborted data vector
.word 0 // unused vector
B SERVICE_IRQ       // IRQ interrupt vector
B SERVICE_FIQ       // FIQ interrupt vector
.text
PB_int_flag :
    .word 0x0
tim_int_flag :
    .word 0x0
.global _start
_start:
.equ KEY_BASE, 0xff200050
.equ TIM_P, 0xfffec600
.equ HEX_0_3, 0xff200020
.equ HEX_4_5, 0xff200030
.equ PB_EDGE, 0xff20005c

    /* Set up stack pointers for IRQ and SVC processor modes */
    MOV        R1, #0b11010010      // interrupts masked, MODE = IRQ
    MSR        CPSR_c, R1           // change to IRQ mode
    LDR        SP, =0xFFFFFFFF - 3  // set IRQ stack to A9 onchip memory
    /* Change to SVC (supervisor) mode with interrupts disabled */
    MOV        R1, #0b11010011      // interrupts masked, MODE = SVC
    MSR        CPSR, R1             // change to supervisor mode
    LDR        SP, =0x3FFFFFFF - 3  // set SVC stack to top of DDR3 memory
    BL     CONFIG_GIC           // configure the ARM GIC
	bl enable_PB_INT_ASM
	mov r1, #7
	bl ARM_TIM_config_ASM
    // To DO: write to the pushbutton KEY interrupt mask register
    // Or, you can call enable_PB_INT_ASM subroutine from previous task
    // to enable interrupt for ARM A9 private timer, use ARM_TIM_config_ASM subroutine
    LDR        R0, =0xFF200050      // pushbutton KEY base address
    MOV        R1, #0xF             // set interrupt mask bits
    STR        R1, [R0, #0x8]       // interrupt mask register (base + 8)
    // enable IRQ interrupts in the processor
    MOV        R0, #0b01010011      // IRQ unmasked, MODE = SVC
	mov r3, #0
	mov r4, #0
	mov r5, #0
	mov r6, #0
	mov r7, #0
	mov r8, #0
	mov r9, #0
	mov r10, #0
    MSR        CPSR_c, R0
	mov r0, #0
beginning: 
	ldr r2, =PB_int_flag
	ldr r0, [r2]
	tst r0, #4
	movne r5, #0
	movne r3, #0
	movne r4, #0
	movne r6, #0
	movne r7, #0
	movne r8, #0
	movne r9, #0
	movne r0, #0
	movne r1, #63
	blne HEX_write_ASM
	blne PB_clear_edgecp_ASM
	movne r1, #6
	blne ARM_TIM_config_ASM
	bne beginning
	cmp r0, #2
	beq beginning
	tst r0, #1
	beq beginning
	movne r1, #7
	blne ARM_TIM_config_ASM
count:
	ldr r2, =tim_int_flag
	ldr r0, [r2]
	mov r2, #0
	cmp r0, #1
	bne count
	add r6, r6, #1
	add r5, r6, #0
last_digit:
	push {r0}
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
	cmp r7, #10
	addge r4, r4, #1
	cmp r7, #10
	subge r7, #10
	cmp r7, #10
	bge last_digit
	add r0, r7, #0
	mov r1, #2
	bl HEX_write_ASM
	cmp r5, #10
	addeq r7, r7, #1
	cmp r5, #10
	subge r5, r5, #10
	cmp r5, #10
	bge last_digit
	add r0, r5, #0
	mov r1, #1
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
	pop {r0}
	mov r1, #0
	ldr r2, =tim_int_flag
	ldr r0, [r2]
	cmp r0, #2
	movge r0, #0
	strge r0, [r2]
	tst r0, #1
	movne r0, #0
	strne r0, [r2]
    B beginning // This is where you write your objective task
	/*--- Undefined instructions ---------------------------------------- */
SERVICE_UND:
    B SERVICE_UND
/*--- Software interrupts ------------------------------------------- */
SERVICE_SVC:
    B SERVICE_SVC
/*--- Aborted data reads -------------------------------------------- */
SERVICE_ABT_DATA:
    B SERVICE_ABT_DATA
/*--- Aborted instruction fetch ------------------------------------- */
SERVICE_ABT_INST:
    B SERVICE_ABT_INST
/*--- IRQ ----------------------------------------------------------- */
SERVICE_IRQ:
    PUSH {R0-R5, r6, r7, LR}
/* Read the  from the CPU Interface */
    LDR R4, =0xFFFEC100
    LDR R5, [R4, #0x0C] // read from ICCIAR
Timer_check:
	cmp r5, #29
	bne Pushbutton_check
	bl ARM_TIM_ISR
	b EXIT_IRQ
/* To Do: Check which interrupt has occurred (check interrupt IDs)
   Then call the corresponding ISR
   If the ID is not recognized, branch to UNEXPECTED
   See the assembly example provided in the De1-SoC Computer_Manual on page 46 */
 Pushbutton_check:
    CMP R5, #73
UNEXPECTED:
    BNE UNEXPECTED      // if not recognized, stop here
    BL keys_isr
EXIT_IRQ:
/* Write to the End of Interrupt Register (ICCEOIR) */
    STR R5, [R4, #0x10] // write to ICCEOIR
    POP {R0-R5, r6, r7, LR}
SUBS PC, LR, #4
/*--- FIQ ----------------------------------------------------------- */
SERVICE_FIQ:
    B SERVICE_FIQ
CONFIG_GIC:
    PUSH {LR}
/* To configure the FPGA KEYS interrupt (ID 73):
* 1. set the target to cpu0 in the ICDIPTRn register
* 2. enable the interrupt in the ICDISERn register */
/* CONFIG_INTERRUPT (int_ID (R0), CPU_target (R1)); */
/* To Do: you can configure different interrupts
   by passing their IDs to R0 and repeating the next 3 lines */
    MOV R0, #73            // KEY port (Interrupt ID = 73)
    MOV R1, #1             // this field is a bit-mask; bit 0 targets cpu0
    BL CONFIG_INTERRUPT
	MOV R0, #29            // KEY port (Interrupt ID = 73)
    MOV R1, #1             // this field is a bit-mask; bit 0 targets cpu0
    BL CONFIG_INTERRUPT

/* configure the GIC CPU Interface */
    LDR R0, =0xFFFEC100    // base address of CPU Interface
/* Set Interrupt Priority Mask Register (ICCPMR) */
    LDR R1, =0xFFFF        // enable interrupts of all priorities levels
    STR R1, [R0, #0x04]
/* Set the enable bit in the CPU Interface Control Register (ICCICR).
* This allows interrupts to be forwarded to the CPU(s) */
    MOV R1, #1
    STR R1, [R0]
/* Set the enable bit in the Distributor Control Register (ICDDCR).
* This enables forwarding of interrupts to the CPU Interface(s) */
    LDR R0, =0xFFFED000
    STR R1, [R0]
    POP {PC}

/*
* Configure registers in the GIC for an individual Interrupt ID
* We configure only the Interrupt Set Enable Registers (ICDISERn) and
* Interrupt Processor Target Registers (ICDIPTRn). The default (reset)
* values are used for other registers in the GIC
* Arguments: R0 = Interrupt ID, N
* R1 = CPU target
*/
CONFIG_INTERRUPT:
    PUSH {R4-R5, LR}
/* Configure Interrupt Set-Enable Registers (ICDISERn).
* reg_offset = (integer_div(N / 32) * 4
* value = 1 << (N mod 32) */
    LSR R4, R0, #3    // calculate reg_offset
    BIC R4, R4, #3    // R4 = reg_offset
    LDR R2, =0xFFFED100
    ADD R4, R2, R4    // R4 = address of ICDISER
    AND R2, R0, #0x1F // N mod 32
    MOV R5, #1        // enable
    LSL R2, R5, R2    // R2 = value
/* Using the register address in R4 and the value in R2 set the
* correct bit in the GIC register */
    LDR R3, [R4]      // read current register value
    ORR R3, R3, R2    // set the enable bit
    STR R3, [R4]      // store the new register value
/* Configure Interrupt Processor Targets Register (ICDIPTRn)
* reg_offset = integer_div(N / 4) * 4
* index = N mod 4 */
    BIC R4, R0, #3    // R4 = reg_offset
    LDR R2, =0xFFFED800
    ADD R4, R2, R4    // R4 = word address of ICDIPTR
    AND R2, R0, #0x3  // N mod 4
    ADD R4, R2, R4    // R4 = byte address in ICDIPTR
/* Using register address in R4 and the value in R2 write to
* (only) the appropriate byte */
    STRB R1, [R4]
    POP {R4-R5, PC}
keys_isr:
	push {r1, r2, r3}
	ldr r1, =KEY_BASE
	ldr r2, =PB_int_flag
	ldr r0, [r1, #12]
	str r0, [r1, #12]
	str r0, [r2]
	cmp r0, #0
	movne r2, #1
	strne r2, [r1, #12]
	ldr r2, =PB_int_flag
	ldr r3, [r2]
	pop {r1, r2, r3}
	bx lr
KEY_ISR:
    LDR R0, =0xFF200050    // base address of pushbutton KEY port
    LDR R1, [R0, #0xC]     // read edge capture register
    MOV R2, #0xF
    STR R2, [R0, #0xC]     // clear the interrupt
    LDR R0, =0xFF200020    // based address of HEX display
CHECK_KEY0:
    MOV R3, #0x1
    ANDS R3, R3, R1        // check for KEY0
    BEQ CHECK_KEY1
    MOV R2, #0b00111111
    STR R2, [R0]           // display "0"
    B END_KEY_ISR
CHECK_KEY1:
    MOV R3, #0x2
    ANDS R3, R3, R1        // check for KEY1
    BEQ CHECK_KEY2
	push {r1, r2}
	ldr r1, =TIM_P
	mov r2, #6
	//tst r11, #2
	str r2, [r1, #8]
	pop {r1, r2}
    //MOV R2, #0b00000110
    //STR R2, [R0]           // display "1"
    B END_KEY_ISR
CHECK_KEY2:
    MOV R3, #0x4
    ANDS R3, R3, R1        // check for KEY2
    BEQ IS_KEY3
    MOV R2, #0b01011011
    STR R2, [R0]           // display "2"
    B END_KEY_ISR
IS_KEY3:
    MOV R2, #0b01001111
    STR R2, [R0]           // display "3"
END_KEY_ISR:
    BX LR
ARM_TIM_ISR:
	push {r0, r1, r2, r3}
	ldr r3, =tim_int_flag
	ldr r1, =TIM_P
	ldr r2, [r1, #12]
	tst r2, #1
	movne r0, #1
	strne r0, [r3]
	strne r0, [r1, #12]
	pop {r0, r1, r2, r3}
	bx lr
disable_timer: 
	push {r1, r2}
	mov r1, #6
	ldr r2, =TIM_P
	str r1, [r2, #8]
	pop {r1, r2}
	bx lr
enable_PB_INT_ASM:
	push {r1, r2}
	ldr r1, =KEY_BASE
	mov r2, #0x3
	str r2, [r1, #0x8]
	pop {r1, r2}
	bx lr
PB_clear_edgecp_ASM:
	push {r1, r2}
	ldr r1, =PB_EDGE
	mov r2, #0xFFFFFFFF
	str r2, [r1]
	pop {r1, r2}
	bx lr
ARM_TIM_config_ASM:
	push {r2,r4}
	ldr r4, =TIM_P
	LDR R2, =#2000000
	STR R2, [R4]
	//mov r1, #7
	str r1, [r4, #8]
	pop {r2,r4}
	bx lr
HEX_write_ASM:
	push {r1-r7}
	ldr r2, =HEX_0_3
	LDR R3, =HEX_4_5	
	MOV R4, #1			
	MOV R6, #0			
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

WRITE:			
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
Exit_write:	  
	POP {R1-r7}
	BX LR
