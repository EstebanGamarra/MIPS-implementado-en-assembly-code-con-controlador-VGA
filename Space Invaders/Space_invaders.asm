#AUTOR: ESTEBAN JOSE GAMARRA DUARTE 
.data
	.eqv	memoria	0x10010000
	.eqv	botones	0xFFFFD000
	.eqv	tope_columna_izq 0x00000000	#posicion columna 0
	.eqv	tope_columna_der 0x0000C000	#posicion columna 192
	.eqv    tiempo_espera 0x0003D090       #tiempo a esperar por ciclo
	.eqv	cantidad_bichos 0x000000001B	#36 en total
	.eqv	fila_1_bichos    0x0000000A	#10 inicialmente 
	.eqv    columna_1_bichos 0x00000000	#0 inicialmente
	.eqv    fila_e_bichos 0x0000000A 	#14 filas entre bichos hay
	.eqv    desp_fila_bichos 0x00000014     #14 filas se desplaza toda la patota 
	.eqv    desp_columna_bichos 0x00000006  #6 columnas se desplazan cada medio segundo
	.eqv    fila_jugador 0x000000DC		#220 (tope fila bicho tambien) 
	.eqv	fila_proyectil 0x000000D4	#220 - 8 = 212 OTRO ERROR
	.eqv 	columna_jugador 0x00004800	#72 para inicializar
	.eqv	codif_bichos_ini 0x00370000 #0011 0111 (VERDE)
	.eqv	codif_jugador_ini 0x003A0000  #0011 1010 = (de izquierda a derecha) 10 sprite, 10 color, 11 vivo (Rosado)
	.eqv 	codif_proyectil_ini 0x003D0000 #0011 1101 (blanco)
	.eqv    memoria_jugador 0x10010090 # 36*4 
	.eqv    memoria_proyectil_jugador 0x10010094 # jugador + 4
	.eqv    memoria_proyectil_enemigo 0x10010098 # proyectil jugador + 4
.text
ini:
	addi $s0,$zero,12 #12 bichos (3 veces) (tambien cantidad de movimientos en pantalla luego de la inicialización)
	addi $s1,$zero,3 #3 filas
	addi $s2,$zero,16 #16
	#    $s3 no uso 
	#    $s4 no uso 
	addi $s5,$zero,botones #para poder buscar directamente desde esta posicion de memoria del mips siempre
	#    $s6 no uso
	addi $s7,$zero,0 #Bandera gameover, si mueren todos los bichos o si un bicho llega al limite permitido hacia abajo
#Inicializamos la pantalla del juego con los sprites colocados en un primer lugar
#Luego de esto, esperamos el input de un boton para iniciar el juego
ini_mapeo_enemigos_1: #inicializo variables
	addi $t0,$zero,fila_1_bichos	#y = 10 (byte)
	addi $t1,$zero,columna_1_bichos	#x = 0 (byte)
	addi $t2,$zero,codif_bichos_ini	#sprite,color,vivo/muerto, 11, 01, 11 (byte) (sobre este siempre voy modificando mis valores a escribir en memoria)
	addi $t3,$zero,0 #contador de cantidad de bichos
	addi $t4,$zero,0 #contador de cantidad de NOPS para esperar al sprite mapper que termine su trabajo
	addi $t5,$zero,memoria #memoria
	addi $t6,$zero,0  #cantidad de filas mapeadas
	
ini_mapeo_enemigos_2: #30 clocks una vez enviado el sprite a mapear
	addi $t2,$zero,codif_bichos_ini	#sprite,color,vivo/muerto, 11, 01, 11 (byte) (sobre este siempre voy modificando mis valores a escribir en memoria)
	or $t2,$t2,$t0 # sumo fila
	or $t2,$t2,$t1 # sumo columna
	sw $t2,($t5) #(0 clock, arranca el sprite mapper) cargo dato en memoria
	jal while_mapeo #espero que se escriba todo
	addi $t3,$t3,1 #aumento mi contador de bichos en 1
	beq $t3,$s0,filas_ini_mapeo_enemigos #pregunto si es igual a 12
	#si no es igual a 12, continuo acá, incrementando mi posición de memoria y columna
	addi $t5,$t5,4 # incremento en 4 la posición de memoria para mi siguiente bicho
	addi $t1,$t1,0x00000C00 #incremento la posición de la columna en 12
	j ini_mapeo_enemigos_2 #vuelvo a escribir el siguiente bicho
	
