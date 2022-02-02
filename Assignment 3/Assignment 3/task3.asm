;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2021-09-30
; Author:
; Albin W. Palmfeldt
; Vilgot Karlsson
;
; Lab number: 3
; Title: Task 3 - Rear lights on a car
;
; Hardware: STK600, CPU ATmega2560
;
; Function: When pressing pin0 and pin1 it simulates the lights on a car when signaling.
; Based upon half a ring counter, these a triggered by interrupts.
;
; Input ports: PIND is used for button presses
;
; Output ports: PORTB is used for LED output
;
; Subroutines: reset initializes the stack and interrupts (and their values)
;  main is a default loop which the program will go back to
; left sets the startvalues for the leds while left_loop is the ring counter.
; In this case OR was used to make some of the leds unchangable.
; The same thing is done in right and right_loop (however reversed)
; Wait is the same ol' deal. It wastes 500 000 cycles
;
; Included files: m2560def.inc
;
; Other information: This was a hard nut to crack.
;
; Changes in program: N/A
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 



.include "m2560def.inc"
.def temp = r16


;; set up the interrupt vector
jmp reset
.org INT0addr ; INT0addr is the address of EXT_INT0
; when pressing button 0 goto right
jmp right_check
.org INT1addr
jmp left_check

; reset initializes the stack and interrupts (and their values)
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

 ldi r20, 0xff
 out DDRB, r20

main_loop:
	ldi r18, 0b00111100
    out PORTB, r18
    rjmp main_loop

right_check:
	rcall wait
	in r27, PIND
	cpi r27, 0b11111110
	breq right
	reti

right:
	; r18 is led
    ldi r18, 0b00110111
	; r19 is compare
	ldi r19, 0b00110000

right_loop:
    out PORTB,r18
    rcall wait
    lsr r18
	or r18, r19
	out PORTB, r18

	cpi r18, 0b00111111
	breq right_check
    in r27, PIND
	cpi r27, 0b11111110
	breq right_loop
	cpi r27, 0b11111111
	breq right_check
	reti

	
left_check:
	rcall wait
	in r27, PIND
	cpi r27, 0b11111101
	breq left
	reti

left:
	; r18 is led
    ldi r18, 0b11101100
	; r19 is compare
	ldi r19, 0b00001100

left_loop:
    out PORTB,r18
    rcall wait
    lsl r18
	or r18, r19
	out PORTB, r18

	;shoudnt this breq to left?
	cpi r18, 0b11111100
	breq left_check
    in r27, PIND
	cpi r27, 0b11111101
	breq left_loop
	cpi r27, 0b11111111
	breq left_check
	reti


wait:
; Assembly code auto-generated
; by utility from Bret Mulvey
; Delay 500 000 cycles
; 500ms at 1 MHz
    ldi  r22, 2
    ldi  r25, 2
    ldi  r21, 2
L1: 
    dec  r21
    brne L1
    dec  r25
    brne L1
    dec  r22
    brne L1
    ret
