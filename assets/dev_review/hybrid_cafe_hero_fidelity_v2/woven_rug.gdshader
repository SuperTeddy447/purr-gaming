shader_type spatial;
render_mode diffuse_lambert_wrap, specular_disabled;
void fragment(){
 float edge=min(min(UV.x,1.0-UV.x),min(UV.y,1.0-UV.y));
 float border=1.0-smoothstep(.072,.095,edge);
 float pair=smoothstep(.12,.123,edge)*(1.0-smoothstep(.129,.132,edge));
 float brush=(sin(UV.x*8.0+sin(UV.y*4.0))*.013+sin(UV.y*18.0)*.006);
 ALBEDO=mix(vec3(.66,.56,.40),vec3(.22,.30,.16),border)+brush+pair*vec3(.045,.055,.021);
 ROUGHNESS=.99;SPECULAR=0.0;
}