filas_ini_mapeo_enemigos:
	addi $t3,$zero,0 #ceramos nuestro contador de bichos local para la fila
	addi $t6,$t6,1 #incremento en 1 mis filas mapeadas de bichos
	beq $t6,$s1,ini_mapeo_jugador_1 #pregunto si ya mapeó las 3 filas, de ser así, salto a mapear el jugador
	#de no ser así sigo de largo y reseteo mi posición en columna para volver a mapear, incremento la fila
	addi $t0,$t0,14 #aumento en 14 mis filas
	addi $t1,$zero,columna_1_bichos #vuelvo a poner en la primera posición de columnas
	addi $t5,$t5,4 #incremento en 4 la posición de memoria para mi siguiente bicho
	j ini_mapeo_enemigos_2 #vuelvo al mapeo
	
while_mapeo:
	addi $t4,$t4,1 
	bne $t4, $s2,while_mapeo
	addi $t4,$zero,0
	jr $ra #vuelvo
	
ini_mapeo_jugador_1: #30 clocks una vez enviado el sprite a mapear
	addi $t0,$zero,fila_jugador 
	addi $t1,$zero,columna_jugador 
	addi $t2,$zero,codif_jugador_ini
	addi $t3,$zero,memoria_jugador
	addi $t4,$zero,0
	
ini_mapeo_jugador_2:
	or $t2,$t2,$t0
	or $t2,$t2,$t1
	sw $t2,($t3)
	jal while_mapeo
start:
	########################OJO#######################
	#ahora cambiamos los valores de las variables guardadas para usarlas en el juego durante su ejecución ($s0 y $s1)
	#tambien usamos $t0 y $t1 de nuevo
	addi $s0,$zero,0 #bandera derecha/izquierda movimiento enemigos 
	addi $s1,$zero,0 #bandera proyectil
	addi $s2,$zero,16 #16, contador de NOPS
	addi $s3,$zero,0 #contador de horizontal 
	addi $s4,$zero,0 #contador de vertical 
	addi $s5,$zero,botones #para poder buscar directamente desde esta posicion de memoria del mips siempre
	addi $s6,$zero,0 #contador de ciclos
	addi $s7,$zero,0x00010000 #Bandera gameover, si mueren todos los bichos o si un bicho llega al limite permitido hacia abajo
	#Una vez terminado la inicializacion de start, me voy a un loop que espera el inicio por un switch
main: #ESTADO ESTABLE (de aca me voy por las ramas, pero este siempre se ejecuta)
	addi $t1,$zero,16 #para verificar la pausa del SWITCH
main_pause_ask_loop:
	lw   $t0,($s5) #leo mi switch numero 1 (menos significativo)
	blt  $t0,$t1,main_pause_ask_loop #hago un loop infinito hasta que mi switch de correr esté prendido
	j main_if_movimiento_proyectil_del_jugador
	#continuo a preguntar si el juego esta en GAMEOVER
main_juego_gameover_success:
	j mapeo_cerar_actual #
main_juego_gameover_return:
	j ini #luego ya si puedo saltar a inicializar de nuevo 
	#continuo al main, sgte estado es si no hubo reinicio y continua la lectura del main de manera normal
##LECTURA DE ESTADOS
main_if_movimiento_proyectil_del_jugador:
	addi $t1,$zero,1
	bne $t1,$s1, main_if_enemigos_muertos #si no existe ningun proyectil en pantalla...
	#no verifico mas tampoco si colisiono mi proyectil si es que no existe en un primer lugar
	j movimiento_proyectil
	#ahora hago la siguiente verificacion
	#si mi proyectil se movio demasiado fuera de pantalla me salto esta etiqueta 
main_if_enemigos_muertos: #modifica bandera GAME OVER si no hay mas enemigos
	j enemy_dead_check
