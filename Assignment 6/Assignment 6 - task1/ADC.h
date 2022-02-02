#ifndef ADC_H_
#define ADC_H_
#include <avr/io.h>

// Reference Voltage.
#define VREF 5.0

// mux - See pinout on page 2 and MUX table on page 290.
void ADC_init(uint8_t mux);

double ADC_read_voltage();

#endif /* ADC_H_ */