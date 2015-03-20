#include <LiquidCrystal.h>
#include <LCDKeypad.h>

#define MINVAL 1
#define MAXVAL 1000

LCDKeypad lcd;

byte c_up[8] = {
  B00100,
  B01110,
  B10101,
  B00100,
  B00100,
  B00100,
  B00100,
  B00100,
};

byte c_down[8] = {
  B00100,
  B00100,
  B00100,
  B00100,
  B00100,
  B10101,
  B01110,
  B00100,
};

byte c_select[8] = {
  B00000,
  B01110,
  B11111,
  B11111,
  B11111,
  B11111,
  B01110,
  B00000,
};

void setup()
{
  int i,k;

  lcd.createChar(1,c_select);
  lcd.createChar(2,c_up);
  lcd.createChar(3,c_down);
  lcd.begin(16, 2);
  lcd.clear();
  lcd.print("     Guess");
  lcd.setCursor(0,1);
  lcd.print("   The Number");
  delay(3000);
  for (k=0;k<3;k++)
  {
    lcd.scrollDisplayLeft();
    delay(200);
  }
  for (i=0;i<3;i++)
  {
    for (k=0;k<6;k++)
    {
      lcd.scrollDisplayRight();
      delay(200);
    }
    for (k=0;k<6;k++)
    {
      lcd.scrollDisplayLeft();
      delay(200);
    }
  }
  for (k=0;k<16;k++)
  {
    lcd.scrollDisplayLeft();
    delay(200);
  }
}

void loop()
{
  int bottom=MINVAL, top=MAXVAL;
  int trynumber=0;
  int guess, buttonPressed;

  lcd.clear();
  lcd.print("Make up a number");
  lcd.setCursor(0,1);
  lcd.print("from ");
  lcd.print(MINVAL,DEC);
  lcd.print(" to ");
  lcd.print(MAXVAL,DEC);
  lcd.print(" ");
  waitButton();
  waitReleaseButton();
  do
  {
    lcd.clear();
    guess=bottom+(top-bottom)/2;
    trynumber++;

    lcd.print("Is it ");
    lcd.print(guess,DEC);
    lcd.print("?");
    lcd.setCursor(0,1);
    lcd.write(1);
    lcd.write(' ');
    lcd.write(2);
    lcd.write(' ');
    lcd.write(3);
    lcd.write(' ');
    do
    {
      buttonPressed=waitButton();
    }
    while(!(buttonPressed==KEYPAD_SELECT || buttonPressed==KEYPAD_UP || buttonPressed==KEYPAD_DOWN));
    lcd.setCursor(0,1);
    lcd.write(buttonPressed==KEYPAD_SELECT?1:' ');
    lcd.write(' ');
    lcd.write(buttonPressed==KEYPAD_UP?2:' ');
    lcd.write(' ');
    lcd.write(buttonPressed==KEYPAD_DOWN?3:' ');
    delay(100);
    waitReleaseButton();
    if (buttonPressed==KEYPAD_UP)
    {
      bottom=constrain(guess+1,MINVAL,top);
    }
    else if (buttonPressed==KEYPAD_DOWN)
    {
      top=constrain(guess-1,bottom,MAXVAL);
    }
  }
  while (buttonPressed!=KEYPAD_SELECT && top!=bottom);
  lcd.clear();
  if (top==bottom)
  {
    lcd.print("It must be ");
    guess=top;
  }
  else
  {
    lcd.print("It is ");
  }
  lcd.print(guess,DEC);
  lcd.print("!");
  lcd.setCursor(0,1);
  lcd.print("Tries: ");
  lcd.print(trynumber,DEC);
  lcd.print(" ");
  waitButton();  
  waitReleaseButton();  
}

int waitButton()
{
  int buttonPressed; 
  waitReleaseButton;
  lcd.blink();
  while((buttonPressed=lcd.button())==KEYPAD_NONE)
  {
  }
  delay(50);  
  lcd.noBlink();
  return buttonPressed;
}

void waitReleaseButton()
{
  delay(50);
  while(lcd.button()!=KEYPAD_NONE)
  {
  }
  delay(50);
}