main_enemy_refresh_ask:
	addi $t0,$zero,22
	addi $s6,$s6,1 #aumento el contador de ciclos en 1
	blt  $s6,$t0,main_if_colision_del_jugador  #pregunto si es 16, de no ser así, contionuo en el main
	#de ser asi, tengo que cerar mis posiciones de enemigos actuales y luego moverlos en 2 subrutinas
	addi $s6,$zero,0
	j movimiento_enemigos
	#continuo con el main luego
main_if_colision_del_jugador: #modifica el GAME OVER
	addi $t0,$zero,memoria #verifico el bicho del medio de mi ultima fila
	addi $t0,$t0, 120 #memoria + 36*4 - 4*6  
	lw $t1,($t0) #veo que tengo que mi ultima dirección
	andi $t1,$t1, 0x000000FF #checkeo solamente la fila
	addi $t2,$zero,fila_jugador #copio en un auxiliar para comparar la altura de la fila del jugador
	addi $t3,$zero,14 #12 de  distancia
	subu $t2,$t2,$t1 #resto posicion del jugador - posicion del enemigo
	ble $t2,$t3, main_juego_gameover_success #es t2, osea la distancia jugador - enemigo menor a 6?
#de no ser asi paso a leer los botones
#LECTURA DE BOTONES
main_lectura_botones:
#--------------------------------------
#Registros temporales, funciones:
#--------------------------------------
#Para recibir información de los botones, disparar, moverse, reiniciar
#PARÁMETRO: $a0= dato del boton (N,S,E,W) 
#RECORDANDO, bits: Norte = 1 (reinicio del juego), South = 2 (mover jugador derecha) , East = 3 (disparar), West = 4 (mover jugador izquierda)
#$t1= dato a comparar
	lw $a0,($s5)
main_if_jugador_movimiento_derecha:
	addi $t1,$zero, 18 #btn south 2
	beq $a0,$t1, jugador_movimiento_derecha 
	#si no hay input por el btn south continuo
main_if_jugador_movimiento_izquierda:
	addi $t1,$zero,24 #btn west 8
	beq $a0,$t1, jugador_movimiento_izquierda
	#si no hay input por el btn west continuo
main_if_disparo_proyectil_jugador:
	addi $t1,$zero,1
	beq $t1,$s1, main_if_reinicio_del_juego #si ya hay un proyectil salgo (verificando la bandera de proyectil), sino...
	addi $t1,$zero,20 #btn east 4
	bne $a0,$t1, main_if_reinicio_del_juego  #si se puede disparar el proyectil pero no aprete la tecla correspondiente salto
	j disparo_proyectil #
	#si no hay disparo del proyectil continuo 
	#######################OJO################################
	#el proyectil del enemigo lo disparo cada 16 ciclos en movimiento_enemigos
main_if_reinicio_del_juego:
	addi $t1,$zero, 17 #btn north 1
	beq $a0,$t1, main_juego_gameover_success #si reinicio el juego salto sino continuo...
#TERMINAN LOS BOTONES PRESIONABLES
main_anti_rebote:
	addi $t0,$zero,0
	addi $t1,$zero,tiempo_espera
main_anti_rebote_loop:
	addi $t0,$t0,1
	bne $t0,$t1,main_anti_rebote_loop
	j main
	
###SUBRUTINAS
jugador_movimiento_derecha:
#--------------------------------------	
#Registros temporales, funciones:
#--------------------------------------
#$t0 = posic memoria jugador
#$t1 = dato del jugador
#$t2 = dato auxiliar
#$t3 = para comparar si llegué al tope derecho
#$t4 = contador de espera del mapeo de sprite
	addi $t0,$zero,memoria_jugador #memoria inicial
	addi $t3,$zero,tope_columna_der #para saber primeramente antes de incrementar si la direccion ya es la máxima
	addi $t4,$zero,0 #contador de espera del mapeo de sprite 
	lw $t1,($t0) #guardo lo que tengo originalmente en memoria
	#Para comparar si es posible incrementar la posición a la derecha
	add $t2,$zero,$t1 #copio lo que tengo en mi memoria a otro registro auxiliar
	andi $t2,$t2,0x0000FF00 #para dejar columna solamente
	bgt  $t2,$t3,main_if_jugador_movimiento_izquierda #si $t2 es mayor a ese valor ya no puedo mover a la derecha
	#Si se puede mover, muevo 2 espacios
	#cambio mi información para que el jugador actual se vuelva de color negro	
	andi $t1,$t1,0x0032FFFF #00,00(configuración = 11(vivo/muerto) 00(color)10(sprite),00(columna),00(fila)
	sw $t1,($t0) #guardo mi jugador con color negro cambiado
	jal while_mapeo #espero el mapeo del sprite
	#ahora vuelvo a escribir mi jugador pero avanzando 2 posiciones en columnas
	addi $t1,$t1,0x00000200 #aumento en 2 columnas
	ori $t1,$t1,codif_jugador_ini #pongo la configuración original del jugador (vivo, color, sprite)
	sw $t1,($t0) #guardo mi jugador en la nueva columna
	jal while_mapeo #espero el mapeo del sprite
	j main_if_jugador_movimiento_izquierda
	
