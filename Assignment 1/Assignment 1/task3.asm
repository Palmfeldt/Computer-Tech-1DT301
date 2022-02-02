;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2021-09-17
; Author:
; Albin Widerberg Palmfeldt
; Vilgot Karlsson
;
; Lab number: 1
; Title: task3 Led light w specific button
;
; Hardware: STK600, CPU ATmega2560
;
; Function: User presses the 5th button and led 0 (ie the first) lights up
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
	ldi r16, 0x00 ; Controls init pin status
	ldi r18, 0xFF; Controls if led is shutdown after
	out DDRD, r16 ; DDRB data direction register for port D
	out DDRB, r18
	out PORTB, r18


bttn_chk:
	in r16, PIND
	cpi r16, 0b11110111 ; compare if r18 is equal to one button being pushed
	breq led_active ; branch if equal to led active

	rjmp bttn_chk

; adds value 0xFE to r20 and sends it out
; 0xFE has a zero at the end which responds to led 0
led_active:
	ldi r20, 0b11111110
	out PORTB, r20
	rjmp start
