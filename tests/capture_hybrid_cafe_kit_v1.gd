extends SceneTree
var app
var out:String
var checks:Dictionary={}
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
 var manifest:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/dev_review/hybrid_cafe_kit_v1/kit_manifest.json"))
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
    if mat and mat.albedo_texture:
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
 if label=="counter_back":name="07_CAT_BEHIND_COUNTER.png"
 if label=="counter_front":name="08_CAT_FRONT_COUNTER.png"
 await shot(name)
func isolate(label:String,target:Node3D):
 app.source_sprite.pause();app.cat.pause();app.contact.visible=false
 app.cat.visible=false;target.visible=false;await shot("diagnostics/"+label+"_background.png")
 app.cat.visible=true;await shot("diagnostics/"+label+"_cat_only.png")
 app.cat.visible=false;target.visible=true;await shot("diagnostics/"+label+"_object_only.png")
 app.cat.visible=true;await shot("diagnostics/"+label+"_combined.png")
 app.contact.visible=true;app.source_sprite.play()
func run():
 DisplayServer.window_move_to_foreground();await asset_validation()
 app=load("res://scenes/dev/hybrid_cafe_kit/hybrid_cafe_asset_kit_v1.tscn").instantiate();root.add_child(app)
 for i in 300:
  await process_frame
  if app.ready_for_review:break
 check(app.ready_for_review,"slice_ready");check(app.slice.authority()==app.baseline_authority,"authority_initial")
 check(app.cat.sprite_frames==app.source_sprite.sprite_frames,"exact_canonical_orange_spriteframes");check(not app.cat.no_depth_test,"actual_3D_depth_test");check(is_equal_approx(app.cat.scale.y*absf(app.camera.global_basis.y.y),1),"authored_screen_height_preserved")
 for id in ["counter_shell","espresso_station","grinder_station","pos_station","table_a","table_b","chair_a","chair_b","chair_c","chair_d","plant","cat_bed","scratch_post","pastry_case","entrance_door"]:check(app.groups[id].position==app.project_point(app.authority_world.find_object(StringName(id)).global_position),id+"_world_root")
 var w:Rect2=app.authority_world.find_object(&"front_wall_west").get_node("PhysicalFootprint").global_bounds();var e:Rect2=app.authority_world.find_object(&"front_wall_east").get_node("PhysicalFootprint").global_bounds()
 check(is_equal_approx((e.position.x-w.end.x)*.01,.64),"authoritative_door_opening_matches_authored_arch")
 check(app.geometry.find_children("*","CollisionObject3D",true,false).is_empty(),"no_second_collision_world")
 app.get_node("DiagnosticControls").visible=false
 check(await navigate(Vector2(325,300)),"hero_approach");check(await navigate(Vector2(325,355)),"hero_position")
 await shot("02_GODOT_HYBRID_CAFE_FULL.png");await shot("09_GAMEPLAY_SCALE.png")
 var original:Transform3D=app.camera.transform;var size:float=app.camera.size
 for row in [{"name":"03_COUNTER_CLOSEUP.png","position":Vector3(4.4,4.5,7.1),"target":Vector3(3.3,1.25,1.72),"size":4.3},{"name":"04_TABLE_CHAIR_CLOSEUP.png","position":Vector3(4.5,5.3,10.0),"target":Vector3(3.15,.65,4.99),"size":4.7},{"name":"05_WINDOW_ARCHITECTURE_CLOSEUP.png","position":Vector3(4.5,5.5,7.0),"target":Vector3(2.0,1.35,.26),"size":4.1}]:
  app.camera.position=row.position;app.camera.look_at(row.target);app.camera.size=row.size;await shot(row.name)
 app.camera.transform=original;app.camera.size=size
 app.camera.position+=app.project_point(app.actor.global_position)-Vector3(3.2,0,5.0);app.camera.size=2.35;await shot("06_CAT_GROUNDED.png");app.camera.transform=original;app.camera.size=size
 app.checkpoint.connect(checkpoint);recording=true;app.start_tour()
 while app.touring:await create_timer(.10).timeout
 await create_timer(.2).timeout;recording=false
 check(app.tour_results.size()==7 and app.tour_results.all(func(v):return v.success),"seven_real_navigation_targets")
 check(app.trace.any(func(v):return String(v.clip).begins_with("walk_")),"original_walk_clips")
 check(app.trace.any(func(v):return v.xy!=app.trace[0].xy),"actual_actor_motion")
 for row in [{"label":"counter_back","point":Vector2(230,97),"object":"counter_shell"},{"label":"counter_front","point":Vector2(230,225),"object":"counter_shell"},{"label":"table_back","point":Vector2(175,369),"object":"table_a"},{"label":"table_front","point":Vector2(175,535),"object":"table_a"}]:
  check(await navigate(row.point),"occlusion_nav_"+row.label);await isolate(row.label,app.groups[row.object])
  if row.label=="counter_back":await shot("07_CAT_BEHIND_COUNTER.png")
  if row.label=="counter_front":await shot("08_CAT_FRONT_COUNTER.png")
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
 save("diagnostics/native_proof.json",{"passed":checks.values().all(func(v):return v),"count":checks.size(),"checks":checks,"scope":"ISOLATED_DEV_ONLY; not canonical integration proof or production approval","tour":app.tour_results,"trace":app.trace,"placements":app.placements,"frames":frames,"frame_timestamps_ms":times,"renderer":RenderingServer.get_current_rendering_method(),"driver":RenderingServer.get_current_rendering_driver_name(),"device":RenderingServer.get_video_adapter_name(),"godot":Engine.get_version_info()})
 print("HYBRID CAFE KIT PROOF ",checks.values().all(func(v):return v)," checks=",checks.size()," frames=",frames);app.queue_free();for i in 12:await process_frame
 quit(0 if checks.values().all(func(v):return v) else 1)
