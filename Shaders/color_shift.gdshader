shader_type canvas_item;

uniform float time_scale = 1.0;
uniform vec4 color: source_color;

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	float color_shift = sin(TIME * time_scale) * 0.5 + 0.5;
	vec3 final_output = mix(texture_color.rgb, color.rgb, color_shift);
	COLOR.rgb = final_output;
}