###########################################	
###########################################
###########################################	
jugador_movimiento_izquierda:
#--------------------------------------	
#Registros temporales, funciones:
#--------------------------------------
#$t0 = posic memoria jugador
#$t1 = dato del jugador
#$t2 = dato auxiliar
#$t3 = para comparar si llegué al tope izquierdo
#$t4 = contador de espera del mapeo de sprite
	addi $t0,$zero,memoria_jugador #memoria inicial
	addi $t3,$zero,tope_columna_izq #para saber primeramente antes de incrementar si la direccion ya es la máxima
	addi $t4,$zero,0 #contador de espera del mapeo de sprite 
	lw $t1,($t0) #guardo lo que tengo originalmente en memoria
	#Para comparar si es posible incrementar la posición a la izquierda
	add $t2,$zero,$t1 #copio lo que tengo en mi memoria a otro registro auxiliar
	andi $t2,$t2,0x0000FF00 #para dejar columna solamente
	#Pregunto si ya es cero la posición actual del jugador
	beq $t2,$zero, main_if_disparo_proyectil_jugador
	#Si se puede mover, muevo 2 espacios
	#cambio mi información para que el jugador actual se vuelva de color negro	
	andi $t1,$t1,0x0032FFFF #00,00(configuración = 11(vivo/muerto) 00(color)10(sprite),00(columna),00(fila)
	sw $t1,($t0) #guardo mi jugador con color negro cambiado
	jal while_mapeo #espero el mapeo del sprite
	#ahora vuelvo a escribir mi jugador pero avanzando 2 posiciones en columnas
	#ya no uso t2, ahora puedo usarlo para cargar las 2 columnas que le voy a restar a la posicion
	addi $t2,$zero,0x00000200
	subu $t1,$t1,$t2 #reduzco en 2 columnas
	ori $t1,$t1,codif_jugador_ini #pongo la configuración original del jugador (vivo, color, sprite)
	sw $t1,($t0) #guardo mi jugador en la nueva columna
	jal while_mapeo #espero el mapeo del sprite
	j main_if_disparo_proyectil_jugador #vuelvo al main
	
###########################################	
###########################################
###########################################
disparo_proyectil:
#--------------------------------------	
#Registros temporales, funciones:
#PARA EL JUGADOR
#$t0 = informacion del proyectil
#$t2 = posicion memoria jugador
#$t3 = info del jugador
#$t4 = contador de espera del mapeo de sprite
#$t6 = variable extra	

	addi $t4,$zero,0
	addi $t2,$zero,memoria_jugador #cargo la memoria de mi jugador
	addi $t7,$zero,memoria_proyectil_jugador
	lw $t3,($t2) #informacion de mi jugador
	andi $t3,$t3,0x0000FF00 #solo me importa en la columna que se encuentra, lo demás, borro
	addi $t3,$t3,0x00000200 #incremento en 2 respecto a la posicion de mi jugador
	addi $t0,$zero,codif_proyectil_ini #cargo codificacion de mi proyectil
	addi $t0,$t0,fila_proyectil #cargo la fila donde inicia el proyectil
	add $t0,$t0,$t3 #le agrego la columna donde va a estar el proyectil (posicion jugador + 2 lugares a la derecha)
	sw $t0,($t7) #guardo en mi memoria y empieza el mapeo de sprite
	jal while_mapeo 
	addi $s1,$zero,1
	j main_if_reinicio_del_juego #la siguiente tecla

