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
    W_TEMP:               DS 1
    STATUS_TEMP:          DS 1
    
    Banderas_Botones:     DS 1
    #define B_Modo        5    ; pines puerto B, Modo, Incremento y Decremento
    #define B_Inc         6   
    #define B_Dec         7
    
    Banderas1:            DS 1
    #define Dis_Multi     0    ; Bandera de multiplexión de displays 
    #define Modo_1        1    ; Banderas Modo de funcionamiento
    #define Modo_2        2
    #define Modo_3        3
    #define Modo_4        4
    #define Modo_5        5
    Banderas_Semaforos:   DS 1 
    #define Blink         0
    #define Un_Seg        1
    #define Medio_Seg     2
    #define Tres_Seg      3
    			     
    Banderas_Estados:     DS 1
    #define Cambio_Estado 0
    #define Estado_1      1
    #define Estado_2      2
    #define Estado_3      3
    #define Estado_4      4
    #define Reset_Inicio  5
    Banderas_Dis:         DS 1
    #define Dis_11        0
    #define Dis_12        1
    #define Dis_21        2
    #define Dis_22        3 
    #define Dis_31        4
    #define Dis_32        5
    #define Dis_41        6
    #define Dis_42        7
    V_Display_11:         DS 1       ; Valor que muestra mostrará el display
    V_Display_12:         DS 1
    V_Display_21:         DS 1
    V_Display_22:         DS 1
    V_Display_31:         DS 1
    V_Display_32:         DS 1
    V_Display_41:         DS 1
    V_Display_42:         DS 1
    
    #define Verde         0         
    #define Amarillo      1
    #define Rojo          2
    
    Contador_Blink:       DS 1
    Contador_1Seg:        DS 1
    Contador_General:     DS 1
    Contador_3Seg:        DS 1
    
    Temporizador_1:       DS 1
    Temporizador_2:       DS 1
    Temporizador_3:       DS 1
    
    Tiempo_Via1:          DS 1
    Tiempo_Via2:          DS 1
    Tiempo_Via3:          DS 1
    
    Tiempo_Modo:          DS 1
    Tiempo_Modo2:         DS 1
    Tiempo_Modo3:         DS 1
    Tiempo_Modo4:         DS 1
    
    Decenas_Via1:         DS 1
    Unidades_Via1:        DS 1
    Decenas_Via2:         DS 1
    Unidades_Via2:        DS 1
    Decenas_Via3:         DS 1
    Unidades_Via3:        DS 1
    Decenas_Modo:         DS 1
    Unidades_Modo:        DS 1
    
    Operacion_Dis:        DS 1

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
    goto   Interrupcion_PORTB;Interrupcion Puerto B
   
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
Interrupcion_PORTB:
    ; Revisa el boton de modo
    btfss  PORTB, B_Modo
    bsf    Banderas_Botones, B_Modo
    ; Revisa el boton de Incremento
    btfss  PORTB, B_Inc
    bsf    Banderas_Botones, B_Inc
    ; Revisa el boton de Decremento
    btfss  PORTB, B_Dec
    bsf    Banderas_Botones, B_Dec
    
    bcf    RBIF
    goto   isr
    
