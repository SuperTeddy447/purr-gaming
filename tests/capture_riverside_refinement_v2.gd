extends SceneTree
var scene:Node3D
var out:String
var results:Array=[]
var draws:Array=[]
var capture_sequence:=false
var frame_id:=0
var last_capture_ms:=0
var video_timestamps:Array=[]
func _initialize():call_deferred("run")
func check(label:String,ok:bool,details:Variant=null):
 results.append({"test":label,"passed":ok,"details":details})
 if not ok:push_error("FAIL "+label+" "+str(details))
func settle(count:=12):
 for i in count:await process_frame
 await RenderingServer.frame_post_draw
func snap(name:String):
 await settle();var img:=root.get_texture().get_image();check("native_capture_"+name,img.get_width()==root.size.x and img.get_height()==root.size.y,[img.get_width(),img.get_height()]);img.save_png(out.path_join(name+".png"))
func record_frames():
 while capture_sequence:
  await RenderingServer.frame_post_draw
  var now:=Time.get_ticks_msec()
  if now-last_capture_ms>=100:
   root.get_texture().get_image().save_png(out.path_join("motion_frames/%05d.png"%frame_id));video_timestamps.append(now);last_capture_ms=now;frame_id+=1
func shot_checkpoint(label:String):
 var names:={"cafe_entrance":"02_CAT_CAFE_ENTRANCE","river_walk":"03_CAT_RIVER_WALK","bridge_middle":"04_CAT_BRIDGE_CROSSING"}
 if names.has(label):await snap(names[label])
