[org 0x0100]

jmp start

title_game: db 'ALPHABET COLLECTOR', 0
new_game: db 'New Game', 0
single_player: db 'Single Player', 0
multiplayer: db 'Multiplayer', 0
end_game: db 'End Game' , 0
timer: db 'TIMER: ', 0
score: db 'SCORE: ', 0
Single: db 'Press S for Single Player' , 0
Multi: db 'Press M for Multi Player' , 0
Missed: db 'MISSED: ', 0
GAMEOVER: db 'GAME IS OVER', 0
Restart: db 'Press P to play again and E to end', 0
Scorecount: dw 0
missedcount: dw 0
timercount: dw 0
timercount2: dw 0
multi: dw 0
shiftpressed: dw 0
col2: dw 10000
col: dw 3920
char1T: dw 0
char2T: dw 0
char6T: dw 0
char7T: dw 0
char5T: dw 0

oldkb: dd 0
oldtimer: dd 0
lives: dw 0
gameover: dw 0

rand: dw 0
randnum: dw 7
char1_offset: dw 0
char2_offset: dw 0

char5_offset: dw 0
char6_offset: dw 0
char7_offset: dw 0

character1: dw '0'
character2: dw '0'

character5: dw '0'
character6: dw '0'
character7: dw '0'


printNumber:
    push bp
    mov bp, sp
    push es
    push ax
    push bx
    push cx
    push dx
    push di
	push 0xb800
	pop es
    mov ax, [bp+4] ; load number in ax
    mov bx, 10 ; use base 10 for division
    mov cx, 0 ; initialize count of digits
	
nextDigit:
    mov dx, 0 ; zero upper half of dividend
    div bx ; divide by 10
    add dl, 0x30 ; convert digit into ascii value
    push dx ; save ascii value on stack
    inc cx ; increment count of values
    cmp ax, 0 ; is the quotient zero
    jnz nextDigit ; if no divide it again
    mov di, [bp+6] ; point di to 70th column
	
nextPosition:
    pop dx ; remove a digit from the stack
    mov dh, 0x07 ; use normal attribute
    mov [es:di], dx ; print char on screen
    add di, 2 ; move to next screen location
    loop nextPosition ; repeat for all digits on stack
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop es
    pop bp
    ret 4
	
	
kbisr:
    pusha

    mov ax, 0xb800
    mov es, ax
    in al, 0x60         ; Read keyboard input

    cmp al, 0x01        ; ESC key
    je set_gameover

    cmp al, 0x2A        ; Left Shift make code
    je set_shift_pressed

    cmp al, 0xAA        ; Left Shift break code
    je reset_shift_pressed
	
;	cmp al, 0x36        ; Right Shift make code
;	je set_shift_pressed
	
;	cmp al, 0xB6        ; Right Shift break code
;	je reset_shift_pressed

    cmp al, 0x4B        ; Left Arrow key
    je handle_left_arrow

    cmp al, 0x4D        ; Right Arrow key
    je handle_right_arrow

    cmp al, 0x1E        ; 'A' key
    je handle_A
	
    cmp al, 0x20        ; 'D' key
    je handle_D

    jmp exitkbisr       ; Ignore other keys and exit

set_gameover:
    mov word[gameover], 1
    jmp exitkbisr

set_shift_pressed:
    mov word[shiftpressed], 1
    jmp exitkbisr

reset_shift_pressed:
    mov word[shiftpressed], 0
    jmp exitkbisr

handle_left_arrow:
    cmp word[shiftpressed], 1
    je move_box_left_fast       ; Move box at double speed
    jmp move_box_left           ; Move box at normal speed

handle_right_arrow:
    cmp word[shiftpressed], 1
    je move_box_right_fast      ; Move box at double speed
    jmp move_box_right          ; Move box at normal speed
	
handle_A:
    cmp word[shiftpressed], 1
    je move_box2_left_fast       ; Move box at double speed
    jmp move_box2_left           ; Move box at normal speed

handle_D:
    cmp word[shiftpressed], 1
    je move_box2_right_fast      ; Move box at double speed
    jmp move_box2_right 	

move_box2_left:
    sub word[col2], 2           ; Decrease column position
    cmp word[col2], 3840        ; Check if it goes beyond the left edge
    jl reset_left2              ; Reset if it’s out of bounds
    jmp update_screen
	
	
