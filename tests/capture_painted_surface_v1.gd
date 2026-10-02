extends SceneTree
var app
var out:String
var checks:Dictionary={}
var frozen_camera:Transform3D
var frozen_size:float
var frozen_groups:Dictionary={}
var frozen_lighting:Dictionary={}
var frozen_placements:Array=[]
var frozen_roles:Array=[]
var frozen_geometry:String
func lighting(x)->Dictionary:return {"key_color":x.key_light.light_color,"key_energy":x.key_light.light_energy,"key_transform":x.key_light.transform,"shadow_opacity":x.key_light.shadow_opacity,"blur":x.key_light.shadow_blur,"ambient_color":x.environment.environment.ambient_light_color,"ambient_energy":x.environment.environment.ambient_light_energy,"practical_color":x.practical.light_color,"practical_energy":x.practical.light_energy,"practical_range":x.practical.omni_range,"shadow_bias":x.key_light.shadow_bias,"normal_bias":x.key_light.shadow_normal_bias}
var frames:=0
var recording:=false
var pending:=false
var clock:=0.0
var times:Array=[]
func _initialize():out=OS.get_cmdline_user_args()[0];DirAccess.make_dir_recursive_absolute(out+"/diagnostics");DirAccess.make_dir_recursive_absolute(out+"/frames");run.call_deferred()
func check(v:bool,k:String):checks[k]=v;if not v:push_error(k)
func save(path:String,value):var f=FileAccess.open(out+"/"+path,FileAccess.WRITE);f.store_string(JSON.stringify(value,"\t",true,true));f.close()
func shot(path:String):await RenderingServer.frame_post_draw;check(root.get_texture().get_image().save_png(out+"/"+path)==OK,"capture_"+path)
func _process(delta:float)->bool:
 if recording:
  clock+=delta
  if clock>=.10 and not pending:clock=0;pending=true;movie.call_deferred()
 return false
func movie():
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(out+"/frames/%05d.png"%frames);times.append(Time.get_ticks_msec());frames+=1;pending=false
func navigate(p:Vector2)->bool:
 var marker:=Marker2D.new();marker.position=p;app.slice.add_child(marker);var accepted:bool=app.actor.navigate_to_marker(marker)
 for i in 1800:
  await physics_frame
  if app.actor.phase==HardeningActor.Phase.IDLE:break
 var okay:bool=accepted and not app.actor.failed_navigation and app.actor.phase==HardeningActor.Phase.IDLE;marker.queue_free();return okay
func asset_validation():
 var manifest:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/dev_review/hybrid_cafe_hero_replacement_v1/kit_manifest.json"))
 for row in manifest.assets:
  var a=load("res://"+row.godot_prefab).instantiate();root.add_child(a)
  var bounds:=AABB();var have:=false;var uv:=true;var coverage:=true;var normals:=true;var mapped:=true;var tris:=0
  for n in a.find_children("*","MeshInstance3D",true,false):
   var b:AABB=n.global_transform*n.get_aabb();bounds=b if not have else bounds.merge(b);have=true;tris+=n.mesh.get_faces().size()/3
   for i in n.mesh.get_surface_count():
    var arrays:Array=n.mesh.surface_get_arrays(i);uv=uv and arrays[Mesh.ARRAY_TEX_UV].size()==arrays[Mesh.ARRAY_VERTEX].size();normals=normals and arrays[Mesh.ARRAY_NORMAL].size()==arrays[Mesh.ARRAY_VERTEX].size()
    for normal in arrays[Mesh.ARRAY_NORMAL]:normals=normals and normal.is_finite() and normal.length_squared()>0
    mapped=mapped and n.get_surface_override_material(i)!=null
    var mat=n.get_surface_override_material(i)
    if mat and ((mat is BaseMaterial3D and mat.albedo_texture) or (mat is ShaderMaterial and mat.get_shader_parameter("painted_albedo"))):
     var lo:=Vector2(INF,INF);var hi:=Vector2(-INF,-INF)
     for t in arrays[Mesh.ARRAY_TEX_UV]:lo=lo.min(t);hi=hi.max(t)
     coverage=coverage and hi.x>lo.x and hi.y>lo.y
  var id:String=row.asset_id
  check(have,id+"_import_mesh");check(uv,id+"_UV0");check(coverage,id+"_noncollapsed_painted_UV0");check(normals,id+"_valid_normals");check(mapped,id+"_shared_material_mapping");check(a.transform==Transform3D.IDENTITY,id+"_semantic_root_identity");check(a.find_children("*","CollisionObject3D",true,false).is_empty(),id+"_collision_separation")
  var p=row.measured_aabb_godot.position;var s=row.measured_aabb_godot.size
  check(bounds.position.is_equal_approx(Vector3(p[0],p[1],p[2])) and bounds.size.is_equal_approx(Vector3(s[0],s[1],s[2])),id+"_Blender_Godot_bounds_parity")
  check(tris==row.triangles_evaluated,id+"_triangle_parity")
  a.queue_free();await process_frame
