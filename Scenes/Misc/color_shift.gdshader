shader_type canvas_item;

uniform float time_scale = 1.0;
uniform vec4 color: source_color;

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	vec4 final_output = texture_color;
	
	float color_shift = sin(TIME * time_scale) * 0.5 + 0.5;
	
	final_output.rgb = mix(texture_color.rgb, color.rgb, color_shift);
	
	COLOR.rgb = final_output.rgb;
}
