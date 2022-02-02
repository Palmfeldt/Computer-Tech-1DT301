/*;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2021-10-27
; Author:
; Albin Widerberg Palmfeldt
; Vilgot Karlsson
;
; Lab number: 6
; Title: task4 in Assignment 5 converted to C
;
; Hardware: STK600, CPU ATmega2560
;
; Function: Program displays character received from serial and displays it on the LCD.
; after five seconds are passed then an automatic linebreak is made.
;
; Input ports: N/A
;
; Output ports: PORTA and PORTC connected to LCD
;
; Subroutines: write_char is called when you want a write a letter to lcd.
; init_disp initializes the LCD
; spaceadder sends spaces to the lcd (for line break)
; write_saved sends the saved characters to the lcd.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
*/

#define F_CPU 16000000

#include <avr/interrupt.h>
#include <avr/cpufunc.h>
#include <util/delay.h>
#include <stdbool.h>
#include <stdio.h>

#include "ADC.h"

#define BUF_SIZE 100
volatile char str_buffer[BUF_SIZE];

#define FOSC 1843200// Clock Speed
#define BAUD 9600

unsigned char RS = 0b00000000;
#define cbi(port, bitpos) (port) &= ~(1 << (bitpos))
#define sbi(port, bitpos) (port) |= (1 << (bitpos))
unsigned char store[6];
int counter = 0;




void USART_Init(){
    /* Set baud rate */
    UBRR0H = (unsigned char)(BAUD>>8);
    UBRR0L = (unsigned char)BAUD;
    /* Enable receiver and transmitter */
    UCSR0B = (1<<RXEN0)|(1<<TXEN0);
    /* Set frame format: 8data, 2stop bit */
    UCSR0C = (1<<USBS0) |(3<<UCSZ00);
}

unsigned char USART_Receive( void )
{
    /* Wait for data to be received */
    while ( !(UCSR0A & (1<<RXC0)) );
        
    /* Get and return received data from buffer */
    return UDR0;
}

/*
    Read temp.
    Don't forget to call ADC_init() before calling this function.
*/
double lm35_read_temp()
{    
    return ADC_read_voltage() / 0.01;
}

// Send a string using USART
void send_log_msg(char *str)
{
        /* Wait for empty transmit buffer */
        while ( !( UCSR0A & (1<<UDRE0)) )
        ;
        /* Put data into buffer, sends the data */
        for(int i = 0; str[i]; i++) {
			UDR0 = str[i];
		}
}

ISR(USART_RX_vect)
{    
     //read_letter();
}


void init_display(void) {
    DDRA = 0xFF;
    DDRC = 0b111;
    cbi(PORTC, 0);
    PORTA = 0b0001110;
    sbi(PORTC, 2);
    cbi(PORTC, 2);
}




// this is the function you call when wanting to write a letter
unsigned char write_char(unsigned char input) {
    sbi(PORTC, PC0);
    write_f(input);
}

void write_f(unsigned char input) {
    // clear RS ffs
    cbi(PORTC, PC1);
    PORTA = input;
    sbi(PORTC, PC2);
    cbi(PORTC, PC2);
}

void read_letter(void) {
        unsigned char ch = USART_Receive();
		write_char(ch);
        store[counter] = ch;
        counter++;

}

// sends shitty blank character
void clear_screen(void) {
    _delay_us(0.02); // wait 2 ms useless in simulator
    cbi(PORTC, PC0);
	cbi(PORTC, PC1);
	write_f(0x01);
}


void space_adder(int lengh) {
	for (int i = 0; i < lengh; i++) {
		write_char(0x20);
	}
}


int main(void) {    
    
    // Connect PORTF pin 0, i.e ADC0, to temp sensor.
    // See pinout on page 2 and MUX table on page 290. 
    ADC_init(0b00000);
    USART_Init();
    init_display();
    sei();
    while(1){
        if(counter == 6) {
			_delay_ms(5000); ; // 5 seconds.
            clear_screen();
			space_adder(40);
			for (int x = 0; x <= sizeof(store); x++) {
				write_char(store[x]);
			}
			space_adder(33);
			counter = 0;
			
    }
        else {
            read_letter();
        }
    }
  
}