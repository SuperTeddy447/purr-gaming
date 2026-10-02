extends SceneTree
func _initialize():run.call_deferred()
func run():
 var manifest:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/dev_review/hybrid_cafe_painted_surface_v1/material_manifest.json"));var checks:Dictionary={}
 for name in manifest.material_map.values():
  var m=load("res://assets/dev_review/hybrid_cafe_painted_surface_v1/materials/"+name+".tres")
  checks[name+"_typed_material"]=m is ShaderMaterial;checks[name+"_painted_texture"]=m.get_shader_parameter("painted_albedo") is Texture2D;checks[name+"_matte_nonmetal"]=m.get_shader_parameter("material_roughness")>=.8
 for name in manifest.texture_crops:
  var tex=load("res://"+manifest.texture_crops[name].runtime_path);checks[name+"_512_crop"]=tex.get_width()==512 and tex.get_height()==512
 var f=FileAccess.open(OS.get_cmdline_user_args()[0],FileAccess.WRITE);f.store_string(JSON.stringify({"passed":checks.values().all(func(v):return v),"count":checks.size(),"checks":checks},"\t"));f.close();quit(0 if checks.values().all(func(v):return v) else 1)
