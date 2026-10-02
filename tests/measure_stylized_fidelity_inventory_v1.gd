extends SceneTree
func _initialize():run.call_deferred()
func run():
 var app=load("res://scenes/dev/stylized_fidelity/stylized_cafe_micro_diorama_v1.tscn").instantiate();app.auto_hero=false;root.add_child(app)
 while not app.ready_for_review:await process_frame
 var rows:Array=[];var casters:=0
 for n in app.geometry.find_children("*","GeometryInstance3D",true,false):
  var cast:bool=n.cast_shadow!=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  if cast:casters+=1
  rows.append({"path":str(app.geometry.get_path_to(n)),"class":n.get_class(),"cast_shadow":cast})
 var f:=FileAccess.open(OS.get_cmdline_user_args()[0],FileAccess.WRITE);f.store_string(JSON.stringify({"geometry_instances":rows,"shadow_casters":casters,"label3d_count":app.geometry.find_children("*","Label3D",true,false).size(),"custom_shader_resource":"res://scripts/dev/stylized_fidelity/painted_albedo.gdshader","custom_shader_resources":1,"authored_piece_count":app.authored_piece_count,"batched_mesh_count":app.geometry.find_children("*","MeshInstance3D",true,false).size(),"triangles":app.batched_triangle_count,"live_subviewport_count":app.find_children("*","SubViewport",true,false).size()},"\t"));f.close();print("GEOMETRY SHADOW CASTERS ",casters);quit()
