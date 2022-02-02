;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2021-10-14
; Author:
; Albin Widerberg Palmfeldt
; Vilgot Karlsson
;
; Lab number: 4
; Title: Square wave generator
;
; Hardware: STK600, CPU ATmega2560
;
; Function: Led is connected to a frequence of 1 Hz. 0.5 sec on 0.5 off.
;
; Input ports: N/A
;
; Output ports: PORTB
;
; Subroutines: start sets SP, sets DDRB to output, sets TIMSK0 etc.
; Main loops and branches when counter is equal. 
; ledon sets led to on and goes to main
; timer increases the counter
; 
; Included files: m2560def.inc
;
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 

.include "m2560def.inc"

.CSEG
.org 0x0000
rjmp start

.org OVF0addr
jmp timer0

.org 0x72
start:
	.def temp = r16
	.def counter = r18
	ldi counter, 0

	ldi temp, LOW(RAMEND)
	out SPL, temp
	ldi temp, HIGH(RAMEND)
	out SPH, temp

	ldi r20, 0xFF
	out DDRB, temp

	ldi temp, 0x04
	out TCCR0B, temp
	ldi temp, (1<<TOIE0)
	sts TIMSK0, temp

	ldi temp, 200
	out TCNT0, temp
	sei



main:
	cpi counter, 50
	breq ledon
	cpi counter, 100
	breq ledoff
	rjmp main

ledon:
	ldi r20, 0b11111110
	out PORTB, r20
	rjmp main

ledoff:
	ldi counter, 0
	ldi r20, 0x01
	out PORTB, r20
	rjmp main
	

timer0:
	push temp
	in temp, SREG
	push temp

	ldi temp, 200
	out TCNT0, temp

	pop temp
	out SREG, temp
	pop temp
	inc counter
	reti