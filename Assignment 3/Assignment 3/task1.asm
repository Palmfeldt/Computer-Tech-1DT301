;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2021-09-30
; Author:
; Albin W. Palmfeldt
; Vilgot Karlsson
;
; Lab number: 3?
; Title: Task 1 - Led light up using pin interrupt call
;
; Hardware: STK600, CPU ATmega2560
;
; Function: When pressing pin0 it enables led0 to light up. 
; The same is reversed once you press it again.
;
; Input ports: PIND is used for button presses
;
; Output ports: PORTB is used for LED output
;
; Subroutines: reset will reset the stack and initialize the interrupt,
;  main is a default loop which the program will go back to
; handle_pb0 is for checking the the button value
; setled is for turning on the led, while clearled is for turning off the led 
; Included files: m2560def.inc
;
; Other information: N/A.
;
; Changes in program: N/A
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 


.include "m2560def.inc"
.def temp = r16


;; set up the interrupt vector
jmp reset
.org INT0addr ; INT0addr is the address of EXT_INT0
jmp loop

reset:
	;; init the stack
	ldi temp, low(RAMEND)
	out SPL, temp
	ldi temp, high(RAMEND)
	out SPH, temp

	;; set DDRC to 0xFF.
	ser temp
	out DDRC, temp

	;; set int1 and int0 for falling edge trigger.
	ldi temp, (1 << ISC11) | (1 << ISC01)
	sts EICRA, temp

	;; enable int0 and int1
	in temp, EIMSK 
	ori temp, (1<<INT0) | (1<<INT1)
	out EIMSK, temp
	sei

main_loop:
	nop
	rjmp main_loop


;; this is the handler for PushButton0
loop:
	rcall wait
	in r19, PIND
	cpi r19, 0b11111110
	breq handle_pb0
	reti

handle_pb0:
	; skip if bit in reg is cleared
	ldi r17, 0xff
	out DDRB, r17

	; skip if bit in io is set
	sbis PORTB, PIND0
	ldi r18, 0b11111111

	;skip if bit in io is cleared
	sbic PORTB, PIND0
	ldi r18, 0b11111110
	out PORTB, r18
	reti

	wait:
; Assembly code auto-generated
; by utility from Bret Mulvey
; Delay 500 000 cycles
; 100ms at 1 MHz
	
    ldi  r18, 130
    ldi  r19, 222
L1: 
    dec  r19
    brne L1
    dec  r18
    brne L1
    ret
