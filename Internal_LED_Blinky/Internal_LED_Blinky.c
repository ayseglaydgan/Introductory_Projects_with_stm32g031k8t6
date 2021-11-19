/*PROBLEM 1
 * main.c
 *
 *
 *
 * description: Blinks 1 external which is connected to PA6 LED at roughly 1 second         * intervals. system
 *   clock is running from HSI which is 16 Mhz. Delay function is just a simple
 *   counter so is not accurate and the delay time will change based on the
 *   optimization flags.
 */

#include "stm32g0xx.h"

#define LEDDELAY    1600000

void delay(volatile uint32_t);

int main(void) {

    /* Enable GPIOA clock */
    RCC->IOPENR |= (1U);

    /* Setup PC6 as output */
    GPIOA->MODER &= ~(3U << 2*6);
    GPIOA->MODER |= (1U << 2*6);

    /* Turn on LED */
    GPIOA->ODR |= (1U << 6);

    while(1) {
        delay(LEDDELAY);
        /* Toggle LED */
        GPIOA->ODR ^= (1U << 6);
    }

    return 0;
}

void delay(volatile uint32_t s) {
    for(; s>0; s--);
}
