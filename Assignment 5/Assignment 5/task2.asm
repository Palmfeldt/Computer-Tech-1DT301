;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2021-10-15
; Author:
; Albin Widerberg Palmfeldt
; Vilgot Karlsson
;
; Lab number: 5
; Title: Electronic bingo machine
;
; Hardware: STK600, CPU ATmega2560
;
; Function: Program simulates a bingo machine by randomly generating a number between 1-75. 
; said number is then displayed on the lcd.
;
; Input ports: PORTD, button
;
; Output ports: PORTE, LCD
;
; Subroutines: reset sets SP and sets output.
; init_disp, initializes display. write_char sends reg "Data" to lcd with correct sleep/wait times.
; ms is a delay. inc_firstnumber increases the "random" number that will be displayed.
; the number will later be reset back 
; Included files: m2560def.inc

;<<<<<<<<<
.include 	"m2560def.inc"


.equ	BITMODE4	= 0b00000010		; 4-bit operation
.equ	CLEAR	= 0b00000001			; Clear display
.equ	DISPCTRL	= 0b00001111		; Display on, cursor on, blink on.

.cseg
.org	0x0000				; Reset vector
jmp reset

.org	0x0072

.org INT0addr ; INT0addr is the address of EXT_INT0
; when pressing button 0 goto right
jmp start_roll

reset:	

	.def	Temp	= r16
	.def	Data	= r17
	.def	RS	= r18	
	.def	first = r19
	.def	second = r20
	.def	maxi = r21
	.def counter = r24
	.def button = r25

	ldi Temp, HIGH(RAMEND)	; Temp = high byte of ramend address
	out SPH, Temp			; sph = Temp
	ldi Temp, LOW(RAMEND)	; Temp = low byte of ramend address
	out SPL, Temp			; spl = Temp

	ser Temp				; r16 = 0b11111111
	out DDRE, Temp			; port E = outputs ( Display JHD202A)
	clr Temp				; r16 = 0
	out PORTE, Temp


    ;; set DDRC to 0xFF.
    ser temp
    out DDRC, temp

    ;; set int1 and int0 for falling edge trigger.
    ldi temp, (1 << ISC01)
    sts EICRA, temp
    ;; enable int0 and int1
    in temp, EIMSK 
    ori temp, (1<<INT0)
    out EIMSK, temp
    sei
	

ldi first, 48
ldi second, 48
main:
	rcall init_disp
loop:
	rcall inc_firstnumber
	rjmp loop

start_roll:
	rcall inc_secondnumber
	in button, PIND
	cpi button, 0b11111110
	breq start_roll
	
	rcall clr_disp
	
	mov data, first
	rcall display

	mov data, second
	rcall ms
	rcall display
	reti

ms: ; Second delay so we can run a delay inside interupt
    ldi  r27, 240
    ldi  r29, 240
L2: 
    dec  r29
    brne L2
    dec  r27
    brne L2
    ret

display:
	rcall write_char
	ret
		

; **
; ** init_display
; **
init_disp:	
	rcall power_up_wait		; wait for display to power up

	ldi Data, BITMODE4		; 4-bit operation
	rcall write_nibble		; (in 8-bit mode)
	rcall short_wait		; wait min. 39 us
	ldi Data, DISPCTRL		; disp. on, blink on, curs. On
	rcall write_cmd			; send command
	rcall short_wait		; wait min. 39 us
clr_disp:	
	ldi Data, CLEAR			; clr display
	rcall write_cmd			; send command
	rcall long_wait			; wait min. 1.53 ms
	ret

; **
; ** write char/command
; **

write_char:		
	ldi RS, 0b00110000		; RS = high
	rjmp write
write_cmd: 	
	clr RS					; RS = low
write:	
	mov Temp, Data			; copy Data
	andi Data, 0b11110000	; mask out high nibble
	swap Data				; swap nibbles
	or Data, RS				; add register select
	rcall write_nibble		; send high nibble
	mov Data, Temp			; restore Data
	andi Data, 0b00001111	; mask out low nibble
	or Data, RS				; add register select

write_nibble:
	rcall switch_output		; Modify for display JHD202A, port E
	nop						; wait 542nS
	sbi PORTE, 5			; enable high, JHD202A
	nop
	nop						; wait 542nS
	cbi PORTE, 5			; enable low, JHD202A
	nop
	nop						; wait 542nS
	ret

; **
; ** busy_wait loop
; **
short_wait:	
	clr zh					; approx 50 us
	ldi zl, 30
	rjmp wait_loop
long_wait:	
	ldi zh, HIGH(1000)		; approx 2 ms
	ldi zl, LOW(1000)
	rjmp wait_loop
dbnc_wait:	
	ldi zh, HIGH(4600)		; approx 10 ms
	ldi zl, LOW(4600)
	rjmp wait_loop
power_up_wait:
	ldi zh, HIGH(9000)		; approx 20 ms
	ldi zl, LOW(9000)

wait_loop:	
	sbiw z, 1				; 2 cycles
	brne wait_loop			; 2 cycles
	ret

; **
; ** modify output signal to fit LCD JHD202A, connected to port E
; **

switch_output:
	push Temp
	clr Temp
	sbrc Data, 0				; D4 = 1?
	ori Temp, 0b00000100		; Set pin 2 
	sbrc Data, 1				; D5 = 1?
	ori Temp, 0b00001000		; Set pin 3 
	sbrc Data, 2				; D6 = 1?
	ori Temp, 0b00000001		; Set pin 0 
	sbrc Data, 3				; D7 = 1?
	ori Temp, 0b00000010		; Set pin 1 
	sbrc Data, 4				; E = 1?
	ori Temp, 0b00100000		; Set pin 5 
	sbrc Data, 5				; RS = 1?
	ori Temp, 0b10000000		; Set pin 7 (wrong in previous version)
	out porte, Temp
	pop Temp
	ret

inc_firstnumber: 
	inc first
	cpi first, 56	; 57 = 7
	breq first_reset
	ret
first_reset:
	ldi first, 48	; 48 = 0
	ret

inc_secondnumber: ; Increase secondnumber 
	ldi maxi, 58 ; 58 = 10
	cpi first, 55	; check if first number is 7 change maxi to 6
	brsh set_maxi
do_second:
	inc second
	cp second, maxi
	breq second_reset
	ret
second_reset:
	ldi second, 48
	ret
set_maxi:
	ldi maxi, 54 
	rjmp do_second