###########################################	
###########################################
###########################################
#############################
movimiento_proyectil:	
#---------------
#Para mover mi proyectil
#$t0 = dato del proyectil
#$t1 = dato auxiliar para cargar a la memoria
#$t2 = dato auxiliar para ver si llegó al tope de filas
#$t3 = dato auxiliar para comparar cual memoria se usa
#-------------------------------------
#Como funciona:
#Verifico si es posible incrementar la posición de mi proyectil primeramente
#Incremento en 4 posiciones mi proyectil
#Si no es posible, lo hago desaparecer (mato)
#---------------
	addi $t7,$zero,memoria_proyectil_jugador
	addi $t4,$zero,0
	addi $t2,$zero,14 #posicion 14
	lw $t0,($t7) #cargo lo que tengo en mi direccion de memoria de proyectil jugador
	andi $t1,$t0,0x000000FF #cargo la fila de mi proyectil
	ble $t1,$t2,cerar_proyectil_jugador	#pregunto si la distancia es menor o igual a 14
	#de no haber llegado a esta posición aún puedo incrementar sin problema la fila
	andi $t1,$t0,0x0033FFFF #preparo el dato para guardarlo como proyectil negro pero vivo
	sw $t1,($t7) #lo guardo en negro
	jal while_mapeo
	add $t1,$zero,$t0 #cargo con la información de mi proyectil
	subiu $t1,$t1,6  #decremento las filas en 6
	ori $t1,$t1,codif_proyectil_ini #me aseguro que este en el estado,sprite,colo correspondiente
	sw $t1,($t7) #guardo la información
	jal while_mapeo 
	#una vez termiando el mapeo
	j colision_proyectil #vuelvo al main

cerar_proyectil_jugador:
	#simplemente cero mi proyectil y lo mato
	lw $t0,($t7) #cargo lo que tengo en mi direccion de memoria de proyectil jugador
	andi $t1,$t0,0x0003FFFF #preparo el dato para guardarlo como proyectil negro y muerto (para poder disparar otro luego)
	sw $t1,($a1)
	jal while_mapeo
	addi $s1,$zero,0 #bandera proyectil
	j main_if_enemigos_muertos#########################################
	
#########################################
#########################################
#-------------------------------
colision_proyectil:
#------------------------------------------------
#Para la detección de colisión de proyectil 
#------------------------------------------------
#$t0 = dato del proyectil
#$t1 = dato del bicho
#$t2 = direccion de memoria del proyectil
#$t3 = direccion de memoria del enemigo
#$t4 = tiempo para mapear
#$t5 = contador de bichos checkeados
#$t6 = 36
#$t7 = variable auxiliar para las comparaciones de fila/columna
#-------------------------------------
#Como funciona:
#Verifico posicion de mi invader
#Verifico distancia minima
#Verifico vivo/muerto
#Impacto y dibujo el sprite nuevo
#------------------------------------
	addi $t2,$zero,memoria_proyectil_jugador
	addi $t3,$zero,memoria
	addi $t3,$t3,140
	addi $t4,$zero,0
	addi $t5,$zero,0
	addi $t6,$zero,36
