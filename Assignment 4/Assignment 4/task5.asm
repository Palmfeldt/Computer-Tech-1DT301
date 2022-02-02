;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2021-10-14
; Author:
; Albin Widerberg Palmfeldt
; Vilgot Karlsson
;
; Lab number: 4
; Title: task 5 Serial communication with echo using interrupt
;
; Hardware: STK600, CPU ATmega2560
;
; Function: Takes serial input and displays it in terminal and the leds.
;
; Input ports: N/A
;
; Output ports: PORTB
;
; Subroutines: start sets output to PORTB and sets input value for serial.
; Getletter gets value from serial and sets it to r17
; it also displays it in terminal and leds.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 
.include "m2560def.inc"
.def temp = r16
; baude rate 4800
.equ UBRR_val =  12 ; sida 227

.CSEG
.org 0x00
rjmp start

.org URXC1addr
rjmp readletter

.org 0x72

start:
	ldi temp, LOW(RAMEND)
	out SPL, temp
	ldi temp, HIGH(RAMEND)
	out SPH, temp

	ldi temp, 0xFF		
	out DDRB, temp		; set portB to output
	ldi temp, 0x00		
	out PORTB, temp

	ldi temp, UBRR_val	; set baud rate to r16
	sts UBRR1L, temp	; store serial output to sram
	ldi temp, (1<<RXEN1) | (1<<TXEN1) | (1<<RXCIE1)
	sts UCSR1B, temp	; set RX and TX enable flags
	sei


main:
	nop
	rjmp main

readLetter:
	lds r17, UDR1		; read letter in UDR
	out PORTB, r17
				
	sts UDR1, r17
	reti