Temporizador:
    bsf    Banderas1, Dis_Multi     
    incf   Contador_Blink,1
    incf   Contador_1Seg,1
    incf   Contador_General,1
    
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
    retlw 0111111B ; Cero
    retlw 0000110B ;Uno
    retlw 1011011B ;Dos
    retlw 1001111B ;Tres
    retlw 1100110B ;Cuatro
    retlw 1101101B ;Cinco
    retlw 1111101B ;Seis 
    retlw 0000111B ;Siete
    retlw 1111111B ;Ocho
    retlw 1100111B ;Nueve
    retlw 1110111B ;A
    retlw 1111100B ;B
    retlw 0111001B ;C
    retlw 1011110B ;D
    retlw 1111001B ;E
    retlw 1110001B ;F 
    
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
    
    bcf      TRISB,0
    
    movlw    00000000B     ; PORTC Todos los pines como salidas
    movwf    TRISC
    
    movlw    00000000B     ; PORTD los pines 0-2 como salidas, 3-7 como entradas
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
    clrf     Tiempo_Modo     ; variable que se en Modo
    clrf     V_Display_11
    clrf     V_Display_12
    clrf     V_Display_31
    clrf     V_Display_32
    clrf     V_Display_41
    clrf     V_Display_42
    clrf     Contador_Blink
    clrf     Contador_1Seg
    clrf     Contador_3Seg
    clrf     Temporizador_1
    clrf     Temporizador_2
    clrf     Temporizador_3
    clrf     Tiempo_Via1
    clrf     Tiempo_Via2
    clrf     Tiempo_Via3
    clrf     Tiempo_Modo2
    clrf     Tiempo_Modo3
    clrf     Tiempo_Modo4
    clrf     Contador_General
    clrf     Decenas_Via1
    clrf     Unidades_Via1
    clrf     Decenas_Via2
    clrf     Unidades_Via2
    clrf     Decenas_Via3
    clrf     Unidades_Via3
    clrf     Banderas_Botones
    clrf     Operacion_Dis
    clrf     Banderas_Estados
    ;------- Activaciones de registros o puertos
    btfss    PORTB, 0      ; Primera instrucción que no genera interrupción
    nop 
    bsf   Banderas_Dis, Dis_11              ; Encdender la bandera del display 1
    
    bsf	  Banderas_Estados, Estado_3        ; la primera vez que entre colocara
    bsf   Banderas_Estados, Cambio_Estado   ; los tiempos correctos en cada 
                                            ; display, empezando con la via 1 
					    ; en verde
					    
    bsf	  Banderas1, Modo_1   ; Bandera activada para comenzar en el modo 1
    
    movlw 10                  ; El tiempo inicial de cada via es de 10 segundos
    movwf Tiempo_Via1
    movwf Tiempo_Via2
    movwf Tiempo_Via3
     
;---------------------------------------------------------
;-------------------  Loop Forever -----------------------
;---------------------------------------------------------
loop:  
    call    Tiempos
    call    Revisiones_Botones
    call    Modos
    call    Estados
    call    Apagar_Banderas_Tiempos
    
    btfsc   Banderas1,Dis_Multi  ; Mostrar valores en displays cada 5ms
    goto    Seleccion_Display 
    goto loop
;---------------- Fin Loop principal ---------------------  
;---------------------------------------------------------  
;*********************************************************    
;---------------------------------------------------------
;--------- Elección del Modo de funcionamiento ----------- 
Modos:
    btfsc Banderas1, Modo_1
    goto  Modo1
    btfsc Banderas1, Modo_2
    goto  Modo2
    btfsc Banderas1, Modo_3
    goto  Modo3
    btfsc Banderas1, Modo_4
    goto  Modo4
    btfsc Banderas1, Modo_5
    goto  Modo5
    goto  Fin_Modos
    Modo1:
	; Funcionamiento Normal
	goto Fin_Modos
    Modo2:
	movf  Tiempo_Modo2,0
	movwf Tiempo_Modo
	goto  Fin_Modos
    Modo3:
	movf  Tiempo_Modo3,0
	movwf Tiempo_Modo
	goto  Fin_Modos
    Modo4:
	movf  Tiempo_Modo4,0
	movwf Tiempo_Modo
	goto  Fin_Modos
    Modo5:
	movlw 0
	movwf Tiempo_Modo
	goto  Fin_Modos
    Fin_Modos:
