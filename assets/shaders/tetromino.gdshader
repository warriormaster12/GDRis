shader_type spatial;

instance uniform vec4 albedo_color: source_color = vec4(1.0);
instance uniform float emissive_power: hint_range(0.0, 16.0, 0.1) = 0.0; 

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = albedo_color.rgb;
	EMISSION = albedo_color.rgb * emissive_power;
	ALPHA = albedo_color.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
