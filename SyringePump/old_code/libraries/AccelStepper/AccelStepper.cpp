// AccelStepper.cpp
//
// Copyright (C) 2009 Mike McCauley
// $Id: AccelStepper.cpp,v 1.5 2012/01/28 22:45:25 mikem Exp mikem $

#include "AccelStepper.h"

void AccelStepper::moveTo(long absolute)
{
    _targetPos = absolute;
    computeNewSpeed();
}

void AccelStepper::move(long relative)
{
    moveTo(_currentPos + relative);
}

// Implements steps according to the current speed
// You must call this at least once per step
// returns true if a step occurred
boolean AccelStepper::runSpeed()
{
    // Dont do anything unless we actually have a speed
    if (_speed == 0.0f)
	return false;

    unsigned long time = micros();
    // Gymnastics to detect wrapping of either the nextStepTime and/or the current time
    unsigned long nextStepTime = _lastStepTime + _stepInterval;
    if (   ((nextStepTime >= _lastStepTime) && ((time >= nextStepTime) || (time < _lastStepTime)))
	|| ((nextStepTime < _lastStepTime) && ((time >= nextStepTime) && (time < _lastStepTime))))

    {
	if (_speed > 0.0f)
	{
	    // Clockwise
	    _currentPos += 1;
	}
	else if (_speed < 0.0f)
	{
	    // Anticlockwise  
	    _currentPos -= 1;
	}
	step(_currentPos & 0x7); // Bottom 3 bits (same as mod 8, but works with + and - numbers) 

	_lastStepTime = time;
	return true;
    }
    else
    {
	return false;
    }
}

long AccelStepper::distanceToGo()
{
    return _targetPos - _currentPos;
}

long AccelStepper::targetPosition()
{
    return _targetPos;
}

long AccelStepper::currentPosition()
{
    return _currentPos;
}

// Useful during initialisations or after initial positioning
void AccelStepper::setCurrentPosition(long position)
{
    _targetPos = _currentPos = position;
    computeNewSpeed(); // Expect speed of 0
}

void AccelStepper::computeNewSpeed()
{
    setSpeed(desiredSpeed());
}

// Work out and return a new speed.
// Subclasses can override if they want
// Implement acceleration, deceleration and max speed
// Negative speed is anticlockwise
// This is called:
//  after each step
//  after user changes:
//   maxSpeed
//   acceleration
//   target position (relative or absolute)
float AccelStepper::desiredSpeed()
{
    float requiredSpeed;
    long distanceTo = distanceToGo(); // +ve is clockwise from curent location

    if (distanceTo == 0)
	return 0.0f; // We're there

    // sqrSpeed is the signed square of _speed.
    float sqrSpeed = sq(_speed);
    if (_speed < 0.0)
      sqrSpeed = -sqrSpeed;
    float twoa = 2.0f * _acceleration; // 2ag
    // if v^^2/2as is the the left of target, we will arrive at 0 speed too far -ve, need to accelerate clockwise
    if ((sqrSpeed / twoa) < distanceTo)
    {
	// Accelerate clockwise
	// Need to accelerate in clockwise direction
	if (_speed == 0.0f)
	    requiredSpeed = sqrt(twoa);
	else
	    requiredSpeed = _speed + fabs(_acceleration / _speed);
	if (requiredSpeed > _maxSpeed)
	    requiredSpeed = _maxSpeed;
    }
    else
    {
	// Decelerate clockwise, accelerate anticlockwise
	// Need to accelerate in clockwise direction
	if (_speed == 0.0f)
	    requiredSpeed = -sqrt(twoa);
	else
	    requiredSpeed = _speed - fabs(_acceleration / _speed);
	if (requiredSpeed < -_maxSpeed)
	    requiredSpeed = -_maxSpeed;
    }
    
//    Serial.println(requiredSpeed);
    return requiredSpeed;
}

// Run the motor to implement speed and acceleration in order to proceed to the target position
// You must call this at least once per step, preferably in your main loop
// If the motor is in the desired position, the cost is very small
// returns true if we are still running to position
boolean AccelStepper::run()
{
    if (_targetPos == _currentPos)
	return false;
    
    if (runSpeed())
	computeNewSpeed();
    return true;
}

