; Fredy Godoy 19260
; Programación de Microcontroladores
; Proyecto 1
    
processor 16F887
#include <xc.inc>
#include "Macros.s"
; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF             ; Watchdog Timer Enable bit (WDT enabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF            ; Brown Out Reset Selection bits (BOR enabled)
  CONFIG  IESO = OFF             ; Internal External Switchover bit (Internal/External Switchover mode is enabled)
  CONFIG  FCMEN = OFF            ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is enabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

;---------------------------------------------------------
;------------ Variables a usar ---------------------------
;---------------------------------------------------------
PSECT udata_bank0     
    #define B_Modo      5    ; pines puerto B, Modo, Incremento y Decremento
    #define B_Inc       6   
    #define B_Dec       7
    
    W_TEMP:             DS 1
    STATUS_TEMP:        DS 1
    
    Banderas1:          DS 1
    #define Sel_Via     0
    
    Banderas_Semaforos: DS 1 
    #define Blink       0
    #define Un_Seg      1
    #define Tres_Seg    2
    #define Seis_Seg    3
    #define Blink_A_S1  4    ; Bandera del blink luz amarilla del semaforo 1
    #define Blink_A_S2  5    ; Bandera del blink luz amarilla del semaforo 2
    #define Blink_A_S3  6    ; Bandera del blink luz amarilla del semaforo 3
    
    Banderas_Dis:       DS 1
    #define Dis_11      0
    #define Dis_12      1
    #define Dis_21      2
    #define Dis_22      3 
    #define Dis_31      4
    #define Dis_32      5
    #define Dis_41      6
    #define Dis_42      7
    V_Display_11:       DS 1       ; Valor que muestra mostrará el display
    V_Display_12:       DS 1
    V_Display_21:       DS 1
    V_Display_22:       DS 1
    V_Display_31:       DS 1
    V_Display_32:       DS 1
    V_Display_41:       DS 1
    V_Display_42:       DS 1
    #define Verde       0         
    #define Amarillo    1
    #define Rojo        2
    Contador_Blink:     DS 1
    Contador_1Seg:      DS 1
    Contador_3Seg:      DS 1
    Contador_6Seg:      DS 1
    

;---------------------------------------------------------
;------------ Reset Vector -------------------------------
PSECT resVect, class=code, abs, delta=2  
ORG 00h
resVect:
    PAGESEL main
    goto    main 

;---------------------------------------------------------
;------------ Interrupción -------------------------------
;---------------------------------------------------------
PSECT resVect, class=code, abs, delta=2  
ORG 04h
push:
    movwf  W_TEMP
    swapf  STATUS,W
    movwf  STATUS_TEMP
isr:
    btfsc  RBIF
    goto   Contador;Interrupcion Puerto B
   
    btfsc  T0IF
    goto   Temporizador    ;Interrupcion timer0
    
    bcf    T0IF
    BCF    RBIF
pop: 
    swapf  STATUS_TEMP,W
    movwf  STATUS
    swapf  W_TEMP, F
    swapf  W_TEMP, W
    
    RETFIE
Contador:
    btfss  PORTB, B_Inc
    incf    V_Display_11,1
    
    btfss  PORTB, B_Dec
    decf    V_Display_11,1
    
    bcf    RBIF
    goto   isr
Temporizador:
    bsf    Banderas1,Sel_Via     
    incf   Contador_Blink,1
    incf   Contador_1Seg,1
    
    movlw  246                 ; Timer para una interrupción cada 5ms 
    movwf  TMR0
    bcf    T0IF
    goto   isr
;---------------------------------------------------------
;------------ Definición del Inicio ----------------------
PSECT code, delta=2, abs
ORG 100h
;---------------------------------------------------------
;------------ Tablas -------------------------------------
Display:
    clrf  PCLATH
    bsf   PCLATH,0
    andlw 0x0F
    addwf PCL
    retlw 00111111B ; Cero
    retlw 00000110B ;Uno
    retlw 01011011B ;Dos
    retlw 01001111B ;Tres
    retlw 01100110B ;Cuatro
    retlw 01101101B ;Cinco
    retlw 01111101B ;Seis 
    retlw 00000111B ;Siete
    retlw 01111111B ;Ocho
    retlw 01100111B ;Nueve
    retlw 01110111B ;A
    retlw 01111100B ;B
    retlw 00111001B ;C
    retlw 01011110B ;D
    retlw 01111001B ;E
    retlw 01110001B ;F 
    
;---------------------------------------------------------
;------------ Main ---------------------------------------
;---------------------------------------------------------
main: 
    ;------- Configuraciones -------
    ;------- Oscilador -------------
    BANKSEL  OSCCON
    bsf      IRCF0       ; Configuración del reloj interno 
    bsf      IRCF1
    bcf      IRCF2       ; 500khz   
    
    ;------- Timer0 ---------------
    bcf      OPTION_REG, 5
    bcf      OPTION_REG, 3
    bsf      OPTION_REG, 0     ; Se selecciona un preescaler de 64
    bcf      OPTION_REG, 1
    bsf      OPTION_REG, 2     
    
    banksel  INTCON           ; Habilitar Interrupciones
    movlw    10101000B
    movwf    INTCON
    
    clrf     TMR0
    movlw    246              ; n de timer0
    movwf    TMR0
    
    ;------- Puertos ---------------
    BANKSEL  ANSEL         ; Disponer los pines como I/O Inputs
    clrf     ANSEL 
    clrf     ANSELH
    
    BANKSEL  TRISA
    movlw    00000000B     ; PORTA Todos los pines como salidas
    movwf    TRISA
    
    movlw    00000000B     ; PORTC Todos los pines como salidas
    movwf    TRISC
    
    movlw    11000000B     ; PORTD los pines 0-2 como salidas, 3-7 como entradas
    movwf    TRISD
    
    movlw    00000000B     ; PORTE Todos los pines como salidas
    movwf    TRISE
    ;------- Activación de pull ups
    banksel  OPTION_REG
    bcf      OPTION_REG, 7
    bsf      WPUB, B_Inc    
    bsf      WPUB, B_Dec 
    
    ;------- Activación Interrup on change
    banksel  IOCB
    bsf      IOCB, B_Modo 
    bsf      IOCB, B_Inc   
    bsf      IOCB, B_Dec  
    
    
    ;------- Limpieza de puertos y variables 
    banksel  PORTA
    ;movf     PORTB, W
    clrf     PORTA
    clrf     PORTB
    clrf     PORTC
    clrf     PORTD
    clrf     PORTE
    clrf     Banderas1
    clrf     Banderas_Dis
    clrf     Banderas_Semaforos
    clrf     V_Display_11
    clrf     V_Display_12
    clrf     V_Display_31
    clrf     V_Display_32
    clrf     V_Display_41
    clrf     V_Display_42
    clrf     Contador_Blink
    clrf     Contador_1Seg
    clrf     Contador_3Seg
    clrf     Contador_6Seg
    
    
    ;------- Activaciones de registros o puertos
    btfss    PORTB, 0      ; Primera instrucción que no genera interrupción
    nop 
    bsf      Banderas_Dis, Dis_11     ; Encdender la bandera del display 1
    
;---------------------------------------------------------
;----------- Loop Forever --------------------------------
;---------------------------------------------------------
loop:
    movf    V_Display_11,0    
    call    Display    
    movwf   V_Display_12
    
    movlw   10B
    call    Display
    movwf   V_Display_21
    movwf   V_Display_22
    
    movlw   11B
    call    Display
    movwf   V_Display_31
    movwf   V_Display_32
    
    movlw   100B
    call    Display
    movwf   V_Display_41
    movwf   V_Display_42
    
    bcf   Banderas_Semaforos, Un_Seg
    bcf   Banderas_Semaforos, Tres_Seg
    bcf   Banderas_Semaforos, Seis_Seg
    
    
    call  Tiempos
    
    btfsc   Banderas1,Sel_Via  ; Mostrar valores en displays cada 5ms
    goto    Seleccion_Via 
    
    goto loop
;---------------------------------------------------------
;-------- Actualización de banderas para tiempos ---------
Tiempos:
    ; Dado que la interrupción del Timer 0 es de 5ms, se requieren de 
    ; 200 interrupciones para llevar 1 segundo.
    ; Asi mismo se determinan los tiempos de tres y seis segundos
    ; La primera vez que se enciende la bandera de un segundo sucede 
    ; cuando han pasado 1.066s
Un_Segundo:
    movlw 200              
    subwf Contador_1Seg,0
    btfss STATUS, 2 ; ZERO
    goto  Fin_Tiempos

    bsf   Banderas_Semaforos, Un_Seg
    clrf  Contador_1Seg
 
Tres_Segundos:
    incf  Contador_3Seg
    movlw 3              
    subwf Contador_3Seg,0
    btfss STATUS, 2 ; ZERO
    goto  Fin_Tiempos

    bsf   Banderas_Semaforos, Tres_Seg
    clrf  Contador_3Seg
    
Seis_Segundos:
    incf  Contador_6Seg
    movlw 2              
    subwf Contador_6Seg,0
    btfss STATUS, 2 ; ZERO
    goto  Fin_Tiempos

    bsf   Banderas_Semaforos, Seis_Seg
    clrf  Contador_6Seg
     
    ; - -- - -- - - - - - - - - -- -- - - - - - - -- - -
    ; Al inicio de loop se limpian las banderas para que 
    ; en el resto del proceso se tengan las referencias 
    ; de las banderas
    ; - - --- - - - - - - - - - - - - - - - -- - - - - - 
    Fin_Tiempos:
    return ; Regresa al call de Tiempos en loop 
    
;---------------------------------------------------------
;----------- Selección de vía para Mostrar Datos ---------
Seleccion_Via:
    bcf     Banderas1, Sel_Via
    ; Para este punto los valores que se representaran tanto en los semaforos
    ; como en los displays ya estan actualizados.
    ; Al mostrar los valores de cada una de las vías, primero
    ; se encienden los semaforos luego los displays de cada vía
    ; Primeo se dirige a la subrutina principal de los Semaforos, 
    ; esta se encarga de direccionar a la subrutina especifica de cada semaforo 
    ; luego se dirige a la subrutina principal de los displays, 
    ; esta se encarga de direccionar a la subrutina especifica de cada display
    call    Leds_Semaforos
    goto    Displays_7Seg   
    
;---------------------------------------------------------
;----------- Encender Semaforos --------------------------
Leds_Semaforos:
    ;Semaforo1 Verde
    ;Semaforo2 Rojo
    ;Semaforo3 Amarillo
    ;Blink_Semaforo1 Contador_Blink, Verde
    ;Blink_Semaforo2 Contador_Blink, Amarillo
    ;Blink_Semaforo3 Contador_Blink, Rojo
    
    ;btfsc Banderas_Semaforos, Seis_Seg
    goto Blink_Final_Semaforo3
    
    Fin_Leds_Semaforos:
    return   ; Regresa a call hecho en Seleccion_Via
    
;---- Subrutina por semaforo para blink de led verde y amarillo, 3 seg cada led     
Blink_Final_Semaforo1:
    ; Cuando terminan los tres segundos del blink verde, se preparara para 
    ; el blink amarillo, esto consiste en apagar el led verde (sí llegara a 
    ; a quedar encendido), ahi tambien se activa la vandera del blink amarillo
    ; semaforo 1. 
    ; Las siguiente condición solo sera evaluada una vez
    btfsc Banderas_Semaforos, Tres_Seg     
    goto  Preparar_Blink_Amarillo_Semaforo1
       
    ; Se evalua la bandera del blink amarillo, si esta activada direcciona a 
    ; la subrutina del blink amarillo, sí esta apagada direcciona a la 
    ; subrutian del blink verde. 
    btfsc Banderas_Semaforos, Blink_A_S1
    goto  Blink_Amarillo_Semaforo1 
    
    Blink_Verde_Semaforo1:
    Blink_Semaforo1 Contador_Blink, Verde
    goto  Fin_Blink_Final_Semaforo1
    Preparar_Blink_Amarillo_Semaforo1:
    Off_Semaforo1
    bsf   Banderas_Semaforos, Blink_A_S1
    Blink_Amarillo_Semaforo1:
    Blink_Semaforo1 Contador_Blink, Amarillo
    
    ; Cuando han pasado los 3 segundos del blink amarillo se apaga la bandera 
    ; del blink amarillo del semaforo 1
    btfsc Banderas_Semaforos, Seis_Seg
    bcf   Banderas_Semaforos, Blink_A_S1
    Fin_Blink_Final_Semaforo1: 
    return
    

Blink_Final_Semaforo2:
    ; Cuando terminan los tres segundos del blink verde, se preparara para 
    ; el blink amarillo, esto consiste en apagar el led verde (sí llegara a 
    ; a quedar encendido), ahi tambien se activa la vandera del blink amarillo
    ; semaforo 1. 
    ; Las siguiente condición solo sera evaluada una vez
    btfsc Banderas_Semaforos, Tres_Seg     
    goto  Preparar_Blink_Amarillo_Semaforo2
       
    ; Se evalua la bandera del blink amarillo, si esta activada direcciona a 
    ; la subrutina del blink amarillo, sí esta apagada direcciona a la 
    ; subrutian del blink verde. 
    btfsc Banderas_Semaforos, Blink_A_S2
    goto  Blink_Amarillo_Semaforo2 
    
    Blink_Verde_Semaforo2:
    Blink_Semaforo2 Contador_Blink, Verde
    goto  Fin_Blink_Final_Semaforo2
    Preparar_Blink_Amarillo_Semaforo2:
    Off_Semaforo2
    bsf   Banderas_Semaforos, Blink_A_S2
    Blink_Amarillo_Semaforo2:
    Blink_Semaforo2 Contador_Blink, Amarillo
    
    ; Cuando han pasado los 3 segundos del blink amarillo se apaga la bandera 
    ; del blink amarillo del semaforo 1
    btfsc Banderas_Semaforos, Seis_Seg
    bcf   Banderas_Semaforos, Blink_A_S2
    Fin_Blink_Final_Semaforo2: 
    return

Blink_Final_Semaforo3:
    ; Cuando terminan los tres segundos del blink verde, se preparara para 
    ; el blink amarillo, esto consiste en apagar el led verde (sí llegara a 
    ; a quedar encendido), ahi tambien se activa la vandera del blink amarillo
    ; semaforo 1. 
    ; Las siguiente condición solo sera evaluada una vez
    btfsc Banderas_Semaforos, Tres_Seg     
    goto  Preparar_Blink_Amarillo_Semaforo3
       
    ; Se evalua la bandera del blink amarillo, si esta activada direcciona a 
    ; la subrutina del blink amarillo, sí esta apagada direcciona a la 
    ; subrutian del blink verde. 
    btfsc Banderas_Semaforos, Blink_A_S3
    goto  Blink_Amarillo_Semaforo3 
    
    Blink_Verde_Semaforo3:
    Blink_Semaforo3 Contador_Blink, Verde
    goto  Fin_Blink_Final_Semaforo3
    Preparar_Blink_Amarillo_Semaforo3:
    Off_Semaforo3
    bsf   Banderas_Semaforos, Blink_A_S3
    Blink_Amarillo_Semaforo3:
    Blink_Semaforo3 Contador_Blink, Amarillo
    
    ; Cuando han pasado los 3 segundos del blink amarillo se apaga la bandera 
    ; del blink amarillo del semaforo 1
    btfsc Banderas_Semaforos, Seis_Seg
    bcf   Banderas_Semaforos, Blink_A_S3
    Fin_Blink_Final_Semaforo3: 
    return
  
;---------------------------------------------------------
;----------- Encendre Displays ---------------------------
Displays_7Seg:
    clrf    PORTA
    clrf    PORTC
 
    btfsc   Banderas_Dis, Dis_11     ; Debe encender el display 2 vía 1
    goto    Encender_Dis12
    
    btfsc   Banderas_Dis, Dis_12     ; Debe encender el display 1 vía 2
    goto    Encender_Dis21

    btfsc   Banderas_Dis, Dis_21     ; Debe encender el display 2 vía 2
    goto    Encender_Dis22
    
    btfsc   Banderas_Dis, Dis_22     ; Debe encender el display 1 vía 3
    goto    Encender_Dis31
    
    btfsc   Banderas_Dis, Dis_31     ; Debe encender el display 2 vía 3
    goto    Encender_Dis32
    
    btfsc   Banderas_Dis, Dis_32     ; Debe encender el display 1 vía 4
    goto    Encender_Dis41
    
    btfsc   Banderas_Dis, Dis_41     ; Debe encender el display 2 vía 4
    goto    Encender_Dis42
    
    btfsc   Banderas_Dis, Dis_42     ; Debe encender el display 1 vía 1
    goto    Encender_Dis11
    
    goto loop ; No debe llegar a esta parte

;----------- Subrutinas Especificas de cada Display
Encender_Dis11:
    movf    V_Display_11,0
    movwf   PORTA
    movlw   00000001B ; Anodo:00000001B  Catodo:11111110B
    movwf   PORTC
    
    bcf     Banderas_Dis, Dis_42     ; Apagar bandera del display anterior
    bsf     Banderas_Dis, Dis_11     ; Encender bandera del display actual
    goto loop
Encender_Dis12:
    movf    V_Display_12,0
    movwf   PORTA
    movlw   00000010B 
    movwf   PORTC
    
    bcf     Banderas_Dis, Dis_11     ; Apagar bandera del display anterior
    bsf     Banderas_Dis, Dis_12     ; Encender bandera del display actual
    goto loop    
Encender_Dis21:
    movf    V_Display_21,0
    movwf   PORTA
    movlw   00000100B 
    movwf   PORTC
    
    bcf     Banderas_Dis, Dis_12     ; Apagar bandera del display anterior
    bsf     Banderas_Dis, Dis_21     ; Encender bandera del display actual
    goto loop
Encender_Dis22:
    movf    V_Display_22,0
    movwf   PORTA
    movlw   00001000B 
    movwf   PORTC
    
    bcf     Banderas_Dis, Dis_21     ; Apagar bandera del display anterior
    bsf     Banderas_Dis, Dis_22     ; Encender bandera del display actual
    goto loop
Encender_Dis31:
    movf    V_Display_31,0
    movwf   PORTA
    movlw   00010000B 
    movwf   PORTC
    
    bcf     Banderas_Dis, Dis_22     ; Apagar bandera del display anterior
    bsf     Banderas_Dis, Dis_31     ; Encender bandera del display actual
    goto loop
Encender_Dis32:
    movf    V_Display_32,0
    movwf   PORTA
    movlw   00100000B 
    movwf   PORTC
    
    bcf     Banderas_Dis, Dis_31     ; Apagar bandera del display anterior
    bsf     Banderas_Dis, Dis_32     ; Encender bandera del display actual
    goto loop
Encender_Dis41:
    movf    V_Display_41,0
    movwf   PORTA
    movlw   01000000B 
    movwf   PORTC
    
    bcf     Banderas_Dis, Dis_32     ; Apagar bandera del display anterior
    bsf     Banderas_Dis, Dis_41     ; Encender bandera del display actual
    goto loop
Encender_Dis42:
    movf    V_Display_42,0
    movwf   PORTA
    movlw   10000000B 
    movwf   PORTC
    
    bcf     Banderas_Dis, Dis_41     ; Apagar bandera del display anterior
    bsf     Banderas_Dis, Dis_42     ; Encender bandera del display actual
    goto loop