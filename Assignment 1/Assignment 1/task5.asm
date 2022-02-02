;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2021-09-17
; Author:
; Albin Widerberg Palmfeldt
; Vilgot Karlsson
;
; Lab number: 1
; Title: task5 Ring counter
;
; Hardware: STK600, CPU ATmega2560
;
; Function: flashes each led in a ring formation.
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

; Program is a ring counter
; Initialize SP, Stack Pointer
ldi r20, HIGH(RAMEND) ; R20 = high part of RAMEND address
out SPH,R20 ; SPH = high part of RAMEND address
ldi R20, low(RAMEND) ; R20 = low part of RAMEND address
out SPL,R20 ; SPL = low part of RAMEND address


start:
    ldi r16, 0xFF ; Controls init pin status
    ldi r17, 0xFE ; Controls if led is shutdown after
    ldi r22, 0x01

    out DDRB, r16
    
loop:
    cpi r17, 0xFF	; Set registers to Start values. 
    breq start
    out PORTB, r17	; Output r17 to PORTB
    lsl r17			; Logical shift left r17 
    add r17, r22	; set bit0 in r17
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
	dec  r21
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
    ret