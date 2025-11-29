# RSA_mini-version
##RSA-Encryption-Decryption-Tool-Assembly Language
---

## Overview

This is an 8086 Assembly language implementation of the RSA encryption and decryption algorithm. The program demonstrates public-key cryptography by generating RSA keys, encrypting messages, and decrypting ciphertext.

## Features

- **Key Generation**: Automatically calculates public and private keys
- **Encryption**: Encrypts messages using the public key
- **Decryption**: Decrypts ciphertext using the private key
- **User Interface**: Interactive console interface with formatted output

## How It Works

### Algorithm Steps

1. Input two prime numbers (p and q)
2. Calculate n = p × q
3. Calculate Euler's totient function: φ(n) = (p-1) × (q-1)
4. Choose public exponent e such that:
   - 1 < e < φ(n)
   - e is coprime with φ(n)
5. Calculate private exponent d as the modular inverse: d ≡ e⁻¹ mod φ(n)
6. Encryption: C ≡ Mᵉ mod n
7. Decryption: M ≡ Cᵈ mod n

### Key Components

- **Public Key**: (n, e)
- **Private Key**: (n, d)

## Program Structure

### Data Segment

**Messages and prompts** for user interface

**Variables** for RSA parameters:
- `p`, `q`: Prime numbers
- `n`: Modulus
- `phi`: Euler's totient function
- `e`: Public exponent
- `d`: Private exponent
- `message`: Original message
- `cipher`: Encrypted message
- `decrypted_msg`: Decrypted message

### Procedures

1. **`main`**: Main program flow
2. **`dash`**: Display separator lines
3. **`new_line`**: Print new line
4. **`read_number`**: Read 1-2 digit numbers from input
5. **`print_number`**: Display numbers
6. **`mod_exp`**: Modular exponentiation (for encryption/decryption)
7. **`find_modular_inverse`**: Calculate modular inverse for private key

## Getting Started

### Example Usage

```
  |-------------------------WELCOME---------------------|
  |-----------------------------------------------------|
  |-----------RSA Encryption/Decryption tool------------|
  |-----------------------------------------------------|
  | Enter two prime numbers p , q : 7 , 11
  | n = p * q = 77
  | phi(n) = (p-1) * (q-1) = 60
  | Choose e and must be 1<e<phi(n) and coprime with phi(n) : 7
  | d = e^-1 mod phi(n) = 43
  | The public key is (n,e) = (77,7)
  | The private key is (n,d) = (77,43)
  | Enter the message : 5
  | The encrypted message :    C = m^e mod n = 47
  | The decrypted message :    D = c^d mod n = 5
  |-----------------------------------------------------|
```

## Limitations

- **Small Numbers Only**: Due to 8-bit/16-bit register constraints, works only with small prime numbers
- **Educational Purpose**: Not suitable for real-world encryption
