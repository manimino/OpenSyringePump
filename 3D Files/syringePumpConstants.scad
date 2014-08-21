
/* === Project-universal Constants === */

//Not all of these variables are used in this specific model,
//but the same variable set is used across all models in this project.

$fs = 0.1;

inch = 25.4; //for mm conversion

//width of base
baseSizeY = 2*inch;
centerY = baseSizeY / 2; //both axes go right down the middle of the base

//stepper motor
stepperZSize = 42;
stepperYSize = 42;

//608 bearing 
bearing608Height = 8.5;
bearing608Diameter = 22.5;

//height of holder for 80/20 screws
mountPlateHeight = 5;

//axis heights
threadedAxisHeight = stepperZSize/2 + mountPlateHeight + 4;
smoothAxisHeight = (threadedAxisHeight-6.6) / 2;
smoothRodRadius = 4.2;

//syringe properties
barrelDiameter = 25;

barrelSlotThickness = 3;
barrelSlotHeight = 28;

syringeCenterHeight = threadedAxisHeight + bearing608Diameter/2 + 4 + barrelDiameter/2;

//fixes render oddities
floatCorrection = 0.001; 
floatCorrection2 = 2*floatCorrection; 

//8020 mounting plate
screwPlateSize = 25;	
screwRadius = 3.5;
