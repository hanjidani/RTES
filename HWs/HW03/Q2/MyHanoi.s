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
	.file	"MyHanoi.c"
	.text
	.align	2
	.global	createStack
	.syntax unified
	.arm
	.type	createStack, %function

@ Function: createStack
createStack:
	@ Prologue: Save frame pointer and link register, set up new frame
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	@ Store function argument r0 (capacity) in stack frame
	str	r0, [fp, #-16]
	@ Allocate memory for the stack structure (3 integers = 12 bytes)
	mov	r0, #12
	bl	malloc
	@ Store the pointer to the allocated memory in the local variable
	mov	r3, r0
	str	r3, [fp, #-8]
	@ Initialize the stack structure fields
	ldr	r3, [fp, #-8]
	ldr	r2, [fp, #-16]
	str	r2, [r3]       @ Set capacity
	ldr	r3, [fp, #-8]
	mvn	r2, #0
	str	r2, [r3, #4]  @ Set top index to -1 (mvn inverts 0 to -1)
	@ Allocate memory for the data array
	ldr	r3, [fp, #-8]
	ldr	r3, [r3]
	lsl	r3, r3, #2    @ Multiply capacity by 4 (size of int)
	mov	r0, r3
	bl	malloc
	@ Store the pointer to the allocated data array
	mov	r3, r0
	mov	r2, r3
	ldr	r3, [fp, #-8]
	str	r2, [r3, #8]  @ Set data pointer
	@ Return the stack structure pointer
	ldr	r3, [fp, #-8]
	mov	r0, r3
	@ Epilogue: Restore stack pointer, frame pointer, and return
	sub	sp, fp, #4
	pop	{fp, pc}
	.size	createStack, .-createStack

	.align	2
	.global	isFull
	.syntax unified
	.arm
	.type	isFull, %function

@ Function: isFull
isFull:
	@ Prologue: Save frame pointer, set up new frame
	str	fp, [sp, #-4]!
	add	fp, sp, #0
	sub	sp, sp, #12
	@ Store function argument r0 (stack pointer) in stack frame
	str	r0, [fp, #-8]
	@ Load top and capacity
	ldr	r3, [fp, #-8]
	ldr	r2, [r3, #4]   @ Load top
	ldr	r3, [fp, #-8]
	ldr	r3, [r3]       @ Load capacity
	sub	r3, r3, #1    @ capacity - 1
	@ Compare top and capacity - 1
	cmp	r2, r3
	@ Set result in r0: 1 if full, 0 if not full
	moveq	r3, #1
	movne	r3, #0
	and	r3, r3, #255  @ Ensure the result is 8-bit
	mov	r0, r3
	@ Epilogue: Restore stack pointer, frame pointer, and return
	add	sp, fp, #0
	ldr	fp, [sp], #4
	bx	lr
	.size	isFull, .-isFull

	.align	2
	.global	isEmpty
	.syntax unified
	.arm
	.type	isEmpty, %function

@ Function: isEmpty
isEmpty:
	@ Prologue: Save frame pointer, set up new frame
	str	fp, [sp, #-4]!
	add	fp, sp, #0
	sub	sp, sp, #12
	@ Store function argument r0 (stack pointer) in stack frame
	str	r0, [fp, #-8]
	@ Load top index
	ldr	r3, [fp, #-8]
	ldr	r3, [r3, #4]  @ Load top
	@ Check if top is -1 (stack empty)
	cmn	r3, #1        @ Compare top with -1
	@ Set result in r0: 1 if empty, 0 if not empty
	moveq	r3, #1
	movne	r3, #0
	and	r3, r3, #255  @ Ensure the result is 8-bit
	mov	r0, r3
	@ Epilogue: Restore stack pointer, frame pointer, and return
	add	sp, fp, #0
	ldr	fp, [sp], #4
	bx	lr
	.size	isEmpty, .-isEmpty

	.align	2
	.global	push
	.syntax unified
	.arm
	.type	push, %function

@ Function: push
push:
	@ Prologue: Save frame pointer and link register, set up new frame
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #8
	@ Store function arguments r0 (stack pointer) and r1 (value) in stack frame
	str	r0, [fp, #-8]
	str	r1, [fp, #-12]
	@ Check if the stack is full
	ldr	r0, [fp, #-8]
	bl	isFull
	@ Load result of isFull in r3
	mov	r3, r0
	cmp	r3, #0
	bne	.L10         @ If full, branch to .L10 (handle error)
	@ Push value onto stack
	ldr	r3, [fp, #-8]
	ldr	r2, [r3, #8]  @ Load data array pointer
	ldr	r3, [fp, #-8]
	ldr	r3, [r3, #4]  @ Load top
	add	r1, r3, #1   @ Increment top
	ldr	r3, [fp, #-8]
	str	r1, [r3, #4]  @ Store new top
	@ Calculate address of the new top element
	ldr	r3, [fp, #-8]
	ldr	r3, [r3, #4]
	lsl	r3, r3, #2    @ Multiply top by 4 (size of int)
	add	r3, r2, r3
	@ Store the value at the new top position
	ldr	r2, [fp, #-12]
	str	r2, [r3]
	b	.L7          @ Branch to .L7 (normal return)
.L10:
	nop             @ No operation (placeholder for error handling)
.L7:
	@ Epilogue: Restore stack pointer, frame pointer, and return
	sub	sp, fp, #4
	pop	{fp, pc}
	.size	push, .-push

	.align	2
	.global	pop
	.syntax unified
	.arm
	.type	pop, %function

@ Function: pop
pop:
	@ Prologue: Save frame pointer and link register, set up new frame
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #8
	@ Store function argument r0 (stack pointer) in stack frame
	str	r0, [fp, #-8]
	@ Check if the stack is empty
	ldr	r0, [fp, #-8]
	bl	isEmpty
	@ Load result of isEmpty in r3
	mov	r3, r0
	cmp	r3, #0
	beq	.L12         @ If not empty, branch to .L12 (pop value)
	@ Stack is empty, return -1
	mvn	r3, #0
	b	.L13         @ Branch to .L13 (return value)
.L12:
	@ Pop value from stack
	ldr	r3, [fp, #-8]
	ldr	r2, [r3, #8]  @ Load data array pointer
	ldr	r3, [fp, #-8]
	ldr	r3, [r3, #4]  @ Load top
	sub	r0, r3, #1   @ Decrement top
	ldr	r1, [fp, #-8]
	str	r0, [r1, #4]  @ Store new top
	@ Calculate address of the old top element
	lsl	r3, r3, #2    @ Multiply top by 4 (size of int)
	add	r3, r2, r3
	@ Load the value from the old top position
	ldr	r3, [r3]
.L13:
	@ Return the value (either popped value or -1)
	mov	r0, r3
	@ Epilogue: Restore stack pointer, frame pointer, and return
	sub	sp, fp, #4
	pop	{fp, pc}
	.size	pop, .-pop

	.section	.rodata
	.align	2
.LC0:
	.ascii	"Move disk %d from rod %c to rod %c\012\000"
	.text
	.align	2
	.global	moveDisk
	.syntax unified
	.arm
	.type	moveDisk, %function

@ Function: moveDisk
moveDisk:
	@ Prologue: Save frame pointer and link register, set up new frame
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	@ Store function arguments r0 (source stack), r1 (destination stack), r2 (source rod), r3 (destination rod) in stack frame
	str	r0, [fp, #-8]
	str	r1, [fp, #-12]
	str	r2, [fp, #-16]
	str	r3, [fp, #-20]
	@ Pop disk from source stack
	ldr	r0, [fp, #-8]
	bl	pop
	@ Store the popped disk in r3
	mov	r3, r0
	mov	r1, r3
	@ Push disk onto destination stack
	ldr	r0, [fp, #-12]
	bl	push
	@ Calculate source rod name (A, B, or C)
	ldr	r3, [fp, #-8]
	ldr	r3, [r3]
	add	r2, r3, #65
	@ Calculate destination rod name (A, B, or C)
	ldr	r3, [fp, #-12]
	ldr	r3, [r3]
	add	r3, r2, #65
	@ Print move message
	mov	r2, r3
	ldr	r1, [fp, #-16]
	ldr	r0, .L15
	bl	printf
	@ Increment move counter
	ldr	r3, [fp, #-20]
	ldr	r3, [r3]
	add	r2, r3, #1
	ldr	r3, [fp, #-20]
	str	r2, [r3]
	@ Epilogue: Restore stack pointer, frame pointer, and return
	nop
	sub	sp, fp, #4
	pop	{fp, pc}
.L16:
	.align	2
.L15:
	.word	.LC0
	.size	moveDisk, .-moveDisk

	.align	2
	.global	towerOfHanoi
	.syntax unified
	.arm
	.type	towerOfHanoi, %function

@ Function: towerOfHanoi
towerOfHanoi:
	@ Prologue: Save frame pointer and link register, set up new frame
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #24
	@ Store function arguments r0 (number of disks), r1 (source stack), r2 (destination stack), r3 (auxiliary stack) in stack frame
	str	r0, [fp, #-8]
	str	r1, [fp, #-12]
	str	r2, [fp, #-16]
	str	r3, [fp, #-20]
	@ Base case: If number of disks is 1, move the disk directly
	ldr	r3, [fp, #-8]
	cmp	r3, #1
	bne	.L18
	@ Move disk from source to destination
	ldr	r3, [fp, #4]
	mov	r2, #1
	ldr	r1, [fp, #-16]
	ldr	r0, [fp, #-12]
	bl	moveDisk
	b	.L17
.L18:
	@ Recursive case: Move n-1 disks from source to auxiliary
	ldr	r3, [fp, #-8]
	sub	r0, r3, #1
	ldr	r3, [fp, #4]
	str	r3, [sp]
	ldr	r3, [fp, #-16]
	ldr	r2, [fp, #-20]
	ldr	r1, [fp, #-12]
	bl	towerOfHanoi
	@ Move nth disk from source to destination
	ldr	r3, [fp, #4]
	ldr	r2, [fp, #-8]
	ldr	r1, [fp, #-16]
	ldr	r0, [fp, #-12]
	bl	moveDisk
	@ Move n-1 disks from auxiliary to destination
	ldr	r3, [fp, #-8]
	sub	r0, r3, #1
	ldr	r3, [fp, #4]
	str	r3, [sp]
	ldr	r3, [fp, #-12]
	ldr	r2, [fp, #-16]
	ldr	r1, [fp, #-20]
	bl	towerOfHanoi
.L17:
	@ Epilogue: Restore stack pointer, frame pointer, and return
	sub	sp, fp, #4
	pop	{fp, pc}
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

@ Function: main
main:
	@ Prologue: Save frame pointer and link register, set up new frame
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #40
	@ Store stack guard
	ldr	r3, .L25
	ldr	r3, [r3]
	str	r3, [fp, #-8]
	@ Initialize move counter to 0
	mov	r3, #0
	mov	r3, #0
	str	r3, [fp, #-28]
	@ Print prompt for number of disks
	ldr	r0, .L25+4
	bl	printf
	@ Read number of disks from user input
	sub	r3, fp, #32
	mov	r1, r3
	ldr	r0, .L25+8
	bl	__isoc99_scanf
	@ Store number of disks in local variable
	ldr	r3, [fp, #-32]
	@ Create three stacks for the rods
	mov	r0, r3
	bl	createStack
	str	r0, [fp, #-20]
	ldr	r3, [fp, #-32]
	mov	r0, r3
	bl	createStack
	str	r0, [fp, #-16]
	ldr	r3, [fp, #-32]
	mov	r0, r3
	bl	createStack
	str	r0, [fp, #-12]
	@ Push disks onto the source stack
	ldr	r3, [fp, #-32]
	str	r3, [fp, #-24]
	b	.L21
.L22:
	ldr	r1, [fp, #-24]
	ldr	r0, [fp, #-20]
	bl	push
	ldr	r3, [fp, #-24]
	sub	r3, r3, #1
	str	r3, [fp, #-24]
.L21:
	ldr	r3, [fp, #-24]
	cmp	r3, #0
	bgt	.L22
	@ Start the Tower of Hanoi algorithm
	ldr	r0, [fp, #-32]
	sub	r3, fp, #28
	str	r3, [sp]
	ldr	r3, [fp, #-12]
	ldr	r2, [fp, #-16]
	ldr	r1, [fp, #-20]
	bl	towerOfHanoi
	@ Print total number of moves
	ldr	r3, [fp, #-28]
	mov	r1, r3
	ldr	r0, .L25+12
	bl	printf
	@ Free allocated memory for the stacks and data arrays
	ldr	r3, [fp, #-20]
	ldr	r3, [r3, #8]
	mov	r0, r3
	bl	free
	ldr	r0, [fp, #-20]
	bl	free
	ldr	r3, [fp, #-16]
	ldr	r3, [r3, #8]
	mov	r0, r3
	bl	free
	ldr	r0, [fp, #-16]
	bl	free
	ldr	r3, [fp, #-12]
	ldr	r3, [r3, #8]
	mov	r0, r3
	bl	free
	ldr	r0, [fp, #-12]
	bl	free
	@ Check stack guard and return 0
	mov	r3, #0
	ldr	r2, .L25
	ldr	r1, [r2]
	ldr	r2, [fp, #-8]
	eors	r1, r2, r1
	mov	r2, #0
	beq	.L24
	bl	__stack_chk_fail
.L24:
	mov	r0, r3
	sub	sp, fp, #4
	pop	{fp, pc}
.L26:
	.align	2
.L25:
	.word	__stack_chk_guard
	.word	.LC1
	.word	.LC2
	.word	.LC3
	.size	main, .-main
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",%progbits