return ; regresa a loop
;---------------------------------------------------------
;----------- Elección del Estado de cada Vía ------------- 
Estados:      ; Estados de los semaforos
    Cambio_Estado:
	CambioDeEstado
	
	btfss Banderas_Estados, Cambio_Estado
	goto  Eleccion_Estado
	; Verificar que no toque resetear
	btfsc Banderas_Estados, Estado_4
	goto  Estado4
	
	; Al cambiar de estado se deben restablecer los tiempos de cada vía  
	Si_Toca_Cambiar_Estado:
	    btfsc Banderas_Estados, Estado_1    ; Revisar bandera del estado 1
	    goto  TiemposParaVia_2
	    btfsc Banderas_Estados, Estado_2    ; Revisar bandera del estado 2
	    goto  TiemposParaVia_3
	    btfsc Banderas_Estados, Estado_3    ; Revisar bandera del estado 3
	    goto  TiemposParaVia_1
	
	TiemposParaVia_1:
	    Tiempos_Via_1
	    bcf  Banderas_Estados, Estado_3 
	    bsf  Banderas_Estados, Estado_1 
	    bcf  Banderas_Estados, Cambio_Estado
	    goto Eleccion_Estado
	TiemposParaVia_2:
	    Tiempos_Via_2
	    bcf  Banderas_Estados, Estado_1 
	    bsf  Banderas_Estados, Estado_2 
	    bcf  Banderas_Estados, Cambio_Estado
	    goto Eleccion_Estado
	TiemposParaVia_3:    
	    Tiempos_Via_3
	    bcf  Banderas_Estados, Estado_2 
	    bsf  Banderas_Estados, Estado_3 
	    bcf  Banderas_Estados, Cambio_Estado
	    goto Eleccion_Estado
	    goto Fin_Estados
    Eleccion_Estado:
	btfsc Banderas_Estados, Estado_1    ; Revisar bandera del estado 1
	goto  Estado1
	btfsc Banderas_Estados, Estado_2    ; Revisar bandera del estado 2
	goto  Estado2
	btfsc Banderas_Estados, Estado_3    ; Revisar bandera del estado 3
	goto  Estado3
	goto  Fin_Estados
    Estado1:       ; Via 1 en verde
        Dec_1Seg Temporizador_1, Un_Seg   ; Decrementos de los temporizadores
	Dec_1Seg Temporizador_2, Un_Seg
	Dec_1Seg Temporizador_3, Un_Seg
	movlw 6                    ; Activación del verde titilante cuando 
	subwf Temporizador_1, 0    ; falten 6 segundos de via
	btfsc ZERO
	bsf   Banderas_Semaforos, Blink
	btfss Banderas_Semaforos, Blink
	goto  Amarillo_1
	Blink_Verde_1:
	    Blink_Semaforo1 Verde
	Amarillo_1:
	    movlw 3                    ; Activación del color amarillo cuando 
	    subwf Temporizador_1, 0    ; falten 3 segundos de via
	    btfss ZERO
	    goto  Fin_Estados
	    btfss Banderas_Semaforos, Blink
	    goto  Fin_Estados
	    bcf   Banderas_Semaforos, Blink
	    Semaforo1 Amarillo
	    goto  Fin_Estados
    Estado2:       ; Vía 2 en verde
	Dec_1Seg Temporizador_1, Un_Seg   ; Decrementos de los temporizadores
	Dec_1Seg Temporizador_2, Un_Seg
	Dec_1Seg Temporizador_3, Un_Seg
	movlw 6                    ; Activación del verde titilante cuando 
	subwf Temporizador_2, 0    ; falten 6 segundos de via
	btfsc ZERO
	bsf   Banderas_Semaforos, Blink
	btfss Banderas_Semaforos, Blink
	goto  Amarillo_2
	Blink_Verde_2:
	    Blink_Semaforo2 Verde
	Amarillo_2:
	    movlw 3                    ; Activación del color amarillo cuando 
	    subwf Temporizador_2, 0    ; falten 3 segundos de via
	    btfss ZERO
	    goto  Fin_Estados
	    btfss Banderas_Semaforos, Blink
	    goto  Fin_Estados
	    bcf   Banderas_Semaforos, Blink
	    Semaforo2 Amarillo
	    goto  Fin_Estados
    Estado3:       ; Vía 3 en verde
	Dec_1Seg Temporizador_1, Un_Seg   ; Decrementos de los temporizadores
	Dec_1Seg Temporizador_2, Un_Seg
	Dec_1Seg Temporizador_3, Un_Seg
	movlw 6                    ; Activación del verde titilante cuando 
	subwf Temporizador_3, 0    ; falten 6 segundos de via
	btfsc ZERO
	bsf   Banderas_Semaforos, Blink
	btfss Banderas_Semaforos, Blink
	goto  Amarillo_3
	Blink_Verde_3:
	    Blink_Semaforo3 Verde
	Amarillo_3:
	    movlw 3                    ; Activación del color amarillo cuando 
	    subwf Temporizador_3, 0    ; falten 3 segundos de via
	    btfss ZERO
	    goto  Fin_Estados
	    btfss Banderas_Semaforos, Blink
	    goto  Fin_Estados
	    bcf   Banderas_Semaforos, Blink
	    Semaforo3 Amarillo
	    goto  Fin_Estados
    Estado4:       ; Reseteo
        btfss  Banderas_Estados, Reset_Inicio
	goto   Resetear
	movf   Tiempo_Modo2,0
	movwf  Tiempo_Via1
	movf   Tiempo_Modo3,0
	movwf  Tiempo_Via2
	movf   Tiempo_Modo4,0
	movwf  Tiempo_Via3
	bcf    Banderas_Estados, Estado_1
	bcf    Banderas_Estados, Estado_2
	bcf    Banderas_Estados, Estado_3
	bcf    Banderas_Estados, Reset_Inicio
	bsf    Banderas_Estados, Cambio_Estado
	clrf   Contador_3Seg
	clrf   Contador_1Seg
	clrf   Contador_Blink
	Off_Semaforos ; apaga todos los semaforos para prepara el reseteo
	Resetear:
	    Reseteo
	    clrf  Temporizador_1
	    clrf  Temporizador_2
	    clrf  Temporizador_3
	    btfss Banderas_Semaforos, Tres_Seg   ; Cuando se cumplen 3 segundos
	    goto  Fin_Estados                    ; de reseteo cambia de estado
	    bcf   Banderas_Estados, Estado_4     ;
	    bsf   Banderas_Estados, Estado_3
    Fin_Estados: 
