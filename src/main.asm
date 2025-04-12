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

clearscreen:
	mov ah, 0x06
	mov al, 0
	mov bh, 0x07
	mov cx, 0x0000
	mov dx, 0x184F
	int 0x10
	; moving cursor to the top left position
	mov ah, 0x02
	mov bh, 0x00
	mov dh, 0x00
	mov dl, 0x00
	int 0x10
	ret

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


drawmenu:
	push cx
	push dx
	push si
	push ax
	push bx

	mov cx, 1; by default 2
.loop:
	cmp cx, max_menu
	jge .done
	
	mov ah, 0x02
	mov bh, 0x00
	mov dh, cl-1
	mov dl, 0x00
	int 0x10
	
	mov al, [current]
	cmp cl, al
	jne .not_selected
	
	;mov ah, 0x0E
	;mov al, '>'
	;int 0x10
	;jmp .draw_text
	;; this stuff could add another one '>' symbol

.not_selected:
	mov ah, 0x0E
	mov al, ' '
	int 0x10

.draw_text:
	mov bx, 0
	je .got_item
.next_item:
	cmp bx,0
	je .got_item
.skip:
	lodsb
	cmp al, 0
	jne .skip
	dec bx
	jmp .next_item

.got_item:
	mov al, [current]
	cmp cl, al
	je .this
	;mov ah, 0x0e
	;mov al, '>'
	;int 0x10
	inc cx
	jmp .loop
.this:
	mov ah, 0x0e
	mov al, '>'
	int 0x10
.done:
	pop ax
	pop bx
	pop si
	pop dx
	pop cx
	ret		



changeOption:
	push si
	push ax

	

gotolinestart:
	push ax
.do:
	mov ah, 0x0e
	mov al, 0x0D
	mov bh, 0
	int 0x10
	jmp .done
.done:
	pop ax
	ret



work:
	push si
	push ax
.do:
	xor ah, ah
	int 0x16
	cmp ah, 0x48
	je .go_top
	cmp ah, 0x50
	je .go_bottom
	jmp .do
.go_top:
	mov al, [current]
	cmp al, [possible_min]
	jne .increase
	je .do_nothing
.do_nothing:
	jmp .done
.increase:
	mov al, [current]
	dec al
	mov [current], al
	jmp .done
.go_bottom:
	mov al, [current]
	cmp al, [possible_max]
	jne .decrease
	je .do_nothing
.decrease:
	mov al, [current]
	inc al
	mov [current], al
	jmp .done
.done:
	pop si
	pop ax
	jmp start
	;jmp start ; redrawing whole menu. It is not that heavy at the moment so I can do like that
	ret
	


main:
	
	mov ax, 0
	mov ds, ax
	mov es, ax

	mov ss, ax
	mov sp, 0x7C00	

	call clearscreen
	;call drawmenu	
	;mov ah, 0x06
	;mov al, 0
	;mov bh, 0x07
	;mov cx, 0x0000
	;mov dx, 0x184F
	;int 0x10

	;mov si, bootloadername
	;call puts

	mov si, bootloadername
	call puts
	
	mov si, 0x0A
	call puts
	mov si, 0x0D
	call puts

	mov si, header
	call puts
	
	; printing message
	mov si, message
	call puts
	
	mov si, msg
	call puts
	
	mov si, msg_two
	call puts

	mov si, msg_three
	call puts

	mov si, 0x0A
	call puts
	mov si, 0x0D
	call puts

	;mov si, ; IDK what it was supposed to do, lmao

	call gotolinestart

	call drawmenu
	
	call work
	
	;mov si, current
	;add si, 5
	;mov ah, 7
	;mul si
	;call puts

	hlt
	
	jmp $

.halt:
	jmp .halt


message 	db "    Arch Linux", ENDL, 0
msg 		db "    WaxusBS", ENDL, 0
msg_two 	db "    Gentoo Linux", ENDL, 0
msg_three 	db "    Debian Linux", ENDL, 0
bootloadername		db "LoaDuck Bootloader", ENDL, ENDL, ENDL, 0
header 		db "Select boot option: ", ENDL, ENDL, 0

possible_min db 5
possible_max db 8
current db 6

max_menu equ 9

times 510-($-$$) db 0
dw 0AA55h 