move_box2_left_fast:
    sub word[col2], 4          ; Decrease column position
    cmp word[col2], 3840        ; Check if it goes beyond the left edge
    jl reset_left2              ; Reset if it’s out of bounds
    jmp update_screen	

move_box_left:
    sub word[col], 2            ; Decrease column position
    cmp word[col], 3840         ; Check if it goes beyond the left edge
    jl reset_left               ; Reset if it’s out of bounds
    jmp update_screen

move_box_left_fast:
    sub word[col], 4            ; Decrease column position with double speed
    cmp word[col], 3840         ; Check if it goes beyond the left edge
    jl reset_left               ; Reset if it’s out of bounds
    jmp update_screen

move_box_right:
    add word[col], 2            ; Increase column position
    cmp word[col], 3998         ; Check if it goes beyond the right edge
    jg reset_right              ; Reset if it’s out of bounds
    jmp update_screen

move_box_right_fast:
    add word[col], 4            ; Increase column position with double speed
    cmp word[col], 3998         ; Check if it goes beyond the right edge
    jg reset_right              ; Reset if it’s out of bounds
    jmp update_screen

move_box2_right:
    add word[col2], 2           ; Increase column position
    cmp word[col2], 3998        ; Check if it goes beyond the right edge
    jg reset_right2             ; Reset if it’s out of bounds
    jmp update_screen
	
	
move_box2_right_fast:
    add word[col2], 4          ; Increase column position
    cmp word[col2], 3998        ; Check if it goes beyond the right edge
    jg reset_right2             ; Reset if it’s out of bounds
    jmp update_screen	

reset_left:
    mov word[col], 3998
    jmp update_screen

reset_left2:
    mov word[col2], 3998
    jmp update_screen

reset_right:
    mov word[col], 3840
    jmp update_screen

reset_right2:
    mov word[col2], 3840
    jmp update_screen

update_screen:
    call clearbox
    call box                    ; Redraw box at the new position
    call box2
    jmp exitkbisr

exitkbisr:
    mov al, 0x20
    out 0x20, al
    popa
    iret
	
timerisr:
;call Alphabetsdrop
;jmp far[cs:oldtimer]
mov al,0x20
out 0x20,al
iret
;-----------------------------------------
sleep1:
pusha
pushf

mov cx,600
mydelay1:
mov bx,10   ; increase this number if you want to add more delay, and decrease this number if you want to reduce delay.
mydelay11:
dec bx
jnz mydelay11
loop mydelay1

popf
popa
ret

sleep2:
pusha
pushf

mov cx,200
mydelay2:
mov bx,30   ; increase this number if you want to add more delay, and decrease this number if you want to reduce delay.
mydelay22:
dec bx
jnz mydelay22
loop mydelay2

popf
popa
ret

sleep3:
pusha
pushf

mov cx,100
mydelay3:
mov bx,50    ; increase this number if you want to add more delay, and decrease this number if you want to reduce delay.
mydelay33:
dec bx
jnz mydelay33
loop mydelay3

popf
popa
ret

sleep4:
pusha
pushf

mov cx,400
mydelay4:
mov bx,500   ; increase this number if you want to add more delay, and decrease this number if you want to reduce delay.
mydelay44:
dec bx
jnz mydelay44
loop mydelay4

popf
popa
ret

sleep5:
pusha
pushf

mov cx,100
mydelay5:
mov bx,300    ; increase this number if you want to add more delay, and decrease this number if you want to reduce delay.
mydelay55:
dec bx
jnz mydelay55
loop mydelay5

popf
popa
ret

sleep6:
pusha
pushf

mov cx,700
mydelay6:
mov bx,700    ; increase this number if you want to add more delay, and decrease this number if you want to reduce delay.
mydelay66:
dec bx
jnz mydelay66
loop mydelay6

popf
popa
ret

sleep7:
pusha
pushf

mov cx,80
mydelay7:
mov bx,80   ; increase this number if you want to add more delay, and decrease this number if you want to reduce delay.
mydelay77:
dec bx
jnz mydelay77
loop mydelay7

popf
popa
ret

str_length:
    push bp
    mov bp, sp
    push es
    push ax
    push di

    les di, [bp + 4]      
    mov cx, 0xffff
    xor al, al            
    repne scasb          
    mov ax, 0xffff
    sub ax, cx          
    mov cx, ax            

    pop di
    pop ax
    pop es
    pop bp
    ret 4      