func checkpoint(label:String):capture_checkpoint.call_deferred(label)
func capture_checkpoint(label:String):
 var name="diagnostics/depth_"+label+".png"
 if label=="counter_back":name="diagnostics/cat_behind_counter.png"
 if label=="counter_front":name="diagnostics/cat_front_counter.png"
 await shot(name)
func isolate(label:String,target:Node3D):
 app.source_sprite.pause();app.cat.pause();app.contact.visible=false
 app.cat.visible=false;target.visible=false;await shot("diagnostics/"+label+"_background.png")
 app.cat.visible=true;await shot("diagnostics/"+label+"_cat_only.png")
 app.cat.visible=false;target.visible=true;await shot("diagnostics/"+label+"_object_only.png")
 app.cat.visible=true;await shot("diagnostics/"+label+"_combined.png")
 app.contact.visible=true;app.source_sprite.play()
func paired_asset_closeups(prefix:String):
 var original:Transform3D=app.camera.transform;var size:float=app.camera.size
 for row in [{"label":"counter","at":Vector3(4.4,4.5,7.1),"target":Vector3(3.3,.85,1.72),"size":4.3},{"label":"espresso","at":Vector3(4.2,3.6,6.2),"target":Vector3(3.5,1.43,1.69),"size":2.8},{"label":"chair","at":Vector3(4.5,5.3,10.0),"target":Vector3(1.8,.65,4.99),"size":3.6},{"label":"window","at":Vector3(3.2,3.4,5.6),"target":Vector3(.92,1.3,.27),"size":2.75},{"label":"plants","at":Vector3(4.1,4.6,9),"target":Vector3(1.5,.7,6.14),"size":2.65}]:
  app.camera.position=row.at;app.camera.look_at(row.target);app.camera.size=row.size;await shot("diagnostics/"+prefix+"_"+row.label+".png")
 app.camera.transform=original;app.camera.size=size
func geometry_identity(x)->String:
 var h:=HashingContext.new();h.start(HashingContext.HASH_SHA256)
 for n in x.geometry.find_children("*","MeshInstance3D",true,false):
  if not n.is_visible_in_tree():continue
  h.update(var_to_bytes(n.global_transform));h.update(var_to_bytes(n.mesh.get_surface_count()))
  for i in n.mesh.get_surface_count():
   var arrays:Array=n.mesh.surface_get_arrays(i)
   for index in [Mesh.ARRAY_VERTEX,Mesh.ARRAY_NORMAL,Mesh.ARRAY_TANGENT,Mesh.ARRAY_TEX_UV,Mesh.ARRAY_INDEX]:h.update(var_to_bytes(arrays[index]))
 return h.finish().hex_encode()
func apply_lighting(x,l:Dictionary):
 x.key_light.light_color=l.key_color;x.key_light.light_energy=l.key_energy;x.key_light.transform=l.key_transform;x.key_light.shadow_opacity=l.shadow_opacity;x.key_light.shadow_blur=l.blur;x.key_light.shadow_bias=l.shadow_bias;x.key_light.shadow_normal_bias=l.normal_bias
 x.environment.environment.ambient_light_color=l.ambient_color;x.environment.environment.ambient_light_energy=l.ambient_energy;x.practical.light_color=l.practical_color;x.practical.light_energy=l.practical_energy;x.practical.omni_range=l.practical_range