return ; Regresa al loop principal
    
;---------------------------------------------------------
;----------- Apagar Las banderas de los tiempos ----------   
Apagar_Banderas_Tiempos:
    bcf     Banderas_Semaforos, Un_Seg
    bcf     Banderas_Semaforos, Tres_Seg
    bcf     Banderas_Semaforos, Medio_Seg
return
 
;---------------------------------------------------------
;-------- Actualización de banderas para tiempos ---------
Tiempos:
    Un_Segundo:
	movlw 200
	subwf Contador_1Seg,W
	btfss ZERO
	goto  Medio_Segundo
	bsf   Banderas_Semaforos, Un_Seg
	clrf  Contador_1Seg
    Medio_Segundo:  ; para blink 
	movlw 100
	subwf Contador_Blink,W
	btfss ZERO
	goto  Tres_Segundos
	bsf   Banderas_Semaforos, Medio_Seg
	clrf  Contador_Blink
    Tres_Segundos:  ; Para reseteo
	btfsc Banderas_Semaforos, Un_Seg
	incf  Contador_3Seg,1
	movlw 3
	subwf Contador_3Seg,W
	btfss ZERO
	goto  Fin_Tiempos
	bsf   Banderas_Semaforos, Tres_Seg
	clrf  Contador_3Seg
    Fin_Tiempos:
    return ; Regresa al call de Tiempos en loop 
;---------------------------------------------------------
;----------- Selección de vía para Mostrar Datos ---------
Seleccion_Display:
    bcf     Banderas1, Dis_Multi
    call    Actualizacion_Valores_Displays   
;----------- Encender Displays ---------------------------
Displays_7Seg:
    clrf   PORTA
    btfsc   Banderas_Dis, Dis_42     ; Debe encender el display 1 vía 1
    goto    Encender_Dis11
    
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

    btfss Banderas1, Modo_1   ; Revisa si esta en modo_1 o en configuración
    goto  Displays_Configuraciones
    Modo_Normal: 
	bsf     Banderas_Dis, Dis_42     ; Encender bandera del display actual
	goto    loop  ; Termina el proceso y empieza con Display 1

    Displays_Configuraciones: 
	btfsc   Banderas_Dis, Dis_32     ; Debe encender el display 1 vía 4
	goto    Encender_Dis41

	btfsc   Banderas_Dis, Dis_41     ; Debe encender el display 2 vía 4
	goto    Encender_Dis42

    goto loop ; No debe llegar a esta parte

;-------- Subrutinas Especificas de cada Display ---------
Encender_Dis11:
    movf    V_Display_11,0
    movwf   PORTA
    movlw   00000001B ; Anodo:00000001B  Catodo:11111110B
    movwf   PORTC
    
    bcf     Banderas_Dis, Dis_42     ; Apagar bandera del display anterior
    bsf     Banderas_Dis, Dis_11     ; Encender bandera del display actual
    goto    loop
