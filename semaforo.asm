; ***********************************************************************
; Programa: Semaforo de 5 pasos para TP de procesamiento de datos, 2019 ;
; Alumno: Juan Blanc							                                      ;
; Profesor : Fabio Bruschetti, Pedro Iriso	                       	    ;
; Carrera: Tecnicatura en Redes Informaticas			                      ;
; ***********************************************************************


;DISCLAIMER : No usar acentos en los comentarios de este codigo, explota el tasm.
;plus DISCLAIMER: se debe ejecutar el instalador del driver -timerend- antes de ejecutar el programa.

.8086   ;tipo de procesador en estudio
.model small ;modelo adaptado 
.stack 100h  ; tamanio de stack para el Trabajo practico
.data        ;seccion de datos               ; bits para escribir en el puerto
                                             ; r1 a1 v1 r2 a2 v2 n/a n/a
; Constantes de semaforo
rojo1verde2paso1 EQU 21h       ; 5 segundos    1  0  0  0 | 0  1  0  0 = 84h 
rojo1amari2verde2paso2 EQU 31h ; 1 segundo     1  0  0  0 | 1  1  0  0 = 8Ch
rojo1rojo2paso3 EQU 09h        ; 1 segundo     1  0  0  1 | 0  0  0  0 = 90h
verde1rojo2paso4 EQU 0Ch       ; 5 segundos    0  0  1  1 | 0  0  0  0 = 30h
amarillo1y2pint  EQU 12h       ; 1 segundo     0  1  0  0 | 1  0  0  0 = 48h 
apagartodo       EQU 00h       ; 0 segundos    0  0  0  0 | 0  0  0  0 = 00h

; constantes de control para IBM ThinkPad 600, cambiar para otras PC's

puertodatos  EQU 3BCh  ; 378 en otras pc’s
puertoestado EQU 3BDh  ;  un bit mas
teclasalida EQU 0dh    ; tecla Enter en ASCII
codigoboton EQU 7Fh    ; direccion usada en la deteccion de semaforo	 
    ; boton de salida 
; carteles informativos 
cartel db "PASO:"
cartel1 db "Semaforo 1.0",0dh,0ah,'$' 
cartel2 db "Presione Intro para detener",0dh,0ah,'$'
cartel3 db "Esperando llave",0dh,'$'

.code
main proc
	mov ax,@data
	mov ds,ax
       mov si,0  ;ponemos el registro fuente en 0, se usa para saber si alguien apreto enter
       mov di,1  ;ponemos el registro destino en 1, porque es lo que se usa para comparar lo anterior
	mov ah,9  ; sacamos 
	mov dx, offset cartel1  ; cartel informativo
	int 21h
        mov dx,offset cartel2
        int 21h
        xor dx,dx
        mov dx,puertodatos ;cargo en el registro una sola vez el puerto de datos
paso1:  
        call llave  ;llama a la llave para ver si esta activa
	push dx    ; se hace esto porque esta guardada la direccion del puerto en ese momento
	mov dx,offset 31h    ; entonces se usa esto para senislizar que esta en el paso 1
	int 21h		      ; sale por pantalla	
	pop dx               ; devolvemos el contenido de DX 
        call notinterrupt   ; con esta llamada nos fijamos si se apreto una tecla
        cmp si,1	     ; buscando si se apreto
        je fin 	             ; programa termina
	mov al,rojo1verde2paso1  ; sino, ejecuta el paso
	out dx,al	       ; saca por el puerto
	mov al,5		; vamos a esperar 5 segundos
        int 81h			; interrumpimos 5 segundos
paso2: 
        push dx
	mov dx,offset 32h  ; en vez de uno, ahora es un dos
	int 21h
	pop dx
        call notinterrupt
	cmp si,1  
        je fin
	mov al,rojo1amari2verde2paso2  ; carga paso2
	out dx,al
	mov al,1   			; vamos a esperar un segundo
       int 81h  				
paso3:
	push dx
	mov dx,offset 33h     ; ahora es un tres, paso 3
	int 21h
	pop dx
       call notinterrupt
       cmp si,1  
       je fin
       mov al,rojo1rojo2paso3
       out dx,al
       mov al,1
       int 81h

paso4:
	push dx	
	mov dx,offset 34h  ;ahora es un 4, paso 4
	int 21h
	pop dx
        call notinterrupt
        cmp si,1  
        je fin
	mov al,verde1rojo2paso4 
	out dx,al
	mov al,5  ; esperaremos 5 segundos
        int 81h
        jmp paso1  ; volvemos al inicio


fin:
        mov al,apagartodo
	out dx,al
        mov ax,4c00h
	int 21h
main endp




notinterrupt proc 
	push dx ax ; guardo los contenidos de los registros
	mov ah,0bh ; hay caracteres disponibles en el buffer?
	int 21h    ; se pregunta al DOS esto
	cmp al,0   ; si los hay, al != 0 (al no es igual a cero)
	je nopasonada  ; nos vamos panchos, nadie apreto nada
	mov ah,0  ; pero si paso algo
	int 16h   ; pregunto  que tecla es y
	mov ah,2  ; que guarde en al la tecla detectada
	cmp al,teclasalida ; comparo con la tecla definida mas arriba
	je pasoalgo   ; me voy a pasoalgo si es igual
	nopasonada: 
	mov si,0   ; si sigue en cero
	pop ax dx ; se devuelven registros contenidos en el stack
	ret	   ;volvemos al main

	pasoalgo:  ; importante en caso de deteccion de tecla
	inc si   ; si pasa algo se incrementa si
	pop ax dx ; se devuelve el contenido del stack a los registros
	ret  ; volvemos al main
notinterrupt endp



llave proc
       push ax bx dx  ; 
        mov dx,puertoestado  ; aqui cargo el puerto de lectura 
lectura:
        call notinterrupt ; llamo a la funcion para ver si alguien apreto enter
	cmp si,1	; compara si con 1 para saber si alguien apreto enter

        in al,dx    ; aca dx es puerto de estado
        cmp al,codigoboton   ; busca si se cerro el circuito, comparando los valores de al y bl
	je sigasiga ; se va al final

        push dx ; guardo dx para escribir en pantalla
        mov dx,offset 07h  ;saca un cartel para indicar que la llave no esta activada
        int 21h  ; escribo
        pop dx  ; devuelvo dx que recien guarde (que tenia el puerto de estado)

        push bx dx  ; guardo el valor de al que saque de la lectura
	mov al,amarillo1y2pint 	;enciende las luces amarillas
        mov dx, puertodatos
        out dx,al
	mov al,1  ;vamos a esperar un segundo
        int 81h ; espera un segundo

        ; esperando un segundo con las luces encendidas
        mov al,apagartodo
        out dx,al
        mov al,1
        int 81h

        pop dx bx 
	mov al,0
        in al,dx    ; aca dx es puerto de estado
	NOP ; NOP agregados por debouncing
	NOP
	NOP
	NOP
	NOP	
	NOP
	NOP
	NOP
        jmp lectura ; volvemos a leer, porque esta activado el switch   

	sigasiga:   ; si cambio se sigue porque se activo el sistema
        mov ah,2h
        mov dx,offset 3Bh ; saco un punto y coma, indicando que esta activa la llave
        int 21h

       pop dx bx ax ; recupero el puerto de control y los datos de las variables
       ret ; volvemos al programa principal

llave endp   
				
	

end main
