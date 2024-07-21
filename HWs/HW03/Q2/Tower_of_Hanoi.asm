.LC0:
	.ascii	"Move disk %d from rod %c to rod %c\012\000"
	.text
	.align	2
	.global	towerOfHanoi
	.syntax unified
	.arm
	.type	towerOfHanoi, %function
towerOfHanoi:
	@ Function supports interworking.
	@ args = 4, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	str	r0, [fp, #-8]
	mov	r0, r1
	mov	r1, r2
	mov	r2, r3
	mov	r3, r0
	strb	r3, [fp, #-9]
	mov	r3, r1
	strb	r3, [fp, #-10]
	mov	r3, r2
	strb	r3, [fp, #-11]
	ldr	r3, [fp, #-8]
	cmp	r3, #0
	beq	.L4
	ldr	r3, [fp, #-8]
	sub	r0, r3, #1
	ldrb	ip, [fp, #-10]	@ zero_extendqisi2
	ldrb	r2, [fp, #-11]	@ zero_extendqisi2
	ldrb	r1, [fp, #-9]	@ zero_extendqisi2
	ldr	r3, [fp, #4]
	str	r3, [sp]
	mov	r3, ip
	bl	towerOfHanoi
	ldrb	r2, [fp, #-9]	@ zero_extendqisi2
	ldrb	r3, [fp, #-10]	@ zero_extendqisi2
	ldr	r1, [fp, #-8]
	ldr	r0, .L5
	bl	printf
	ldr	r3, [fp, #4]
	ldr	r3, [r3]
	add	r2, r3, #1
	ldr	r3, [fp, #4]
	str	r2, [r3]
	ldr	r3, [fp, #-8]
	sub	r0, r3, #1
	ldrb	ip, [fp, #-9]	@ zero_extendqisi2
	ldrb	r2, [fp, #-10]	@ zero_extendqisi2
	ldrb	r1, [fp, #-11]	@ zero_extendqisi2
	ldr	r3, [fp, #4]
	str	r3, [sp]
	mov	r3, ip
	bl	towerOfHanoi
	b	.L1
.L4:
	nop
.L1:
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, lr}
	bx	lr
.L6:
	.align	2
.L5:
	.word	.LC0
	.size	towerOfHanoi, .-towerOfHanoi
	.section	.rodata
	.align	2
.LC1:
	.ascii	"Enter the number of disks: \000"
	.align	2
.LC2:
	.ascii	"%d\000"
	.align	2
.LC3:
	.ascii	"Total number of moves: %d\012\000"
	.text
	.align	2
	.global	main
	.syntax unified
	.arm
	.type	main, %function
main:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	mov	r3, #0
	str	r3, [fp, #-12]
	ldr	r0, .L9
	bl	printf
	sub	r3, fp, #8
	mov	r1, r3
	ldr	r0, .L9+4
	bl	scanf
	ldr	r0, [fp, #-8]
	sub	r3, fp, #12
	str	r3, [sp]
	mov	r3, #66
	mov	r2, #67
	mov	r1, #65
	bl	towerOfHanoi
	ldr	r3, [fp, #-12]
	mov	r1, r3
	ldr	r0, .L9+8
	bl	printf
	mov	r3, #0
	mov	r0, r3
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, lr}
	bx	lr
.L10:
	.align	2
.L9:
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.size	main, .-main