clear_screen:
    pusha
    mov ax, 0xb800        
    mov es, ax
    xor di, di            
    mov ax, 0x0720      
    mov cx, 2000        
    cld                    
    rep stosw            
    popa
    ret

Title_Game:

    push bp
mov bp, sp
    pusha
    push es
    push si
    push di


mov ax, 0xb800
    mov es, ax
mov ax, 80
mul byte [bp+4]
add ax, 20
shl ax, 1
mov di, ax

mov si, [bp+8]
mov ah, 0x81
mov cx, [bp+6]

print_title:
    lodsb
stosw
add di, 2
loop print_title

pop di
pop si
pop es
popa
pop bp
ret 4


New_Game:
    push bp
    mov bp, sp
    pusha
    push es
    push si
    push di


mov ax, 0xb800
    mov es, ax
mov ax, 80
mul byte [bp+4]
add ax, 33
shl ax, 1
mov di, ax

mov si, [bp+8]
mov ah, 0x07
mov cx, [bp+6]

print_newgame:
    lodsb
stosw
loop print_newgame

pop di
pop si
pop es
popa
pop bp
ret 4

Game_Over:
    push bp
    mov bp, sp
    pusha
    push es
    push si
    push di


mov ax, 0xb800
mov es, ax
mov ax, 80
mul byte [bp+4]
add ax, 33
shl ax, 1
mov di, ax

mov si, [bp+8]
mov ah, 0x07
mov cx, [bp+6]

print_gameover:
lodsb
stosw
loop print_gameover

pop di
pop si
pop es
popa
pop bp
ret 4

Restart_Game:
    push bp
    mov bp, sp
    pusha
    push es
    push si
    push di

mov ax, 0xb800
mov es, ax
mov ax, 80
mul byte [bp+4]
add ax, 22
shl ax, 1
mov di, ax

mov si, [bp+8]
mov ah, 0x07
mov cx, [bp+6]

print_restart:
lodsb
stosw
loop print_restart

pop di
pop si
pop es
popa
pop bp
ret 4

Single_player:
    push bp
mov bp, sp
    pusha
    push es
    push si
    push di

mov ax, 0xb800
    mov es, ax
mov ax, 80
mul byte [bp+4]
add ax, 31
shl ax, 1
mov di, ax

mov si, [bp+8]
mov ah, 0x07
mov cx, [bp+6]

print_singleplayer:
    lodsb
stosw
loop print_singleplayer

    pop di
pop si
pop es
popa
pop bp
ret 4


Display_multiplayer:
    push bp
mov bp, sp
    pusha
    push es
    push si
    push di

mov ax, 0xb800
    mov es, ax
mov ax, 80
mul byte [bp+4]
add ax, 32
shl ax, 1
mov di, ax

mov si, [bp+8]
mov ah, 0x07
mov cx, [bp+6]

print_multiplayer:
    lodsb
stosw
loop print_multiplayer

    pop di
pop si
pop es
popa
pop bp
ret 4


End_Game:
    push bp
mov bp, sp
    pusha
    push es
    push si
    push di


mov ax, 0xb800
    mov es, ax
mov ax, 80
mul byte [bp+4]
add ax, 33
shl ax, 1
mov di, ax

mov si, [bp+8]
mov ah, 0x07
mov cx, [bp+6]

print_endgame:
    lodsb
stosw
loop print_endgame

    pop di
pop si
pop es
popa
pop bp
ret 4

clearbox:
    push ax
    push 0xb800
	pop es
    mov di, 3840
	mov ax, 0x0720
	mov cx, 2000
	cld
	rep stosw
    pop ax
    ret

AskS:

    push bp
    mov bp, sp
    pusha
    push es
    push si
    push di

mov ax, 0xb800
    mov es, ax
mov ax, 80
mul byte [bp+4]
add ax, 28
shl ax, 1
mov di, ax

mov si, [bp+8]
mov ah, 0x07
mov cx, [bp+6]

print_S:
lodsb
stosw
loop print_S

    pop di
pop si
pop es
popa
pop bp
ret 4


AskM:
    push bp
    mov bp, sp
    pusha
    push es
    push si
    push di

mov ax, 0xb800
    mov es, ax
