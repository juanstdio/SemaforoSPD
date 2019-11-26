# SemaforoSPD
Semaforo controlado por LPT1 realizado en Assembler, con una configuración de Interrupción en 81h

### ¿Que tenía que hacer? 
Debia controlar 6 led's conectados por el puerto de datos de un puerto paralelo. A su vez, usando un bit del puerto de control del mismo puerto (pero distinta dirección), activar o desactivarlo (Quedando en caso afirmativo, titlando en amarillo y, en caso negativo, el funcionamiento normal).

El __temporizado__ del tiempo tenía que hacerse a traves de una interrupción instalada en la posición 81h, el _Delay_ del mismo debía pasarse por el registro AL (en segundos) para así generar las pseudo-demoras en el transcurso de la secuencia.

El programa debía detenerse si se pulsaba la tecla _Enter_, en cualquier momento.

### Datos importantes

* Este software fue programado totalmente en Windows 98, usando una Thinkpad 600 con Pentium II y 64 mb de memoria RAM.

*Para compilarlo se requiere Turbo Assembler , (tambien llamado "TASM") y tlink

´´´
tasm semaforo.asm
´´´
y luego
´´´
tlink semaforo.obj
´´´




