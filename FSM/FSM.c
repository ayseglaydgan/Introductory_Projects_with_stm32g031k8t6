/*
 * author: Aysegul Aydogan
 *
 * description: Blinks 1 external LED at roughly 2 second, 1 second, 0.5 *second and 0.1 second intervals. Each interval represent a state of FSM.
 * system clock is running from HSI which is 16 Mhz. Delay function is just a * simple countdown.
 */

#include "stm32g0xx.h"

/* 1 second */
#define LEDDELAY1    1600000
/* 2 second */
#define LEDDELAY2    3200000
/* 5 second */
#define LEDDELAY3     800000

#define LEDDELAY4 	  160000

#define BUTTONDELAY  2000000



enum blinkStates{
	LED_OFF, // 0
	BLINK_2sec, // 1
	BLINK_1sec, // 2
	BLINK__5sec,  // 3
	BLINK__1sec,  // 4
	LED_ON, // 5
};



int i = 0;
volatile int buttonCounter = 0;

void delay(volatile uint32_t);


int main(void) {

    /* Enable GPIOA clock */
    RCC->IOPENR |= (1U);

    /* Setup PA6 as output */
    GPIOA->MODER &= ~(3U << 2*6);
    GPIOA->MODER |= (1U << 2*6);

    GPIOA->ODR |= (1U << 6);
    /* For Button */
    /* Enable GPIOB clock */
    RCC->IOPENR |= (1U << 1);
    /* Setup PB5 as input */
    GPIOB->MODER &= ~(3U << 2*5);





    while(1) {


    	if ((GPIOB->IDR >> 5) & 1)
    	{
    		delay(BUTTONDELAY);
    		buttonCounter++;
    		i++;
    	}

		if(buttonCounter == LED_OFF + 1)
		{
			while(1)
			{
				delay(LEDDELAY1);
				GPIOA->ODR &= (0U << 6);
				if ((GPIOB->IDR >> 5) & 1)
				{
					i++;
					break;
				}
			}
		}
		else if(buttonCounter == BLINK_2sec + 1)
		{
			while(1)
			{
				delay(LEDDELAY2);
				GPIOA->ODR ^= (1U << 6);
				if ((GPIOB->IDR >> 5) & 1)
				{
					i++;
					break;
				}
			}
		}

		else if(buttonCounter == BLINK_1sec + 1)
		{
			while(1)
			{
				delay(LEDDELAY1);
				GPIOA->ODR ^= (1U << 6);
				if ((GPIOB->IDR >> 5) & 1)
				{
					i++;
					break;
				}
			}
		}
		else if(buttonCounter == BLINK__5sec + 1)
		{
			while(1)
			{
				delay(LEDDELAY3);
				GPIOA->ODR ^= (1U << 6);
				if ((GPIOB->IDR >> 5) & 1)
				{
					i++;
					break;
				}
			}
		}
		else if(buttonCounter == BLINK__1sec + 1)
		{
			while(1)
			{
				delay(LEDDELAY4);
				GPIOA->ODR ^= (1U << 6);
				if ((GPIOB->IDR >> 5) & 1)
				{
					i++;
					break;
				}
			}
		}
		else if(buttonCounter == LED_ON + 1)
		{
			while(1)
			{
				delay(LEDDELAY1);
				GPIOA->ODR |= (1U << 6);
				if ((GPIOB->IDR >> 5) & 1)
				{
					i++;
					break;
				}
			}
			buttonCounter = 0;
			i = 0;
    	}

    }

    return 0;
}

void delay(volatile uint32_t s) {
    for(; s>0; s--);
}
