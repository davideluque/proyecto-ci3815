# Universidad Simón Bolívar
# Departamento de Computación y Tecnología de la Información
# CI-3815: Organización del computador
# Prof. Angela Di Serio

# Proyecto 1: Bitmap.asm - Programa para visualizar una imagen basada en mapa de bits.
# Convierte la imagen a blanco y negro, la rota noventa grados y le hace un
# flip vertical / horizontal

# Autores: 
# 	David Cabeza - USBID: 13-10191
# 	Fabiola Martínez - USBID: 13-10838

# Octubre, 2016.

.data
	bienvenida: .asciiz "Bienvenido a la herramienta de manipulación de imágenes\n"
	inicio: .asciiz "Introduce el nombre del archivo .bmp con la imagen que deseas manipular: "
	
	archivo: .space 20
	descriptor: .word 0
	dir_display: .word 0
	len_display: .word 0
	dir_file: .word 0
	len_file: .word 0
	cabecera: .space 54

	error_apertura: .asciiz "Hubo un error al abrir el archivo. No se encontró o es inválido. El archivo debe estar en el mismo directorio que MARS"
	error_formato: .asciiz "El archivo no tiene formato bitmap. Intentalo con otro archivo."
	error_opciones: .asciiz "La opcion debe estar entre 0 y 5. Intentalo de nuevo"
	
	exito_apertura: .asciiz "La imagen fue abierta correctamente.\n"
	exito_lectura: .asciiz "La imagen fue leida correctamente."
	espera: .asciiz "\nPresiona enter para continuar... "
	enter_espera: .byte 0
	
	configuracion_1: .asciiz "Para visualizar la imagen debes abrir el Bitmap Display presionando en la barra superior Tools y luego Bitmap Display\n"
	configuracion_2: .asciiz "Ajusta el valor Display Width in Pixels con el valor: "
	configuracion_3: .asciiz "\nAjusta el valor Display Height in Pixels con el valor: "
	configuracion_4: .asciiz "\nAjusta el valor Base address for display con el valor: 0x10040000 (heap)"
	
	opciones_menu: .asciiz "\n\n 1 - Visualizar imagen \n 2 - Convertir imagen blanco y negro \n 3 - Rotar 90 grados la imagen \n 4 - Flip horizontal \n 5 - Flip vertical \n Introduzca la opcion que desea: "
	#opciones: .word visualizar, blanco_negro, # rotar, flip_h, flip_v

			
.text
	li $v0, 4
	la $a0, bienvenida	# Mostrar mensaje de bienvenida
	syscall
	
	li $v0, 4
	la $a0, inicio		# Mostrar mensaje de inicio
	syscall
	
	li $v0, 8
	la $a0, archivo		# Esperar entrada y almacenarla en memoria en la dirección de archivo
	li $a1, 19		# El máximo de caracteres a leer es 19
	syscall
	
reemplazar_salto:
	lb $t0, archivo($t1)		# Este bloque lee byte a byte el string entrada del usuario y al encontrarse
	beq, $t0, 10, salto_encontrado	# el salto de línea lo reemplaza por el caracter nulo para aperturar el ar-
	addi, $t1, $t1, 1 		# chivo sin problemas
	b reemplazar_salto

salto_encontrado:
	sb $0, archivo($t1)
	
	li $v0, 13
	la $a0, archivo		# Se procede a leer el archivo especificado en el string leído.
	li $a1, 0		# Este flag representa la apertura del archivo en modo sólo lectura.
	syscall
	
	bge, $v0, $0, apertura_exitosa
	
	li $v0, 4		# Este bloque se ejecuta solo si hubo un problema al abrir el archivo.
	la $a0, error_apertura	# En ese caso, el descriptor del archivo (almacenado en $v0) es menor que cero.
	syscall			# Se muestra un mensaje de error y se termina la ejecución del programa.
	li $v0, 10		
	syscall

apertura_exitosa:
	sw $v0, descriptor	# Salvamos la dirección del descriptor en memoria.
	
	li $v0, 14		# Este bloque se encarga de leer los primeros 54 bytes del archivo
	lw $a0, descriptor	# que corresponden a la cabecera de la imagen bitmap.
	la $a1, cabecera
	li $a2, 54
	syscall 

	#	******************************** 	#
	#		OPTIMIZAR BLOQUE		#
	#	********************************	#

	li $t1, 0		# Reiniciamos el valor del registro t1
	li $t2, 0x42		# Valor hexadecimal del caracter B
	lb $t0, cabecera($t1)
	beq $t0, $t2, continuar_verificacion
	
	li $v0, 4		# Este bloque se encarga de mostrar un mensaje de error de formato  
	la $a0, error_formato	# y terminar la ejecución del programa.
	syscall
	li $v0, 10
	syscall
	
continuar_verificacion:
	addi $t1, $t1, 1
	li $t2, 0x4D
	lb $t0, cabecera($t1)
	beq $t0, $t2, formato_correcto
	
	li $v0, 4
	la $a0, error_formato
	syscall
	li $v0, 10
	syscall
	
formato_correcto:
	li $v0, 4
	la $a0, exito_apertura
	syscall
	
