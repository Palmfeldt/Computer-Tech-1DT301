;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2021-09-17
; Author:
; Albin Widerberg Palmfeldt
; Vilgot Karlsson
;
; Lab number: 1
; Title: task1 Led light
;
; Hardware: STK600, CPU ATmega2560
;
; Function: Lights led
;
; Output ports: PORTB
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 
start:
	ldi r16, 0xff 
	ldi r18, 0b10111111 ; Controls if led is shutdown after
	out DDRB, r16 ; 
	out PORTB, r18 ; output r18 to PORTB
