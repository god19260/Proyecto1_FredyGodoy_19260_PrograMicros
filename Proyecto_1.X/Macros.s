    
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
    
Off_Semaforo1 macro
    bcf PORTD, 0
    bcf PORTD, 1
    bcf PORTD, 2
    endm
Off_Semaforo2 macro
    bcf PORTD, 3
    bcf PORTD, 4
    bcf PORTD, 5
    endm
Off_Semaforo3 macro
    bcf PORTE, 0
    bcf PORTE, 1
    bcf PORTE, 2
    endm
Blink_Semaforo1 macro contador, color 
    movlw 100
    subwf contador,0
    btfsc STATUS,2 ;ZERO
    bsf   PORTD, color
    movlw 200
    subwf contador,0
    btfsc STATUS, 2 ;ZERO
    bcf   PORTD, color
    movlw 200
    subwf contador,0
    btfsc STATUS, 2 ; ZERO
    clrf  contador
endm

Blink_Semaforo2 macro contador, color 
    movlw 100
    subwf contador,0
    btfsc STATUS,2 ;ZERO
    bsf   PORTD, color+3
    movlw 200
    subwf contador,0
    btfsc STATUS, 2 ;ZERO
    bcf   PORTD, color+3
    movlw 200
    subwf contador,0
    btfsc STATUS, 2 ; ZERO
    clrf  contador
endm

Blink_Semaforo3 macro contador, color 
    movlw 100
    subwf contador,0
    btfsc STATUS,2 ;ZERO
    bsf   PORTE, color
    movlw 200
    subwf contador,0
    btfsc STATUS, 2 ;ZERO
    bcf   PORTE, color
    movlw 200
    subwf contador,0
    btfsc STATUS, 2 ; ZERO
    clrf  contador
endm

E_B macro cont1, cont2, cont3, registro, bit   ; Enable Blink
    clrf cont1
    clrf cont2
    clrf cont3
    bsf  registro, bit
endm

 
Nuevo_Tiempo macro tiempo, contador
    movlw tiempo
    movwf contador
endm
 
inc_1Seg macro contador, incremento
    movlw 200
    subwf contador,0
    btfsc ZERO
    incf  incremento,1
    
    movlw 200
    subwf contador,0
    btfsc ZERO
    clrf  contador
endm

dec_1Seg macro contador, decremento
    movlw 200
    subwf contador,0
    btfsc ZERO
    decf  decremento,1
    
    movlw 200
    subwf contador,0
    btfsc ZERO
    clrf  contador
endm
    