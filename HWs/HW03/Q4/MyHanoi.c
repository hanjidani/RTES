#include <stdio.h>
#include <stdlib.h>

typedef struct {
    int size;
    int top;
    int *arr;
} Stack;

Stack* createStack(int size) {
    Stack* stack = (Stack*)malloc(sizeof(Stack));
    stack->size = size;
    stack->top = -1;
    stack->arr = (int*)malloc(stack->size * sizeof(int));
    return stack;
}

int isFull(Stack* stack) {
    return stack->top == stack->size - 1;
}

int isEmpty(Stack* stack) {
    return stack->top == -1;
}

void push(Stack* stack, int item) {
    if (isFull(stack))
        return;
    stack->arr[++stack->top] = item;
}

int pop(Stack* stack) {
    if (isEmpty(stack))
        return -1;
    return stack->arr[stack->top--];
}

void moveDisk(Stack* from, Stack* to, int disk, int* move_count) {
    push(to, pop(from));
    printf("Move disk %d from rod %c to rod %c\n", disk, 'A' + from->size - from->top - 2, 'A' + to->size - to->top - 1);
    (*move_count)++;
}

void towerOfHanoi(int n, Stack* source, Stack* destination, Stack* auxiliary, int* move_count) {
    if (n == 1) {
        moveDisk(source, destination, 1, move_count);
        return;
    }

    towerOfHanoi(n - 1, source, auxiliary, destination, move_count);
    moveDisk(source, destination, n, move_count);
    towerOfHanoi(n - 1, auxiliary, destination, source, move_count);
}

int main() {
    int n;
    int move_count = 0;

    printf("Enter the number of disks: ");
    scanf("%d", &n);

    Stack* source = createStack(n);
    Stack* destination = createStack(n);
    Stack* auxiliary = createStack(n);

    for (int i = n; i >= 1; i--) {
        push(source, i);
    }

    towerOfHanoi(n, source, destination, auxiliary, &move_count);

    printf("Total number of moves: %d\n", move_count);

    free(source->arr);
    free(source);
    free(destination->arr);
    free(destination);
    free(auxiliary->arr);
    free(auxiliary);

    return 0;
}