mov ax, 80
mul byte [bp+4]
add ax, 28
shl ax, 1
mov di, ax

mov si, [bp+8]
mov ah, 0x07
mov cx, [bp+6]

print_M:
lodsb
stosw
loop print_M

    pop di
pop si
pop es
popa
pop bp
ret 4

box:
    push bp
    mov bp, sp
    pusha
    push es
    mov ax, 0xb800       
    mov es, ax
    mov ax, word [col]  

    mov di, ax          
    mov ah, 0x07        
    mov al, 0xDC        
    stosw               
    pop es
    popa
    pop bp
    ret

box2:
    push bp
    mov bp, sp
    pusha
    push es
    mov ax, 0xb800      
    mov es, ax
    mov ax, word [col2] 

    mov di, ax           
    mov ah, 0x04      
    mov al, 0xDC       
    stosw               
    pop es
    popa
    pop bp
    ret

print_timer:
    push bp
mov bp, sp
    pusha
    push es
    push si
    push di


mov ax, 0xb800
    mov es, ax
mov ax, 80
mul byte [bp+4]
add ax, 68
shl ax, 1
mov di, ax

mov si, [bp+8]
mov ah, 0x07
mov cx, [bp+6]

Print_timer:
    lodsb
stosw
loop Print_timer

    pop di
pop si
pop es
popa
pop bp
ret 4

print_missed:
    push bp
mov bp, sp
    pusha
    push es
    push si
    push di


mov ax, 0xb800
    mov es, ax
mov ax, 80
mul byte [bp+4]
add ax, 0
shl ax, 1
mov di, ax

mov si, [bp+8]
mov ah, 0x07
mov cx, [bp+6]

Print_missed:
    lodsb
stosw
loop Print_missed

    pop di
pop si
pop es
popa
pop bp
ret 4



print_score:
    push bp
mov bp, sp
    pusha
    push es
    push si
    push di


mov ax, 0xb800
    mov es, ax
mov ax, 80
mul byte [bp+4]
add ax, 68
shl ax, 1
mov di, ax

mov si, [bp+8]
mov ah, 0x07
mov cx, [bp+6]

Print_score:
    lodsb
stosw
loop Print_score

    pop di
pop si
pop es
popa
pop bp
ret 4
;---------------------------------------------------ALPHABETS Dropping below

randG:
   push bp
   mov bp, sp
   pusha
   cmp word [rand], 0
   jne next

  MOV     AH, 00h   ; interrupt to get system timer in CX:DX
  INT     1AH
  inc word [rand]
  mov     [randnum], dx
  jmp next1

  next:
  mov     ax, 25173          ; LCG Multiplier
  mul     word  [randnum]     ; DX:AX = LCG multiplier * seed
  add     ax, 13849          ; Add LCG increment value
  ; Modulo 65536, AX = (multiplier*seed+increment) mod 65536
  mov     [randnum], ax          ; Update seed = return value

 next1:xor dx, dx
 mov ax, [randnum]
 mov cx, [bp+4]
 inc cx
 div cx
 
 mov [bp+6], dx
 popa
 pop bp
 ret 2

Alphabetsdrop:


printchar:
push bp
mov bp,sp
push es
pusha
mov ax,0xb800
mov es,ax
mov ax,310
push ax
push word[Scorecount]
call printNumber

cmp word[gameover],1
je endalpha
jmp movedown

char1:
sub sp,2
push 80
call randG
pop ax
shl ax,1
add ax,54
add ax, 320 ; to start from third row
   
mov di,ax
mov word[char1_offset],di  
mov ax,0
sub sp,2
push 25
call randG
pop dx

mov ax,dx
mov ah,07
add al,'A'                    ; converting into a character
mov word[character1],ax       ; save the character in memory
 call sleep1                  
mov dx,0

ret

char2:


sub sp,2
push 80
call randG
pop ax
shl ax,1
add ax,128
add ax, 320

mov word[char2_offset],ax
mov di,ax
mov ax,0

sub sp,2
push 25
call randG
pop dx



mov ax,dx
mov ah,07
add al,'A'
mov word[character2],ax
call sleep2
mov dx,0

ret
;----------------------------
char5:
sub sp,2
push 80
call randG
pop ax
shl ax,1
add ax,88
add ax, 320

mov word[char5_offset],ax
mov di,ax
mov ax,0

