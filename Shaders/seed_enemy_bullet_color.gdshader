shader_type canvas_item;

uniform vec4 og_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 new_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 fore_color : source_color = vec4(1.0, 0.894, 0.894, 1.0);

void fragment() {
	vec4 curr_color = texture(TEXTURE, UV);

    // Define a threshold for the comparison
	uvec4 uint_curr_color = uvec4(round(curr_color * 255.0));
	uvec4 uint_og_color = uvec4(round(og_color * 255.0));
	if (uint_curr_color == uint_og_color){
		COLOR = new_color;
	}
	else{
		COLOR = fore_color;
		COLOR.a = curr_color.a;
	}
	
}