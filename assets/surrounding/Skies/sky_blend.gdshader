shader_type sky;

// target are two panoramas (night and sunrise sky) which will be blended
uniform sampler2D sky_a : source_color, filter_linear;
uniform sampler2D sky_b : source_color, filter_linear;

// A=0.0, B=1.0, add up to 1, 
uniform float blend : hint_range(0.0, 1.0) = 0.0;
uniform float energy = 1.0;

void sky() {
	vec3 a = texture(sky_a, SKY_COORDS).rgb;
	vec3 b = texture(sky_b, SKY_COORDS).rgb;
	
	//mix and change brightness
	COLOR = mix(a, b, blend) * energy;
}