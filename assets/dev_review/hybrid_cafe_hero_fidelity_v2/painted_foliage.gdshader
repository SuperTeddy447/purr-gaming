shader_type spatial;
render_mode diffuse_lambert_wrap, cull_disabled;
uniform sampler2D painted_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 palette_color : source_color = vec4(1.0);
uniform float reference_luma = 0.3;
uniform float texture_strength = 0.22;
uniform float painted_field_strength = 0.025;
uniform float edge_warmth = 0.02;
uniform float material_roughness = 0.94;
uniform float restrained_specular = 0.0;
uniform float texture_softness = 1.8;
uniform bool use_vertex_pigment = false;
uniform vec4 pigment_dark : source_color = vec4(0.25,0.36,0.23,1.0);
uniform vec4 pigment_light : source_color = vec4(0.55,0.62,0.38,1.0);
varying vec3 local_form_normal;
void vertex(){local_form_normal=NORMAL;}
void fragment(){
 vec3 t=textureLod(painted_albedo,UV,texture_softness).rgb;
 float value=clamp(dot(t,vec3(.2126,.7152,.0722))/max(reference_luma,0.001),.72,1.32);
 // Two broad, gently uneven brush fields: no per-pixel noise, normals or grunge.
 float field=sin(UV.x*6.1+sin(UV.y*2.6)*.7)*.55+sin(UV.y*7.4+UV.x*1.8)*.45;
 float relief=clamp(local_form_normal.y,0.0,1.0)*edge_warmth;
 vec3 pigment=palette_color.rgb;
 if(use_vertex_pigment){pigment=COLOR.g<.5?mix(pigment_dark.rgb,palette_color.rgb,COLOR.g*2.0):mix(palette_color.rgb,pigment_light.rgb,(COLOR.g-.5)*2.0);}
 ALBEDO=pigment*(1.0+(value-1.0)*texture_strength+field*painted_field_strength);
 ALBEDO+=pigment*relief*vec3(1.0,.72,.38);
 ROUGHNESS=material_roughness;SPECULAR=restrained_specular;METALLIC=0.0;
 AO=clamp(COLOR.r,.78,1.0);AO_LIGHT_AFFECT=.20;
}
