;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2021-09-17
; Author:
; Albin W. Palmfeldt
; Vilgot Karlsson
;
; Lab number: 2
; Title: Task 1 - Ring and Johnsson counter switcher
;
; Hardware: STK600, CPU ATmega2560
;
; Function: Program switches between a ring counter and a Johnsson counter. 
;
; Input ports: PIND is used for button presses
;
; Output ports: PORTB is used for LED output
;
; Subroutines: <Describe>
; Included files: N/A
;
; Other information: N/A.
;
; Changes in program: N/A
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 
; Program is a ring counter
; Initialize SP, Stack Pointer
ldi r20, HIGH(RAMEND) ; R20 = high part of RAMEND address
out SPH,R20 ; SPH = high part of RAMEND address
ldi R20, low(RAMEND) ; R20 = low part of RAMEND address
out SPL,R20 ; SPL = low part of RAMEND address


; Ring counter
start:
	rcall wait
	; Set values to Registers
    ldi r16, 0xFF
    ldi r17, 0xFE ; Controls led
    ldi r22, 0x01
	ldi r23, 0x00
	;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	ldi r24, 0x00 ; This is flag
	out DDRD, r23
    out DDRB, r16

    
loop:
	in r23, PIND
    cpi r17, 0xFF 
    breq start
    out PORTB, r17
    lsl r17
    add r17, r22
    rcall wait
	rjmp loop

wait:
; Assembly code auto-generated
; by utility from Bret Mulvey
; Delay 500 000 cycles
; 500ms at 1 MHz

	
    ldi  r18, 3
    ldi  r19, 138
    ldi  r21, 86
L1: 
	in r23, PIND

	dec  r21
    brne L1
	cpi r23, 0b01111111
	breq flag
    dec  r19
    brne L1
    dec  r18
    brne L1

    ret


; start of Johnsson counter/cunter
johnsson:
	rcall wait ; delay
	; Set values to Registers
	ldi r24, 0x01
	ldi R16, 0xff
	ldi R17, 0b11111111
	ldi R26, 0b10000000
	out DDRB, R16
	;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

left_loop:
	 out PORTB, R17
	 cpi R17, 0b00000000 ; check if johnsson counter should go backwards
	 breq right_loop	; rjmp to other loop
	 lsl R17

	 rcall wait
	 rjmp left_loop


right_loop:
	;when in the right loop, set R22 to 16
	ldi R22, 0x0F
	out PortB, R17
	cpi R17, 0b11111111
	breq left_loop
 
	lsr R17
	add R17, R26 ,  ;set bit 0 in r17
	
	rcall wait ; Delay
	rjmp right_loop

; Check what coutner is currently running and change to the other
flag: 
	cpi r24, 0x00
	breq johnsson
	rjmp start