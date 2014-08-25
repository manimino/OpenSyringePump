include <syringePumpConstants.scad>

/* === Model-specific Constants === */

//cube containing rods and syringe barrel stop
mountXSize = 10;
mountZSize = syringeCenterHeight;


/* === Model === */

//main cube, holds the two axes
difference(){
	cube(size=[mountXSize,baseSizeY,mountZSize]);
	
	
	//bore hole for threaded rod
	translate([-floatCorrection,centerY,threadedAxisHeight]){
		rotate(a=[0,90,0]){
			cylinder(h=mountXSize+floatCorrection2, r=smoothRodRadius+0.5);
		}
	}

	//hole for smooth rod (needs to fit fairly tight)
	translate([-floatCorrection,centerY,smoothAxisHeight]){
		rotate(a=[0,90,0]){
			cylinder(h=mountXSize+floatCorrection2, r=smoothRodRadius);
		}
	}
	
	//hole for syringe barrel stopper
	translate([-floatCorrection,centerY,syringeCenterHeight]){
		rotate(a=[0,90,0]){
			cylinder(h=mountXSize+floatCorrection2, r=5.2);
		}
	}
}

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