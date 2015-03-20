/*
  LCDKeypad.h
*/

// ensure this library description is only included once
#ifndef LCDKeypad_h
#define LCDKeypad_h

// library interface description
#define KEYPAD_NONE -1
#define KEYPAD_RIGHT 0
#define KEYPAD_UP 1
#define KEYPAD_DOWN 2
#define KEYPAD_LEFT 3
#define KEYPAD_SELECT 4

class LCDKeypad: public LiquidCrystal
{
  public:
    LCDKeypad();
    int button();
};

#endif