Encender_Dis12:
    movf    V_Display_12,0
    movwf   PORTA
    movlw   00000010B 
    movwf   PORTC
    
    bcf     Banderas_Dis, Dis_11     ; Apagar bandera del display anterior
    bsf     Banderas_Dis, Dis_12     ; Encender bandera del display actual
    goto    loop    
Encender_Dis21:
    movf    V_Display_21,0
    movwf   PORTA
    movlw   00000100B 
    movwf   PORTC
    
    bcf     Banderas_Dis, Dis_12     ; Apagar bandera del display anterior
    bsf     Banderas_Dis, Dis_21     ; Encender bandera del display actual
    goto    loop
Encender_Dis22:
    movf    V_Display_22,0
    movwf   PORTA
    movlw   00001000B 
    movwf   PORTC
    
    bcf     Banderas_Dis, Dis_21     ; Apagar bandera del display anterior
    bsf     Banderas_Dis, Dis_22     ; Encender bandera del display actual
    goto    loop
Encender_Dis31:
    movf    V_Display_31,0
    movwf   PORTA
    movlw   00010000B 
    movwf   PORTC
    
    bcf     Banderas_Dis, Dis_22     ; Apagar bandera del display anterior
    bsf     Banderas_Dis, Dis_31     ; Encender bandera del display actual
    goto    loop
Encender_Dis32:
    movf    V_Display_32,0
    movwf   PORTA
    movlw   00100000B 
    movwf   PORTC
    
    bcf     Banderas_Dis, Dis_31     ; Apagar bandera del display anterior
    bsf     Banderas_Dis, Dis_32     ; Encender bandera del display actual
    goto    loop

Encender_Dis41:
    movf    V_Display_41,0
    movwf   PORTA
    movlw   01000000B 
    movwf   PORTC
    
    bcf     Banderas_Dis, Dis_32     ; Apagar bandera del display anterior
    bsf     Banderas_Dis, Dis_41     ; Encender bandera del display actual
    goto    loop
Encender_Dis42:
    movf    V_Display_42,0
    movwf   PORTA
    movlw   10000000B 
    movwf   PORTC
    
    bcf     Banderas_Dis, Dis_41     ; Apagar bandera del display anterior
    bsf     Banderas_Dis, Dis_42     ; Encender bandera del display actual
    goto    loop
    
