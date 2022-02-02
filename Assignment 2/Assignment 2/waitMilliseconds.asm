
 ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2021-09-24
; Author:
; Albin W. Palmfeldt
; Vilgot Karlsson
;
; Lab number: 2
; Title: Task 4 - Delay subroutine with variable delay time
;
; Hardware: STK600, CPU ATmega2560
;
; Function: Program is a ring counter with a modifiable delay counter between each led blink
; Delay can be modified by changing milliseconds
;
; Input ports: PIND is used for button presses
;
; Output ports: PORTB is used for LED output
;
; Subroutines: start loads register values for led
; loop is the ring counter.
; millisecond is the splitting and loading of milliseconds value into two registers
; check subtracts one from the "milliseconds" word and then branches to delay
; Included files: N/A
;
; Other information: N/A.
;
; Changes in program: N/A
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 

; Initialize the Stack Pointer (SP) to the highest address 
    ; in SRAMs (RAMEND).
ldi r16, HIGH(RAMEND)  ; MSB part av address to RAMEND
out SPH, r16           ; store in SPH
ldi r16, LOW(RAMEND)   ; LSB part av address to RAMEND
out SPL, r16           ; store in SPL 

;*--------------------------------------------------------------------*
.def mH = r25
.def mL = r24

.equ milliseconds = 2000	; Set amount of time between every led

; get higer part of milliseconds
ldi mH, HIGH(milliseconds)
; get lower part of milliseconds
ldi mL, LOW(milliseconds)

start:
	; Set values in registers
	ldi r16, 0xFF
	ldi r17, 0xFE ; led status
	ldi r22, 0x01
	;<<<<<<<<<<<<<<<<<<<<<
	out DDRB, r16
	
	;ring conter
loop:
	cpi r17, 0b11111111 ; Check if counter is done
	breq start			; reset counter
	out PORTB, r17
	lsl r17
	add r17, r22
	rcall milli_seconds ; Call delay
	rjmp loop	



; Creates a delay
milli_seconds:
	ldi mH, HIGH(milliseconds)	; get Higer part of milliseconds
	ldi mL, LOW(milliseconds)	; get lower part of milliseconds

check:	
	sbiw mH:mL,1	; decrease milliseconds
	cpi mH, 0x00	; Check if milliseconds is 0
	brne delay		; Go to 1ms delay
	ret
	
; 1ms delay
delay:
	ldi  r18, 2
    ldi  r19, 75
L2: 
	dec  r19
    brne L2
    dec  r18
    brne L2
	rjmp check
