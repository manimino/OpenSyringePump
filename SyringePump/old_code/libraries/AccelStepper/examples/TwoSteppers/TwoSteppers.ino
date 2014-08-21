//This is an example of how you would control 2 steppers at the same time

#include <AccelStepper.h>

int motorSpeed = 9600; //maximum steps per second (about 3rps / at 16 microsteps)
int motorAccel = 80000; //steps/second/second to accelerate

int motor1DirPin = 2; //digital pin 2
int motor1StepPin = 3; //digital pin 3

int motor2DirPin = 4; //digital pin 4
int motor2StepPin = 5; //digital pin 5

//set up the accelStepper intances
//the "1" tells it we are using a driver
AccelStepper stepper1(1, motor1StepPin, motor1DirPin);
AccelStepper stepper2(1, motor2StepPin, motor2DirPin);


void setup(){
  stepper1.setMaxSpeed(motorSpeed);
  stepper2.setMaxSpeed(motorSpeed);

  stepper1.setSpeed(motorSpeed);
  stepper2.setSpeed(motorSpeed);

  stepper1.setAcceleration(motorAccel);
  stepper2.setAcceleration(motorAccel);
  
  stepper1.moveTo(32000); //move 32000 steps (should be 10 rev)
  stepper2.moveTo(15000); //move 15000 steps
}

void loop(){
  
  //if stepper1 is at desired location
  if (stepper1.distanceToGo() == 0){
    //go the other way the same amount of steps
    //so if current position is 400 steps out, go position -400
    stepper1.moveTo(-stepper1.currentPosition()); 
  }
  
  //if stepper2 is at desired location
  if (stepper2.distanceToGo() == 0){
    //go the other way the same amount of steps
    //so if current position is 400 steps out, go position -400
    stepper2.moveTo(-stepper2.currentPosition()); 
  }	

  
  //these must be called as often as possible to ensure smooth operation
  //any delay will cause jerky motion
  stepper1.run();
  stepper2.run();
}