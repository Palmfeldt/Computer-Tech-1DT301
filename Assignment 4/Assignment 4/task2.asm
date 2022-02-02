;Assigment 4 Task 2
; Date: 2021-10-14
; Author:
; Albin W. Palmfeldt
; Vilgot Karlsson
;
; Lab number: 3
; Title: Task 2 - PWM
;
; Hardware: STK600, CPU ATmega2560
;
; Function: When pressing pin0 switches between previous ring counter and johnsson counter
;
; Input ports: PIND is used for button presses
;
; Output ports: PORTB is used for LED output
;
; Subroutines: start will reset the stackpointer.
; INT0addr interrupt will goto inc_int0 which will add change into number (with delay)
; INT1addr interrupt will goto dec_int1 which will sub change into number (with delay)
; timer0 adds to the counter
; ms is a delay
; Included files: m2560def.inc
;
; Other information: N/A.
;
; Changes in program: N/A
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 
.include "m2560def.inc"

.CSEG
.org 0x0000
rjmp start

.org OVF0addr
jmp timer0

.org INT0addr
jmp inc_int0

.org INT1addr
jmp dec_int1


.org 0x72
.def temp = r16
    .def counter = r18
    .def number = r17 
    .def change = r19

start:
    ldi temp, LOW(RAMEND)
    out SPL, temp
    ldi temp, HIGH(RAMEND)
    out SPH, temp

    ldi r20, 0xff
    out DDRB, temp
    out PORTB, temp

    ldi temp, 0x01
    out TCCR0B, temp
    ldi temp, (1<<TOIE0)
    sts TIMSK0, temp

    ldi temp, 200
    out TCNT0, temp

    ldi temp, (1 << ISC11) | (1 << ISC01)
    sts EICRA, temp

    ;; enable int0 and int1
    in temp, EIMSK 
    ori temp, (1<<INT0) | (1<<INT1)
    out EIMSK, temp

    sei

ldi counter, 0
ldi change, 5
ldi number, 50

main:
    cp counter, number
    breq ledon
    cpi counter, 100
    breq ledoff
    rjmp main


ledon:
    ldi r20, 0b11111110
    out PORTB, r20
    rjmp main

ledoff:
    ldi counter, 0
    ldi r20, 0xff
    out PORTB, r20
    rjmp main

timer0:
    push temp
    in temp, SREG
    push temp

    ldi temp, 200
    out TCNT0, temp

    pop temp
    out SREG, temp
    pop temp
    inc counter
    reti

inc_int0:
    in r21, PIND
    sbrs r21, 0
        rjmp inc_int0
    rcall ms
    add number, change
    reti

dec_int1:
    in r21, PIND
    sbrs r21, 0
        rjmp dec_int1
    rcall ms
    sub number, change
    reti

ms: ; Second delay so we can run a delay inside interupt
    ldi  r27, 130
    ldi  r29, 222
L2: 
    dec  r29
    brne L2
    dec  r27
    brne L2
    ret