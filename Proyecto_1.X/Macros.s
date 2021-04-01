
Semaforo1 macro color
    bcf PORTD, 0
    bcf PORTD, 1
    bcf PORTD, 2
    bsf PORTD, color
endm

Semaforo2 macro color
    bcf PORTD, 3
    bcf PORTD, 4
    bcf PORTD, 5
    bsf PORTD, color+3
endm

Semaforo3 macro color
    bcf PORTE, 0
    bcf PORTE, 1
    bcf PORTE, 2
    bsf PORTE, color
endm
    
Off_Semaforo1 macro color
    bcf PORTD, color
endm
Off_Semaforo2 macro color
    bcf PORTD, color+3
endm
Off_Semaforo3 macro color
    bcf PORTE, color
endm
    
Blink_Semaforo1 macro color 
    btfss Banderas_Semaforos, 2       ; Revisa Bandera de Medio Segundo
    goto Fin_Blink_Semaforo1
    
    btfss PORTD, color
    goto  Encender_Blink_Semaforo1
    
    btfsc PORTD, color
    goto  Apagar_Blink_Semaforo1
    
    Apagar_Blink_Semaforo1:
	bcf   PORTD, color
	goto  Fin_Blink_Semaforo1
    Encender_Blink_Semaforo1:
	bsf   PORTD, color
 
    Fin_Blink_Semaforo1:
endm

Blink_Semaforo2 macro color 
    btfss Banderas_Semaforos, 2
    goto Fin_Blink_Semaforo2
    
    btfsc PORTD, color+3
    goto  Apagar_Blink_Semaforo2
    
    btfss PORTD, color+3
    goto  Encender_Blink_Semaforo2
    
    Apagar_Blink_Semaforo2:
	bcf   PORTD, color+3
	goto  Fin_Blink_Semaforo2
    Encender_Blink_Semaforo2:
	bsf   PORTD, color+3
 
    Fin_Blink_Semaforo2:
endm

Blink_Semaforo3 macro color 
    btfss Banderas_Semaforos, 2
    goto Fin_Blink_Semaforo3
    
    btfsc PORTE, color
    goto  Apagar_Blink_Semaforo3
    
    btfss PORTE, color
    goto  Encender_Blink_Semaforo3
    
    Apagar_Blink_Semaforo3:
	bcf   PORTE, color
	goto  Fin_Blink_Semaforo3
    Encender_Blink_Semaforo3:
	bsf   PORTE, color
 
    Fin_Blink_Semaforo3:
endm
    
Reseteo macro
    btfss Banderas_Semaforos, 2
    goto Fin_Reseteo
    
    btfsc PORTE, 2
    goto  Apagar_Reseteo
    
    btfss PORTE, 2
    goto  Encender_Reseteo
    
    Apagar_Reseteo:
	bcf   PORTD, 2
	bcf   PORTD, 2+3
	bcf   PORTE, 2
	goto  Fin_Reseteo
    Encender_Reseteo:
	bsf   PORTD, 2
	bsf   PORTD, 2+3
	bsf   PORTE, 2
    Fin_Reseteo:
endm 
 
Nuevo_Tiempo macro tiempo, contador
    movlw tiempo
    movwf contador
endm

Dec_1Seg macro temporizador, bandera
    btfsc Banderas_Semaforos, bandera
    decf temporizador,1
endm
    
CambioDeEstado macro 
    movlw 0
    subwf Temporizador_1,0
    btfsc ZERO
    goto  Cambio
    movlw 0
    subwf Temporizador_2,0
    btfsc ZERO
    goto  Cambio
    movlw 0
    subwf Temporizador_3,0
    btfsc ZERO
    goto  Cambio
    goto fin_CambioDeEstado
    Cambio:
    bsf Banderas_Estados, 0 ; Bandera de Cambio de estado
    fin_CambioDeEstado:
endm
      
Underflow macro registro
    movlw 9
    subwf registro, 0 
    btfsc ZERO
    movlw 20
    btfsc ZERO
    movwf registro 
endm
    
Overflow macro registro
    movlw 21
    subwf registro, 0 
    btfsc ZERO
    movlw 10
    btfsc ZERO
    movwf registro 
endm
    
; Restablecer los tiempos dependiendo de la vía 
Tiempos_Via_1 macro 
	Off_Semaforo1 2 ;Rojo    ; Apagamos el led Rojo en el semaforo 1
	Semaforo1 0 ;Verde       ; Encendemos el led Verde en el semaforo 1
	Semaforo2 2 ;Rojo        ; Encender el color rojo en los semaforos 2 y 3
	Semaforo3 2 ;Rojo
	
	movf  Tiempo_Via1, 0   ; Actualización del tiempo de Via 1, corresponde al 
	movwf Temporizador_1       ; tiempo en el que lleva la vía

	movf  Tiempo_Via1, 0   ; Actualización del tiempo de Via 2, corresponde al
	movwf Temporizador_2       ; Corresponde al tiempo que estara en rojo

	movf  Tiempo_Via2, 0   ; Actualización del tiempo de Via 3, corresponde al
	addwf Tiempo_Via1,0    ; Corresponde al tiempo que estara en rojo
	movwf Temporizador_3
endm
	
Tiempos_Via_2 macro         
        Off_Semaforo2 2 ;Rojo      ; Apagamos el led Rojo en el semaforo 2
	Semaforo2 0 ;Verde         ; Encendemos el led Verde en el semaforo 2
        Semaforo1 2 ;Rojo          ; Encender el color rojo en los semaforos 1 y 3
	Semaforo3 2 ;Rojo
	
	movf  Tiempo_Via2, 0   ; Actualización del tiempo de Via 1, corresponde al
	addwf Tiempo_Via3, 0   ; Corresponde al tiempo que estara en rojo
	movwf Temporizador_1

	movf  Tiempo_Via2, 0   ; Actualización del tiempo de Via 2, corresponde al 
	movwf Temporizador_2       ; tiempo en el que lleva la vía

	movf  Tiempo_Via2, 0   ; Actualización del tiempo de Via 3, corresponde al
	movwf Temporizador_3       ; Corresponde al tiempo que estara en rojo
endm
	
Tiempos_Via_3 macro 	
	Off_Semaforo3 2 ;Rojo      ; Apagamos el led Rojo en el semaforo 3
	Semaforo3 0 ;Verde         ; Encendemos el led Verde en el semaforo 3
	Semaforo1 2 ;Rojo          ; Encender el color rojo en los semaforos 1 y 2 
	Semaforo2 2 ;Rojo

	movf  Tiempo_Via3, 0   ; Actualización del tiempo de Via 1, corresponde al 
	movwf Temporizador_1       ; tiempo en el que lleva la vía

	movf  Tiempo_Via3, 0   ; Actualización del tiempo de Via 2, corresponde al
	addwf Tiempo_Via1, 0   ; Corresponde al tiempo que estara en rojo
	movwf Temporizador_2

	movf  Tiempo_Via3, 0   ; Actualización del tiempo de Via 3, corresponde al
	movwf Temporizador_3       ; Corresponde al tiempo que estara en rojo
endm    
    