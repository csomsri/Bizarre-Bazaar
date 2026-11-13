shader_type spatial;
render_mode unshaded;

uniform sampler2D mirror_txt : filter_linear;
uniform float bulge = 0.25;
uniform float vignette = 0.6;

void fragment() {
	vec2 c = UV - 0.5;
	float r = length(c) * 2.0;

	if (r > 1.0) {
		discard;
	}

	vec2 d = c * (1.0 + bulge * r * r);
	vec2 uv = d + 0.5;
	uv.x = 1.0 - uv.x;

	vec3 col = texture(mirror_txt, uv).rgb;
	col *= 1.0 - vignette * r * r;
	ALBEDO = col;
}