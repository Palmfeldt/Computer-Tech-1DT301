;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2021-10-14
; Author:
; Albin Widerberg Palmfeldt
; Vilgot Karlsson
;
; Lab number: 4
; Title: task 3 Serial communication
;
; Hardware: STK600, CPU ATmega2560
;
; Function: Takes serial input and displays it on the leds.
;
; Input ports: N/A
;
; Output ports: PORTB
;
; Subroutines: start sets output to PORTB and sets input value for serial.
; Getletter gets value from serial and sets it to r17
; ledOut outputs r17
; Included files: m2560def.inc
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 
.include "m2560def.inc"
.def temp = r16
; baude rate 4800
.equ UBRR_val =  12 ; sida 227

.CSEG
.org 0x00
rjmp start

.org 0x72

start:
	ldi temp, 0xFF		
	out DDRB, temp		; set portB to output
	ldi temp, 0x00		; Init value to outputs
	out PORTB, temp

	ldi temp, UBRR_val	; set baud rate to r16
	sts UBRR1L, temp	; store serial output to sram
	ldi temp, (1<<RXEN1)		
	sts UCSR1B, temp	; set RX enable flags


getLetter:
	
	lds temp, UCSR1A 	; read UCSR1A I/O register to temp(r16)
	sbrs temp, RXC1		; skip if RXC1 in r16
	rjmp getLetter		; if r16 is clear goto getLetter
	lds r17, UDR1		; read letter in UDR


ledOut:
	out PORTB, r17			
	rjmp getLetter
