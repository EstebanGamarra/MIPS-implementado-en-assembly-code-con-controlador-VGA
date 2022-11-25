# Space-Invaders-implementado-con-MIPS-en-assembly-code-con-controlador-VGA

Trabajo de noveno semestre de la carrera Ingeniería Electrónica de la cátedra Proyecto con Microprocesadores 2

Autores: Esteban José Gamarra Duarte (controlador VGA, programa space invaders), Prof. Ing. Vicente González (Código base MIPS con 16 instrucciones de base) 

Institución: Universidad Católica Nuestra Señora de la Asunción

País: Paraguay

Ciudad: Asunción

Carrera: Ingeniería Electrónica

Año: 2022

Resumen:

Este trabajo se basa en un programa base (Space invaders) escrito en assembly code .asm, todo el sistema del FPGA funciona mediante varios archivos en lenguaje VHDL (lenguaje de descripción de hardware) que reflejan la arquitectura de un MIPS sencillo con una cantidad especifica de instrucciones, manejo de memoria específico y simulación de periféricos para distintos tipos de funcionalidades (como el uso de botones de la placa o el LCD). El programa funciona en una placa FPGA Spartan-7 Evaluation Kit, de la marca Xilinx. 

El mapeamiento de los sprites es mediante RAM, opuesto al común utilizado ROM, se usa un decodificador a nivel de hardware que mapea el sprite indicado cuando ocurre un cambio de posición ya sea para proyectil/jugador/enemigo en pantalla. La ROM es pequeña y posee información directa que es utilizada por el decodificador así la memoria tiene los campos: POSICION X - POSICION Y - TIPO/COLOR - BANDERA VIVO/MUERTO, de esta manera mediante una ALU se calcula la posición relativa en pantalla respecto a lo que se tiene en memoria, ya que las posiciones reales de los elementos del juego se mapean en memoria como una matriz X . Y , con 64x64 espacios disponibles de ocupación, mientras que el TIPO/COLOR y BANDERA VIVO/MUERTO son utilizados por el decodificador para mandar la información requerida al controlador de color del VGA durante su barrido de imágen.

De esta forma la ROM es muy pequeña y la mayoría de los procesos díficiles de mapeamiento y control de posición son relegados al hardware, por software simplemente vamos llenando esta pequeña ROM que tiene la información de cada objeto del juego.