sub sp,2
push 25
call randG
pop dx


;-----------------------------
mov ax,dx
mov ah,07
add al,'A'
mov word[character5],ax

mov dx,0
ret
;--------------------------------

char6:

sub sp,2
push 80
call randG
pop ax
shl ax,1
add ax,22
add ax, 320

mov word[char6_offset],ax
mov di,ax
mov ax,0

sub sp,2
push 25
call randG
pop dx


;-----------------------------
mov ax,dx
mov ah,07
add al,'A'
mov word[character6],ax

mov dx,0
ret

char7:
sub sp,2
push 80
call randG
pop ax
shl ax,1
add ax, 110
add ax, 320

mov word[char7_offset],ax
mov di,ax
mov ax,0

sub sp,2
push 25
call randG
pop dx


;-----------------------------
mov ax,dx
mov ah,07
add al,'A'
mov word[character7],ax

mov dx,0
ret

movedown:
cmp word[gameover],1
je endalpha
call box

move1:
inc word[char1T]
cmp word[Scorecount],7
jbe reg1
cmp word[char1T], 4000
jne move2
jmp reg11
reg1:
cmp word[char1T], 8000
jne move2
reg11:
mov word[char1T],0
mov di,[char1_offset]
mov ax,0x0720
mov [es:di],ax

mov ah, 0x04        ;red
add di,160
cmp di,4000
jb mv1
call char1

mv1:
mov al,[character1]
mov [es:di],ax
mov [char1_offset],di
mov ax,di
cmp ax, word[col]
je score_increment1
cmp ax, word[col2]
je score_increment1
jmp move1skip

score_increment1:
inc word[Scorecount]
push 310
push word[Scorecount]
call printNumber
call box
call box2

move1skip:
add di,160
cmp di,4000
jb nomiss1
inc word[missedcount]
push 16
push word[missedcount]
call printNumber

nomiss1:
sub di,160
cmp word[gameover],1
je endalpha
cmp word[missedcount],10
je endalpha
cmp word[Scorecount],10
je endalpha

;-----------------------------------------------------
move2:
inc word[char2T]
cmp word[Scorecount],7
jbe reg2
cmp word[char2T],4000
jne move5
jmp reg22
reg2:
cmp word[char2T],8000
jne move5
reg22:
mov word[char2T],0
mov di,[char2_offset]
mov ax,0x0720
mov [es:di],ax

mov ah, 0x0E      ;yelloe
add di,160
cmp di,4000
jb mv2
call char2

mv2:
mov al,[character2]
mov [es:di],ax
mov [char2_offset],di
call sleep2
mov ax,di
cmp ax, word[col]
je score_increment2
cmp ax, word[col2]
je score_increment2
jmp move2skip

score_increment2:
inc word[Scorecount]
push 310
push word[Scorecount]
call printNumber
call box
call box2


move2skip:
add di,160
cmp di,4000
jb nomiss2
inc word[missedcount]
push 16
push word[missedcount]
call printNumber

nomiss2:
sub di,160
cmp word[gameover],1
je endalpha
cmp word[missedcount],10
je endalpha
cmp word[Scorecount],10
je endalpha

;-----------------------------------------------------
move5:
inc word[char5T]
cmp word[Scorecount],7
jbe reg5
cmp word[char5T],2500
jne move6
jmp reg55
reg5:
cmp word[char5T],5000
jne move6
reg55:
mov word[char5T],0
mov di,[char5_offset]
mov ax,0x0720
mov [es:di],ax
mov ah, 0x05                 ;pink
add di,160
cmp di,4000
jb mv5
call char5

mv5:
mov al,[character5]
mov [es:di],ax
mov [char5_offset],di

mov ax,di
cmp ax, word[col]
je score_increment5
cmp ax, word[col2]
je score_increment5
jmp move5skip

score_increment5:
inc word[Scorecount]
push 310
push word[Scorecount]
call printNumber
call box
call box2

move5skip:
add di,160
cmp di,4000
jb nomiss5
inc word[missedcount]
push 16
push word[missedcount]
call printNumber

nomiss5:
sub di,160
cmp word[gameover],1
je endalpha
cmp word[missedcount],10
je endalpha
cmp word[Scorecount],10
je endalpha

