include <syringePumpConstants.scad>

nema_17_mount();

module nema_17_mount()
{
	wall_thickness = 5;
	motor_width = 42;
	frame_width = motor_width + (wall_thickness + 1)*2;
	bolt = 4;
	height = 25;

	inch = 25.4;
	screwPlateSize = 25;	
	screwRadius = 3.25;
	
	//these are all the mount point holes.
	x1 = -wall_thickness;
	y1 = wall_thickness*2;
	x2 = frame_width+wall_thickness;
	y2 = wall_thickness*2;
	x3 = -wall_thickness;
	y3 = frame_width-wall_thickness*2;
	x4 = frame_width + wall_thickness;
	y4 = frame_width-wall_thickness*2;
	
	//center the whole thing in X
	translate([-frame_width/2, 0, 0])
	{

		//floor, with mounting holes for 80/20
			
		translate([0,-screwPlateSize,-wall_thickness]){
			difference(){
				cube(size=[frame_width,frame_width+screwPlateSize,wall_thickness]);
				
				translate([frame_width/2-inch/2, screwPlateSize/2, 0]){
					cylinder(h=wall_thickness, r=screwRadius);
				}
				translate([frame_width/2+inch/2, screwPlateSize/2, 0]){
					cylinder(h=wall_thickness, r=screwRadius);
				}

			}
		}

		difference()
		{
			//build the main unit.
			union()
			{
				//structure
				cube([wall_thickness, frame_width, frame_width]); //front face
				cube([frame_width, wall_thickness, frame_width]); //left face
				translate([frame_width-wall_thickness, 0, 0])     //right face
					cube([wall_thickness, frame_width, frame_width]);

			}


			//front left mount hole
			echo(x1, y1);
			translate([x1, y1, 0])
			{
				cylinder(r=bolt/2, h=wall_thickness);
				translate([0,0,wall_thickness])
					cylinder(r=bolt, h=wall_thickness*2);
			}
			
			//front right mount hole
			echo(x2, y2);
			translate([x2, y2, 0])
			{
				cylinder(r=bolt/2, h=wall_thickness);
				translate([0,0,wall_thickness])
					cylinder(r=bolt, h=wall_thickness*2);			
			}
			
			//rear left mount hole
			echo(x3, y3);
			translate([x3, y3, 0])
			{
				cylinder(r=bolt/2, h=wall_thickness);
				translate([0,0,wall_thickness])
					cylinder(r=bolt, h=wall_thickness*2);
			}
			
			//rear right mount hole
			echo(x4, y4);
			translate([x4, y4, 0])
			{
				cylinder(r=bolt/2, h=wall_thickness);
				translate([0,0,wall_thickness])
					cylinder(r=bolt, h=wall_thickness*2);
			}
			
			//mount hole slits
			translate([frame_width + wall_thickness*1.5, frame_width-wall_thickness*2, wall_thickness/2])
				cube(size=[wall_thickness, 0.1, wall_thickness*3], center=true);
			translate([frame_width + wall_thickness*1.5, wall_thickness*2, wall_thickness/2])
				cube(size=[wall_thickness, 0.1, wall_thickness*3], center=true);
			translate([-wall_thickness*1.5, frame_width-wall_thickness*2, wall_thickness/2])
				cube(size=[wall_thickness, 0.1, wall_thickness*3], center=true);
			translate([-wall_thickness*1.5, wall_thickness*2, wall_thickness/2])
				cube(size=[wall_thickness, 0.1, wall_thickness*3], center=true);

			//nema 17 mount
			rotate([90, 0, 0])
			{
				translate([frame_width/2+0.5, height, -wall_thickness])
				{
					translate([15.5, 15.5, 0])
						cylinder(r=bolt/2, h=wall_thickness+1);
					translate([-15.5, 15.5, 0])
						cylinder(r=bolt/2, h=wall_thickness+1);
					translate([15.5, -15.5, 0])
						cylinder(r=bolt/2, h=wall_thickness+1);
					translate([-15.5, -15.5, 0])
						cylinder(r=bolt/2, h=wall_thickness+1);

					cylinder(r=11.5, h=wall_thickness+1);

					translate([-11.5, 0, 0])
						cube([23, frame_width, wall_thickness+1]);
				}
			}

			//back slant cutaway
			translate([0, 0, frame_width+wall_thickness])
				rotate([45, 0, 0])
					translate([-frame_width, 0, -frame_width*2])
						cube(size=[frame_width*4, frame_width*2, frame_width*4]);

			//front anti-warp circle
			translate([frame_width/2, wall_thickness*1.25, 0])
				rotate([90, 0, 0])
					cylinder(r=wall_thickness, h=wall_thickness*2);

			//middle anti-warp circle			
			translate([0, motor_width/2 + wall_thickness, 0])
				rotate([0, 90, 0])
					cylinder(r=wall_thickness, h=frame_width+1);

			//cutout / tidy up cubes.
			translate([wall_thickness, wall_thickness-0.1, -1])
				cube([frame_width-wall_thickness*2, frame_width-wall_thickness, motor_width*2]);
			translate([-frame_width/2,-frame_width/2, wall_thickness+motor_width])
				cube([frame_width*2, frame_width*2, frame_width]);
			translate([-frame_width/2, -frame_width/2,-frame_width])
				cube([frame_width*2, frame_width*2, frame_width]);
		}
	}
}
