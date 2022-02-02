; Assigment 3 Task 2
; Date: 2021-09-30
; Author:
; Albin W. Palmfeldt
; Vilgot Karlsson
;
; Lab number: 3
; Title: Task 2 - Switch Ring and Johnson counter using interrupt
;
; Hardware: STK600, CPU ATmega2560
;
; Function: When pressing pin0 switches between previous ring counter and johnsson counter
;
; Input ports: PIND is used for button presses
;
; Output ports: PORTB is used for LED output
;
; Subroutines: reset will reset the stackpointer. Start is for initializing the ring counter.
; then it will go over loop which will left shift and update the leds
; wait will waste 500 000 cycles
; when intterupt is triggered it will check if the flag is set.
; if so it will go to the johnsson subroutine. This is will initialize the leds for the johnsson part
; left loop and right loop will shift the leds in the right order to create the effect.
; Included files: m2560def.inc
;
; Other information: N/A.
;
; Changes in program: N/A
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 

.include "m2560def.inc"
.def temp = r16
.def flag = r24


;; set up the interrupt vector
jmp reset
.org INT1addr ; INT0addr is the address of EXT_INT0
jmp flag_chk

;setflag
ldi r22, 0xFF

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

setUp:
	ldi temp, 0x00
	out DDRD, temp
	ldi temp, 0xFF ; Controls init pin status
    out DDRB, temp
	

start:
    ldi r17, 0xFE ; Controls if led is shutdown after
    ldi r22, 0x01

  
loop:
	in r23, PIND
    cpi r17, 0xFF 
    breq start
    out PORTB, r17
    lsl r17
    add r17, r22
    rcall wait
	cpi flag, 0x01
	breq johnsson
	rjmp loop
	

wait:
; Assembly code auto-generated
; by utility from Bret Mulvey
; Delay 500 000 cycles
; 500ms at 1 MHz
    ldi  r18, 3
    ldi  r19, 80
    ldi  r21, 86
L1: 
	dec  r21
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1

    ret


; start of Johnsson counter/cunter
johnsson:
	ldi r17, 0b11111111
	ldi r26, 0b10000000

left_loop:
	rcall wait
	out PORTB, r17
	cpi r17, 0b00000000
	breq right_loop
	lsl r17

	cpi flag, 0x00
	breq start
	rjmp left_loop


right_loop:
	rcall wait
	;when in the right loop, set R22 to 16
	ldi r22, 0x0F
	out PortB, r17
	cpi r17, 0b11111111
	breq left_loop
	lsr r17
	add r17, r26

	;Controller, Check if program should switch counter
	cpi flag, 0x00
	breq start
	rjmp right_loop

flag_chk: ; Check if button is pressed, if not go to set_flag
	rcall ms
newLabel:
	in r27, PIND
	sbrs r27, 0
		rjmp newLabel
	rcall ms
	ldi r25, 0x01
	eor flag, r25

	reti

ms: ; Second delay so we can run a delay inside interupt
	ldi  r27, 244
    ldi  r29, 244
L2: 
    dec  r29
    brne L2
    dec  r27
    brne L2
    ret