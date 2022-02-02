;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2021-09-17
; Author:
; Albin Widerberg Palmfeldt
; Vilgot Karlsson
;
; Lab number: 1
; Title: task2 Led light w button
;
; Hardware: STK600, CPU ATmega2560
;
; Function: User presses the 5th button and the responding led lights up
;
; Input ports: PIND
;
; Output ports: PORTB
;
; Subroutines: N/A
; Included files:
;
; Other information:
;
; Changes in program: (Description and date)
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 
start:
	; Set values to register
	ldi r16, 0x00
	ldi r18, 0xFF
	;<<<<<<<<<<<<<<<<<

	; Inizilace DDRB and DDRD
	out DDRB, r18
	out DDRD, r16

	
bttn_chk:
	in r16, PIND	; assign Status of PIND to r16
	out PORTB, R16	; Output r16 value to PORTB
	rjmp bttn_chk
