.kdata 0x90000000
_msg1: .asciiz "\n!! Ocorreu uma exceção !!\n"
.align 2
_regs: .space 252

jump_table: .word case_0, case_1, case_2, case_3, case_4, case_5, case_6, case_7, case_8, case_9, case_10, case_11, case_12,
		  case_13, case_14, case_15
	         
print0: .asciiz "Hardware interrupt \n"
print4: .asciiz "ADDRL - Address error caused by load or fetch instruction \n"
print5: .asciiz "ADDRS - Address error caused by store instrution \n"
print6: .asciiz "IBUS error feth instruction \n"
print7: .asciiz "DBUS error data load or store \n "
print8: .asciiz "SYSCALL \n"
print9: .asciiz "BKPT braekpoint \n"
print10: .asciiz "RI - Reserved \n"
print12: .asciiz "OVF -  Arithmetic overflow \n"
print13: .asciiz "TRAP - Trap instruction \n"
print15: .asciiz "FPE - Float point \n"
printdefaut: .asciiz "Causa desconhecida"


.ktext 0x80000180 

#status $12
#CAUSA 	$13
#EPC  	$14  -> ENDEREÇO MEMORIA ONDE OCORREU A EXECUÇÃO


move $k0, $at 	# $k0 = $at
la $k1, _regs 	# $k1 = address of _regs
sw $k0, 0($k1) 	# save $at
sw $v0, 4($k1)	# save $v0
sw $v1, 8($k1)
sw $a0, 12($k1) 	# save $a0
sw $a1, 16($k1)
sw $a2, 20($k1)
sw $a3, 24($k1)
sw $t0, 28($k1)
sw $t1, 32($k1)
sw $t2, 36($k1)
sw $t3, 40($k1)
sw $t4, 44($k1)
sw $t5, 48($k1)
sw $t6, 52($k1)
sw $t7, 56($k1)
sw $s0, 60($k1)
sw $s1, 64($k1)
sw $s2, 68($k1)
sw $s3, 72($k1)
sw $s4, 76($k1)
sw $s5, 80($k1)
sw $s6, 84($k1)
sw $s7, 88($k1)
sw $t8, 92($k1)
sw $t9, 96($k1)
sw $gp, 100($k1)
sw $sp, 104($k1)
sw $fp, 108($k1)
sw $ra, 112($k1)
swc1 $f0, 116($k1)
swc1 $f1, 120($k1)
swc1 $f2, 124($k1)
swc1 $f3, 128($k1)
swc1 $f4, 132($k1)
swc1 $f5, 136($k1)
swc1 $f6, 140($k1)
swc1 $f7, 144($k1)
swc1 $f8, 148($k1)
swc1 $f9, 152($k1)
swc1 $f10, 156($k1)
swc1 $f11, 160($k1)
swc1 $f12, 164($k1)
swc1 $f13, 168($k1)
swc1 $f14, 172($k1)
swc1 $f15, 176($k1)
swc1 $f16, 180($k1)
swc1 $f17, 184($k1)
swc1 $f18, 188($k1)
swc1 $f19, 192($k1)
swc1 $f20, 196($k1)
swc1 $f21, 200($k1)
swc1 $f22, 204($k1)
swc1 $f23, 208($k1)
swc1 $f24, 212($k1)
swc1 $f25, 216($k1)
swc1 $f26, 220($k1)
swc1 $f27, 224($k1)
swc1 $f28, 228($k1)
swc1 $f29, 232($k1)
swc1 $f30, 236($k1)
swc1 $f31, 240($k1)
mfhi $t0
sw $t0, 244($k1)
mfhi $t0
sw $t0, 248($k1)
 

 	
mfc0 $s0, $13          #carrega reg interrupção
andi $s0, 0xFC         # MASCARA PARA VALOR $13
srl  $s0, $s0, 2       # PA	
  
  
  