Actualizacion_Valores_Displays:
    clrf    Decenas_Via1
    clrf    Unidades_Via1
    clrf    Decenas_Via2
    clrf    Unidades_Via2
    clrf    Decenas_Via3
    clrf    Unidades_Via3
    clrf    Decenas_Modo
    clrf    Unidades_Modo
    
    movf    Temporizador_1,0
    movwf   Operacion_Dis
    ; Actualización de valores que se mostraran en los displays de la via 1
    Decena_V1:
	movlw   10
	subwf   Operacion_Dis, 1
	incf    Decenas_Via1,1
	btfsc   CARRY
	goto    Decena_V1
	movlw   10
	addwf   Operacion_Dis,1
	decf    Decenas_Via1,1
	
	movf    Decenas_Via1,0
	andlw   0x0f
	call    Display
	movwf   V_Display_12
    Unidades_V1:
	movlw   1
	subwf   Operacion_Dis, 1
	incf    Unidades_Via1,1
	btfsc   CARRY
	goto    Unidades_V1
	movlw   1
	addwf   Operacion_Dis,1
	decf    Unidades_Via1,1
	
	movf    Unidades_Via1,0
	andlw   0x0f
	call    Display
	movwf   V_Display_11
    
    ; Actualización de valores que se mostraran en los displays de la via 2
    movf   Temporizador_2,0
    movwf  Operacion_Dis
    Decena_V2:
	movlw   10
	subwf   Operacion_Dis, 1
	incf    Decenas_Via2,1
	btfsc   CARRY
	goto    Decena_V2
	movlw   10
	addwf   Operacion_Dis,1
	decf    Decenas_Via2,1
	
	movf    Decenas_Via2,0
	andlw   0x0f
	call    Display
	movwf   V_Display_22
    Unidades_V2:
	movlw   1
	subwf   Operacion_Dis, 1
	incf    Unidades_Via2,1
	btfsc   CARRY
	goto    Unidades_V2
	movlw   1
	addwf   Operacion_Dis,1
	decf    Unidades_Via2,1
	
	movf    Unidades_Via2,0
	andlw   0x0f
	call    Display
	movwf   V_Display_21
    
    ; Actualización de valores que se mostraran en los displays de la via 3
    movf   Temporizador_3,0
    movwf  Operacion_Dis
    Decena_V3:
	movlw   10
	subwf   Operacion_Dis, 1
	incf    Decenas_Via3,1
	btfsc   CARRY
	goto    Decena_V3
	movlw   10
	addwf   Operacion_Dis,1
	decf    Decenas_Via3,1
	
	movf    Decenas_Via3,0
	andlw   0x0f
	call    Display
	movwf   V_Display_32
    Unidades_V3:
	movlw   1
	subwf   Operacion_Dis, 1
	incf    Unidades_Via3,1
	btfsc   CARRY
	goto    Unidades_V3
	movlw   1
	addwf   Operacion_Dis,1
	decf    Unidades_Via3,1
	
	movf    Unidades_Via3,0
	andlw   0x0f
	call    Display
	movwf   V_Display_31
	
    ; Actualización de valores que se mostraran en los displays de Modo
    movf   Tiempo_Modo,0
    movwf  Operacion_Dis
    Decena_MOdo:
	movlw   10
	subwf   Operacion_Dis, 1
	incf    Decenas_Modo,1
	btfsc   CARRY
	goto    Decena_MOdo
	movlw   10
	addwf   Operacion_Dis,1
	decf    Decenas_Modo,1
	
	movf    Decenas_Modo,0
	andlw   0x0f
	call    Display
	movwf   V_Display_42
    Unidades_MOdo:
	movlw   1
	subwf   Operacion_Dis, 1
	incf    Unidades_Modo,1
	btfsc   CARRY
	goto    Unidades_MOdo
	movlw   1
	addwf   Operacion_Dis,1
	decf    Unidades_Modo,1
	
	movf    Unidades_Modo,0
	andlw   0x0f
	call    Display
	movwf   V_Display_41
return  ; Regresa a call de Actualizacion_Valores_Displays hecho en 
        ; Seleccion_Display
    
