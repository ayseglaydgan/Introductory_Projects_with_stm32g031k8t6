/*
 * author: Aysegul Aydogan
 *
 * Construct a diamond pattern by using STM32 
 * and 8 external LEDs
 */


.syntax unified
.cpu cortex-m0plus
.fpu softvfp
.thumb


/* make linker see this */
.global Reset_Handler

/* get these from linker script */
.word _sdata
.word _edata
.word _sbss
.word _ebss


.equ RCC_BASE,         (0x40021000)          // RCC base address
.equ RCC_IOPENR,       (RCC_BASE   + (0x34)) // RCC IOPENR register offset

.equ GPIOA_BASE,       (0x50000000)          // GPIOA base address
.equ GPIOA_MODER,      (GPIOA_BASE + (0x00)) // GPIOA MODER register offset
.equ GPIOA_IDR,        (GPIOA_BASE + (0x10)) // GPIOA IDR register offset
.equ GPIOA_ODR,        (GPIOA_BASE + (0x14)) // GPIOA ODR register offset

.equ GPIOB_BASE,       (0x50000400)          // GPIOB base address
.equ GPIOB_MODER,      (GPIOB_BASE + (0x00)) // GPIOB MODER register offset
.equ GPIOB_IDR,        (GPIOB_BASE + (0x10)) // GPIOB IDR register offset
.equ GPIOB_ODR,        (GPIOB_BASE + (0x14)) // GPIOB ODR register offset

/* vector table, +1 thumb mode */
.section .vectors
vector_table:
	.word _estack             /*     Stack pointer */
	.word Reset_Handler +1    /*     Reset handler */
	.word Default_Handler +1  /*       NMI handler */
	.word Default_Handler +1  /* HardFault handler */
	/* add rest of them here if needed */


/* reset handler */
.section .text
Reset_Handler:
	/* set stack pointer */
	ldr r0, =_estack
	mov sp, r0

	/* initialize data and bss
	 * not necessary for rom only code
	 * */
	bl init_data
	/* call main */
	bl main
	/* trap if returned */
	b .


/* initialize data and bss sections */
.section .text
init_data:

	/* copy rom to ram */
	ldr r0, =_sdata
	ldr r1, =_edata
	ldr r2, =_sidata
	movs r3, #0
	b LoopCopyDataInit

	CopyDataInit:
		ldr r4, [r2, r3]
		str r4, [r0, r3]
		adds r3, r3, #4

	LoopCopyDataInit:
		adds r4, r0, r3
		cmp r4, r1
		bcc CopyDataInit

	/* zero bss */
	ldr r2, =_sbss
	ldr r4, =_ebss
	movs r3, #0
	b LoopFillZerobss

	FillZerobss:
		str  r3, [r2]
		adds r2, r2, #4

	LoopFillZerobss:
		cmp r2, r4
		bcc FillZerobss

	bx lr


/* default handler */
.section .text
Default_Handler:
	b Default_Handler


/* main function */
.section .text

delay:
	//push{r1,lr}
	subs r3, #1
	bne delay
	//pop{r2,pc}
	bx lr


main:
	/* enable GPIOA/B clock, bit0 and bit1 on IOPENR */
	ldr r6, =RCC_IOPENR
	ldr r5, [r6]
	/* movs expects imm8, so this should be fine */
	movs r4, 0x3
	orrs r5, r5, r4
	str r5, [r6]

	/* setup
	 PA0 -> Status Led
	 PA1 -> Led
	 PA4 -> Led
	 PA5 -> Led
	 PA6 -> Led
	 PA7 -> Led
	 PA11 -> Led
	 PA12 -> Led


     */
	ldr r6, =GPIOA_MODER
	ldr r5, [r6]
	/* cannot do with movs, so use pc relative */
	ldr r4, =0x3C0FF0F
	mvns r4, r4
	ands r5, r5, r4
	ldr r4, =0x1405505
	orrs r5, r5, r4
	str r5, [r6]

    ldr r6, =GPIOB_MODER
	ldr r5, [r6]
	/* cannot do with movs, so use pc relative */
	ldr r4, =0x3
	mvns r4, r4
	ands r5, r5, r4
	str r5, [r6]

	//clear GPIOA_ODR
	ldr r6, =GPIOA_ODR
    ldr r5, [r6]
    ldr r4, =0x0
    ands r5, r5 ,r4
    str r5, [r6]

    /* Button is pressed*/
    ldr r1, =GPIOB_IDR
    ldr r5, [r1]

    movs r4, #0x1
    ands r5, r5, r4

    cmp r5, #0x1
    beq leds_light
    bne leds_stop

button_read:
    /* Button is pressed*/
    ldr r1, =GPIOB_IDR
    ldr r5, [r1]

    movs r4, #0x1
    ands r5, r5, r4

    cmp r5, #0x1
    bne leds_stop
    bx lr


leds_light:

	ldr r6, =GPIOA_ODR
    ldr r5, [r6]
    ldr r4, =0x0
    ands r5, r5 ,r4
    str r5, [r6]

   	ldr r3, =0x1E8480
	bl delay
	bl button_read

    /* turn on leds connected to PA in ODR */
    ldr r6, =GPIOA_ODR
    ldr r5, [r6]
    ldr r4, =0x1000
    orrs r5, r5, r4
	str r5, [r6]

	ldr r3, =0x1E8480
	bl delay
	bl button_read

    ldr r6, =GPIOA_ODR
    ldr r5, [r6]
    ldr r4, =0x1820
    orrs r5, r5, r4
	str r5, [r6]

	ldr r3, =0x1E8480
	bl delay
	bl button_read

	ldr r6, =GPIOA_ODR
    ldr r5, [r6]
    ldr r4, =0x1870
    orrs r5, r5, r4
	str r5, [r6]

	ldr r3, =0x1E8480
	bl delay
	bl button_read

	ldr r6, =GPIOA_ODR
    ldr r5, [r6]
    ldr r4, =0x18F2
    orrs r5, r5, r4
	str r5, [r6]

	ldr r3, =0x1E8480
	bl delay
	bl button_read

	b leds_light

leds_stop:
    /* turn off led connected to C6 in ODR */
   	ldr r6, =GPIOA_ODR
    ldr r5, [r6]
    ldr r4, =0x1
    orrs r5, r5 ,r4
    str r5, [r6]

	ldr r1, =GPIOB_IDR
    ldr r5, [r1]

    movs r4, #0x1
    ands r5, r5, r4

    cmp r5, #0x1
	bne leds_stop

	ldr r6, =GPIOA_ODR
    ldr r5, [r6]
    ldr r4, =0xFFFE
    ands r5, r5 ,r4
    str r5, [r6]

	bx lr

    nop
