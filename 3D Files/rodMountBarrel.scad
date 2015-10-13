include <syringePumpConstants.scad>

/* === Model-specific Constants === */

//cube containing rods and syringe barrel stop
mountXSize = 20;
mountZSize = syringeCenterHeight;

//slot parameters
plungerDiameter = 26.5;
barrelSlotThickness = 2.5;
barrelSlotOffset = mountXSize/2 - barrelSlotThickness/2;
barrelSlotHeight = 36;

/* === Model === */

//main cube, holds the two axes
difference(){
	cube(size=[mountXSize,baseSizeY,mountZSize]);

	//608 bearing for threaded rod
	translate([-floatCorrection,centerY,threadedAxisHeight]){
		rotate(a=[0,90,0]){
			nutWell();
		}
	}
	
	//bore hole for threaded rod
	translate([-floatCorrection,centerY,threadedAxisHeight]){
		rotate(a=[0,90,0]){
			cylinder(h=mountXSize+floatCorrection2, r=smoothRodRadius);
		}
	}

	//hole for smooth rod (needs to fit fairly tight)
	translate([-floatCorrection,centerY,smoothAxisHeight]){
		rotate(a=[0,90,0]){
			cylinder(h=mountXSize+floatCorrection2, r=smoothRodRadius);
		}
	}

	//hole for syringe barrel top to go in
	translate([barrelSlotOffset,centerY,syringeCenterHeight]){
		translate([0,-baseSizeY/2,-barrelSlotHeight/2]){
			cube(size=[barrelSlotThickness, baseSizeY, barrelSlotHeight]);
		}
	}	
	translate([-floatCorrection,centerY,syringeCenterHeight]){
		rotate(a=[0,90,0]){
			cylinder(h=mountXSize+floatCorrection2, r=plungerDiameter/2);
		}	
		translate([0,-plungerInnerDiameter/2,0]){
			cube(size=[barrelSlotThickness+floatCorrection2,plungerInnerDiameter,mountZSize]);
		}
	}	
	
}

// 80/20 screw plate
difference(){
	translate([-screwPlateSize,0,0]){
		cube(size=[screwPlateSize,baseSizeY,mountPlateHeight]);
	}

	translate([-screwPlateSize/2,baseSizeY/4,0]){
		cylinder(h=mountPlateHeight, r=screwRadius);
	}
	translate([-screwPlateSize/2,3*baseSizeY/4,0]){
		cylinder(h=mountPlateHeight, r=screwRadius);
	}

}

module bearing608(){
	cylinder(h=bearing608Height, r=bearing608Diameter/2);	
}