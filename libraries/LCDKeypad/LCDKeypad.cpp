/*
  LCDKeypad.cpp
*/
#if ARDUINO >= 100
  #include "Arduino.h"
#else
  #include "WProgram.h"
#endif


// include this library's description file

#include <LiquidCrystal.h>
#include "LCDKeypad.h"

LCDKeypad::LCDKeypad() : LiquidCrystal(8, 9, 4, 5, 6, 7)
{
}

int LCDKeypad::button()
{
  static int NUM_KEYS=5;
  static int adc_key_val[5] ={  
    30, 150, 360, 535, 760     };
  int k, input;
  input=analogRead(0);
  for (k = 0; k < NUM_KEYS; k++)
  {
    if (input < adc_key_val[k])
    {
      return k;
    }
  }
  if (k >= NUM_KEYS)
    k = -1;     // No valid key pressed
  return k;
}