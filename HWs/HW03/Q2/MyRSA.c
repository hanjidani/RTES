#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>


// Function to calculate the greatest common divisor (GCD)
int calculateGCD(int a, int b);

// Function to find the modular inverse of e under modulo phi
int findModularInverse(int e, int phi);

// Function to perform modular exponentiation
int performModularExponentiation(int base, int exponent, int modulus);

// Function to factorize n into p and q
void factorizeNumber(int n, int *p, int *q);


int main() {
    int n, e;
    int encryptedMessages[100];
    int numMessages = 0;
    int p, q, phi, d;
    char inputBuffer[1000];

    // Input the public key (n, e) and the encrypted messages
    printf("Enter the public key (n, e): ");
    scanf("%d %d", &n, &e);
    printf("Enter the encrypted messages separated by spaces: ");
    scanf(" %[^\n]s", inputBuffer);

    // Tokenize the input string to extract each encrypted message
    char *token = strtok(inputBuffer, " ");
    while (token != NULL) {
        encryptedMessages[numMessages++] = atoi(token);
        token = strtok(NULL, " ");
    }

    // Factorize n to find p and q
    factorizeNumber(n, &p, &q);
    printf("p: %d, q: %d\n", p, q);

    // Calculate phi
    phi = (p - 1) * (q - 1);

    // Calculate the private key d
    d = findModularInverse(e, phi);
    printf("Private key d: %d\n", d);

    // Decrypt and print each message
    printf("Decrypted messages:\n");
    for (int i = 0; i < numMessages; i++) {
        int decryptedMessage = performModularExponentiation(encryptedMessages[i], d, n);
        printf("%d ", decryptedMessage);
    }

    return 0;
}



// Function to calculate the greatest common divisor (GCD)
int calculateGCD(int a, int b) {
    while (b != 0) {
        int temp = b;
        b = a % b;
        a = temp;
    }
    return a;
}

// Function to find the modular inverse of e under modulo phi
int findModularInverse(int e, int phi) {
    int m0 = phi, temp, quotient;
    int x0 = 0, x1 = 1;

    if (phi == 1)
        return 0;

    while (e > 1) {
        quotient = e / phi;
        temp = phi;

        phi = e % phi;
        e = temp;
        temp = x0;

        x0 = x1 - quotient * x0;
        x1 = temp;
    }

    if (x1 < 0)
        x1 += m0;

    return x1;
}

// Function to perform modular exponentiation
int performModularExponentiation(int base, int exponent, int modulus) {
    int result = 1;
    base = base % modulus;
    while (exponent > 0) {
        if (exponent % 2 == 1)
            result = (result * base) % modulus;
        exponent = exponent >> 1;
        base = (base * base) % modulus;
    }
    return result;
}

// Function to factorize n into p and q
void factorizeNumber(int n, int *p, int *q) {
    int i;
    double sq = sqrt(n);
    for (i = 2; i <= sq; i++) {
        if (n % i == 0) {
            *p = i;
            *q = n / i;
            return;
        }
    }
}