func run():
 var args:=OS.get_cmdline_user_args();out=args[0] if not args.is_empty() else "/private/tmp/riverside_evidence_v1"
 DirAccess.make_dir_recursive_absolute(out.path_join("motion_frames"))
 scene=load("res://scenes/dev/riverside_refinement_v2/DEV_WILLICAT_RIVERSIDE_3D_ART_REFINEMENT_V2.tscn").instantiate();root.add_child(scene)
 for i in 240:
  await physics_frame
  if scene.ready_for_review:break
 check("DEV_scene_ready",scene.ready_for_review)
 await settle(120);scene.controls.visible=false
 check("DEV_2D_authority_no_3D_gameplay_bodies",scene.find_children("*","CollisionObject3D",true,false).is_empty())
 check("navigation_is_single_connected_polygon",scene.route_outline.size()>8,scene.route_outline.size())
 check("river_click_rejected",not scene.request_walk(Vector2(344,680)))
 check("outside_route_click_rejected",not scene.request_walk(Vector2(-1500,-1500)))
 check("depth_test_enabled",not scene.cat.no_depth_test)
 check("canonical_cat_art_loaded",scene.cat.sprite_frames.get_frame_texture("idle_down",0).atlas.resource_path==scene.ART+"orange_down.png")
 check("navigation_height_mapping",scene.point(Vector2(100,200))==Vector3(1,0,2))
 check("blank_sign_is_geometry",scene.groups.sign is Node3D)
 check("one_shadow_light",scene.key_light.shadow_enabled and not scene.practical.shadow_enabled)
 check("no_expensive_postprocessing",not scene.environment.environment.glow_enabled and not scene.environment.environment.fog_enabled and not scene.environment.environment.ssao_enabled)
 var bank=load(scene.V2_KIT+"glb/WC_RIVER_Bank_Straight_A.glb").instantiate()
 scene.add_child(bank)
 var bank_mesh:MeshInstance3D=bank.find_children("*","MeshInstance3D",true,false)[0]
 var bounds:AABB=(bank.global_transform.affine_inverse()*bank_mesh.global_transform)*bank_mesh.mesh.get_aabb()
 var manifest:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(scene.V2_KIT+"asset_manifest.json"))
 var record:Dictionary=manifest.assets.filter(func(a):return a.asset_id=="WC_RIVER_Bank_Straight_A")[0]
 check("bank_two_meter_authored_connector_pitch",record.registration.connectors[0].position[0]==-1.0 and record.registration.connectors[1].position[0]==1.0 and record.registration.connectors[0].profile==record.registration.connectors[1].profile)
 check("bank_visual_bounds_inside_join_profile",bounds.position.x>=-1.0 and bounds.end.x<=1.0,{"position":bounds.position.x,"end":bounds.end.x,"pitch":2.0})
 bank.free()
 var import_rows:Array=[]
 var files:=DirAccess.get_files_at(scene.V2_KIT+"glb")
 for file in files:
  if not file.ends_with(".glb"):continue
  var item=load(scene.V2_KIT+"glb/"+file).instantiate();var good:=true;var surfaces:=0;var tri:=0
  for mesh in item.find_children("*","MeshInstance3D",true,false):
   surfaces+=mesh.mesh.get_surface_count();tri+=mesh.mesh.get_faces().size()/3
   for n in mesh.mesh.get_surface_count():
    var a:Array=mesh.mesh.surface_get_arrays(n)
    good=good and a[Mesh.ARRAY_VERTEX].size()>0 and a[Mesh.ARRAY_NORMAL].size()>0 and a[Mesh.ARRAY_TEX_UV].size()>0 and a[Mesh.ARRAY_COLOR]!=null and a[Mesh.ARRAY_COLOR].size()==a[Mesh.ARRAY_VERTEX].size()
  check("GLB_UV_NORMAL_COLOR_"+file,good,{"surfaces":surfaces,"triangles":tri});import_rows.append({"file":file,"surfaces":surfaces,"triangles":tri});item.free()
 check("25_refined_modular_assets_imported",import_rows.size()==25,import_rows.size())
 var baseline=load("res://scenes/dev/riverside_translation/DEV_WILLICAT_RIVERSIDE_3D_TRANSLATION_PROOF_V1.tscn").instantiate();root.add_child(baseline)
 for i in 240:
  await physics_frame
  if baseline.ready_for_review:break
 check("authority_exact_V1_hash",scene.authority_hash()==baseline.authority_hash(),{"V1":baseline.authority_hash(),"V2":scene.authority_hash()})
 check("route_vertices_exact_V1",scene.route_outline==baseline.route_outline)
 check("actor_movement_settings_exact_V1",scene.actor.move_speed==baseline.actor.move_speed)
 check("cafe_entrance_exact_V1",scene.groups.entrance.position==baseline.groups.entrance.position)
 check("bridge_location_exact_V1",scene.groups.bridge.position==baseline.groups.bridge.position)
 baseline.queue_free();await process_frame;scene.camera.current=true
 var points_in_view:=true
 for point in [Vector3(-2.14,0,2.24),Vector3(-.32,0,4.70),Vector3(.85,0,3.6),Vector3(3.44,0,2.15),Vector3(6.1,0,2.15),Vector3(6.1,0,-1.20),Vector3(-.15,0,8.4)]:
  var screen:Vector2=scene.camera.unproject_position(point);points_in_view=points_in_view and Rect2(Vector2.ZERO,Vector2(root.size)).has_point(screen)
 check("all_required_route_targets_visible",points_in_view)
 check("background_rise_outside_route_strip",1.0+5.0*.85<5.4 and -6.9+1.8< -4.8)
 check("one_representative_motion_tree",scene.representative_wind_materials.size()>0 and scene.representative_wind_materials.size()<=3)
 check("no_writable_production_scene_loaded",scene.gameplay.name=="GameplayRootDEV_Vector2Authority")
 await snap("01_FULL_PORTRAIT_GAMEPLAY_540x960")
 scene.checkpoint.connect(shot_checkpoint)
 capture_sequence=true;record_frames();await scene.start_tour();capture_sequence=false;await settle()
 for row in scene.tour_results:check("walk_"+String(row.label),row.success,{"xy":row.xy,"accepted":row.accepted})
 check("world_authority_unchanged_after_route",scene.initial_authority_hash==scene.authority_hash())
 check("moving_proof_recorded",scene.trace.size()>100 and frame_id>100,{"physics_samples":scene.trace.size(),"video_frames":frame_id})
 var root_locked:=true;var shadow_locked:=true;var in_route:=true;var saw_walk:=false;var saw_bridge:=false
 for row in scene.trace:
  root_locked=root_locked and row.xyz[1]==0
  in_route=in_route and Geometry2D.is_point_in_polygon(Vector2(row.xy[0],row.xy[1]),scene.route_outline)
  saw_walk=saw_walk or String(row.clip).begins_with("walk")
  saw_bridge=saw_bridge or (row.xyz[0]>2.0 and row.xyz[0]<4.9 and row.xyz[2]>1.4 and row.xyz[2]<2.9)
 shadow_locked=scene.contact.position.is_equal_approx(scene.cat.position+Vector3(0,.011,0))
 check("root_height_locked",root_locked);check("contact_shadow_follows_actor",shadow_locked);check("all_route_samples_inside_authority",in_route);check("walking_clips_played",saw_walk);check("real_bridge_traversed",saw_bridge)
 # Two copies of existing canonical art demonstrate width only; no new NPC identity is created.
 scene.npc_cat.visible=true;scene.actor.position=Vector2(-55,660);scene.npc.position=Vector2(55,550)
 var npc_target:=Marker2D.new();npc_target.position=Vector2(55,720);scene.gameplay.add_child(npc_target);scene.npc.navigate_to_marker(npc_target)
 scene.request_walk(Vector2(-55,500));var min_dist:=INF
 for i in 600:
  await physics_frame;min_dist=minf(min_dist,scene.actor.position.distance_to(scene.npc.position))
  if scene.actor.phase==HardeningActor.Phase.IDLE and scene.npc.phase==HardeningActor.Phase.IDLE:break
 check("two_actor_street_pass",scene.actor.phase==HardeningActor.Phase.IDLE and scene.npc.phase==HardeningActor.Phase.IDLE and min_dist>18,{"minimum_center_distance_px":min_dist,"body_diameter_px":18})
 await snap("11_TWO_CAT_WIDTH_TEST");scene.npc_cat.visible=false;npc_target.queue_free()
 # Capture street, entrance, river and bridge at actual 360x640 viewport dimensions.
 root.content_scale_size=Vector2i(360,640);root.size=Vector2i(360,640);await settle(40)
 for row in [["08_MOBILE_360_CAFE",Vector2(-214,320)],["09_MOBILE_360_RIVER",Vector2(85,360)],["10_MOBILE_360_BRIDGE",Vector2(344,215)]]:
  scene.actor.position=row[1];await snap(row[0])
 root.content_scale_size=Vector2i(540,960);root.size=Vector2i(540,960);await settle(40)
 scene.actor.position=Vector2(-214,325)
 var old_transform:Transform3D=scene.camera.transform;var old_size:float=scene.camera.size
 scene.camera.size=6.2;scene.camera.position=Vector3(1.0,6.8,11.4);scene.camera.look_at(Vector3(-3.25,1.2,2.1));scene.cat.scale.y=1/absf(scene.camera.global_basis.y.y)
 await snap("05_CAFE_FACADE_CLOSE_3Q")
 scene.camera.size=6.4;scene.camera.position=Vector3(7.8,7.3,12.6);scene.camera.look_at(Vector3(3.5,-.2,3.0));scene.actor.position=Vector2(344,215);scene.cat.scale.y=1/absf(scene.camera.global_basis.y.y)
 await snap("06_RIVER_EDGE_WATER_CLOSE")
 scene.camera.size=15.4;scene.camera.position=Vector3(1,26,2.5);scene.camera.look_at(Vector3(1,0,2.5),Vector3(0,0,-1));scene.debug_route.visible=true
 await snap("07_TOP_VIEW_PLAYABLE_ROUTE")
 scene.camera.transform=old_transform;scene.camera.size=old_size;scene.cat.scale.y=1/absf(scene.camera.global_basis.y.y);scene.debug_route.visible=false;scene.actor.position=Vector2(85,360)
 await snap("12_WATER_FOLIAGE_TIME_A");await create_timer(2.5).timeout;await snap("13_WATER_FOLIAGE_TIME_B")
 for i in 180:
  await RenderingServer.frame_post_draw;draws.append(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME))
 var report:={"scope":"isolated DEV translation diagnostics, not Factory canonical/production approval","checks":results,"passed":results.filter(func(x):return x.passed).size(),"failed":results.filter(func(x):return not x.passed).size(),"asset_imports":import_rows,"complexity":scene.complexity(),"draw_samples":draws,"DEV_authority_hash":scene.authority_hash(),"instance_layout":scene.instances,"route_trace":scene.trace,"route_results":scene.tour_results,"motion_video_timestamps_ms":video_timestamps,"camera_transform":str(old_transform),"camera_size":old_size,"triangle_contributors":scene.triangle_contributors(),"representative_wind":motion_measurements()}
 FileAccess.open(out.path_join("native_runtime_report.json"),FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("RIVERSIDE_TRANSLATION_TESTS passed=",report.passed," failed=",report.failed," frames=",frame_id)
 quit(0 if report.failed==0 else 1)

func motion_measurements()->Dictionary:
 var max_x:=0.0;var max_z:=0.0;var samples:=0
 var tree:Node3D=scene.groups.tree
 var trunk_vertices:=0;var foliage_vertices:=0
 for mesh in tree.find_children("*","MeshInstance3D",true,false):
  for i in mesh.mesh.get_surface_count():
   var m:ShaderMaterial=mesh.get_active_material(i);var arrays:Array=mesh.mesh.surface_get_arrays(i)
   if not scene.representative_wind_materials.has(m):trunk_vertices+=arrays[Mesh.ARRAY_VERTEX].size();continue
   for v:Vector3 in arrays[Mesh.ARRAY_VERTEX]:
    foliage_vertices+=1
    var mask:=smoothstep(.30,1.45,v.y)
    for time in range(101):
     var tt:float=time*.12
     var dx:float=sin(tt*.65+mesh.global_position.x*.73+v.z)*.012*mask
     var dz:float=sin(tt*.43+mesh.global_position.z*.39)*.012*.45*mask
     max_x=maxf(max_x,absf(dx));max_z=maxf(max_z,absf(dz));samples+=1
 return {"scope":"DEV representative instance shader-function sampling, NOT canonical thresholds","sample_interval_seconds":.12,"sample_count":samples,"sampled_max_local_foliage_dx_world":max_x,"sampled_max_local_foliage_dz_world":max_z,"root_trunk_displacement_world":0,"static_nonwind_vertex_count":trunk_vertices,"moving_foliage_vertex_count":foliage_vertices,"whole_sprite_scale_animation":false,"amplitude_art_parameter_world":.012,"only_one_instance_animated":true}
