;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2021-09-17
; Author:
; Albin Widerberg Palmfeldt
; Vilgot Karlsson
;
; Lab number: 1
; Title: task6 johnsson counter
;
; Hardware: STK600, CPU ATmega2560
;
; Function: flashes each led in a "johnsson counter" formation.
;
; Input ports: N/A
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
	; Set Vales to registers
	ldi R16, 0xff
	ldi R17, 0b11111111
	ldi R18, 0b10000000
	;<<<<<<<<<<<<<<<<<<<<<<<
	out DDRB, R16 ; Initialize DDRB 

	
left_loop:	; Loop to the end 
	 out PORTB, R17
	 cpi R17, 0b00000000	; Check if all LEDS is on
	 breq right_loop		; goto next loop
	 lsl R17	; Logical shift left r17

	 rcall wait ; delay
	 rjmp left_loop


right_loop:
	;when in the right loop, set R22 to 16
	ldi R22, 0x0F


	out PortB, R17
	cpi R17, 0b11111111
	breq start
 
	lsr R17	; Logical shift right r17
	add R17, R18  ;set bit7 in r17
	
	rcall wait ; delay
	rjmp right_loop

 wait:
; Assembly code auto-generated
; by utility from Bret Mulvey
; Delay 500 000 cycles
; 500ms at 1 MHz

    ldi  r23, 3
    ldi  r19, 138
    ldi  r21, 86
L1: 
	dec  r21
    brne L1
    dec  r19
    brne L1
    dec  r23
    brne L1
    ret
