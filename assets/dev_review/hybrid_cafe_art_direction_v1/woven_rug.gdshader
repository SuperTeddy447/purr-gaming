shader_type spatial;
render_mode diffuse_lambert_wrap, specular_disabled;
uniform sampler2D fabric : source_color, filter_linear_mipmap, repeat_enable;
void fragment(){
 float edge=min(min(UV.x,1.0-UV.x),min(UV.y,1.0-UV.y));
 vec3 cream=vec3(.66,.55,.38);vec3 sage=vec3(.13,.20,.115);
 float border=1.0-smoothstep(.075,.095,edge);
 float stitch=(sin(UV.x*350.0)*sin(UV.y*320.0))*.014;
 float fine_line=smoothstep(.108,.112,edge)*(1.0-smoothstep(.117,.121,edge));
 ALBEDO=mix(cream,sage,border)+stitch+fine_line*vec3(.065,.055,.029);
 ROUGHNESS=.99;SPECULAR=0.0;
}
