# Autores: David Cabeza (13-10191)
#	   Fabiola Martínez (13-10838
# Fecha: Octubre, 2016.
# BitMap.asm: Programa para visualizar una imagen basada en mapa de bits,
# convierte la imagen a blanco y negro, la rota noventa grados y le hace un
# flip vertical / horizontal

.data
inicio: .asciiz "Introduzca el nombre del archivo .bmp con la imagen que desea leer: "
error: .asciiz "Hubo un error al abrir el archivo"
#archivo: "imagen.bmp"
archivo: .space 20
cabecera: .space 54

.text
	la $a0, inicio
	li $v0, 4    	# Mostrar el contenido de inicio al usuario.
	syscall      	 
	li $v0, 8	 
	la $a0, archivo # Leemos la entrada del usuario y almacenamos su valor en un archivo.
	li $a1, 19 	# El máximo de caracteres a leer es 19.
	syscall
# Ver el valor de $v0 y mover el registro para cambiar el salto del línea por un caracter cero (nulo)
	li $v0, 13
	la $a0, archivo # Llamamos a la lectura de archivos con la direccion en el string leido.
	li $a1, 0	# Read-only.
	syscall
	bge $v0, $zero, abrio_correctamente
	la $a0, error
	li $v0, 4	# No se pudo abrir el archivo, mostrar mensaje de error. 
	syscall
	li $v0, 10	# Terminar la ejecución.
	syscall
abrio_correctamente:
	move $a0, $v0 	# Para no perder el valor del descriptor lo movemos a $a0 
	li $v0, 14
	la $a1, cabecera # Leemos el archivo y almacenamos los primeros 54 bytes en espacio reservado como cabecera 
	la $a2, 54
	syscall