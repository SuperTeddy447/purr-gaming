shader_type spatial;
render_mode diffuse_burley, specular_disabled;
uniform sampler2D painted_texture: source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 color_tint: source_color = vec4(1.0);
uniform float tex_scale = 1.0;
uniform float roughness_value = 0.96;
varying vec3 local_position;
varying vec3 local_normal;
void vertex(){ local_position=VERTEX; local_normal=NORMAL; }
void fragment(){
 vec3 w=pow(abs(normalize(local_normal)),vec3(5.0)); w/=max(w.x+w.y+w.z,0.0001);
 vec3 p=local_position*tex_scale;
 vec3 c=texture(painted_texture,p.zy).rgb*w.x + texture(painted_texture,p.xz).rgb*w.y + texture(painted_texture,p.xy).rgb*w.z;
 ALBEDO=c*color_tint.rgb*COLOR.rgb; ROUGHNESS=roughness_value; SPECULAR=0.0;
}
