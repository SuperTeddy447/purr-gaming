shader_type spatial;
render_mode specular_disabled;
uniform sampler2D surface_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 painted_color : source_color = vec4(1.0);
uniform vec4 texture_crop = vec4(0.0, 0.0, 1.0, 1.0);
uniform vec2 grain_scale = vec2(1.0);
uniform float texture_strength = 0.3;
void fragment() {
 vec3 ink = texture(surface_texture, texture_crop.xy + fract(UV * grain_scale) * texture_crop.zw).rgb;
 float grain = dot(ink, vec3(0.299, 0.587, 0.114));
 ALBEDO = painted_color.rgb * COLOR.rgb * mix(1.0, 0.60 + grain * 0.80, texture_strength);
 ROUGHNESS = 0.95;
 METALLIC = 0.0;
 SPECULAR = 0.0;
}
