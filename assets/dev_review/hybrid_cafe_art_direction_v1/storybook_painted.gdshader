shader_type spatial;
render_mode diffuse_lambert_wrap, specular_disabled, cull_back;
uniform sampler2D painted_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 painted_tint : source_color = vec4(1.0);
uniform float grain_contrast = 0.78;
uniform float broad_variation = 0.045;
uniform float saturation = 0.91;
uniform float texture_softness = 1.4;
uniform float material_roughness = 0.96;
varying vec3 asset_position;
float hash(vec3 p) { return fract(sin(dot(p,vec3(12.9898,78.233,37.719)))*43758.5453); }
float paint(vec3 p) {
 vec3 i=floor(p);vec3 f=fract(p);f=f*f*(3.0-2.0*f);
 return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x),f.y),f.z);
}
void vertex() { asset_position=VERTEX; }
void fragment() {
 vec3 texture_color=textureLod(painted_albedo,UV,texture_softness).rgb;
 vec3 quiet=textureLod(painted_albedo,UV,5.0).rgb;
 vec3 surface=mix(quiet,texture_color,grain_contrast)*painted_tint.rgb;
 float luminance=dot(surface,vec3(.299,.587,.114));surface=mix(vec3(luminance),surface,saturation);
 float brush=(paint(asset_position*3.3)-.5)*broad_variation;
 ALBEDO=surface*(1.0+brush);
 ROUGHNESS=material_roughness;METALLIC=0.0;SPECULAR=0.0;
 AO=COLOR.r;AO_LIGHT_AFFECT=.25;
}