AccelStepper::AccelStepper(uint8_t pins, uint8_t pin1, uint8_t pin2, uint8_t pin3, uint8_t pin4)
{
    _pins = pins;
    _currentPos = 0;
    _targetPos = 0;
    _speed = 0.0;
    _maxSpeed = 1.0;
    _acceleration = 1.0;
    _stepInterval = 0;
    _minPulseWidth = 1;
    _dirInverted = false;
    _stepInverted = false;
    _enablePin = 0xff;
    _lastStepTime = 0;
    _pin1 = pin1;
    _pin2 = pin2;
    _pin3 = pin3;
    _pin4 = pin4;
//_stepInterval = 20000;
//_speed = 50.0;
//_lastRunTime = 0xffffffff - 20000;
//_lastStepTime = 0xffffffff - 20000 - 10000;
    enableOutputs();
}

AccelStepper::AccelStepper(void (*forward)(), void (*backward)())
{
    _pins = 0;
    _currentPos = 0;
    _targetPos = 0;
    _speed = 0.0;
    _maxSpeed = 1.0;
    _acceleration = 1.0;
    _stepInterval = 0;
    _minPulseWidth = 1;
    _dirInverted = false;
    _stepInverted = false;
    _enablePin = 0xff;
    _lastStepTime = 0;
    _pin1 = 0;
    _pin2 = 0;
    _pin3 = 0;
    _pin4 = 0;
    _forward = forward;
    _backward = backward;
}

void AccelStepper::setMaxSpeed(float speed)
{
    _maxSpeed = speed;
    computeNewSpeed();
}

void AccelStepper::setAcceleration(float acceleration)
{
    _acceleration = acceleration;
    computeNewSpeed();
}

void AccelStepper::setSpeed(float speed)
{
    if (speed == _speed)
        return;

    if ((speed > 0.0f) && (speed > _maxSpeed))
        _speed = _maxSpeed;
    else if ((speed < 0.0f) && (speed < -_maxSpeed))
        _speed = -_maxSpeed;
    else
        _speed = speed;
    _stepInterval = fabs(1000000.0 / _speed);
}

float AccelStepper::speed()
{
    return _speed;
}

// Subclasses can override
void AccelStepper::step(uint8_t step)
{
    switch (_pins)
    {
        case 0:
            step0();
            break;
	case 1:
	    step1(step);
	    break;
    
	case 2:
	    step2(step);
	    break;
    
	case 4:
	    step4(step);
	    break;  

	case 8:
	    step8(step);
	    break;  
    }
}

// 0 pin step function (ie for functional usage)
void AccelStepper::step0()
{
  if (_speed > 0)
    _forward();
  else
    _backward();
}

// 1 pin step function (ie for stepper drivers)
// This is passed the current step number (0 to 7)
// Subclasses can override
void AccelStepper::step1(uint8_t step)
{
    digitalWrite(_pin2, (_speed > 0) ^ _dirInverted); // Direction
    // Caution 200ns setup time 
    digitalWrite(_pin1, HIGH ^ _stepInverted);
    // Delay the minimum allowed pulse width
    delayMicroseconds(_minPulseWidth);
    digitalWrite(_pin1, LOW ^ _stepInverted);
}

// 2 pin step function
// This is passed the current step number (0 to 7)
// Subclasses can override
void AccelStepper::step2(uint8_t step)
{
    switch (step & 0x3)
    {
	case 0: /* 01 */
	    digitalWrite(_pin1, LOW);
	    digitalWrite(_pin2, HIGH);
	    break;

	case 1: /* 11 */
	    digitalWrite(_pin1, HIGH);
	    digitalWrite(_pin2, HIGH);
	    break;

	case 2: /* 10 */
	    digitalWrite(_pin1, HIGH);
	    digitalWrite(_pin2, LOW);
	    break;

	case 3: /* 00 */
	    digitalWrite(_pin1, LOW);
	    digitalWrite(_pin2, LOW);
	    break;
    }
}

// 4 pin step function for half stepper
// This is passed the current step number (0 to 7)
// Subclasses can override
void AccelStepper::step4(uint8_t step)
{
    switch (step & 0x3)
    {
	case 0:    // 1010
	    digitalWrite(_pin1, HIGH);
	    digitalWrite(_pin2, LOW);
	    digitalWrite(_pin3, HIGH);
	    digitalWrite(_pin4, LOW);
	    break;

	case 1:    // 0110
	    digitalWrite(_pin1, LOW);
	    digitalWrite(_pin2, HIGH);
	    digitalWrite(_pin3, HIGH);
	    digitalWrite(_pin4, LOW);
	    break;

	case 2:    //0101
	    digitalWrite(_pin1, LOW);
	    digitalWrite(_pin2, HIGH);
	    digitalWrite(_pin3, LOW);
	    digitalWrite(_pin4, HIGH);
	    break;

	case 3:    //1001
	    digitalWrite(_pin1, HIGH);
	    digitalWrite(_pin2, LOW);
	    digitalWrite(_pin3, LOW);
	    digitalWrite(_pin4, HIGH);
	    break;
    }
}


