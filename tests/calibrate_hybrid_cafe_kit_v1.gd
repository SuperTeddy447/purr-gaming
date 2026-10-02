extends SceneTree
var checks:Dictionary={}
func check(v:bool,k:String):checks[k]=v;if not v:push_error(k)
func _initialize():run.call_deferred()
func run():
 var table=load("res://assets/dev_review/hybrid_cafe_kit_v1/calibration/WC_CAFE_Calibration_Table_A.glb").instantiate();root.add_child(table)
 var bounds:=AABB();var have:=false;var vertices:=0;var uv_count:=0;var normals:=0;var texture_surfaces:=0
 for n in table.find_children("*","MeshInstance3D",true,false):
  var b: AABB=n.global_transform*n.get_aabb();bounds=b if not have else bounds.merge(b);have=true
  for i in n.mesh.get_surface_count():
   var a:Array=n.mesh.surface_get_arrays(i);vertices+=a[Mesh.ARRAY_VERTEX].size();uv_count+=a[Mesh.ARRAY_TEX_UV].size();normals+=a[Mesh.ARRAY_NORMAL].size();var m=n.mesh.surface_get_material(i)
   if m is StandardMaterial3D and m.albedo_texture!=null:texture_surfaces+=1
 check(have,"GLB_instantiates_meshes");check(bounds.position.y>=-.02 and bounds.position.y<.02,"ground_origin");check(absf(bounds.size.y-.89)<.02,"meters_and_Y_up_height");check(absf(bounds.size.x-1.65)<.02 and absf(bounds.size.z-1.65)<.02,"orientation_width_depth");check(uv_count==vertices and vertices>0,"UV0_per_vertex");check(normals==vertices,"normals_per_vertex");check(texture_surfaces==7,"embedded_painted_material_mapping");check(table.find_children("*","CollisionObject3D",true,false).is_empty(),"no_automatic_gameplay_collision");check(table.transform==Transform3D.IDENTITY,"no_post_import_axis_correction")
 var cam:=Camera3D.new();root.add_child(cam);cam.projection=Camera3D.PROJECTION_ORTHOGONAL;cam.size=2.5;cam.position=Vector3(2,2.3,3);cam.look_at(Vector3(0,.35,0));cam.current=true
 var env:=WorldEnvironment.new();var e:=Environment.new();e.background_mode=Environment.BG_COLOR;e.background_color=Color("#EAE3D6");e.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;e.ambient_light_color=Color("#F4EEE3");e.ambient_light_energy=.55;env.environment=e;root.add_child(env)
 var light:=DirectionalLight3D.new();root.add_child(light);light.rotation_degrees=Vector3(-60,-30,0);light.light_energy=.65;light.shadow_enabled=true
 var ground:=MeshInstance3D.new();var plane:=PlaneMesh.new();plane.size=Vector2(3,3);ground.mesh=plane;var m:=StandardMaterial3D.new();m.albedo_color=Color("#E1CFB2");m.roughness=.95;ground.material_override=m;root.add_child(ground)
 await create_timer(1).timeout;await RenderingServer.frame_post_draw
 var out:String=OS.get_cmdline_user_args()[0];check(root.get_texture().get_image().save_png(out+"/calibration_godot.png")==OK,"runtime_render_capture")
 var f:=FileAccess.open(out+"/calibration_godot.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":checks.values().all(func(v):return v),"count":checks.size(),"checks":checks,"bounds":bounds,"vertices":vertices,"uv_vertices":uv_count,"normal_vertices":normals,"textured_surfaces":texture_surfaces,"numeric_check_tolerance":"0.02m DEV import sanity margin, not a world/production tolerance"},"\t"));f.close();print("BLENDER GODOT CALIBRATION ",checks);quit(0 if checks.values().all(func(v):return v) else 1)