;-----------------------------------------------------
move6:
inc word[char6T]
cmp word[Scorecount],7
jbe reg6
cmp word[char6T],3500
jne move7
jmp reg66
reg6:
cmp word[char6T],7000
jne move7
reg66:
mov word[char6T],0
mov di,[char6_offset]
mov ax,0x0720
mov [es:di],ax
mov ah, 0x03                 ;green
add di,160
cmp di,4000
jb mv6
call char6

mv6:
mov al,[character6]
mov [es:di],ax
mov [char6_offset],di

mov ax,di
cmp ax, word[col]
je score_increment6
cmp ax, word[col2]
je score_increment6
jmp move6skip

score_increment6:
inc word[Scorecount]
push 310
push word[Scorecount]
call printNumber
call box
call box2

move6skip:
add di,160
cmp di,4000
jb nomiss6
inc word[missedcount]
push 16
push word[missedcount]
call printNumber

nomiss6:
sub di,160
cmp word[gameover],1
je endalpha
cmp word[missedcount],10
je endalpha
cmp word[Scorecount],10
je endalpha


;-----------------------------------------------------
move7:
inc word[char7T]
cmp word[Scorecount],7
jbe reg7
cmp word[char7T],5000
jne endalpha
jmp reg77
reg7:
cmp word[char7T],10000

jne endalpha
reg77:
mov word[char7T],0
mov di,[char7_offset]
mov ax,0x0720
mov [es:di],ax
mov ah, 0x07                ;grey
add di,160
cmp di,4000
jb mv7
call char7
mv7:

mov al,[character7]
mov [es:di],ax
mov [char7_offset],di

mov ax,di
cmp ax, word[col]
je score_increment7
cmp ax, word[col2]
je score_increment7
jmp move7skip

score_increment7:
inc word[Scorecount]
push 310
push word[Scorecount]
call printNumber
call box
call box2


move7skip:
add di,160
cmp di,4000
jb nomiss7
inc word[missedcount]
push 16
push word[missedcount]
call printNumber

nomiss7:
sub di,160
cmp word[gameover],1
je endalpha
cmp word[missedcount],10
je endalpha
cmp word[Scorecount],10
je endalpha

timer_print:
add word [timercount], 1
cmp word [timercount], 3 ; increasing number will decrease speed
je print_t
jne endalpha

print_t:
mov word[timercount],0
add word [timercount2], 1
push 150
push word[timercount2]
call printNumber
   
endalpha:
call box
call box2
cmp word[multi],1
jne skipmulti
cmp word[missedcount],20
jne checkscore
mov word[gameover],1
jmp checkscore
skipmulti:
cmp word[missedcount],10
jne checkscore
mov word[gameover],1

checkscore:
cmp word[Scorecount],10
jne endalpha2
mov word[gameover],1

endalpha2:
popa
pop es
pop bp
ret

reinitialize_variables:
    ; Reset score and count variables
    mov word [Scorecount], 0
    mov word [missedcount], 0
    mov word [multi], 0
    
    ; Reset column positions
    mov word [col2], 10000
    mov word [col], 3920
    
    ; Reset character tracking variables
    mov word [char1T], 0
    mov word [char2T], 0
    mov word [char6T], 0
    mov word [char7T], 0
    mov word [char5T], 0
    
    ; Reset game state variables
    mov word [lives], 0
    mov word [gameover], 0
	mov word [timercount], 0
	mov word [timercount2], 0
    
    ; Reset random number variables
    mov word [rand], 0
    mov word [randnum], 7
    
    ; Reset character offsets
    mov word [char1_offset], 0
    mov word [char2_offset], 0
    mov word [char5_offset], 0
    mov word [char6_offset], 0
    mov word [char7_offset], 0
    
    ; Reset character values
    mov word [character1], '0'
    mov word [character2], '0'
    mov word [character5], '0'
    mov word [character6], '0'
    mov word [character7], '0'
    
    ret

start2:
call reinitialize_variables
call  clear_screen
jmp start

start:
   call  clear_screen
;--------------------------------------------------
	
  
   push ds
   mov ax, title_game
   push ax
   call str_length
   mov ax, title_game
   push ax
   push cx ; length of title name
   push 2 ; second row
   call Title_Game
;-------------------------------------------------  
   push ds
   mov ax, new_game
   push ax
   call str_length
   
   mov ax, new_game
   push ax
   push cx ; length of new game
   push 6
   call New_Game
