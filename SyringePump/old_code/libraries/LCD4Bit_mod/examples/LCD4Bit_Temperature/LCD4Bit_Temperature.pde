//example use of LCD4Bit_mod library

#include <LCD4Bit_mod.h> 
#include <stdio.h>

#define TEMP_PIN 3
//create object to control an LCD.  
//number of lines in display=1
LCD4Bit_mod lcd = LCD4Bit_mod(2); 

void getCurrentTemp(char *temp);

//Key message
int  adc_key_val[5] ={30, 150, 360, 535, 760 };
int NUM_KEYS = 5;
int adc_key_in;
int key=-1;
int oldkey=-1;

void setup() { 
  pinMode(13, OUTPUT);  //we'll use the debug LED to output a heartbeat

   // initialize DS18B20 datapin
    digitalWrite(TEMP_PIN, LOW);
    pinMode(TEMP_PIN, INPUT);      // sets the digital pin as input (logic 1)
  lcd.init();
  //optionally, now set up our application-specific display settings, overriding whatever the lcd did in lcd.init()
  //lcd.commandWrite(0x0F);//cursor on, display on, blink on.  (nasty!)
   lcd.clear();
  lcd.printIn("Temperature is");
    
}

void loop() {

  char temp_string[10];
  adc_key_in = analogRead(0);    // read the value from the sensor  
  key = get_key(adc_key_in);		        // convert into key press
	
 if (key != oldkey)				    // if keypress is detected
 {
    delay(50);		// wait for debounce time
    adc_key_in = analogRead(0);    // read the value from the sensor  
    key = get_key(adc_key_in);		        // convert into key press
    if (key != oldkey)				
    {			
      oldkey = key;
      getCurrentTemp(temp_string);
      lcd.cursorTo(2, 0);  //line=2, x=0
      lcd.printIn(temp_string);
    }
 }
 
  
  
}

// Convert ADC value to key number
int get_key(unsigned int input)
{
	int k;
    
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


void OneWireReset(int Pin) // reset.  Should improve to act as a presence pulse
{
     digitalWrite(Pin, LOW);
     pinMode(Pin, OUTPUT); // bring low for 500 us
     delayMicroseconds(500);
     pinMode(Pin, INPUT);
     delayMicroseconds(500);
}

void OneWireOutByte(int Pin, byte d) // output byte d (least sig bit first).
{
   byte n;

   for(n=8; n!=0; n--)
   {
      if ((d & 0x01) == 1)  // test least sig bit
      {
         digitalWrite(Pin, LOW);
         pinMode(Pin, OUTPUT);
         delayMicroseconds(5);
         pinMode(Pin, INPUT);
         delayMicroseconds(60);
      }
      else
      {
         digitalWrite(Pin, LOW);
         pinMode(Pin, OUTPUT);
         delayMicroseconds(60);
         pinMode(Pin, INPUT);
      }

      d=d>>1; // now the next bit is in the least sig bit position.
   }
   
}

byte OneWireInByte(int Pin) // read byte, least sig byte first
{
    byte d, n, b;

    for (n=0; n<8; n++)
    {
        digitalWrite(Pin, LOW);
        pinMode(Pin, OUTPUT);
        delayMicroseconds(5);
        pinMode(Pin, INPUT);
        delayMicroseconds(5);
        b = digitalRead(Pin);
        delayMicroseconds(50);
        d = (d >> 1) | (b<<7); // shift d to right and insert b in most sig bit position
    }
    return(d);
}


void getCurrentTemp(char *temp)
{  
  int HighByte, LowByte, TReading, Tc_100, sign, whole, fract;

  OneWireReset(TEMP_PIN);
  OneWireOutByte(TEMP_PIN, 0xcc);
  OneWireOutByte(TEMP_PIN, 0x44); // perform temperature conversion, strong pullup for one sec

  OneWireReset(TEMP_PIN);
  OneWireOutByte(TEMP_PIN, 0xcc);
  OneWireOutByte(TEMP_PIN, 0xbe);

  LowByte = OneWireInByte(TEMP_PIN);
  HighByte = OneWireInByte(TEMP_PIN);
  TReading = (HighByte << 8) + LowByte;
  sign = TReading & 0x8000;  // test most sig bit
  if (sign) // negative
  {
    TReading = (TReading ^ 0xffff) + 1; // 2's comp
  }
  Tc_100 = (6 * TReading) + TReading / 4;    // multiply by (100 * 0.0625) or 6.25

  whole = Tc_100 / 100;  // separate off the whole and fractional portions
  fract = Tc_100 % 100;

/*
	if(sign) temp[0]='-';
	else 		 temp[0]='+';
	
	temp[1]= whole%100+'0';
	temp[2]= (whole-100*temp[1])%10 +'0' ;
	temp[3]= whole-100*temp[1]-10*temp[2] +'0';
	
	temp[4]='.';
	temp[5]=fract%10 +'0';
	temp[6]=fract-temp[5]*10 +'0';
	
	temp[7] = '\0';
*/

	sprintf(temp, "%c%3d%c%2d", (sign==0)?'+':'-', whole, '.', fract);
	
}	
	
	
	
