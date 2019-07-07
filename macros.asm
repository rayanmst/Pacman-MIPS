.macro animed_sprite (%name, %id, %pos_x, %pos_y, %mov_x, %mov_y)
.data
%name:
.align 2
	.word %id
	.word %pos_x     #posicao x atual
	.word %pos_y     #posicao y atual
	.word %mov_x     # offset de posição em x
	.word %mov_y     # offset de posição em y
.end_macro

.macro moviment (%name, %x, %y)
.data
%name:
.align 2
	.word %x
	.word %y
	
.end_macro

.macro exit
	li $v0, 10
	syscall
.end_macro 

.macro exit(%status)
	li $v0, 17
	add $a0, $0, %status
	syscall
.end_macro 

.macro get_int
	li $v0, 5
	syscall
.end_macro 

.macro printInt(%x)
	add $a0, $zero, %x
	li $v0, 1
	syscall
.end_macro 

.macro printStr (%str)
.data
mStr: .asciiz %str
.text
	li $v0, 4
	la $a0, mStr
	syscall
.end_macro 