bgt $s0, 15, default
bltz $s0, default
sll $s0, $s0, 2		# mult *4
la $t0, jump_table	# carrega endereco jump table
add $s0, $t0, $s0
lw $t0, 0($s0) 		
jr $t0
  
  case_0:
  
        la $t0, movepac #carrega endereço do mov_pacman(struct)
      	lw $a0, 0xffff0004 #carrega dado do teclado
  	
  	move $t1, $a0
  	
  	    beq $t1, 119, up   #'w'
        beq $t1, 87, up   #'W' 
        beq $t1, 115, down  #'s'
        beq $t1, 83, down   #'S'   
        beq $t1, 97, left #'a'
        beq $t1, 65, left #'A' 
        beq $t1, 100, right #'d' 
        beq $t1, 68, right  #'D'
        #beq $t1, 32, pause1  #' '
      			        			
  	la $a0, print0      #debug    
  	li $v0, 4   #escreve na tela  #debug
  	syscall             #debug

  	j exit1
  	  	
  up:
    sw $zero, 0($t0) #x
    li $t1, -1 
    sw $t1, 4($t0)   #y
    j exit1
  
  down:
    li $t1, 1 
    sw $zero, 0($t0) #x
    sw $t1, 4($t0)   #y
    j exit1
  
  right:
    li $t1, 1 
    sw $t1, 0($t0)    #x
    sw $zero, 4($t0)  #y
    j exit1
  
  left:
    li $t1, -1 
    sw $t1, 0($t0)    #x
    sw $zero, 4($t0)  #y
    j exit1
    
	exit1:
	
    	mfc0 $k0, $14 	# $k0 = EPC  
    	addiu $k0, $k0, -4      # Decrement $k0 by 4
    	mtc0 $k0, $14
  	j exit
  	
  case_4:
	la $a0, print4
  	li $v0, 4   #escreve na tela
  	syscall
  	j exit  
  case_5:
  	la $a0, print5
  	li $v0, 4   #escreve na tela
  	syscall
  	j exit
  case_6:
  	la $a0, print6
  	li $v0, 4   #escreve na tela
  	syscall
  	j exit
  case_7:
  	la $a0, print7
  	li $v0, 4   #escreve na tela
  	syscall
  	j exit
  case_8:
  	la $a0, print8
  	li $v0, 4   #escreve na tela
  	syscall
  	j exit
  
  case_9:
  	la $a0, print9
  	li $v0, 4   #escreve na tela
  	syscall
  	j exit
  
  case_10:
  	la $a0, print10
  	li $v0, 4   #escreve na tela
  	syscall
  	j exit
  case_12:
  	la $a0, print12
  	li $v0, 4   #escreve na tela
  	syscall
  	j exit
 case_13:
  	la $a0, print13
  	li $v0, 4   #escreve na tela
  	syscall
  	j exit
    
 case_15:
  	la $a0, print15
  	li $v0, 4   #escreve na tela
  	syscall
  	j exit
case_1: 
case_2:
case_3:
case_11:
case_14: 
default:
 	la $a0, printdefaut
  	li $v0, 4   #escreve na tela
  	syscall
exit:
    

# preparação para retornar 

la $k1, _regs 	# $k1 = address of _regs
lw $t0, 244($k1)   #hi
mthi $t0
lw $t0, 248($k1)   #lo
mtlo $t0
lw $at, 0($k1)
lw $v0, 4($k1)	# save $v0
lw $v1, 8($k1)
lw $a0, 12($k1) 	# save $a0
lw $a1, 16($k1)
lw $a2, 20($k1)
lw $a3, 24($k1)
lw $t0, 28($k1)
lw $t1, 32($k1)
lw $t2, 36($k1)
lw $t3, 40($k1)
lw $t4, 44($k1)
lw $t5, 48($k1)
lw $t6, 52($k1)
lw $t7, 56($k1)
lw $s0, 60($k1)
lw $s1, 64($k1)
lw $s2, 68($k1)
lw $s3, 72($k1)
lw $s4, 76($k1)
lw $s5, 80($k1)
lw $s6, 84($k1)
lw $s7, 88($k1)
lw $t8, 92($k1)
lw $t9, 96($k1)
lw $gp, 100($k1)
lw $sp, 104($k1)
lw $fp, 108($k1)
lw $ra, 112($k1)
lwc1 $f0, 116($k1)
lwc1 $f1, 120($k1)
lwc1 $f2, 124($k1)
lwc1 $f3, 128($k1)
lwc1 $f4, 132($k1)
lwc1 $f5, 136($k1)
lwc1 $f6, 140($k1)
lwc1 $f7, 144($k1)
lwc1 $f8, 148($k1)
lwc1 $f9, 152($k1)
lwc1 $f10, 156($k1)
lwc1 $f11, 160($k1)
lwc1 $f12, 164($k1)
lwc1 $f13, 168($k1)
lwc1 $f14, 172($k1)
lwc1 $f15, 176($k1)
lwc1 $f16, 180($k1)
lwc1 $f17, 184($k1)
lwc1 $f18, 188($k1)
lwc1 $f19, 192($k1)
lwc1 $f20, 196($k1)
lwc1 $f21, 200($k1)
lwc1 $f22, 204($k1)
lwc1 $f23, 208($k1)
lwc1 $f24, 212($k1)
lwc1 $f25, 216($k1)
lwc1 $f26, 220($k1)
lwc1 $f27, 224($k1)
lwc1 $f28, 228($k1)
lwc1 $f29, 232($k1)
lwc1 $f30, 236($k1)
lwc1 $f31, 240($k1)

mfc0 $k0, $14 
addiu $k0, $k0, 4       
mtc0 $k0, $14 	
eret		
