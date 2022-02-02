;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2021-10-4
; Author:
; Albin W. Palmfeldt
; Vilgot Karlsson
;
; Lab number: 3
; Title: Task 3 - Rear lights on a car, with light for brakes
;
; Hardware: STK600, CPU ATmega2560
;
; Function: When pressing pin0 and pin1 it simulates the lights on a signaling car.
; Based upon half a ring counter, these are triggered by interrupts.
; Unlike task3 this file has the added function of a "break" button. 
; This will simulate breaking on a car. Button can be combined with signaling.
; 
;
; Input ports: PIND is used for button presses
;
; Output ports: PORTB is used for LED output
;
; Subroutines: reset initializes the stack and interrupts (and their values)
; main is a default loop which the program will go back to, it sets the initial led states.
; Main also checks if the breaks button is pressed down, and if so then it branches to breaks.
;
; left_ and right_check are for checking if the break button is pressed down.
; if so then it will rcall to set_left_break else it will go to left_set.
; left_set sets the startvalues for the leds while left_loop is the ring counter.
; This is very much the same thing for set_left_break, however in this case
; all the leds (unless they are a part of the ring counter) will light up.
; 
; OR was used to make some of the leds unchangable.
; This is used in all left, right and break loops.
; Wait is the same ol' deal. It wastes 500 000 cycles by looping.
; 
;	
;
; Included files: m2560def.inc
;
; Other information: This was a hard nut to crack. Even more so than Task 3.
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
	; If break is pressed down
	in r27, PIND
	sbrs r27, 2 
	rjmp breaks
    rjmp main_loop

; Break
breaks:
	ldi r18, 0b00000000 ; Set break
	out PORTB, r18	; output Break to PORTB
	in r27, PIND	
	rjmp main_loop
	
	 	
;Turn left
left_check:
	in r27, PIND
	; If Break is pressed...
	sbrs r27, 2		; True, set breaks together with signaling left.
	rcall set_left_break
	sbrc r27, 2		; False, set signaling left. 
	rcall set_left
   ;-----------------------
	sbrc r27, 1		; Release button
	reti	; return
	rjmp left_loop
	

set_left_break:	;Set LED to for breaking and signal left
	ldi r18, 0b11100000
	ldi r19, 0b00010000
	ret

set_left:	;Set LED to Signal left
	ldi r18, 0b11101100
	ldi r19, 0b00001100
	ret
	
left_loop:
    out PORTB,r18
    rcall wait ;delay
    lsl r18		;logical shift left
	or r18, r19	; set led for next iteration
	out PORTB, r18

	cpi r18, 0b11111100	;Go back to left_check
	breq left_check
	cpi r18, 0b11110000 ;Go back to left_check
	brne left_loop
	breq left_check

;--------------

right_check:
	in r27, PIND	
	; If Break is pressed...
	sbrs r27, 2		; True, set breaks together with signaling right.
	rcall set_right_break
	sbrc r27, 2		; False, set signaling right.
	rcall set_right
      ;-----------------------
	sbrc r27, 0	; release button
	reti	; return
	rjmp right_loop
	
set_right_break: ;Set LED to for breaking and signal right
	ldi r18, 0b00000111
	ldi r19, 0b00001000
	ret

set_right: ;Set LED to signal right
	ldi r18, 0b00110111
	ldi r19, 0b00110000
	ret
	
right_loop:
    out PORTB,r18
    rcall wait	; delay
    lsr r18		; logical shift right
	or r18, r19 ; set led for next iteration
	out PORTB, r18

	cpi r18, 0b00111111	;Go back to right_check
	breq right_check
	cpi r18, 0b00001111 ;Go back to right_check
	breq right_check
	brne right_loop
	


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
