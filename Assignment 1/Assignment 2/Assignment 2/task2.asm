;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2021-09-17
; Author:
; Albin W. Palmfeldt
; Vilgot Karlsson
;
; Lab number: 2
; Title: Task 2 - Electronic dice
;
; Hardware: STK600, CPU ATmega2560
;
; Function: User presses a button and it will simulate rolling a dice using the time between button press and release
;
; Input ports: PIND is used for button presses
;
; Output ports: PORTB is used for LED output
;
; Subroutines: start loads the init values for the registers
; bttnc_chk checks if the button has been pressed
; counter counts from 0 to 6 til button has been released.
; display is a branch sorter, it will goto d1-d6 depending on the counter value.
; Included files: N/A
;
; Other information: N/A.
;
; Changes in program: N/A
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 
start:
	;this is the "random" dice
	ldi r22, 0x00
	; this is the button
	ldi r16, 0x00

	ldi r18, 0xFF
	out DDRB, r18
	
	

; this checks if the button is pressed
bttn_chk:
	in r16, PIND
	cpi R16, 0b01111111
	breq counter
	rjmp bttn_chk


; this resets r22 to zero
reset:
	ldi r22, 0x00
	rjmp counter

; this adds to the counter for how long the button is pressed down
counter:
	inc r22
	; branch if equal or more
	cpi r22, 0x07
	BRSH reset
	in r16, PIND
	cpi R16, 0b11111111
	breq display
	rjmp counter

; this will calculate and display the values
; Need to set value of r22 to leds
display:
	; if dice is equal to one
	cpi R22, 0b00000001
	breq d1
	cpi R22, 0b00000010
	breq d2
	cpi R22, 0b00000011
	breq d3
	cpi R22, 0b00000100
	breq d4
	cpi R22, 0b00000101
	breq d5
	cpi R22, 0b00000110
	breq d6



d1:
	; this is the led
	ldi r26, 0b11101111
	out PORTB, r26
	rjmp bttn_chk

d2:
	; this is the led
	ldi r26, 0b01111101
	out PORTB, r26
	rjmp bttn_chk

d3:
	; this is the led
	ldi r26, 0b01101101
	out PORTB, r26
	rjmp bttn_chk

d4:
	; this is the led
	ldi r26, 0b00101001
	out PORTB, r26
	rjmp bttn_chk

d5:
	; this is the led
	ldi r26, 0b00101001
	out PORTB, r26
	rjmp bttn_chk

d6:
	; this is the led
	ldi r26, 0b00010001
	out PORTB, r26
	rjmp bttn_chk