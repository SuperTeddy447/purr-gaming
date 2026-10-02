shader_type spatial;
render_mode diffuse_burley, cull_back;
uniform vec4 river_deep : source_color = vec4(.23,.43,.46,1.0);
uniform vec4 river_shallow : source_color = vec4(.32,.59,.60,1.0);
uniform float current_speed = .12;
void fragment(){
 vec2 p=UV*vec2(3.1,17.0);
 float broad=.5+.5*sin(p.y*.72+sin(p.x*1.8)*.6-TIME*current_speed);
 float strokes=smoothstep(.92,1.0,.5+.5*sin(p.y*3.2+sin(p.x*2.0)*.8-TIME*current_speed*1.3))*.014;
 ALBEDO=mix(river_deep.rgb,river_shallow.rgb,broad)+strokes;
 ROUGHNESS=.94;SPECULAR=.025;METALLIC=0.0;
}
