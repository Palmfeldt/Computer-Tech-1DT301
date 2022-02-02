;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2021-10-15
; Author:
; Albin Widerberg Palmfeldt
; Vilgot Karlsson
;
; Lab number: 5
; Title: task4 Display charachter with auto line break.
;
; Hardware: STK600, CPU ATmega2560
;
; Function: Program displays character recived from serial and displays it on the LCD.
; after five seconds are passed then an automatic linebreak is made.
;
; Input ports: N/A
;
; Output ports: PORTE, LCD
;
; Subroutines: reset sets SP and sets output.
; init_disp, initializes display. write_char sends reg "Data" to lcd with correct sleep/wait times.
; readLetter takes input from UDR1 and sends it to write_char. 
; said routine will also save characters to sram.
; If no character is found then the subroutine will loop.
; writeout starts the process of writing the saved chars to the lcd.
; it first calls addspace and then goes to finalwrite.
; finalwrite sends all the collected letters (saved in sram) to the lcd.
; addspace and finalspace makes the linebreak by pushing spaces to the lcd.
; miliseconds is a delay of 5 seconds
; resetx resets the position of X pointer.
; Included files: m2560def.inc
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 
	


.include 	"m2560def.inc"
.def	Temp	= r16
.def	Data	= r17
.def	RS	= r18

.def mH = r25
.def mL = r24

.dseg
.org	SRAM_START
var:	.byte	6

.def counter = r22

.equ	BITMODE4	= 0b00000010		; 4-bit operation
.equ	CLEAR	= 0b00000001			; Clear display
.equ	DISPCTRL	= 0b00001111		; Display on, cursor on, blink on.
.equ milliseconds = 5000	
; baude rate 4800
.equ UBRR_val =  12 ; sida 227
.cseg
.org	0x0000				; Reset vector
jmp reset

.org	0x0072

.org URXC1addr
rjmp readletter


reset:	
	; get higer part of milliseconds
	ldi mH, HIGH(milliseconds)
	; get lower part of milliseconds
	ldi mL, LOW(milliseconds)

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
	ldi temp, (1<<RXEN1) | (1<<TXEN1) | (1<<RXCIE1)
	sts UCSR1B, temp	; set RX and TX enable flags
	ldi	XL,LOW(var)		; initialize X pointer
	ldi	XH,HIGH(var)		; to var address
	sei
	
	rcall init_disp


loop:
	nop
	rcall readletter
	cpi counter, 6
	breq writeout
	rjmp loop


waitloop:
	cpi r17, 0b11111111 ; Check if counter is done
	;breq start			; reset counter
	out PORTB, r17
	lsl r17
	add r17, r22
	rcall milli_seconds ; Call delay
	rjmp waitloop	



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
	ldi  r26, 2
    ldi  r27, 75
L2: 
	dec  r27
    brne L2
    dec  r26
    brne L2
	rjmp check



readLetter:
	lds Data, UDR1		; read letter in UDR
	st	X+,Data			; store r16 to var+0 and increment pointer
	rcall write_char
	
	inc counter

	reti


resetx:
	clr r30
	rcall finalspace
	ldi	XL,LOW(var)		; initialize X pointer
	ldi	XH,HIGH(var)		; to var address+
	rjmp loop

writeout:
	rcall milli_seconds
	rcall clr_disp
	ldi	XL,LOW(var)		; initialize X pointer
	ldi	XH,HIGH(var)		; to var address+
	
	rcall addspace


finalwrite:
	dec counter
	ld	Data,X+			; decrement pointer and load var+3 to r3
	rcall write_char
	cpi counter, 0
	breq resetx
	rjmp finalwrite

finalspace:
	nop
	ldi Data, 0x20 
	inc r30
	rcall write_char
	cpi r30, 34
	brne finalspace
	ret

addspace:
	nop
	ldi Data, 0x20 
	inc r30
	rcall write_char
	cpi r30, 40
	brne addspace
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