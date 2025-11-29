.model small

.stack 100h

.data
msg0 db "  |-------------------------WELCOME---------------------|$"
msg1 db "  |-----------------------------------------------------|$"
msg2 db "  |-----------RSA Encryption/Decryption tool------------|$"
nl   db 0dh,0ah,"$" 
pq   db "  | Enter two prime numbers p , q : $" 
space db " , $" 
n0   db "  | n = p * q = $"
euler db "  | phi(n) = (p-1) * (q-1) = $"
e0   db "  | Choose e and must be 1<e<phi(n) and coprime with phi(n) : $"
public_key db "  | The public key is (n,e) = $"
private_key db "  | The private key is (n,d) = $"
encrypted db "  | The encrypted message :    $"
decrypted db "  | The decrypted message :    $"
msg  db "  | Enter the message : $"
d_msg  db "  | d = e^-1 mod phi(n) = $"
s1 db "  | C = m^e mod n = $"
s2 db "  | D = c^d mod n = $"
bac1 db "($"
bac2 db ")$" 
comma db ",$"

; Variables
p    db ?
q    db ?
n    dw ?
phi  dw ?
e    db ?
d    db ?
message db ?
cipher db ?
decrypted_msg db ?

; Temporary variables
base db ?
exp_temp db ?
modulus_temp dw ?
result_temp db ?

.code

    main proc far
        .startup
        
        call dash
        call new_line
        
        lea dx,msg0
        mov ah,09h
        int 21h  
        
        call new_line
        call dash 
        call new_line
        
        lea dx,msg2
        mov ah,09h
        int 21h
        
        call new_line
        call dash
        call new_line
        
        ; Get prime numbers p and q
        lea dx,pq
        mov ah,09h
        int 21h 
        
        ; Read p (up to 2 digits)
        call read_number
        mov p,al
        
        lea dx,space
        mov ah,09h
        int 21h
        
        ; Read q (up to 2 digits)
        call read_number
        mov q,al 
        
        call new_line
        
        ; Calculate and display n = p * q
        lea dx,n0
        mov ah,09h
        int 21h
        
        mov al, p
        mov bl, q
        mul bl
        mov n, ax
        call print_number
        call new_line
        
        ; Calculate and display phi = (p-1) * (q-1)
        lea dx,euler
        mov ah,09h
        int 21h
        
        mov al, p
        dec al
        mov bl, q
        dec bl
        mul bl
        mov phi, ax
        call print_number
        call new_line
        
        ; Get e
        lea dx,e0
        mov ah,09h
        int 21h 
        
        ; Read e (up to 2 digits)
        call read_number
        mov e, al
        
        call new_line
        
        ; Calculate d
        mov al, e
        mov bx, phi
        call find_modular_inverse
        mov d, al
        
        ; Display d
        lea dx,d_msg
        mov ah,09h
        int 21h
        
        mov al, d
        mov ah, 0
        call print_number
        call new_line
        
        ; Display public key (n, e)
        lea dx,public_key
        mov ah,09h
        int 21h  
        
        lea dx,bac1
        mov ah,09h
        int 21h
        
        mov ax, n
        call print_number
        
        lea dx,comma
        mov ah,09h
        int 21h
        
        mov al, e
        mov ah, 0
        call print_number
        
        lea dx,bac2
        mov ah,09h
        int 21h
        call new_line
        
        ; Display private key (n, d)
        lea dx,private_key
        mov ah,09h
        int 21h 
        
        lea dx,bac1
        mov ah,09h
        int 21h
        
        mov ax, n
        call print_number
        
        lea dx,comma
        mov ah,09h
        int 21h
        
        mov al, d
        mov ah, 0
        call print_number
        
        lea dx,bac2
        mov ah,09h
        int 21h
        call new_line
        
        ; Get message to encrypt
        lea dx,msg
        mov ah,09h
        int 21h
        
        ; Read message (up to 2 digits)
        call read_number
        mov message, al
        
        call new_line
        
        ; Encryption: cipher = message^e mod n
        lea dx,encrypted
        mov ah,09h
        int 21h 
        
        lea dx,s1
        mov ah,09h
        int 21h
        
        mov al, message
        mov bl, e
        mov cx, n
        call mod_exp
        mov cipher, al
        
        mov al, cipher
        mov ah, 0
        call print_number
        call new_line
        
        ; Decryption
        lea dx,decrypted
        mov ah,09h
        int 21h
        
        lea dx,s2
        mov ah,09h
        int 21h
        
        mov al, cipher
        mov bl, d
        mov cx, n
        call mod_exp
        mov decrypted_msg, al
        
        mov al, decrypted_msg
        mov ah, 0
        call print_number
        call new_line
        
        call dash
        call new_line
        
        .exit
         
    endp main 
    
