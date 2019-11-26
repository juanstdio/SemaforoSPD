# SemaforoSPD
Semaforo controlado por LPT1 realizado en Assembler, con una configuración de Interrupción en 81h

### ¿Que tenía que hacer? 
Debia __controlar__ 6 led's conectados por el _puerto de datos_ de un puerto paralelo. A su vez, usando un bit del _puerto de control_ del mismo puerto (pero distinta dirección), activar o desactivarlo (Quedando en caso afirmativo, titlando en amarillo y, en caso negativo, el funcionamiento normal).

El __temporizado__ del tiempo tenía que hacerse a traves de una interrupción instalada en la posición 81h, el _tiempo_ del mismo debía pasarse por el registro AL (en segundos) para así generar las pseudo-demoras en el transcurso de la secuencia.

El programa debía detenerse si se pulsaba la tecla _Enter_, en cualquier momento.

### Datos importantes

* Este software fue programado totalmente en Windows 98, usando una __Thinkpad 600 con Pentium II y 64 mb de memoria RAM__

* La interrupción no utiliza variables, trabaja directamente con los registros del DOS.

* Para compilarlo se requiere Turbo Assembler , (tambien llamado "TASM") y tlink

```
tasm semaforo.asm
```
y luego
```
tlink semaforo.obj
```
en caso de querer ver como se mueven los registros, sugiero utilizar Turbo Debugger (programa que viene con TASM), utilizando 
```
td semaforo.exe
```

end
Licencia MIT



