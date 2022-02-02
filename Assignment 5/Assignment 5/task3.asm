;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2021-10-15
; Author:
; Albin Widerberg Palmfeldt
; Vilgot Karlsson
;
; Lab number: 5
; Title: Serial communication and display
;
; Hardware: STK600, CPU ATmega2560
;
; Function: Program recives charachter sent from serial and displays it on the LCD.
;
; Input ports: N/A
;
; Output ports: PORTE LCD
;
; Subroutines: reset sets SP and sets output.
; init_disp, initializes display. write_char sends reg "Data" to lcd with correct sleep/wait times.
; readLetter takes input from UDR1 and sends it to write_char. 
; If no character is found then the subroutine will loop.
; Included files: m2560def.inc

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 
	


.include 	"m2560def.inc"
.def	Temp	= r16
.def	Data	= r17
.def	RS	= r18

.equ	BITMODE4	= 0b00000010		; 4-bit operation
.equ	CLEAR	= 0b00000001			; Clear display
.equ	DISPCTRL	= 0b00001111		; Display on, cursor on, blink on.
; baude rate 4800
.equ UBRR_val =  12 ; sida 227
.cseg
.org	0x0000				; Reset vector
jmp reset

.org	0x0072

reset:	

	ldi Temp, HIGH(RAMEND)	; Temp = high byte of ramend address
	out SPH, Temp			; sph = Temp
	ldi Temp, LOW(RAMEND)	; Temp = low byte of ramend address
	out SPL, Temp			; spl = Temp

	ser Temp				; r16 = 0b11111111
	out DDRE, Temp			; port E = outputs ( Display JHD202A)
	clr Temp				; r16 = 0
	out PORTE, Temp	

	ldi temp, UBRR_val	; set baud rate to r16
	sts UBRR1L, temp	; store serial output to sram
	ldi temp, (1<<RXEN1) | (1<<TXEN1) 
	sts UCSR1B, temp	; set RX and TX enable flags


	rcall init_disp

loop:
	nop
	rcall readletter
	rjmp loop
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

readLetter:
	
	lds temp, UCSR1A 	; read UCSR1A I/O register to temp(r16)
	sbrs temp, RXC1		; skip if RXC1 in r16
	rjmp readLetter		; if r16 is clear goto readLetter
	lds Data, UDR1		; read letter in UDR
	rcall write_char

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