while_colision_proyectil_con_enemigo:
	#primera etapa de verificación, filas, si hay almenos 8 ($t7) filas de distancia e/ el proyectil y el enemigo
	addi $t7,$zero,10 #distancia a comparar en filas
	lw $t0,($t2) #cargo dato proyectil
	lw $t1,($t3) #cargo dato bicho
	andi $t0,$t0,0x000000FF #para dejar en filas solamente proyectil
	andi $t1,$t1,0x000000FF #IDEM bicho
	subu $t0,$t0,$t1 #resto posicion proyectil - bicho (proyectil es mayor a bicho)
	beq $t0,$t7,colision_proyectil_success_1
	addi $t7,$zero,9
	beq $t0,$t7,colision_proyectil_success_1
	addi $t7,$zero,8
	beq $t0,$t7,colision_proyectil_success_1
	addi $t7,$zero,7
	beq $t0,$t7,colision_proyectil_success_1
	addi $t7,$zero,6
	beq $t0,$t7,colision_proyectil_success_1
	addi $t7,$zero,5
	beq $t0,$t7,colision_proyectil_success_1
	addi $t7,$zero,4
	beq $t0,$t7,colision_proyectil_success_1
	addi $t7,$zero,3
	beq $t0,$t7,colision_proyectil_success_1
	addi $t7,$zero,2
	beq $t0,$t7,colision_proyectil_success_1
	addi $t7,$zero,1
	beq $t0,$t7,colision_proyectil_success_1
	addi $t7,$zero,0
	beq $t0,$t7,colision_proyectil_success_1
	#ahora toca comparar si esta vivo el bicho
colision_proyectil_fail:
	subiu $t3,$t3,4 #decremento mi posicion de memoria
	addi $t5,$t5,1 #aumento el contador de bichos
	beq $t5,$t6, main_if_enemigos_muertos
	j while_colision_proyectil_con_enemigo
	
colision_proyectil_success_1:
	#ahora si estoy cerca de la primera fila, verifico las columnas
	addi $t7,$zero,0x00000600 #distancia a comparar en columnas
	lw $t0,($t2)
	lw $t1,($t3)
	andi $t0,$t0,0x0000FF00 #para dejar en columnas solamente proyectil
	andi $t1,$t1,0x0000FF00 #IDEM bicho
	subu $t0,$t0,$t1 #resto posicion proyectil-bicho
	beq $t0,$t7,colision_proyectil_success_2
	addi $t7,$zero,0x00000500
	beq $t0,$t7,colision_proyectil_success_2
	addi $t7,$zero,0x00000400
	beq $t0,$t7,colision_proyectil_success_2
	addi $t7,$zero,0x00000300
	beq $t0,$t7,colision_proyectil_success_2
	addi $t7,$zero,0x00000200
	beq $t0,$t7,colision_proyectil_success_2
	addi $t7,$zero,0x00000100
	beq $t0,$t7,colision_proyectil_success_2
	addi $t7,$zero,0
	beq $t0,$t7,colision_proyectil_success_2
	j colision_proyectil_fail
	
colision_proyectil_success_2:
	#verifico ahora si esta vivo/muerto
	lw $t0,($t2)
	lw $t1,($t3) 
	andi $t1,$t1,0x00300000 #identificar el sprite y que su estado esta en muerto efectivamente (verifica estado + sprite bicho)
	beq $t1,$zero,colision_proyectil_fail #si está ya muerto no hay colisión y se pasa al siguiente bicho

colision_proyectil_sucess_end:
	#si todo lo que venimos comparando se cumple, entonces sí hay colisión y hay que hacer desaparecer ambas partes (proyectil y bicho)
	lw $t0,($t2)
	lw $t1,($t3)
	andi $t0,$t0,0x0003FFFF #dejo en muerto y color negro al proyectil
	sw $t0,($t2) #cargo en memoria el proyectil muerto
	jal while_mapeo #espero que se pinte todo el sprite
	#al retornar hago lo mismo con mi bicho
	andi $t1,$t1,0x0003FFFF #dejo en muerto y color negro al bicho
	sw $t1,($t3) #lo guardo en mi memoria
	jal while_mapeo #espero que se pinte todo el sprite
	addi $s1,$zero,0 #pongo en 0 la bandera de proyectil
	j main_if_enemigos_muertos	

###################
#################
##################
movimiento_enemigos:
#-----------------------------
#Parametros saved:$s0, movimiento derecha = 0, movimiento izquierda = 1
#$s3 horizontal (hasta 8 veces), $s4 (hasta 14 veces, 230 - 30 = 200/14 = 14, 15 es el limite ya)
#-----------------------------
#$t0 = memoria
#$t1 = informacion del enemigo 
#$t2 = comparar 6
#$t3 = comparar 14
#$t4 = 0 ERROR
#$t5 = comparar 36
#$t6 = contador 36
#$t7 = auxiliar
#-----------------------------
	addi $t0,$zero,memoria
	addi $t2,$zero,8
