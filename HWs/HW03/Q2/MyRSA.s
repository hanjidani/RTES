	.arch armv5t
	.fpu softvfp
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"MyRSA.c"
	.text
	.section	.rodata
	.align	2
.LC0:
	.ascii	"Enter the public key (n, e): \000"
	.align	2
.LC1:
	.ascii	"%d %d\000"
	.align	2
.LC2:
	.ascii	"Enter the encrypted messages separated by spaces: \000"
	.align	2
.LC3:
	.ascii	" %[^\012]s\000"
	.align	2
.LC4:
	.ascii	" \000"
	.align	2
.LC5:
	.ascii	"p: %d, q: %d\012\000"
	.align	2
.LC6:
	.ascii	"Private key d: %d\012\000"
	.align	2
.LC7:
	.ascii	"Decrypted messages:\000"
	.align	2
.LC8:
	.ascii	"%d \000"
	.text
	.align	2
	.global	main
	.syntax unified
	.arm
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 1448
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, fp, lr}
	add	fp, sp, #8
	sub	sp, sp, #1440
	sub	sp, sp, #12
	ldr	r3, .L8
	ldr	r3, [r3]
	str	r3, [fp, #-16]
	mov	r3, #0
	mov	r3, #0
	str	r3, [fp, #-1440]
	ldr	r0, .L8+4
	bl	printf
	sub	r2, fp, #1440
	sub	r2, r2, #12
	sub	r3, fp, #1440
	sub	r3, r3, #12
	sub	r3, r3, #4
	mov	r1, r3
	ldr	r0, .L8+8
	bl	__isoc99_scanf
	ldr	r0, .L8+12
	bl	printf
	sub	r3, fp, #1016
	mov	r1, r3
	ldr	r0, .L8+16
	bl	__isoc99_scanf
	sub	r3, fp, #1016
	ldr	r1, .L8+20
	mov	r0, r3
	bl	strtok
	str	r0, [fp, #-1436]
	b	.L2
.L3:
	ldr	r4, [fp, #-1440]
	add	r3, r4, #1
	str	r3, [fp, #-1440]
	ldr	r0, [fp, #-1436]
	bl	atoi
	mov	r2, r0
	lsl	r3, r4, #2
	sub	r3, r3, #12
	add	r3, r3, fp
	str	r2, [r3, #-1404]
	ldr	r1, .L8+20
	mov	r0, #0
	bl	strtok
	str	r0, [fp, #-1436]
.L2:
	ldr	r3, [fp, #-1436]
	cmp	r3, #0
	bne	.L3
	ldr	r0, [fp, #-1456]
	sub	r2, fp, #1424
	sub	r2, r2, #12
	sub	r2, r2, #8
	sub	r3, fp, #1424
	sub	r3, r3, #12
	sub	r3, r3, #12
	mov	r1, r3
	bl	factorizeNumber
	ldr	r3, [fp, #-1448]
	ldr	r2, [fp, #-1444]
	mov	r1, r3
	ldr	r0, .L8+24
	bl	printf
	ldr	r3, [fp, #-1448]
	sub	r3, r3, #1
	ldr	r2, [fp, #-1444]
	sub	r2, r2, #1
	mul	r3, r2, r3
	str	r3, [fp, #-1428]
	ldr	r3, [fp, #-1452]
	ldr	r1, [fp, #-1428]
	mov	r0, r3
	bl	findModularInverse
	str	r0, [fp, #-1424]
	ldr	r1, [fp, #-1424]
	ldr	r0, .L8+28
	bl	printf
	ldr	r0, .L8+32
	bl	puts
	mov	r3, #0
	str	r3, [fp, #-1432]
	b	.L4
.L5:
	ldr	r3, [fp, #-1432]
	lsl	r3, r3, #2
	sub	r3, r3, #12
	add	r3, r3, fp
	ldr	r3, [r3, #-1404]
	ldr	r2, [fp, #-1456]
	ldr	r1, [fp, #-1424]
	mov	r0, r3
	bl	performModularExponentiation
	str	r0, [fp, #-1420]
	ldr	r1, [fp, #-1420]
	ldr	r0, .L8+36
	bl	printf
	ldr	r3, [fp, #-1432]
	add	r3, r3, #1
	str	r3, [fp, #-1432]
.L4:
	ldr	r2, [fp, #-1432]
	ldr	r3, [fp, #-1440]
	cmp	r2, r3
	blt	.L5
	mov	r3, #0
	ldr	r2, .L8
	ldr	r1, [r2]
	ldr	r2, [fp, #-16]
	eors	r1, r2, r1
	mov	r2, #0
	beq	.L7
	bl	__stack_chk_fail
.L7:
	mov	r0, r3
	sub	sp, fp, #8
	@ sp needed
	pop	{r4, fp, pc}
.L9:
	.align	2
.L8:
	.word	__stack_chk_guard
	.word	.LC0
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.word	.LC4
	.word	.LC5
	.word	.LC6
	.word	.LC7
	.word	.LC8
	.size	main, .-main
	.global	__aeabi_idivmod
	.align	2
	.global	calculateGCD
	.syntax unified
	.arm
	.type	calculateGCD, %function
calculateGCD:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	str	r0, [fp, #-16]
	str	r1, [fp, #-20]
	b	.L11
.L12:
	ldr	r3, [fp, #-20]
	str	r3, [fp, #-8]
	ldr	r3, [fp, #-16]
	ldr	r1, [fp, #-20]
	mov	r0, r3
	bl	__aeabi_idivmod
	mov	r3, r1
	str	r3, [fp, #-20]
	ldr	r3, [fp, #-8]
	str	r3, [fp, #-16]
.L11:
	ldr	r3, [fp, #-20]
	cmp	r3, #0
	bne	.L12
	ldr	r3, [fp, #-16]
	mov	r0, r3
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	calculateGCD, .-calculateGCD
	.global	__aeabi_idiv
	.align	2
	.global	findModularInverse
	.syntax unified
	.arm
	.type	findModularInverse, %function
findModularInverse:
	@ args = 0, pretend = 0, frame = 32
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #32
	str	r0, [fp, #-32]
	str	r1, [fp, #-36]
	ldr	r3, [fp, #-36]
	str	r3, [fp, #-16]
	mov	r3, #0
	str	r3, [fp, #-24]
	mov	r3, #1
	str	r3, [fp, #-20]
	ldr	r3, [fp, #-36]
	cmp	r3, #1
	bne	.L17
	mov	r3, #0
	b	.L16
.L18:
	ldr	r1, [fp, #-36]
	ldr	r0, [fp, #-32]
	bl	__aeabi_idiv
	mov	r3, r0
	str	r3, [fp, #-12]
	ldr	r3, [fp, #-36]
	str	r3, [fp, #-8]
	ldr	r3, [fp, #-32]
	ldr	r1, [fp, #-36]
	mov	r0, r3
	bl	__aeabi_idivmod
	mov	r3, r1
	str	r3, [fp, #-36]
	ldr	r3, [fp, #-8]
	str	r3, [fp, #-32]
	ldr	r3, [fp, #-24]
	str	r3, [fp, #-8]
	ldr	r3, [fp, #-12]
	ldr	r2, [fp, #-24]
	mul	r3, r2, r3
	ldr	r2, [fp, #-20]
	sub	r3, r2, r3
	str	r3, [fp, #-24]
	ldr	r3, [fp, #-8]
	str	r3, [fp, #-20]
.L17:
	ldr	r3, [fp, #-32]
	cmp	r3, #1
	bgt	.L18
	ldr	r3, [fp, #-20]
	cmp	r3, #0
	bge	.L19
	ldr	r2, [fp, #-20]
	ldr	r3, [fp, #-16]
	add	r3, r2, r3
	str	r3, [fp, #-20]
.L19:
	ldr	r3, [fp, #-20]
.L16:
	mov	r0, r3
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	findModularInverse, .-findModularInverse
	.align	2
	.global	performModularExponentiation
	.syntax unified
	.arm
	.type	performModularExponentiation, %function
performModularExponentiation:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #24
	str	r0, [fp, #-16]
	str	r1, [fp, #-20]
	str	r2, [fp, #-24]
	mov	r3, #1
	str	r3, [fp, #-8]
	ldr	r3, [fp, #-16]
	ldr	r1, [fp, #-24]
	mov	r0, r3
	bl	__aeabi_idivmod
	mov	r3, r1
	str	r3, [fp, #-16]
	b	.L21
.L23:
	ldr	r3, [fp, #-20]
	cmp	r3, #0
	and	r3, r3, #1
	rsblt	r3, r3, #0
	cmp	r3, #1
	bne	.L22
	ldr	r3, [fp, #-8]
	ldr	r2, [fp, #-16]
	mul	r3, r2, r3
	ldr	r1, [fp, #-24]
	mov	r0, r3
	bl	__aeabi_idivmod
	mov	r3, r1
	str	r3, [fp, #-8]
.L22:
	ldr	r3, [fp, #-20]
	asr	r3, r3, #1
	str	r3, [fp, #-20]
	ldr	r3, [fp, #-16]
	mov	r2, r3
	mul	r2, r3, r2
	mov	r3, r2
	ldr	r1, [fp, #-24]
	mov	r0, r3
	bl	__aeabi_idivmod
	mov	r3, r1
	str	r3, [fp, #-16]
.L21:
	ldr	r3, [fp, #-20]
	cmp	r3, #0
	bgt	.L23
	ldr	r3, [fp, #-8]
	mov	r0, r3
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	performModularExponentiation, .-performModularExponentiation
	.global	__aeabi_i2d
	.global	__aeabi_dcmpge
	.align	2
	.global	factorizeNumber
	.syntax unified
	.arm
	.type	factorizeNumber, %function
factorizeNumber:
	@ args = 0, pretend = 0, frame = 32
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #32
	str	r0, [fp, #-24]
	str	r1, [fp, #-28]
	str	r2, [fp, #-32]
	ldr	r0, [fp, #-24]
	bl	__aeabi_i2d
	mov	r2, r0
	mov	r3, r1
	mov	r0, r2
	mov	r1, r3
	bl	sqrt
	str	r0, [fp, #-12]
	str	r1, [fp, #-8]
	mov	r3, #2
	str	r3, [fp, #-16]
	b	.L26
.L29:
	ldr	r3, [fp, #-24]
	ldr	r1, [fp, #-16]
	mov	r0, r3
	bl	__aeabi_idivmod
	mov	r3, r1
	cmp	r3, #0
	bne	.L27
	ldr	r3, [fp, #-28]
	ldr	r2, [fp, #-16]
	str	r2, [r3]
	ldr	r1, [fp, #-16]
	ldr	r0, [fp, #-24]
	bl	__aeabi_idiv
	mov	r3, r0
	mov	r2, r3
	ldr	r3, [fp, #-32]
	str	r2, [r3]
	b	.L25
.L27:
	ldr	r3, [fp, #-16]
	add	r3, r3, #1
	str	r3, [fp, #-16]
.L26:
	ldr	r0, [fp, #-16]
	bl	__aeabi_i2d
	mov	r2, r0
	mov	r3, r1
	sub	r1, fp, #12
	ldmia	r1, {r0-r1}
	bl	__aeabi_dcmpge
	mov	r3, r0
	cmp	r3, #0
	bne	.L29
.L25:
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
	.size	factorizeNumber, .-factorizeNumber
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",%progbits