// 4 pin step function
// This is passed the current step number (0 to 7)
// Subclasses can override
void AccelStepper::step8(uint8_t step)
{
    switch (step & 0x7)
    {
	case 0:    // 1000
            digitalWrite(_pin1, HIGH);
            digitalWrite(_pin2, LOW);
            digitalWrite(_pin3, LOW);
            digitalWrite(_pin4, LOW);
            break;
	    
        case 1:    // 1010
            digitalWrite(_pin1, HIGH);
            digitalWrite(_pin2, LOW);
            digitalWrite(_pin3, HIGH);
            digitalWrite(_pin4, LOW);
            break;
	    
	case 2:    // 0010
            digitalWrite(_pin1, LOW);
            digitalWrite(_pin2, LOW);
            digitalWrite(_pin3, HIGH);
            digitalWrite(_pin4, LOW);
            break;
	    
        case 3:    // 0110
            digitalWrite(_pin1, LOW);
            digitalWrite(_pin2, HIGH);
            digitalWrite(_pin3, HIGH);
            digitalWrite(_pin4, LOW);
            break;
	    
	case 4:    // 0100
            digitalWrite(_pin1, LOW);
            digitalWrite(_pin2, HIGH);
            digitalWrite(_pin3, LOW);
            digitalWrite(_pin4, LOW);
            break;
	    
        case 5:    //0101
            digitalWrite(_pin1, LOW);
            digitalWrite(_pin2, HIGH);
            digitalWrite(_pin3, LOW);
            digitalWrite(_pin4, HIGH);
            break;
	    
	case 6:    // 0001
            digitalWrite(_pin1, LOW);
            digitalWrite(_pin2, LOW);
            digitalWrite(_pin3, LOW);
            digitalWrite(_pin4, HIGH);
            break;
	    
        case 7:    //1001
            digitalWrite(_pin1, HIGH);
            digitalWrite(_pin2, LOW);
            digitalWrite(_pin3, LOW);
            digitalWrite(_pin4, HIGH);
            break;
    }
}
    
// Prevents power consumption on the outputs
void    AccelStepper::disableOutputs()
{   
    if (! _pins) return;

    if (_pins == 1)
    {
        // Invert only applies for stepper drivers.
        digitalWrite(_pin1, LOW ^ _stepInverted);
        digitalWrite(_pin2, LOW ^ _dirInverted);
    }
    else
    {
        digitalWrite(_pin1, LOW);
        digitalWrite(_pin2, LOW);
    }
    
	if (_pins == 4 || _pins == 8)
    {
        digitalWrite(_pin3, LOW);
        digitalWrite(_pin4, LOW);
    }

    if (_enablePin != 0xff)
    {
        digitalWrite(_enablePin, LOW ^ _enableInverted);
    }
}

void    AccelStepper::enableOutputs()
{
    if (! _pins) 
	return;

    pinMode(_pin1, OUTPUT);
    pinMode(_pin2, OUTPUT);
    if (_pins == 4 || _pins == 8)
    {
        pinMode(_pin3, OUTPUT);
        pinMode(_pin4, OUTPUT);
    }

	if (_enablePin != 0xff)
    {
        pinMode(_enablePin, OUTPUT);
        digitalWrite(_enablePin, HIGH ^ _enableInverted);
    }
}

void AccelStepper::setMinPulseWidth(unsigned int minWidth)
{
    _minPulseWidth = minWidth;
}

void AccelStepper::setEnablePin(uint8_t enablePin)
{
    _enablePin = enablePin;

    // This happens after construction, so init pin now.
    if (_enablePin != 0xff)
    {
        pinMode(_enablePin, OUTPUT);
        digitalWrite(_enablePin, HIGH ^ _enableInverted);
    }
}

void AccelStepper::setPinsInverted(bool direction, bool step, bool enable)
{
    _dirInverted    = direction;
    _stepInverted   = step;
    _enableInverted = enable;
}


// Blocks until the target position is reached
void AccelStepper::runToPosition()
{
    while (run())
	;
}

boolean AccelStepper::runSpeedToPosition()
{
    if (_targetPos >_currentPos)
	_speed = fabs(_speed);
    else
	_speed = -fabs(_speed);
    return _targetPos!=_currentPos ? runSpeed() : false;
}

// Blocks until the new target position is reached
void AccelStepper::runToNewPosition(long position)
{
    moveTo(position);
    runToPosition();
}
