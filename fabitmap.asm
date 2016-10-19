.data
inicio: .asciiz "Introduzca el nombre del archivo .bmp con la imagen que desea leer: "
archivo: .space 20
.align 1
cabecera: .space 54
error_abrir: .asciiz "Hubo un error al abrir el archivo"
error_b: .asciiz "Hubo un error en B del archivo"
error_m: .asciiz"Hubo un error en M del archivo"
no_error: .asciiz "Imagen abierta y leida correctamente \n"
bienvenido_bmp : .asciiz "Ajuste los valores del bitmap: \n - 'Base address for display' a 0x10000000 (global address)"
ancho: .asciiz "\n - El ancho de la imagen es "
largo: .asciiz "\n - El alto de la imagen es "
opciones_menu: .asciiz "\n 1 - Visualizar imagen \n 2 - Convertir imagen blanco y negro \n 3 - Rotar 90 grados la image \n 4 - Flip horizontal \n 5 - Flip vertical \n Introduzca la opcion que desea: "
error_nopciones : .asciiz "El numero de opcion debe estar entre 0 y 5"
opciones: .word visualizar, blanco_negro, rotar, flip_h, flip_v
vis: .asciiz "vi1"
bn: .asciiz "bla2"
ro: .asciiz "ro3"
fh: .asciiz "fh4"
fv: .asciiz "fv5"

.text  
main: 
	la $a0, inicio
	li $v0, 4
	syscall # Mostrar en pantalla mensaje inicio
	
	li $v0, 8
	la $a0, archivo 
	li $a1, 19
	syscall # Introduce nombre archivo 

reemplazar:
	lb $t0, archivo($t1)
	beq $t0, 10, continuar
	addi $t1, $t1, 1
	b reemplazar
	
continuar:
	sb $0, archivo($t1)
	li $v0, 13
	la $a0, archivo
	la $a1, 0 
	# Falta $a2
	syscall
	bge $v0, $zero, abrio_correctamente # Verificamos si se abrio correctamente 
	la $a0 error_abrir 
	li $v0, 4
	syscall # Si no se abrio correctamente mostrar error de abrir 
	li $v0, 10
	syscall # Detenemos la ejecucion
	
abrio_correctamente:
	move $a0, $v0 # Descriptor de la imagen lo movemos para no perderlo
	li $v0, 14
	la $a1, cabecera
	la $a2, 54
	syscall # Leemos el archivo y lo colocamos en los 54 bytes

	lb $t0, cabecera
	beq $t0, 0x42, verificamos_m
	la $a0, error_b
	li $v0,4
	syscall
	li $v0, 10
	syscall # verificamos que el primer byte sea una B sino mostrar error y terminar
	
verificamos_m:
	lb $t1, cabecera+1
	beq $t1, 0x4D, seguimos
	la $a0, error_m
	li $v0,4
	syscall
	li $v0, 10
	syscall # verificamos que el segundo byte sea una M sino mostrar error y terminar
	
seguimos:
	la $a0, no_error
	li $v0, 4
	syscall # mostramos que la imagen de se leyo y abrio correctamente
	
	lw $t3, cabecera+18 # tenemos la anchura 
	lw $t4, cabecera+22 # tenemos la altura 
	lh $t2, cabecera+28 # tenemos numero de bits usados para codificar color 
	
	div $t0, $t2, 0x8 # obtenemos profundidad que en teoria es 3
	
	mul $t1, $t3, $t4 # multiplicamos ancho por largo
	mul $t5, $t0, $t1 # multiplicamos el resultado de axl por profundidad
	
	la $a0, bienvenido_bmp
	li $v0, 4
	syscall # mostramos mensaje de ajuste de Bitmap Display
	
	la $a0, ancho
	li $v0, 4
	syscall # mostramos mensaje de ancho
	la $a0, ($t3)
	li $v0, 1
	syscall # mostramos el valor del ancho
	
	la $a0, largo 
	li $v0, 4
	syscall # mostramos mensaje del largo
	la $a0, ($t4)
	li $v0, 1
	syscall # mostramos valor del largo
	
menu:
	la $a0, opciones_menu
	li $v0, 4
	syscall # mostramos en pantalla el menu
	
	li $v0, 5
	syscall # leemos la opcion dada por el usuario
	
	bltz $v0, error_opciones
	bgt $v0, 5, error_opciones # verifica si la opcion dada es un numero correcto
	
	la $t0, opciones
	addi $v0, $v0, -1
	sll $t1, $v0, 2
	lw $t2, opciones($t1)
	jalr $t2

visualizar:
	la $a0, vis
	li $v0, 4
	syscall
	li $v0, 10
	syscall
	
	jr $ra 	
	
error_abrirarchivo:
	la $a0, error_abrir
	li $v0, 4
	syscall
	li $v0, 10
	syscall
	
error_opciones:
	la $a0, error_nopciones	
	li $v0, 4				
	syscall
	li $v0, 10 
	syscall 
	
	 
blanco_negro:
	la $a0, bn
	li $v0,4
	syscall
	li $v0, 10
	syscall
	
	jr $ra 	
	
rotar: 
	la $a0, ro
	li $v0,4
	syscall
	li $v0, 10
	syscall
	
	jr $ra 	
	
flip_h:
	la $a0, fh
	li $v0, 4
	syscall
	li $v0, 10
	syscall
	
	jr $ra 	

flip_v: la $a0, fv
	li $v0, 4
	syscall 
	li $v0, 10
	syscall
	
	jr $ra 	


	
	


	
	
	
	
	
	
	
	

	
	
	
	
	
	
	 
	