#	addi $t3,$zero,14
	addi $t4,$zero,0
	addi $t5,$zero,36
	addi $t6,$zero,0
	blt $s3,$t2,movimiento_enemigos_horizontal_derecha #pregunto si movimiento en horizontal es menor a 7
	#si no, entonces llegue al tope del movimiento en horizontal y tengo que moverme en vertical
	addi $s3,$zero,0
	j movimiento_enemigos_vertical
	
movimiento_enemigos_horizontal_derecha: #mapeo desde el bicho mas a la derecha al que esta mas a la izquierda
	addi $t0,$zero,memoria
	addi $t0,$t0,140
movimiento_enemigos_horizontal_derecha_loop:
	lw $t1,($t0)
	andi $t1,$t1,0x0033FFFF #dejo en color negro a mis bichos
	sw $t1,($t0)
	jal while_mapeo #espero el mapeo
	lw $t1,($t0)
	addi $t7,$zero,0x00300000 #auxiliar para comparar si está vivo muerto
	andi $t1,$t1,0x00300000 #lo leido de mi memoria está muerto?
	beq $t7,$t1,movimiento_enemigos_horizontal_derecha_vivo #si efectivamente está vivo
	
movimiento_enemigos_horizontal_derecha_muerto:
	lw $t1,($t0)
	andi $t1,$t1,0x0003FFFF #le saco su fila y columna, le pongo en muerto, color, sprite 00 00 11
	addi $t1,$t1, 0x00000600 #le sumo esa cantidad de columnas
	sw $t1,($t0)
	jal while_mapeo
	addi $t6,$t6,1
	beq $t6,$t5,movimiento_enemigos_bandera_horiz_increase #pregunto si ya mapee todos los bichos, de ser asi, vuelvo al main
	#sino, aumento posicion de memoria
	subiu $t0,$t0,4
	j movimiento_enemigos_horizontal_derecha_loop
	
movimiento_enemigos_horizontal_derecha_vivo:
	lw $t1,($t0)
	andi $t1,$t1,0x0000FFFF #le saco su fila y columna
	ori $t1,$t1, codif_bichos_ini #le pongo en vivo, , color,sprite
	addi $t1,$t1, 0x00000600 #le sumo esa cantidad de columnas
	sw $t1,($t0)
	jal while_mapeo
	addi $t6,$t6,1
	beq $t6,$t5,movimiento_enemigos_bandera_horiz_increase #pregunto si ya mapee todos los bichos, de ser asi, vuelvo al main
	#sino, aumento posicion de memoria
	subiu $t0,$t0,4
	j movimiento_enemigos_horizontal_derecha_loop

movimiento_enemigos_vertical:
	addi $t3,$zero,12
	bge $s4,$t3,main_if_colision_del_jugador #pregunto si llegué al límite de filas de ser así, vuelvo al main para corroborar el GAMEOVER
	#si no llegué al tope de nada muevo normalmente
	beq $s0,$zero,movimiento_enemigos_horizontal_reset
	#pregunto si para la siguiente pasada tengo que moverme a la izquierda o a la derecha
	
movimiento_enemigos_horizontal_reset:
	addi $s3,$zero,0
	addi $t0,$zero,memoria
	addi $t0,$t0,140
	j movimiento_enemigos_vertical_loop	
	
movimiento_enemigos_vertical_loop:
	lw $t1,($t0)
	andi $t1,$t1,0x0033FFFF #dejo en color negro a mis bichos
	sw $t1,($t0)
	jal while_mapeo #espero el mapeo
	lw $t1,($t0)
	add $t7,$zero,0x00300000 #auxiliar para comparar si está vivo muerto
	andi $t1,$t1,0x00300000 #lo leido de mi memoria está muerto?
	beq $t7,$t1,movimiento_enemigos_vertical_vivo #si efectivamente está vivo
	
