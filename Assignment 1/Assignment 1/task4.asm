; Press the 5th button but light the first
start:
	ldi r16, 0x00
	ldi r18, 0b11111111
	out DDRB, r16 ; DDRB data direction register
	out DDRB, r18


bttn_chk:
	in r16, PINB
	cpi r18, 0b11101111 ; compare if r18 is equal to one button being pushed
	breq led_active ; branch if equal to led active

	rjmp bttn_chk

led_active:
	ldi r20, 0b11111110
	out PORTB, r18
