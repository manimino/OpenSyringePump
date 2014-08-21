// Controls a stepper motor via an LCD keypad shield.

#include <LCD4Bit_mod.h> 
#include <AccelStepper.h>

/* -- Constants -- */
#define SYRINGE_VOLUME_ML 30.0
#define SYRINGE_BARREL_LENGTH_MM 80.0

#define THREADED_ROD_PITCH 1.25
#define STEPS_PER_REVOLUTION 200.0
#define MICROSTEPS_PER_STEP 16.0

long ustepsPerMM = MICROSTEPS_PER_STEP * STEPS_PER_REVOLUTION / THREADED_ROD_PITCH;
long ustepsPerML = (MICROSTEPS_PER_STEP * STEPS_PER_REVOLUTION * SYRINGE_BARREL_LENGTH_MM) / (SYRINGE_VOLUME_ML * THREADED_ROD_PITCH );

/* -- Pin definitions -- */
int motorDirPin = 2;
int motorStepPin = 3;
int triggerPin = A3;

//Key states
//int  adc_key_val[5] ={30, 150, 360, 535, 760 };
int  adc_key_val[5] ={50, 180, 400, 575, 800 };


enum{ KEY_RIGHT, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_SELECT, KEY_NONE};
int NUM_KEYS = 5;
int adc_key_in;
int key=-1;
int oldkey=-1;

//various enums
enum{PUSH,PULL}; //syringe movement direction
enum{MAIN, BOLUS_MENU}; //UI states

const int mLBolusStepsLength = 9;
float mLBolusSteps[9] = {0.001, 0.005, 0.010, 0.050, 0.100, 0.500, 1.000, 5.000, 10.000};

/* -- Default Parameters -- */
int motorSpeed = 4000; //maximum steps per second
int motorAccel = 80000; //steps/second/second to accelerate

float mLBolus = 0.1;
float mLUsed = 0.0;
int mLBolusStepIdx = 3; //0.05 mL increments at first
float mLBolusStep = mLBolusSteps[mLBolusStepIdx];

long stepperPos = 0; //in microsteps
char charBuf[16];

//debounce params
int lastTick = 0;
int debounceTime = 50;

//menu stuff
int uiState = MAIN;

//triggering
int prevTrigger = LOW;

/* -- Initialize libraries -- */
AccelStepper stepper(1, motorStepPin, motorDirPin); //the "1" tells it we are using a driver
LCD4Bit_mod lcd = LCD4Bit_mod(2); 

void setup(){
  /* LCD setup */  
  lcd.init();
  lcd.clear();

  lcd.printIn("SyringePump v0.1");
  lastTick = millis();

  /* Stepper setup */
  stepper.setMaxSpeed(motorSpeed);
  stepper.setSpeed(motorSpeed);
  stepper.setAcceleration(motorAccel);
  
  /* Triggering setup */
  pinMode(triggerPin, INPUT);
}

void loop(){
  //update stepper position
  stepper.run();

  //check for LCD updates
  readKey();
  
  //look for trigger on trigger line
  checkTrigger();
}


void checkTrigger(){
    int triggerValue = digitalRead(triggerPin);
    if(triggerValue == HIGH && prevTrigger == LOW){
      bolus(PUSH);
    }
    prevTrigger = triggerValue;
}

void bolus(int direction){
	//change units to steps
	long steps;
	if(direction == PUSH){
		steps = mLBolus * ustepsPerML;
		mLUsed += mLBolus;
	}
	else if(direction == PULL){
		steps = -mLBolus * ustepsPerML;
		if((mLUsed-mLBolus) > 0){
			mLUsed -= mLBolus;
		}
		else{
			mLUsed = 0;
		}
	}	
	stepperPos += steps;
	stepper.moveTo(stepperPos);
}

void readKey(){
	//don't poll too often
	long currentTime = millis();
	if ((currentTime-lastTick) < debounceTime){
		return;
	}
	
	lastTick = currentTime;
	adc_key_in = analogRead(0);
	key = get_key(adc_key_in); // convert into key press

	if (key != oldkey){
	if (oldkey == KEY_NONE || key == KEY_NONE){
			oldkey = key;
			doKeyAction(key);
		}
		else{
			//wait for there to be a KEY_NONE before accepting a new key.
			oldkey = key;
		}
	}  
}

void doKeyAction(unsigned int key){
	if(key == KEY_NONE){
        return;
    }

	if(key == KEY_SELECT){
		if(uiState == MAIN){
			uiState = BOLUS_MENU;
		}
		else if(BOLUS_MENU){
			uiState = MAIN;
		}
	}

	String s1; //upper line
	String s2; //lower line
	
	if(uiState == MAIN){
		if(key == KEY_LEFT){
			s2 = (String("Pull ") + decToString(mLBolus) + String(" mL"));
			bolus(PULL);
		}
		if(key == KEY_RIGHT){
			s2 = (String("Push ") + decToString(mLBolus) + String(" mL"));
			bolus(PUSH);
		}
		if(key == KEY_UP){
			mLBolus += mLBolusStep;
		}
		if(key == KEY_DOWN){
			if((mLBolus - mLBolusStep) > 0){
			  mLBolus -= mLBolusStep;
			}
			else{
			  mLBolus = 0;
			}
		}
		s1 = String("Used ") + decToString(mLUsed) + String(" mL");
		s2 = (String("Bolus ") + decToString(mLBolus) + String(" mL"));		
	}
	else if(uiState == BOLUS_MENU){
		if(key == KEY_LEFT){
			//nothin'
		}
		if(key == KEY_RIGHT){
			//nothin'
		}
		if(key == KEY_UP){
			if(mLBolusStepIdx < mLBolusStepsLength-1){
				mLBolusStepIdx++;
				mLBolusStep = mLBolusSteps[mLBolusStepIdx];
			}
		}
		if(key == KEY_DOWN){
			if(mLBolusStepIdx > 0){
				mLBolusStepIdx -= 1;
				mLBolusStep = mLBolusSteps[mLBolusStepIdx];
			}
		}
		s1 = String("Menu> BolusStep");
		s2 = decToString(mLBolusStep);
	}

	//update screen
	lcd.clear();

	s2.toCharArray(charBuf, 16);
	lcd.cursorTo(2, 0);  //line=2, x=0
	lcd.printIn(charBuf);
	
	s1.toCharArray(charBuf, 16);
	lcd.cursorTo(1, 0);  //line=1, x=0
	lcd.printIn(charBuf);
		
	
	//debugging - write character ADC
	/*
        lcd.cursorTo(1, 0);  //line=2, x=0
	String s = String("KEY_ADC: ") + String(adc_key_in);
	s.toCharArray(charBuf, 16);
	lcd.printIn(charBuf);  //line=2, x=0
        */	
}


// Convert ADC value to key number
int get_key(unsigned int input){
  int k;
  for (k = 0; k < NUM_KEYS; k++){
    if (input < adc_key_val[k]){
      return k;
    }
  }
  if (k >= NUM_KEYS){
    k = KEY_NONE;     // No valid key pressed
  }
  return k;
}

String decToString(float decNumber){
	//not a general use converter! Just good for the numbers we're working with here.
	int wholePart = decNumber; //truncate
	int decPart = round(abs(decNumber*1000)-abs(wholePart*1000)); //3 decimal places
        String strZeros = String("");
        if(decPart < 10){
          strZeros = String("00");
        }  
        else if(decPart < 100){
          strZeros = String("0");
        }
	return String(wholePart) + String('.') + strZeros + String(decPart);
}