movimiento_enemigos_vertical_muerto:
	lw $t1,($t0)
	andi $t1,$t1,0x0003FFFF #le saco su fila y columna, le pongo en muerto, color, sprite 00 00 11
	addi $t1,$t1, 14 #le sumo esa cantidad de filas
	subiu $t1,$t1,0x00003000    #si muevo 6 x 8, tengo que restar esa cantidad ahora 
	sw $t1,($t0)
	jal while_mapeo
	addi $t6,$t6,1
	beq $t6,$t5,movimiento_enemigos_bandera_vert_increase #pregunto si ya mapee todos los bichos, de ser asi, vuelvo al main
	#sino, aumento posicion de memoria
	subiu $t0,$t0,4
	j movimiento_enemigos_vertical_loop
	
movimiento_enemigos_vertical_vivo:
	lw $t1,($t0)
	andi $t1,$t1,0x0000FFFF #le saco su fila y columna
	ori $t1,$t1, codif_bichos_ini #le pongo en vivo, color, sprite
	subiu $t1,$t1,0x00003000    #si muevo 6 x 8, tengo que restar esa cantidad ahora 
	addi $t1,$t1, 14 #le sumo esa cantidad de filas
	sw $t1,($t0)
	jal while_mapeo
	addi $t6,$t6,1
	beq $t6,$t5,movimiento_enemigos_bandera_vert_increase #pregunto si ya mapee todos los bichos, de ser asi, vuelvo al main
	#sino, aumento posicion de memoria
	subiu $t0,$t0,4
	j movimiento_enemigos_vertical_loop
		
movimiento_enemigos_bandera_horiz_increase:
	addi $s3,$s3,1
	#pregunto si ya llegó al tope osea 8
	j main_lectura_botones

movimiento_enemigos_bandera_vert_increase:
	addi $s4,$s4,1
	#pregunto si ya llegó al tope osea 15
	j main_lectura_botones
#########################################
#########################################
#########################################
enemy_dead_check:
#----------------
#$t0 = memoria enemigo
#$t1 = contador de enemigos muertos
#$t2 = dato del enemigo
#$t3 = 36
#$t6 = contador de ciclos
#-----------------
	addi $t0,$zero,memoria #memoria
	addi $t1,$zero,0 #contador de muertos
	addi $t6,$zero,0 #contador de ciclos
	addi $t3,$zero,36
enemy_dead_check_loop:
	lw $t2,($t0) #cargo dato
	andi $t2,$t2,0x00300000 #solo quiero el estado vivo / muerto
	beq $t2,$zero,enemy_dead_check_incremento #es mi dato del bicho leido muerto
	#sigue vivo el enemigo...
	addi $t6,$t6, 1 #incremento mi contador de ciclos en 1
	beq $t6,$t3,main_enemy_refresh_ask #ya se contaron 36 ciclos?
	#de no ser asi incremento nada mas mi memoria
	addi $t0,$t0,4 #incremento mi memoria
	j enemy_dead_check_loop
	
enemy_dead_check_incremento:
	addi $t1,$t1,1
	addi $t6,$t6,1 
	beq $t1,$t3,main_juego_gameover_success #hay 36 bichos muertos?
	beq $t6,$t3,main_enemy_refresh_ask #ya se contaron 36 ciclos?
	addi $t0,$t0,4 #incremento mi memoria
	j enemy_dead_check_loop #salto al loop
#########################################
#######################################
#########################################
mapeo_cerar_actual: #solo en gameover o reinicio
#-----------------------------
#$t0 = memoria 
#$t1 = informacion 
#$t3 = contador de 
#$t6 = 39 (36 + 1 jugador + 2 proyectiles)
#------------------------------
	addi $t0,$zero,memoria
	addi $t3,$zero,0
	addi $t4,$zero,0 #ACA EL ERROR
	#addi $t5,$zero,36
	addi $t6,$zero,39

mapeo_cerar_loop:
	lw $t1,($t0)
	andi $t1,$t1,0x0033FFFF #dejo en color negro a mis bichos
	sw $t1,($t0)
	jal while_mapeo #espero el mapeo
	addi $t3,$t3,1
	beq $t3,$t6, main_juego_gameover_return #ya llegó a 39? ERROR LO QUE PREGUNTABA A DONDE SALTABA
	#de no ser así vuelvo a hacer el loop incrementando mi posicion de memoria
	addi $t0,$t0,4
	j mapeo_cerar_loop
	
#############################
#############################