;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
Revisiones_Botones: 
    Boton_Modo:
	btfss Banderas_Botones, B_Modo
	goto  Fin_Boton_Modo
	btfss PORTB, B_Modo
	goto  Fin_Boton_Modo
	;/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/*/*/*/*/*/*/*/*/*/*/*/
	; Instrucciones del boton modo
	btfsc Banderas1, Modo_1
	goto  Activar_Modo_2
	btfsc Banderas1, Modo_2
	goto  Activar_Modo_3
	btfsc Banderas1, Modo_3
	goto  Activar_Modo_4
	btfsc Banderas1, Modo_4
	goto  Activar_Modo_5
	goto  Apagar_Banderas_B_Modo

	Activar_Modo_2:  ; Modo que actualiza tiempo de Via 1
	    Indicador_Via1
	    movf  Tiempo_Via1,0  ; Se coloca el valor del tiempo actual de la  
	    movwf Tiempo_Modo2   ; vía 1 en la variable que se trabaja en modo 2
	    bsf   Banderas1, Modo_2
	    bcf   Banderas1, Modo_1
	    goto  Apagar_Banderas_B_Modo
	Activar_Modo_3:  ; Modo que actualiza tiempo de Via 2
	    Indicador_Via2
	    movf  Tiempo_Via2,0  ; Se coloca el valor del tiempo actual de la  
	    movwf Tiempo_Modo3   ; vía 2 en la variable que se trabaja en modo 3
	    bsf   Banderas1, Modo_3
	    bcf   Banderas1, Modo_2
	    goto  Apagar_Banderas_B_Modo
	Activar_Modo_4:  ; Modo que actualiza tiempo de Via 3
	    Indicador_Via3
	    movf  Tiempo_Via3,0  ; Se coloca el valor del tiempo actual de la  
	    movwf Tiempo_Modo4   ; vía 3 en la variable que se trabaja en modo 4
	    bsf   Banderas1, Modo_4
	    bcf   Banderas1, Modo_3
	    goto  Apagar_Banderas_B_Modo
	Activar_Modo_5:
	    Indicador_Modo5
	    bsf   Banderas1, Modo_5
	    bcf   Banderas1, Modo_4
	    goto  Apagar_Banderas_B_Modo
	;/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/*/*/*/*/*/*/*/*/*/*/*/
	Apagar_Banderas_B_Modo:
	    bcf   Banderas_Botones, B_Modo ; Se apagan las banderas para que  
	    bcf   Banderas_Botones, B_Inc  ; haya solo una operación por boton 
  	    bcf   Banderas_Botones, B_Dec  ; a la vez
	Fin_Boton_Modo:
    
    Boton_Inc:
	btfss Banderas_Botones, B_Inc
	goto  Fin_Boton_Inc
	btfss PORTB, B_Inc
	goto  Fin_Boton_Inc
	;/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/*/*/*/*/*/*/*/*/*/*/*/
	; Instrucciones del boton de incremento
	btfsc Banderas1, Modo_2
	goto  Inc_Modo2
	
	btfsc Banderas1, Modo_3
	goto  Inc_Modo3
	
	btfsc Banderas1, Modo_4
	goto  Inc_Modo4
	
	btfsc Banderas1, Modo_5
	goto  Guardar
	goto  Apagar_Banderas_B_Inc
	
	Inc_Modo2:
	    incf  Tiempo_Modo2,1
	    Overflow Tiempo_Modo2
	    goto  Apagar_Banderas_B_Inc
	Inc_Modo3:
	    incf  Tiempo_Modo3,1
	    Overflow Tiempo_Modo3
	    goto  Apagar_Banderas_B_Inc
	Inc_Modo4:
	    incf  Tiempo_Modo4,1
	    Overflow Tiempo_Modo4
	    goto  Apagar_Banderas_B_Inc
	Guardar:
	    Indicador_Modo1
	    bsf   Banderas1, Modo_1
	    bcf   Banderas1, Modo_5
	    bsf   Banderas_Estados, Estado_4
	    bsf   Banderas_Estados, Reset_Inicio
	;/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/*/*/*/*/*/*/*/*/*/*/*/
	Apagar_Banderas_B_Inc:
	    bcf   Banderas_Botones, B_Modo ; Se apagan las banderas para que  
	    bcf   Banderas_Botones, B_Inc  ; haya solo una operación por boton 
  	    bcf   Banderas_Botones, B_Dec  ; a la vez
	Fin_Boton_Inc: 
    
    Boton_Dec:
	btfss Banderas_Botones, B_Dec
	goto  Fin_Boton_Dec
	btfss PORTB, B_Dec
	goto  Fin_Boton_Dec
	;/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/*/*/*/*/*/*/*/*/*/*/*/
	; Instrucciones del boton de decremento
	btfsc Banderas1, Modo_2
	goto  Dec_Modo2
	
	btfsc Banderas1, Modo_3
	goto  Dec_Modo3
	
	btfsc Banderas1, Modo_4
	goto  Dec_Modo4
	
	btfsc Banderas1, Modo_5
	goto  No_Guardar
	goto  Apagar_Banderas_B_Inc
	
	Dec_Modo2:
	    Decf  Tiempo_Modo2,1
	    Underflow Tiempo_Modo2
	    goto  Apagar_Banderas_B_Inc
	Dec_Modo3:
	    Decf  Tiempo_Modo3,1
	    Underflow Tiempo_Modo3
	    goto  Apagar_Banderas_B_Inc
	Dec_Modo4:
	    decf  Tiempo_Modo4,1
	    Underflow Tiempo_Modo4
	    goto  Apagar_Banderas_B_Inc
	No_Guardar:
	    Indicador_Modo1
	    ; No guarda los valores colocados en cada uno de los modos
	    bsf   Banderas1, Modo_1
	    bcf   Banderas1, Modo_5
	;/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/*/*/*/*/*/*/*/*/*/*/*/
	Apagar_Banderas_B_Dec:
	    bcf   Banderas_Botones, B_Modo ; Se apagan las banderas para que  
	    bcf   Banderas_Botones, B_Inc  ; haya solo una operación por boton 
  	    bcf   Banderas_Botones, B_Dec  ; a la vez
	Fin_Boton_Dec:  
return ; Regresa a loop 
;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-