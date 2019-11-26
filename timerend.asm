;-----------------------------------------------------------------------
; Programa TIMEREND que se instala en el vector de interrupciones 81h
; que genera un retardo de un tiempo recibido por AL.
; Se debe generar el ejecutable .COM con los siguientes comandos:
;       tasm timerend.asm
;       tlink /t timerend.obj
;-----------------------------------------------------------------------
.8086
.model tiny		; Definicion para generar un archivo .COM

.code
   org 100h		; Definicion para generar un archivo .COM
start:
   jmp main		; Comienza con un salto para dejar la parte residente primero

;------------------------------------------------------------------------      ;
;- Interrupción que temporiza el tiempo entre 1 y 9 segundos, que viene por al ;
;------------------------------------------------------------------------      ;
CRONOMETRO PROC FAR
push dx  ; guardo todos los registros, MENOS AX
     ; en al --> segundos que vinieron del programa
     ; en cl -> minutos
     ; en dh -> segundos

mov bl,al  ; como mi programa usa ax, lo muevo a bl para trabajarlo
primero:
mov ah,2ch  ; llamo a la hora
int 21h     ;pido al DOS 
mov bh,dh   ; la guardo en la parte alta de bx
segundos:   ; pasa un ratito
mov ah,2ch  ; vuelvo a pedir la hora
int 21h     ; pido al DOS
cmp bh,dh   ; comparo si son distintos los tiempos 
jne pasoalgo ; si no son iguales, paso un segundo
jmp segundos ; sino, que vuelva a pedir la hora
pasoalgo: ; si pasa un segundo entra aca
mov ah,02h  ; pido cursor
mov dl,2Eh  ; escribo un punto para indicar un segundo
int 21h     ; llamo al DOS escribir
dec bl	    ; decremento bl, registro que tenia guardado el tiempo de al
cmp bl,0   ; comparo bl con cero, para saber si el tiempo paso
je fin    ; si es igual a cero, termine 
jmp primero   ; sino, me vuelvo arriba
    
fin: 	  ; si termine el tiempo, llegue aca	
pop dx    ; devuelvo todos los registros en forma invertida
    iret  ; me voy de la rutina de interrupcion
endp

; Datos usados dentro de la ISR ya que no hay DS dentro de una ISR
DespIntXX dw 0
SegIntXX  dw 0

FinResidente LABEL BYTE		; Marca el fin de la porcion a dejar residente
;------------------------------------------------------------------------
; Datos a ser usados por el Instalador
;------------------------------------------------------------------------
Cartel    DB "Driver de timer instalado :-) ",0dh, 0ah, '$'

main:
; Se apunta todos los registros de segmentos al mismo lugar CS.
    mov ax,CS
    mov DS,ax
    mov ES,ax

InstalarInt:
    mov AX,3581h        ; Obtiene la ISR que esta instalada en la interrupcion
    int 21h    
         
    mov DespIntXX,BX    
    mov SegIntXX,ES

    mov AX,2581h        ; Coloca la nueva ISR en el vector de interrupciones 81
    mov DX,Offset CRONOMETRO
    int 21h

MostrarCartel:
    mov dx, offset Cartel
    mov ah,9
    int 21h

DejarResidente:		
    Mov     AX,(15+offset FinResidente) 
    Shr     AX,1            
    Shr     AX,1        ;Se obtiene la cantidad de paragraphs
    Shr     AX,1
    Shr     AX,1	;ocupado por el codigo
    Mov     DX,AX           
    Mov     AX,3100h    ;y termina sin error 0, dejando el
    Int     21h         ;programa residente
end start