func run():
 DisplayServer.window_move_to_foreground()
 var before=load("res://scenes/dev/hybrid_cafe_hero_replacement/hybrid_cafe_hero_replacement_v1.tscn").instantiate();root.add_child(before)
 for i in 400:
  await process_frame
  if before.ready_for_review:break
 app=before;check(before.ready_for_review,"v2_ready_for_same_camera_comparison")
 check(await navigate(Vector2(325,300)),"v2_hero_approach");check(await navigate(Vector2(325,355)),"v2_hero_root")
 frozen_camera=before.camera.transform;frozen_size=before.camera.size
 for id in before.groups:frozen_groups[id]=before.groups[id].transform
 before.get_node("DiagnosticControls").visible=false;await shot("01_CURRENT_SURFACE_BASELINE.png")
 save("diagnostics/common_camera.json",{"v2_transform":frozen_camera,"v2_size":frozen_size,"projection":before.camera.projection,"keep_aspect":before.camera.keep_aspect,"actor":before.actor.global_position,"groups":frozen_groups})
 await paired_asset_closeups("before")
 frozen_lighting=lighting(before)
 frozen_geometry=geometry_identity(before)
 frozen_placements=before.placements.duplicate(true)
 for r in before.organic_roles:frozen_roles.append({"role":r.role,"local_position":r.local_position,"unit_scale":r.unit_scale})
 before.queue_free();for i in 20:await process_frame
 await asset_validation()
 app=load("res://scenes/dev/hybrid_cafe_painted_surface/hybrid_cafe_painted_surface_v1.tscn").instantiate();root.add_child(app)
 for i in 300:
  await process_frame
  if app.ready_for_review:break
 check(app.camera.transform==frozen_camera and app.camera.size==frozen_size,"exact_common_V2_camera_unchanged")
 check(app.camera.projection==Camera3D.PROJECTION_ORTHOGONAL and app.camera.keep_aspect==Camera3D.KEEP_WIDTH,"same_orthographic_projection_policy")
 for id in frozen_groups:check(app.groups[id].transform==frozen_groups[id],"unchanged_V2_visual_registration_"+String(id))
 var roles:Array=app.organic_roles.map(func(x):return x.role)
 for role in ["floor_lance","trailing","shelf_fan","flowering"]:check(roles.has(role),"authored_organic_role_"+role)
 var vertex_count:=0;var all_finite:=true
 for n in app.geometry.find_children("*","MeshInstance3D",true,false):
  for i in n.mesh.get_surface_count():
   for v in n.mesh.surface_get_arrays(i)[Mesh.ARRAY_VERTEX]:vertex_count+=1;all_finite=all_finite and v.is_finite()
 check(vertex_count>0 and all_finite,"actual_imported_geometry_vertices_finite")
 check(app.placements==frozen_placements,"every_V2_asset_call_transform_and_instance_count_unchanged")
 var current_roles:Array=[]
 for r in app.organic_roles:current_roles.append({"role":r.role,"local_position":r.local_position,"unit_scale":r.unit_scale})
 check(current_roles==frozen_roles,"all_seven_V2_plant_role_placements_unchanged")
 check(app.organic_roles.size()==7 and app.organic_roles.all(func(r):return r.source=="editable_blender_GLB"),"seven_existing_plant_instances_replaced_by_Blender_sources")
 check(app.ready_for_review,"slice_ready");check(app.slice.authority()==app.baseline_authority,"authority_initial")
 check(app.cat.sprite_frames==app.source_sprite.sprite_frames,"exact_canonical_orange_spriteframes");check(not app.cat.no_depth_test,"actual_3D_depth_test");check(is_equal_approx(app.cat.scale.y*absf(app.camera.global_basis.y.y),1),"authored_screen_height_preserved")
 for id in ["counter_shell","espresso_station","grinder_station","pos_station","table_a","table_b","chair_a","chair_b","chair_c","chair_d","plant","cat_bed","scratch_post","pastry_case","entrance_door"]:check(app.groups[id].position==app.project_point(app.authority_world.find_object(StringName(id)).global_position),id+"_world_root")
 var w:Rect2=app.authority_world.find_object(&"front_wall_west").get_node("PhysicalFootprint").global_bounds();var e:Rect2=app.authority_world.find_object(&"front_wall_east").get_node("PhysicalFootprint").global_bounds()
 check(is_equal_approx((e.position.x-w.end.x)*.01,.64),"authoritative_door_opening_matches_authored_arch")
 check(app.geometry.find_children("*","CollisionObject3D",true,false).is_empty(),"no_second_collision_world")
 app.get_node("DiagnosticControls").visible=false
 check(await navigate(Vector2(325,300)),"hero_approach");check(await navigate(Vector2(325,355)),"hero_position")
 check(app.key_light.transform==frozen_lighting.key_transform,"key_light_direction_unchanged")
 check(app.find_children("*","Light3D",true,false).size()==2,"same_two_light_architecture")
 check(geometry_identity(app)==frozen_geometry,"exact_all_visible_vertex_normal_UV_index_and_transform_identity")
 check(app.surface_bindings.size()>0,"painted_materials_bound")
 var all_painted:=true
 for n in app.geometry.find_children("*","MeshInstance3D",true,false):
  for i in n.mesh.get_surface_count():
   if not n.get_active_material(i).resource_name.begins_with("WC3D_MAT_"):all_painted=false
 check(all_painted,"all_material_and_surface_overrides_use_new_library")
 await shot("02_PAINTED_SURFACE_PASS.png");await shot("09_GAMEPLAY_SCALE.png");await paired_asset_closeups("after")
 var final_lighting:Dictionary=lighting(app);apply_lighting(app,frozen_lighting);await shot("diagnostics/material_only_baseline_lighting.png");apply_lighting(app,final_lighting)

 # Compare sprite modes at exact same root/frame/camera; no change to source pixels.
 app.source_sprite.pause();app.cat.pause()
 for mode in ["unshaded","ambient_tinted","lightly_lit"]:
  app.set_cat_material_mode(mode);await shot("diagnostics/cat_mode_"+mode+".png")
 app.set_cat_material_mode("ambient_tinted");app.source_sprite.play()
 var original:Transform3D=app.camera.transform;var size:float=app.camera.size
 app.camera.position+=app.project_point(app.actor.global_position)-Vector3(3.2,0,5.0);app.camera.size=2.35;await shot("08_CAT_ENVIRONMENT.png");app.camera.transform=original;app.camera.size=size
 app.checkpoint.connect(checkpoint);recording=true;app.start_tour()
 while app.touring:await create_timer(.10).timeout
 await create_timer(.2).timeout;recording=false
 check(app.tour_results.size()==7 and app.tour_results.all(func(v):return v.success),"seven_real_navigation_targets")
 check(app.trace.any(func(v):return String(v.clip).begins_with("walk_")),"original_walk_clips")
 check(app.trace.any(func(v):return v.xy!=app.trace[0].xy),"actual_actor_motion")
 for row in [{"label":"counter_back","point":Vector2(230,97),"object":"counter_shell"},{"label":"counter_front","point":Vector2(230,225),"object":"counter_shell"},{"label":"table_back","point":Vector2(175,369),"object":"table_a"},{"label":"table_front","point":Vector2(175,535),"object":"table_a"}]:
  check(await navigate(row.point),"occlusion_nav_"+row.label);await isolate(row.label,app.groups[row.object])
  if row.label=="counter_back":await shot("diagnostics/cat_behind_counter.png")
  if row.label=="counter_front":await shot("diagnostics/cat_front_counter.png")
 var no_solid_entry:=true
 for t in app.trace:
  for id in ["counter_shell","espresso_station","grinder_station","pastry_case"]:
   var rect:Rect2=app.authority_world.find_object(StringName(id)).get_node("PhysicalFootprint").global_bounds()
   if rect.has_point(Vector2(t.xy[0],t.xy[1])):no_solid_entry=false
 check(no_solid_entry,"navigation_roots_outside_solid_cabinets");check(app.cat.position.y==0,"cat_root_on_floor");check(app.slice.authority()==app.baseline_authority,"world_authority_after_motion")
 var before_coins:int=app.authority_world.session.coins
 app.slice.start_coffee();await create_timer(1).timeout;await shot("diagnostics/coffee_running.png")
 for i in 6500:
  await physics_frame
  if not app.authority_world.loop_active:break
 check(app.authority_world.session.coins==before_coins+1 and app.authority_world.session.rewarded_orders.size()==1,"existing_service_reward_once")
 var receipt=app.authority_world.session.rewarded_orders[0];app.authority_world._on_reward_earned(receipt);check(app.authority_world.session.coins==before_coins+1,"duplicate_reward_guard")
 check(app.slice.authority()==app.baseline_authority,"world_authority_after_coffee")
 check(app.grouped_surface_count>0,"rear_only_static_surface_grouping")
 check(app.rear_triangles_before==app.rear_triangles_after,"rear_grouping_preserves_every_triangle")
 check(app.groups.RearArchitecture.find_children("GroupedRearSurface*","MeshInstance3D",true,false).all(func(n):return n.is_visible_in_tree()),"all_grouped_material_surfaces_remain_visible")
 save("diagnostics/native_proof.json",{"passed":checks.values().all(func(v):return v),"count":checks.size(),"checks":checks,"scope":"ISOLATED_DEV_ONLY; not canonical integration proof or production approval","tour":app.tour_results,"trace":app.trace,"placements":app.placements,"organic_roles":app.organic_roles,"v2_camera_transform":app.camera.transform,"v2_camera_size":app.camera.size,"geometry_hash":geometry_identity(app),"baseline_geometry_hash":frozen_geometry,"painted_bindings":app.surface_bindings,"edge_measurements":app.edge_measurements,"lighting_before":frozen_lighting,"lighting_after":lighting(app),"frames":frames,"frame_timestamps_ms":times,"renderer":RenderingServer.get_current_rendering_method(),"driver":RenderingServer.get_current_rendering_driver_name(),"device":RenderingServer.get_video_adapter_name(),"godot":Engine.get_version_info()})
 print("HYBRID CAFE KIT PROOF ",checks.values().all(func(v):return v)," checks=",checks.size()," frames=",frames);app.queue_free();for i in 12:await process_frame
 quit(0 if checks.values().all(func(v):return v) else 1)
