shader_type spatial;
render_mode diffuse_burley, cull_disabled;
uniform sampler2D painted_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 palette_color : source_color = vec4(1.0);
uniform vec3 source_mean = vec3(.4);
uniform float paint_strength = .8;
uniform vec2 paint_scale = vec2(.7);
uniform float material_roughness = .95;
uniform float restrained_specular = .03;
uniform float edge_warmth = .04;
uniform float cavity_strength = .20;
uniform bool foliage_pigment = false;
uniform vec4 pigment_dark : source_color = vec4(.24,.34,.22,1.0);
uniform vec4 pigment_light : source_color = vec4(.54,.61,.41,1.0);
varying vec2 phase_offset;
varying vec3 form_normal;
uniform bool cedar_surface = false;
void vertex(){
 form_normal=NORMAL;
 vec3 p=MODEL_MATRIX[3].xyz;
 phase_offset=vec2(fract(dot(p.xz,vec2(.173,.119))),fract(dot(p.xz,vec2(.137,.227))));
}
void fragment(){
 // Mirror-repeat sampling keeps crop boundaries continuous without claiming a generated tile is seamless.
 vec2 oriented_uv=UV;
 if(cedar_surface && abs(form_normal.y)>.6){oriented_uv=UV.yx;}
 vec2 uv=1.0-abs(fract((oriented_uv*paint_scale+phase_offset)*.5)*2.0-1.0);
 vec3 paint=texture(painted_albedo,uv).rgb;
 vec3 variation=clamp(paint/max(source_mean,vec3(.001)),vec3(.58),vec3(1.56));
 vec3 pigment=palette_color.rgb;
 if(foliage_pigment){pigment=COLOR.g<.5?mix(pigment_dark.rgb,palette_color.rgb,COLOR.g*2.0):mix(palette_color.rgb,pigment_light.rgb,(COLOR.g-.5)*2.0);}
 vec3 albedo=pigment*mix(vec3(1.0),variation,paint_strength);
 float cavity=clamp((1.0-COLOR.r)*1.7,0.0,.28);
 // Screen-space normal-change proxy: subtle form edge tint, not a signed curvature bake.
 float exposed=clamp(length(dFdx(NORMAL))+length(dFdy(NORMAL)),0.0,1.0);
 albedo*=1.0-cavity*cavity_strength;
 albedo*=mix(.84,1.16,COLOR.b); // Authored low-frequency per-part pigment, not texture noise.
 albedo+=pigment*exposed*edge_warmth*vec3(1.0,.66,.29);
 ALBEDO=albedo;ROUGHNESS=material_roughness;SPECULAR=restrained_specular;METALLIC=0.0;
 AO=clamp(COLOR.r,.78,1.0);AO_LIGHT_AFFECT=.27;
}
