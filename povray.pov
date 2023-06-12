#include "textures.inc"
#include "Woods.inc"
#include "colors.inc"
#include "shapes.inc"
#include "textures.inc"
#fopen data_moon "l_moon.txt" read
#fopen data_sun "l_sun.txt" read
#fopen data_attitude "attitude_equ.txt" read
#fopen data_equ "r_equ.txt" read
#read(data_moon, moon_x, moon_y, moon_z)
#read(data_sun, sun_x, sun_y, sun_z)
#read(data_attitude, att_x, att_y, att_z)
#read(data_equ, r_x, r_y, r_z)
#declare L_moon = <moon_x,moon_y,moon_z>;
#declare L_sun = <sun_x, sun_y, sun_z>;
#declare Att_equ = <att_x, att_y, att_z>;
#declare L_equ = <r_x, r_y, r_z>;

global_settings{
    ambient_light <0, 0, 0> // <red, green, blue}
}

camera{ 
	location L_equ
	
	look_at L_equ + <3.0359, 1.1581, 0.8022>

	look_at L_equ + Att_equ
	// look_at <0,0,0>

    angle 7
    right -x*image_width/image_height 
} 
light_source { 
	L_sun
	color rgb <1,1,1>
    parallel
} 
object { 
	sphere {<0 , 0 , 0> , 1737.4} 
	
	texture { 
		pigment { rgb <1 , 1 , 1> } 
	} 

    translate L_moon // <x, y, z>

}
object { 
	sphere {<0 , 0 , 0> , 6378.1} 
	
	texture { 
		pigment { rgb <1 , 1 , 1> } 
	} 

} 