; ==================== PROCEDURES ====================

dash proc near
    lea dx,msg1
    mov ah,09h
    int 21h
    ret
dash endp
 
 
 
new_line proc near
    lea dx,nl
    mov ah,09h
    int 21h
    ret 
new_line endp 
      
      
      
; =========== READ NUMBER (up to 2 digits) =========== 

read_number proc near
    ; Output: AL
    
    push bx
    push cx
    
    mov ah, 01h
    int 21h             ; Read first digit
    
    
    sub al, '0'         ; Convert to number
    mov bl, al          ; Store first digit in BL
    
    ; Check if there's a second digit
    mov ah, 01h
    int 21h             ; Read next character
    
    cmp al, ' '         ; Check if space 
    je single_digit
    
    
    ; second digit
    sub al, '0'         ; Convert to number
    mov cl, al          ; Store second digit in CL
    
    ; Calculate: first_digit * 10 + second_digit
    mov al, bl          ; AL = first digit
    mov bl, 10
    mul bl              ; AX = first digit * 10
    add al, cl          ; AL = first digit * 10 + second digit
    
    pop cx
    pop bx
    ret
    
    
single_digit:
    mov al, bl          ; Return single digit
    pop cx
    pop bx
    ret  
    
read_number endp

; ================= PRINT NUMBER =====================

print_number proc near
    ; Input: AX
    
    push ax
    push bx
    push cx
    push dx
    
    mov cx, 0        ; Counter for digits
    mov bx, 10       ; Divisor
    
    
push_digits:
    mov dx, 0
    div bx           ; DX:AX / 10, AX=quotient, DX=remainder
    push dx          ; Push digit
    inc cx           ; Count digits
    
    test ax, ax      ; Check if zero
    jnz push_digits  ; If not, continue
    
pop_digits:
    pop dx           ; Get digit from stack
    add dl, '0'      ; Convert to ASCII
    mov ah, 02h
    int 21h          ; Print digit
    loop pop_digits
    
print_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret    
    
print_number endp

; ============== MODULAR EXPONENTIATION ==============

mod_exp proc near
    ; Input: AL = base, BL = exponent, CX = modulus
    ; Output: AL
    
    push bx
    push cx
    push dx
    push si
    
    mov result_temp, 1     ; result = 1
    mov base, al           ; store base
    mov exp_temp, bl       ; store exponent
    mov modulus_temp, cx   ; store modulus
    
mod_loop:
    mov bl, exp_temp
    cmp bl, 0              ; while exponent > 0
    jle mod_done
    
    ; Check if exponent is odd
    test bl, 1
    jz exponent_even
    
    ; If exponent is odd: result = (result * base) mod modulus
    mov al, result_temp
    mov bl, base
    mul bl                 ; AX = result * base
    mov cx, modulus_temp
    div cl                 ; AH = (result * base) mod modulus
    mov result_temp, ah    ; store remainder
    
exponent_even:
    ; base = (base * base) mod modulus
    mov al, base
    mul al                 ; AX = base * base
    mov cx, modulus_temp
    div cl                 ; AH = (base * base) mod modulus
    mov base, ah           ; store remainder
    
    ; exponent = exponent / 2
    mov bl, exp_temp
    shr bl, 1              ; divide by 2
    mov exp_temp, bl
    
    jmp mod_loop
    
mod_done:
    mov al, result_temp
    pop si
    pop dx
    pop cx
    pop bx
    ret     
    
mod_exp endp

; ================ MODULAR INVERSE ===================

find_modular_inverse proc near
    ; Input: AL = e, BX = phi
    ; Output: AL = d
    push cx
    push dx
    push si
    
    mov cl, al          ; CL = e
    mov ch, 0           ; Start with d = 0
    
find_loop:
    inc ch              ; Try next d
    
    ; Check if (e * d) mod phi = 1
    mov al, cl          ; AL = e
    mul ch              ; AX = e * d
    mov dx, 0           ; Clear DX for division
    div bx              ; DX = (e * d) mod phi
    
    cmp dx, 1           ; Check if remainder is 1
    je found_inverse
    
    ; Prevent infinite loop - stop at 255
    cmp ch, 255
    jb find_loop
    
    ; If not found, return 1 as default (for safe)
    mov ch, 1
    
found_inverse:
    mov al, ch          ; Return d in AL
    pop si
    pop dx
    pop cx
    ret      
    
find_modular_inverse endp
                          
                          
end main