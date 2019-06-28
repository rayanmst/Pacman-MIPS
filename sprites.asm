.include "graphics.inc"

.text
.globl main
main:
	# CHAMA DRAW GRID
    li $a0, 35
    li $a1, 35
    la $a2, grid
    jal draw_grid    
    li $v0, 10
    syscall
	# TESTE DRAW SPRITE
    #li   $t8,0
    #li   $t9,0
    #main2:
    #move $a0,$t8
    #move $a1,$t9
    #li   $a2,3
    #jal  draw_sprite
    #addi $t8, $t8, 1
	
    #b main2
    
# draw_grid(width, height, grid_table)
.globl draw_grid
#Pilha:
#|-------| 40($sp)
#|  $ra  |
#|-------| 36($sp)
#| empty |
#|-------| 32($sp)
#|  $s4  |
#|-------| 28($sp)
#|  $s3  |
#|-------| 24($sp)
#|  $s2  |
#|-------| 20($sp)
#|  $s1  |
#|-------| 16($sp)
#|  $s0  |
#|-------| 12($sp)
#|  $a2  |
#|-------|  8($sp)
#|  $a1  |
#|-------|  4($sp)
#|  $a0  |
#|-------|  0($sp)
draw_grid:
	addi $sp, $sp, -40
	sw $a0, 0($sp)
        sw $a1, 4($sp)
        sw $a2, 8($sp)
        sw $s0, 12($sp)
        sw $s1, 16($sp)
        sw $s2, 20($sp)
        sw $s3, 24($sp)
        sw $s4, 28($sp)
        sw $ra, 36($sp)
	
	li $s0, 0	#i
	move $s2, $a0	#largura
	move $s3, $a1	#altura
	move $s4, $a2	#grid

draw_grid_altura:
	bge $s0, $s3, draw_grid_altura_end
	li $s1, 0
draw_grid_largura:
	bge $s1, $s2, draw_grid_largura_end
	lb $a2, 0($s4)
	addi $a2, $a2, -64
	add $a0, $s1, $0
	mul $a0, $a0, 7
	add $a1, $s0, $0
	mul $a1, $a1, 7
	jal draw_sprite
	addi $s4, $s4, 1
	addi $s1, $s1, 1
	b draw_grid_largura
draw_grid_largura_end:
	addi $s0, $s0, 1
	b draw_grid_altura
draw_grid_altura_end:
        lw $s0, 12($sp)
        lw $s1, 16($sp)
        lw $s2, 20($sp)
        lw $s3, 24($sp)
        lw $s4, 28($sp)
        lw $ra, 36($sp)	
	addi $sp, $sp, 40	
	jr $ra

# draw_sprite(X, Y, sprite_id) 
.globl draw_sprite

#Pilha:

#|-------| 32($sp)
#|  $ra  |
#|-------| 28($sp)
#|  $s3  |
#|-------| 24($sp)
#|  $s2  |
#|-------| 20($sp)
#|  $s1  |
#|-------| 16($sp)
#|  $s0  |
#|-------| 12($sp)
#|  $a2  |
#|-------|  8($sp)
#|  $a1  |
#|-------|  4($sp)
#|  $a0  |
#|-------|  0($sp)
draw_sprite:
	addi $sp, $sp, -32
	sw $s0, 12($sp)
	sw $s1, 16($sp)
	sw $s2, 20($sp)
	sw $s3, 24($sp)
	sw $ra, 28($sp)
	
	move $s2, $a0 #guardando x em $s2
	move $s3, $a1 #guardando y em $s3
	la $s0, sprites
	mul $t0, $a2, 49 # 49*indice, offset para trabalhar com um sprite específico
	add $s0, $t0, $s0 # & sprites [49*indice]
	
	li $t1, 0  # variável adjacente
	la $s1, colors #tabela de cores
	
draw:	
	bge $t1, SPRITE_SIZE, draw_end
	lbu $t2, 0($s0) #pega o valor correspondente ao índice da tabela de cores
	sll $t2, $t2, 2 #multiplica por 4 pq a tabela de cores é um vetor de word
	add $t2, $t2, $s1 #&colors[i]
	lw $a2, 0($t2) # pega a cor pra jogar no set_pixel
	div $t3, $t1, 7 #$t3 -> offset para y
	mfhi $t4        #$t4 -> offset para x (resto)
	add $a0, $s2, $t4 #posição de x em pixel scale
	add $a1, $s3, $t3 #posição de y em pixel scale
	
	jal set_pixel
	addi $t1, $t1, 1 #incrementando a variável adjacente 
	addi $s0, $s0, 1
	b draw
	
draw_end:
	lw $s0, 12($sp)
	lw $s1, 16($sp)
	lw $s2, 20($sp)
	lw $s3, 24($sp)
	lw $ra, 28($sp)
	addi $sp, $sp, 32
	jr   $ra

# set_pixel(X, Y, color)
set_pixel:
   la  $t0, FB_PTR
   mul $a1, $a1, FB_XRES # y*256
   add $a0, $a0, $a1 # x + y*256
   sll $a0, $a0, 2 # 4*( x + y*256 )
   add $a0, $a0, $t0 # &(pixel + 4*( x + y*256)
   sw  $a2, 0($a0) # joga a cor pro endereço
   jr  $ra

#Pilha
#|-------| 32($sp)
#|  $ra  |
#|-------| 28($sp)
#| Empty |
#|-------| 24($sp)
#|  $s2  |
#|-------| 20($sp)
#|  $s1  |
#|-------| 16($sp)
#|  $s0  |
#|-------| 12($sp)
#|  $a2  |
#|-------|  8($sp)
#|  $a1  |
#|-------|  4($sp)
#|  $a0  |
#|-------|  0($sp)
checkWall:
	addi $sp, $sp, -32
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $s0, 12($sp)
	sw $s1, 16($sp)
	sw $s2, 20($sp)
	sw $ra, 28($sp)
	
	li $t0, 5
	div $t1, $a0, 7	  #gridPosX
	div $t2, $a1, 7	  #gridPosY
	mul $t1, $t1, 35  #Offset em x
	add $t1, $t1, $t2 #gridArrayPos
	add $t1, $t1, $a2 #gridTable[gridArrayPos]
	lbu $t2, 0($t1)	  #$t2 = gridTable[gridArrayPos]
	subi $t2, $t2, 64
	bge $t2, $t0, checkWallIfFalse
checkWallIfTrue:
	li $v0, 0
	j checkWallExit
checkWallIfFalse:
	li $v0, 1
checkWallExit:
	lw $s0, 12($sp)
	lw $s1, 16($sp)
	lw $s2, 20($sp)
	lw $ra, 28($sp)
	
	jr $ra
	
#int returnId(int x, int y) {
