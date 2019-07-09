.include "graphics.inc"
.include "interrupt.inc"
.include "macros.asm"

.data
Pontuacao: .asciiz "\nPontuação:\n"
buffer(0, 0, movepac)
sprites(119, 140, 0, 0, 3, pacman)

.text 
.globl main
main:
        #habilitando interrupção no teclado
        li $t0, 2
        sw $t0, 0xffff0000
        
        #desenha a grid
	li $a0, GRID_COLS  
        li $a1, GRID_ROWS 
        la $a2, grid
        jal draw_grid
	
movingpac:
	li $v0, 32 #delay
	li $a0, 50 #50ms 
	syscall
	 
	la $s0, pacman  #sprite
	la $s1, movepac #buffer
	la $a2, grid
	

	lw $s2, 0($s1)  #s2 = movepac.movx
	lw $s3, 4($s1)  #s1 = movepac.movy

	lw $t1, 0($s0)  #t1 = pacman.posx
	lw $t2, 4($s0)  #t2 = pacman.posy
	div $t3, $t1, 7 #t3 = pacman.posx/7 
	mfhi $t4
	div $t5, $t2, 7 #t5 = pacman.posy/7 
	mfhi $t6
	add $a0, $s2, $t3 #a0 = movepac.movx + pacman.posx/7 
	add $a1, $s3, $t5 #a1 = movepac.movy + pacman.posy/7 
	
	add $t4, $t6, $t4 #checando se o pacman está no meio do sprite
        bnez $t4, ifmovingpac1
        jal  check_wall
        bnez $v0, ifmovingpac1 #checando se é possível mover na direção do buffer
        sw $s2, 8($s0)  # pacman.movx = movepac.movx
        sw $s3, 12($s0) # pacman.movy = movepac.movy
        
ifmovingpac1:
	lw $t0, 8($s0)  #t0 = pacman.movx
	lw $t7, 12($s0)  #t7 = pacman.movy

	lw $t1, 0($s0)  #t1 = pacman.posx
	lw $t2, 4($s0)  #t2 = pacman.posy
	div $t3, $t1, 7 #t3 = pacman.posx/7 
	mfhi $t4
	div $t5, $t2, 7 #t5 = pacman.posy/7 
	mfhi $t6
	
	add $a0, $t0, $t3 #a0 = pacman.movx + pacman.posx/7 
	add $a1, $t7, $t5 #a1 = pacman.movy + pacman.posy/7 
	
	add $t4, $t6, $t4 #checando se o pacman está no meio do sprite
	bnez $t4, ifmovingpac2
	jal check_wall         
   	bnez $v0, movingpacend  #checando se é possível mover 
  
ifmovingpac2:
	add $a0, $t0, $t1
	sw $a0, 0($s0) #atualizando pacman.posx
	add $a1, $t2, $t7
	sw $a1, 4($s0) #atualizando pacman.posy
	li $a2, 3
	jal draw_sprite
	
movingpacend:

	j movingpac

 
    
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
   

.globl check_wall
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

check_wall:
addi $sp, $sp, -32
sw $s0, 12($sp)
sw $s1, 16($sp)
sw $s2, 20($sp)
sw $s3, 24($sp)
sw $ra, 28($sp)



mul $s0, $a1, 35            
add $s1, $a0, $s0   
add $s1, $s1, $a2 #calculando posição do vetor na grid
lb $s0, 0($s1) 
addi $s0, $s0, -64 #sprite id
move $v0, $zero #assumindo que não tem parede


beq $s0, 2, wall #fantasma
blt $s0, 5,check_wall_end #paredes

wall:
addi $v0, $v0, 1 #tem parede
  
check_wall_end:
lw $s0, 12($sp)
lw $s1, 16($sp)
lw $s2, 20($sp)
lw $s3, 24($sp)
lw $ra, 28($sp)
addi $sp, $sp, 32     
jr   $ra

# check_score(*grid,*pacman) s0-> pacman, s1 -> grid
.globl check_score
check_score: #arrumar
	addiu 	$sp, $sp, -24
	sw    	$a0, 0($sp)
	sw    	$a1, 4($sp)
	sw    	$a2, 8($sp)
	sw 	$s0, 12($sp)
	sw 	$s1, 16($sp)
  	sw    	$ra, 20($sp)
  	
  	li $v0,4
  	la $a0, Pontuacao
  	syscall
  	
  	
  	lw	$t0, 0($s0)	#pos x pacman
  	lw	$t1, 4($s0)	#pos y pacman
  	
  	div	$t0, $t0, 7
  	mfhi	$t4
  	div 	$t1, $t1, 7
  	mfhi 	$t2
  	add     $t4, $t2, $t4
  	bnez    $t4, end #checando se não está no meio do sprite
  	
 
  	mul 	$t3, $t1, 35
	add 	$t3, $t3, $t0
  	add 	$t1, $s1, $0
	add 	$t3, $t1, $t3
	lb 	$t0, 0($t3) #calculando vetor na grid
	
	li 	$t2, 0x00 #zerando para não pontuar num possível retorno
	sb   	$t2, 0($t3)
	sub 	$t2, $t0, 64 #sprite id
	bne 	$t2, 0, invenc		# comida
   	addi 	$a1, $a1, 10
   	j	end
invenc:	bne 	$t2, 1, cereja		#invencibilidade
   	addi    $a1, $a1, 50
   	j	end
cereja:	bne 	$t2, 4, end	# cereja
	addi    $a1, $a1, 100
   	 	
end: 
	move $a0, $a1
	li $v0, 1
	syscall
	lw    	$a0, 0($sp)
	lw    	$a1, 4($sp)
	lw    	$a2, 8($sp)
	lw 	$s0, 12($sp)
	lw 	$s1, 16($sp)
  	lw    	$ra, 20($sp)
	addiu 	$sp, $sp, 24
	jr  	$ra
    