;---------------------------------------------------  

   push ds
   mov ax, single_player
   push ax
   call str_length
   
   mov ax, single_player
   push ax
   push cx ; length
   push 10
   call Single_player
;---------------------------------------------------  

   push ds
   mov ax, multiplayer
   push ax
   call str_length
   
   mov ax, multiplayer
   push ax
   push cx
   push 14
   call Display_multiplayer
;---------------------------------------------------  


   push ds
   mov ax, end_game
   push ax
   call str_length
   
   mov ax, end_game
   push ax
   push cx
   push 18
   call End_Game
  
;---------------------------------------------------   STATIC FRONT PAGE ABOVE  
wait_for_enter:
   mov ah, 0          ; Wait for a key stroke
   int 16h            ; Scan code of the pressed key will be returned in AH
   cmp ah, 1Ch        ; Compare AH with 1Ch (Enter key scan code)
   je initialize
   jne wait_for_enter
   
   
initialize:
   call clear_screen
   push ds
   mov ax, Single
   push ax
   call str_length
   mov ax, Single
   push ax
   push cx ; length
   push 10
   call AskS
   
   push ds
   mov ax, Multi
   push ax
   call str_length
   mov ax, Multi
   push ax
   push cx ; length
   push 11
   call AskM
   
    mov ah, 0          ; Wait for a key stroke
    int 16h            ; Scan code of the pressed key will be returned in AH
    cmp ah, 1Fh
	je Single_game
	cmp ah, 32h
	je multi_game
	jne initialize
	
multi_game:
mov word[col],3940
mov word[col2],3900
mov word[multi],1

Single_game:
   call  clear_screen
   
	xor ax, ax
    mov es, ax          ; point es to IVT base
  mov ax, [es:9*4]
  mov bx, [es:9*4+2]
  mov word[oldkb], ax
   mov word[oldkb+2], bx
    cli                 ; disable interrupts
    
	mov word [es:9*4], kbisr ; store offset at n*4
    mov word[es:9*4+2], cs  ; store segment at n*4+2
    sti
	
   call box2
   call box
   ;-------------------------------------------------  
   push ds
   mov ax, timer
   push ax
   call str_length
   
   mov ax, timer
   push ax
   push cx ; length of new game
   push 0
   call print_timer
   
   ;----------------------------------------------------
   push ds
   mov ax, Missed
   push ax
   call str_length
   
   mov ax, Missed
   push ax
   push cx ; length of new game
   push 0
   call print_missed
   
   ;-------------------------------------------------  
   push ds
   mov ax, score
   push ax
   call str_length
   
   mov ax, score
   push ax
   push cx ; length of new game
   push 1
   call print_score


 
call char1
call char2
call char6
call char7
call char5
push 16
push word[missedcount]
call printNumber

gameloop:
call Alphabetsdrop
cmp word[gameover],1
je stay_resident
jmp gameloop

stay_resident:
	call clear_screen

    push ds
    mov ax, GAMEOVER
    push ax
    call str_length

    mov ax, GAMEOVER
    push ax
    push cx ; length of new game
    push 10
    call Game_Over

	push ds
    mov ax, Restart
    push ax
    call str_length
   
    mov ax, Restart
    push ax
    push cx ; length of new game
    push 12
    call Restart_Game   
	
   push ds
   mov ax, score
   push ax
   call str_length
   
   mov ax, score
   push ax
   push cx ; length of new game
   push 0
   call print_score
   
   push 150 
   push word[Scorecount]
   call printNumber
   
   push ds
   mov ax, Missed
   push ax
   call str_length
   
   mov ax, Missed
   push ax
   push cx ; length of new game
   push 0
   call print_missed
   
   push 16
   push word[missedcount]
   call printNumber
	
	
    cli       
    push 0
    pop es	; disable interrupts
    mov cx, word[oldkb]
	mov word [es:9*4], cx ; store offset at n*4
	mov dx,word[oldkb+2]
    mov word[es:9*4+2], dx ; store segment at n*4+2
    sti
	
wait_for_p:
   xor ax, ax
    int 16h              ; Wait for a key press
    cmp al, 'e'          ; Check if the key is 'f'
    je endgame   
    cmp al,'p'
    je start2
    jmp wait_for_p	; Jump to endgame if 'f' is pressed

endgame:    
  mov ax, 0x4c00
  int 0x21