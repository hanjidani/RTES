gcd:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	str	r0, [fp, #-16]
	str	r1, [fp, #-20]
	b	.L2
.L3:
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
.L2:
	ldr	r3, [fp, #-20]
	cmp	r3, #0
	bne	.L3
	ldr	r3, [fp, #-16]
	mov	r0, r3
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, lr}
	bx	lr
	.size	gcd, .-gcd
	.global	__aeabi_idiv
	.align	2
	.global	modInverse
	.syntax unified
	.arm
	.type	modInverse, %function
modInverse:
	@ Function supports interworking.
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
	str	r3, [fp, #-8]
	mov	r3, #1
	str	r3, [fp, #-12]
	ldr	r3, [fp, #-36]
	cmp	r3, #1
	bne	.L8
	mov	r3, #0
	b	.L7
.L9:
	ldr	r1, [fp, #-36]
	ldr	r0, [fp, #-32]
	bl	__aeabi_idiv
	mov	r3, r0
	str	r3, [fp, #-20]
	ldr	r3, [fp, #-36]
	str	r3, [fp, #-24]
	ldr	r3, [fp, #-32]
	ldr	r1, [fp, #-36]
	mov	r0, r3
	bl	__aeabi_idivmod
	mov	r3, r1
	str	r3, [fp, #-36]
	ldr	r3, [fp, #-24]
	str	r3, [fp, #-32]
	ldr	r3, [fp, #-8]
	str	r3, [fp, #-24]
	ldr	r3, [fp, #-20]
	ldr	r2, [fp, #-8]
	mul	r3, r2, r3
	ldr	r2, [fp, #-12]
	sub	r3, r2, r3
	str	r3, [fp, #-8]
	ldr	r3, [fp, #-24]
	str	r3, [fp, #-12]
.L8:
	ldr	r3, [fp, #-32]
	cmp	r3, #1
	bgt	.L9
	ldr	r3, [fp, #-12]
	cmp	r3, #0
	bge	.L10
	ldr	r2, [fp, #-12]
	ldr	r3, [fp, #-16]
	add	r3, r2, r3
	str	r3, [fp, #-12]
.L10:
	ldr	r3, [fp, #-12]
.L7:
	mov	r0, r3
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, lr}
	bx	lr
	.size	modInverse, .-modInverse
	.align	2
	.global	modExp
	.syntax unified
	.arm
	.type	modExp, %function
modExp:
	@ Function supports interworking.
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
	b	.L12
.L14:
	ldr	r3, [fp, #-20]
	cmp	r3, #0
	and	r3, r3, #1
	rsblt	r3, r3, #0
	cmp	r3, #1
	bne	.L13
	ldr	r3, [fp, #-8]
	ldr	r2, [fp, #-16]
	mul	r3, r2, r3
	ldr	r1, [fp, #-24]
	mov	r0, r3
	bl	__aeabi_idivmod
	mov	r3, r1
	str	r3, [fp, #-8]
.L13:
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
.L12:
	ldr	r3, [fp, #-20]
	cmp	r3, #0
	bgt	.L14
	ldr	r3, [fp, #-8]
	mov	r0, r3
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, lr}
	bx	lr
	.size	modExp, .-modExp
	.global	__aeabi_i2d
	.global	__aeabi_dcmple
	.align	2
	.global	factorize
	.syntax unified
	.arm
	.type	factorize, %function
factorize:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, r5, fp, lr}
	add	fp, sp, #12
	sub	sp, sp, #24
	str	r0, [fp, #-24]
	str	r1, [fp, #-28]
	str	r2, [fp, #-32]
	mov	r3, #2
	str	r3, [fp, #-16]
	b	.L17
.L20:
	ldr	r3, [fp, #-24]
	ldr	r1, [fp, #-16]
	mov	r0, r3
	bl	__aeabi_idivmod
	mov	r3, r1
	cmp	r3, #0
	bne	.L18
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
	b	.L16
.L18:
	ldr	r3, [fp, #-16]
	add	r3, r3, #1
	str	r3, [fp, #-16]
.L17:
	ldr	r0, [fp, #-16]
	bl	__aeabi_i2d
	mov	r4, r0
	mov	r5, r1
	ldr	r0, [fp, #-24]
	bl	__aeabi_i2d
	mov	r2, r0
	mov	r3, r1
	mov	r0, r2
	mov	r1, r3
	bl	sqrt
	mov	r2, r0
	mov	r3, r1
	mov	r0, r4
	mov	r1, r5
	bl	__aeabi_dcmple
	mov	r3, r0
	cmp	r3, #0
	bne	.L20
.L16:
	sub	sp, fp, #12
	@ sp needed
	pop	{r4, r5, fp, lr}
	bx	lr
	.size	factorize, .-factorize
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
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 1440
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, fp, lr}
	add	fp, sp, #8
	sub	sp, sp, #1440
	sub	sp, sp, #4
	mov	r3, #0
	str	r3, [fp, #-16]
	ldr	r0, .L27
	bl	printf
	sub	r2, fp, #44
	sub	r3, fp, #40
	mov	r1, r3
	ldr	r0, .L27+4
	bl	scanf
	ldr	r0, .L27+8
	bl	printf
	sub	r3, fp, #1440
	sub	r3, r3, #12
	mov	r1, r3
	ldr	r0, .L27+12
	bl	scanf
	sub	r3, fp, #1440
	sub	r3, r3, #12
	ldr	r1, .L27+16
	mov	r0, r3
	bl	strtok
	str	r0, [fp, #-20]
	b	.L22
.L23:
	ldr	r4, [fp, #-16]
	add	r3, r4, #1
	str	r3, [fp, #-16]
	ldr	r0, [fp, #-20]
	bl	atoi
	mov	r2, r0
	lsl	r3, r4, #2
	sub	r3, r3, #12
	add	r3, r3, fp
	str	r2, [r3, #-432]
	ldr	r1, .L27+16
	mov	r0, #0
	bl	strtok
	str	r0, [fp, #-20]
.L22:
	ldr	r3, [fp, #-20]
	cmp	r3, #0
	bne	.L23
	ldr	r3, [fp, #-40]
	sub	r2, fp, #452
	sub	r1, fp, #448
	mov	r0, r3
	bl	factorize
	ldr	r3, [fp, #-448]
	ldr	r2, [fp, #-452]
	mov	r1, r3
	ldr	r0, .L27+20
	bl	printf
	ldr	r3, [fp, #-448]
	sub	r3, r3, #1
	ldr	r2, [fp, #-452]
	sub	r2, r2, #1
	mul	r3, r2, r3
	str	r3, [fp, #-28]
	ldr	r3, [fp, #-44]
	ldr	r1, [fp, #-28]
	mov	r0, r3
	bl	modInverse
	str	r0, [fp, #-32]
	ldr	r1, [fp, #-32]
	ldr	r0, .L27+24
	bl	printf
	ldr	r0, .L27+28
	bl	puts
	mov	r3, #0
	str	r3, [fp, #-24]
	b	.L24
.L25:
	ldr	r3, [fp, #-24]
	lsl	r3, r3, #2
	sub	r3, r3, #12
	add	r3, r3, fp
	ldr	r3, [r3, #-432]
	ldr	r2, [fp, #-40]
	ldr	r1, [fp, #-32]
	mov	r0, r3
	bl	modExp
	str	r0, [fp, #-36]
	ldr	r1, [fp, #-36]
	ldr	r0, .L27+32
	bl	printf
	ldr	r3, [fp, #-24]
	add	r3, r3, #1
	str	r3, [fp, #-24]
.L24:
	ldr	r2, [fp, #-24]
	ldr	r3, [fp, #-16]
	cmp	r2, r3
	blt	.L25
	mov	r3, #0
	mov	r0, r3
	sub	sp, fp, #8
	@ sp needed
	pop	{r4, fp, lr}
	bx	lr
.L28:
	.align	2
.L27:
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
