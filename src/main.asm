org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

start:
	jmp main

;
; prints a string to the screen
; params:
; 	- ds:si points to string
;
puts:
	; save registers we will modify
	push si
	push ax

.loop:
	lodsb 		; loads bytes from ds:si to al/ax/eax
	or al, al 	; verify if al next char is null
	jz .done

;	cmp al, 0x0A
;	je newline

	mov ah, 0x0e	
	mov bh,0	

	int 0x10

	jmp .loop

.done:
	pop ax
	pop si
	ret	

newline:
	mov al, 0x0D
	mov ah, 0x0E
	int 0x10
	
	mov al, 0x0A
	mov ah, 0x0E	
	int 0x10

	ret

main:
	
	mov ax, 0
	mov ds, ax
	mov es, ax

	mov ss, ax
	mov sp, 0x7C00	
	
	; printing message
	mov si, message
	call puts
	
	mov si, msg
	call puts
	
	mov si, msg_two
	call puts

	mov si, msg_three
	call puts

	hlt
	
	jmp $

.halt:
	jmp .halt


message db "Arch Linux", ENDL, 0
msg db "WaxusBS", ENDL, 0
msg_two db "Gentoo Linux", ENDL, 0
msg_three db "Debian Linux", ENDL, 0

times 510-($-$$) db 0
dw 0AA55h 
