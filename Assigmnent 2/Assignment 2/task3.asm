;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2021-09-17
; Author:
; Albin W. Palmfeldt
; Vilgot Karlsson
;
; Lab number: 2
; Title: Task 3 - Change counter
;
; Hardware: STK600, CPU ATmega2560
;
; Function: user presses a button and it will count press and release. 
; Buttons presses will be shown in binary on the leds
;
; Input ports: PIND is used for button presses
;
; Output ports: PORTB is used for LED output
;
; Subroutines: start sets values for led and button registers.
; bttn_chk checks if the button is pressed and breqs to autoinc if true.
; autoinc & autoinc2 adds 1 to r22
; bttn_rel displays leds and checks if the button has been released,
; if so then it breqs to autoinc.
; 
; Included files: N/A
;
; Other information: N/A.
;
; Changes in program: N/A
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 
start:
	;this is the counter
	ldi r22, 0x00
	; this is the button
	ldi r16, 0x00

	; this is the led
	ldi r18, 0xFF
	out DDRB, r18


bttn_chk:
	out PORTB, r22
	in r16, PIND
	cpi R16, 0b01111111
	breq autoinc

	rjmp bttn_chk


autoinc:
	inc r22
	rjmp bttn_rel

autoinc2:
	inc r22
	rjmp bttn_chk

bttn_rel:

	out PORTB, r22
	in r16, PIND
	cpi R16, 0xFF
	breq autoinc2

	rjmp bttn_rel
