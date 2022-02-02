#include "ADC.h"

void ADC_init(uint8_t mux)
{
	// 1. AVCC with external capacitor at AREF pin
	// 2. MUX[4:0]
	ADMUX = (0b01 << REFS0) + (mux & 0b11111);
	// MUX[5]
	ADCSRB = (mux & 0b100000) >> 2;

	// 1. Enable conversion.
	// 2. Set prescaler = 128 so we get a frequency between 50-100 kHz see chap 26.4.
	ADCSRA = (1 << ADEN) | (0b111 << ADPS0);
}

double ADC_read_voltage()
{
	// Start conversion
	ADCSRA = ADCSRA | (1 << ADSC);
	
	// Wait for completion
	while((ADCSRA &  (1 << ADSC)) == (1 << ADSC));
	
	return 	((ADCH << 8) + ADCL) * VREF / 1024.0;
}