#	lw $t0, cabecera+18 # Ancho de la imagen
#	lw $t1, cabecera+22 # Alto de la imagen
#	lh $t2, cabecera+28 # Número de bits utilizados para codificar el color
	li $t0, 128
	li $t1, 256
	li $t2, 24
	
	# MENSAJE DE ERROR SI LA PROFUNDIDAD NO ES 3
	div $t2, $t2, 0x8 # Aquí se obtiene la profundidad de color en bytes
	
	#	****************************************************** 		#
	#		VALORES T4 Y T5 SE DEBEN SALVAR!!!			#
	#	******************************************************		#
	
	mul $t3, $t0, $t1 # Ancho x Alto
	mul $t4, $t3, $t2 # Ancho x Alto x Profundidad: Bytes a reservar para leer bytes del archivo
	sw $t4, len_file
	mul $t5, $t3, 0x4 # Ancho x Alto x 4: Bytes a reservar para guardar RGB en el Bitmap display
	sw $t5, len_display
	
	#	****************************************************** 		#
	#		RESERVA DE ESPACIO EN MEMORIA DINÁMICA			#
	#	******************************************************		#
	
	li $v0, 9
	move $a0, $t5
	syscall

	sw $v0, dir_display
	
	li $v0, 9
	move $a0, $t4
	syscall
	
	sw $v0, dir_file

	#	************************************************************* 		#
	#		LECTURA Y TRANSFERENCIA DE DATOS A MEMORIA D.			#
	#	*************************************************************		#	
	
	li $v0, 14
	lw $a0, descriptor
	lw $a1, dir_file
	lw $a2, len_file
	syscall 
	
	li $v0, 4
	la $a0, configuracion_1
	syscall
	
	li $v0, 4
	la $a0, configuracion_2
	syscall
	li $v0, 1
	move $a0, $t0
	syscall
	
	li $v0, 4
	la $a0, configuracion_3
	syscall
	li $v0, 1
	move $a0, $t1
	syscall
	
	li $v0, 4
	la $a0, configuracion_4
	syscall
	
	li $v0, 4
	la $a0, espera
	syscall
	li $v0, 8
	la $a0, enter_espera
	li $a1, 10
	syscall

menu:
	li $v0, 4
	la $a0, opciones_menu
	syscall
	
	li $v0, 5
	syscall
	
#	jal visualizar		Para el menú. 	
visualizar:
	lw $t3, dir_display	# Posiciono t3 con la dirección del bitmap display	
	addi $t4, $t3, 512	# DirBitMapDisplay + Ancho * 4 es el tope de la fila
	
	lw $t0, dir_file	# Posiciono t0 con la dirección de los bytes del archivo	
	move $s2, $t0		# Registro auxiliar para marcar el fin de la lectura.
	addi $t0, $t0, 97920  	# Alto - 1 x Ancho x 3

cargar_en_bitmap:
	lbu $t1, ($t0)		# Cargo el azul
	lbu $t2, 1($t0)		# Cargo el verde
	sll $t2, $t2, 8		# Dejo espacio para el azul colocando el verde como 0x0000GG00
	or $t2, $t1, $t2 	# Junto azul y verde. La palabra va como 0x0000GGBB
	lbu $t1, 2($t0)		# Ya no necesito el azul. Lo sobreescribo cargando el rojo.
	sll $t1, $t1, 16	# Dejo espacio para el azul y el verde colocando el rojo como 0x00RR0000
	or $t1, $t1, $t2	# Junto rojo con azul y verde. La palabra va como 0x00RRGGBB
	sw $t1, ($t3)		# La almaceno en la dirección que lee el bitmap.
	addi $t3, $t3, 4	# Me muevo a la siguiente palabra para el bitmap display
	addi, $t0, $t0, 3	# Me muevo al inicio del siguiente píxel de la imagen
	bne $t3, $t4, cargar_en_bitmap 		# ¿Llegue al tope de la fila? Ancho * 4
	beq $t3, $s2, blanco_negro 	# AQUI BRANCH A MENU Antes, se verifica si ese tope es el fin de la imagen para no hacer las operacones.
	subi $t0, $t0, 768	# Se llegó al tope de la fila, restar Ancho * 3 para volver al inicio - Ancho * 3
				# para bajar
	addi $t4, $t3, 512	# Apuntador de mi BMD + (Ancho * 4)
	b cargar_en_bitmap

blanco_negro:
	lw $a0, dir_display
	lw $a2, dir_file
	add $a1, $a0, 512
cambiar_bytes:	
	lbu $t1, ($a0)		# Cargo el azul
	lbu $t2, 1($a0)		# Cargo el verde
	add $t2, $t1, $t2	# Sumo ambos colores
	lbu $t1, 2($a0)		# Ya no necesito el azul. Lo reemplazo cargando el rojo.
	add $t2, $t2, $t1	# En t2 tengo la suma de los tres colores.
	div $t2, $t2, 3		# Promedio los colores
	sll $t3, $t2, 8		
	or $t3, $t3, $t2
	sll $t2, $t2, 16
	or $t2, $t2, $t3
	sw $t2, ($a0)
	addi $a0, $a0, 4
	beq $a0, $a2, flip_v
	b cambiar_bytes
	
flip_v:
	lw $a0, dir_display
	lw $a2, dir_file

realizar_flip:
	lw $t0, 
