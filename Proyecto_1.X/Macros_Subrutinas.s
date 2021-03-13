Leds_Semaforo macro semaforo,color
    ; Semaforo_1 = 001
    ; Semaforo_2 = 010
    ; Semaforo_3 = 100
    movlw semaforo
    movwf SEMAFORO
    addwf 0x0f
    btfsc SEMAFORO,0
    bsf  PORTD, color
    btfsc SEMAFORO,1
    bsf  PORTD, color+3
    btfsc SEMAFORO,2
    bsf  PORTE, color
    
  endm

