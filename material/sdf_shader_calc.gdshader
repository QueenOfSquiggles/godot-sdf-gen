shader_type canvas_item;

uniform int kernel_size = 4;

void fragment(){
	float f_kernel = float(kernel_size);
	
	float outside_density = 0.5;
	float inside_density = 0.5;
	float min_dist = f_kernel;
	// normal pass
	for (int x = -kernel_size; x <= kernel_size; x++){
		for (int y = -kernel_size; y <= kernel_size; y++){
			vec2 pos = vec2(float(x), float(y));
			vec2 local_uv = UV + (pos * TEXTURE_PIXEL_SIZE);
			float local = texture(TEXTURE, local_uv).r;
			if (local <= 0.01){
				// black found
				min_dist = min(min_dist, length(pos));
			}
		}
	}
	outside_density = 1.0 - (min_dist / f_kernel);
	outside_density = (outside_density) * 0.5;
	// inverted pass
	min_dist = f_kernel;
	for (int x = -kernel_size; x <= kernel_size; x++){
		for (int y = -kernel_size; y <= kernel_size; y++){
			vec2 pos = vec2(float(x), float(y));
			vec2 local_uv = UV + (pos * TEXTURE_PIXEL_SIZE);
			float local = 1.0 - texture(TEXTURE, local_uv).r;
			if (local <= 0.01){
				// black found
				min_dist = min(min_dist, length(pos));
			}
		}
	}
	inside_density = (min_dist / f_kernel);
	inside_density = (inside_density) * 0.5;
	// compositing
	float final = (outside_density) + (inside_density);
	COLOR = vec4(vec3(final), 1.0);
}