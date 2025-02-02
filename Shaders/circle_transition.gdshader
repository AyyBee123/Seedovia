shader_type canvas_item;

uniform float circle_size : hint_range(0,1) = 0.5f;
uniform float circle_position_x : hint_range(0,1) = 0.5f;
uniform float circle_position_y : hint_range(0,1) = 0.5f;

void fragment(){
	if (distance(vec2(circle_position_x,circle_position_y), UV) < circle_size){
		COLOR.a = 0.0f;
	}
}