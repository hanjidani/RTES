#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

// Function to calculate gcd
int gcd(int a, int b) {
    while (b != 0) {
        int t = b;
        b = a % b;
        a = t;
    }
    return a;
}

// Function to find modular inverse of e under modulo phi
int modInverse(int e, int phi) {
    int m0 = phi, t, q;
    int x0 = 0, x1 = 1;

    if (phi == 1)
        return 0;

    while (e > 1) {
        q = e / phi;
        t = phi;

        phi = e % phi;
        e = t;
        t = x0;

        x0 = x1 - q * x0;
        x1 = t;
    }

    if (x1 < 0)
        x1 += m0;

    return x1;
}

// Function to perform modular exponentiation
int modExp(int base, int exp, int mod) {
    int result = 1;
    base = base % mod;
    while (exp > 0) {
        if (exp % 2 == 1)
            result = (result * base) % mod;
        exp = exp >> 1;
        base = (base * base) % mod;
    }
    return result;
}

// Function to factorize n into p and q
void factorize(int n, int *p, int *q) {
    int i;
    for (i = 2; i <= sqrt(n); i++) {
        if (n % i == 0) {
            *p = i;
            *q = n / i;
            return;
        }
    }
}

int main() {
    int n, e;
    int encrypted_messages[100]; // Assuming at most 100 encrypted messages
    int num_messages = 0;
    int p, q, phi, d;
    char input[1000]; // Input buffer assuming a maximum input length of 1000 characters

    // Input the public key (n, e) and the encrypted messages
    printf("Enter the public key (n, e): ");
    scanf("%d %d", &n, &e);
    printf("Enter the encrypted messages separated by spaces: ");
    scanf(" %[^\n]s", input);

    // Tokenize the input string to extract each encrypted message
    char *token = strtok(input, " ");
    while (token != NULL) {
        encrypted_messages[num_messages++] = atoi(token);
        token = strtok(NULL, " ");
    }

    // Factorize n to find p and q
    factorize(n, &p, &q);
    printf("p: %d, q: %d\n", p, q);

    // Calculate phi
    phi = (p - 1) * (q - 1);

    // Calculate the private key d
    d = modInverse(e, phi);
    printf("Private key d: %d\n", d);

    // Decrypt and print each message
    printf("Decrypted messages:\n");
    for (int i = 0; i < num_messages; i++) {
        int decrypted_message = modExp(encrypted_messages[i], d, n);
        printf("%d ", decrypted_message);
    }

    return 0;
}
