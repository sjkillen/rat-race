shader_type spatial;

uniform sampler2D normals;
uniform sampler2D shark_mask : source_color;

const float FLOAT_EPSILON = .3;

instance uniform vec3 teeth_tint : source_color;
instance uniform vec3 tongue_tint : source_color;
instance uniform vec3 eye_white_tint : source_color;
instance uniform vec3 eye_pupil_tint : source_color = vec3(1.0, 1.0, 1.0);
instance uniform vec3 skin_back_tint : source_color;
instance uniform vec3 skin_belly_tint : source_color;
instance uniform vec3 mouth_tint : source_color;// ffb5a9

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 mask = texture(shark_mask, UV).rgb;
	
	NORMAL_MAP = texture(normals, UV).rgb;;
	NORMAL_MAP_DEPTH = 1.0;
	float teeth_mask = float(distance(mask, vec3(0.0, 1.0, 0.0)) < FLOAT_EPSILON);
	float tongue_mask = float(distance(mask, vec3(1.0, 0.0, 0.0)) < FLOAT_EPSILON);
	float eye_mask = float(mask.r==0.0) * mask.b;
	float eye_pupil_mask = float(distance(mask, vec3(0.0, 1.0, 1.0)) < FLOAT_EPSILON);
	float mouth_mask = float(distance(COLOR.rgb, vec3(0.0, 0.0, 1.0)) > FLOAT_EPSILON);
	float mouth_falloff = 1.0 - COLOR.r;
	float skin_mask = float((teeth_mask + tongue_mask + eye_mask + mouth_mask) == 0.0);
	
	ALBEDO = (teeth_mask * teeth_tint)
	       + (tongue_mask * tongue_tint * mouth_falloff) 
		   + ((eye_mask-eye_pupil_mask) * eye_white_tint)
		   + (eye_mask*eye_pupil_mask * eye_pupil_tint)
		   + mouth_mask * mouth_tint * mouth_falloff
		   + (skin_mask * mix(skin_back_tint, skin_belly_tint, mask.r));
	
	ROUGHNESS = 0.0;
	METALLIC = .1;
	CLEARCOAT = 1.0;
	CLEARCOAT_ROUGHNESS = 0.0;
	//SPECULAR = 1.0;
}
