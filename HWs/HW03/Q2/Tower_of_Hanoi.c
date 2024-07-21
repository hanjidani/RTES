#include <stdio.h>

void towerOfHanoi(int n, char from_rod, char to_rod, char aux_rod, int *move_count) {
    if (n == 0) {
        return;
    }
    towerOfHanoi(n - 1, from_rod, aux_rod, to_rod, move_count);
    printf("Move disk %d from rod %c to rod %c\n", n, from_rod, to_rod);
    (*move_count)++;
    towerOfHanoi(n - 1, aux_rod, to_rod, from_rod, move_count);
}

int main() {
    int n;
    int move_count = 0;

    printf("Enter the number of disks: ");
    scanf("%d", &n);

    towerOfHanoi(n, 'A', 'C', 'B', &move_count);

    printf("Total number of moves: %d\n", move_count);

    return 0;
}
