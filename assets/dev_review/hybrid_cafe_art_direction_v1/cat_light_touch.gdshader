shader_type spatial;
render_mode unshaded, blend_mix, depth_prepass_alpha, cull_disabled;
uniform sampler2D cat_paint : source_color, filter_linear, repeat_disable;
uniform float key_facing = .5;
void vertex(){
 vec3 right=normalize(INV_VIEW_MATRIX[0].xyz);vec3 up=vec3(0.0,1.0,0.0);vec3 forward=normalize(cross(right,up));
 mat4 aligned=mat4(vec4(right*length(MODEL_MATRIX[0].xyz),0.0),vec4(up*length(MODEL_MATRIX[1].xyz),0.0),vec4(forward*length(MODEL_MATRIX[2].xyz),0.0),MODEL_MATRIX[3]);
 MODELVIEW_MATRIX=VIEW_MATRIX*aligned;
}
void fragment(){
 vec4 painted=texture(cat_paint,UV);float response=.98+.025*key_facing;
 ALBEDO=painted.rgb*vec3(response,response*.998,response*.994);ALPHA=painted.a;
}
