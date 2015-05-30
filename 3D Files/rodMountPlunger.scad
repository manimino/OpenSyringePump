include <syringePumpConstants.scad>

/* === Model-specific Constants === */

//add some clearance, we don't want this against the 8020 rails
spaceAboveFloor = 2;

//plunger
plungerDiameter = 26.5;
plungerThickness = 2.2;
plungerInnerDiameter = 15;
plungerClipThickness = 3;
plungerWellDepth = plungerThickness + plungerClipThickness;

//trap nut
nutAcross = 13.2;
nutDepth = 6.5;
nutWellDepth = nutDepth + 0.05; //tight so it won't rattle
nutWallThicknessFront = plungerWellDepth+3;
nutWallThicknessBack = 4;

nutSlotSizeX = nutWallThicknessFront;
nutSlotSizeY = nutAcross;
nutSlotSizeZ = nutAcross/2;

//linear bearing 
LM8UU_dia = 15.4;
LM8UU_length = 24;

//cube containing nut, linear bearing, and plunger
mountXSize = nutWellDepth + nutWallThicknessFront + nutWallThicknessBack;
mountZSize = syringeCenterHeight + plungerDiameter/2 + 3;

/* === Model === */

//main cube, holds the two axes
difference(){
	translate([0,0,spaceAboveFloor]){
		cube(size=[mountXSize,baseSizeY,mountZSize]);
	}

	//nut
	translate([-floatCorrection+nutWallThicknessFront,centerY,threadedAxisHeight]){
		rotate(a=[0,90,0]){
			nutWell();
		}
		//nut insertion slot
		translate([0,0,nutAcross/sqrt(3)]){
			rotate(a=[0,90,0]){
				nutWell();
			}
		}
		translate([nutWellDepth,0,nutAcross/sqrt(3)]){
			rotate(a=[0,90,0]){
				nutWell();
			}
		}
	}

	
	//bore hole for threaded rod
	translate([-floatCorrection,centerY,threadedAxisHeight]){
		rotate(a=[0,90,0]){
			cylinder(h=mountXSize+floatCorrection2, r=smoothRodRadius);
		}
	}

	//hole for LM8UU
	translate([-floatCorrection,centerY,smoothAxisHeight]){
		rotate(a=[0,90,0]){
			bearingLM8UU();
		}
	}

	//U-shaped hole for syringe plunger to go in
	translate([plungerClipThickness,centerY,syringeCenterHeight]){
		rotate(a=[0,90,0]){
			cylinder(h=plungerThickness, r=plungerDiameter/2);
		}	
		translate([0,-plungerDiameter/2,0]){
			cube(size=[plungerThickness,plungerDiameter,mountZSize]);
		}
	}	
	translate([-floatCorrection,centerY,syringeCenterHeight]){
		rotate(a=[0,90,0]){
			cylinder(h=plungerClipThickness+floatCorrection2, r=plungerInnerDiameter/2);
		}	
		translate([0,-plungerInnerDiameter/2,0]){
			cube(size=[plungerClipThickness+floatCorrection2,plungerInnerDiameter,mountZSize]);
		}
	}	
	
	
	//remove excess volume from sides
	translate([-floatCorrection,centerY+plungerDiameter/2 + 4,0]){
		cube(size=[mountXSize + floatCorrection2, baseSizeY, mountZSize+spaceAboveFloor]);
	}	
	cube(size=[mountXSize + floatCorrection2, centerY-plungerDiameter/2-4, mountZSize+spaceAboveFloor]);
}




module nutWell(){
	//compose the outline of the 6-sided nut using 3 cubes. Yay geometry.
	nutEdgeLength = nutAcross / (sqrt(3));
	
	translate([-nutEdgeLength/2, -nutAcross/2, 0]){
		cube(size=[nutEdgeLength,nutAcross,nutWellDepth+floatCorrection2]);
	}

		rotate(a=[0,0,60]){
			translate([-nutEdgeLength/2, -nutAcross/2, 0]){
				cube(size=[nutEdgeLength,nutAcross,nutWellDepth+floatCorrection2]);
			}
		}
	
		rotate(a=[0,0,-60]){
			translate([-nutEdgeLength/2, -nutAcross/2, 0]){
				cube(size=[nutEdgeLength,nutAcross,nutWellDepth+floatCorrection2]);
			}
		}
}

module bearingLM8UU(){
	cylinder(h=LM8UU_length, r=LM8UU_dia/2);
}
