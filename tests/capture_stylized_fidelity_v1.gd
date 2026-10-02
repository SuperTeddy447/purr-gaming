extends SceneTree
## Visible, real-navigation DEV proof. No production-world or art writes.
var app
var out:String
var checks:Dictionary={}
var metrics:Dictionary={}
var recording:=false
var elapsed:=0.0
var frames:=0
var timestamps:Array=[]
var capture_pending:=false
var shots:Array=[]
var failed:=false
func _initialize():
 out=OS.get_cmdline_user_args()[0];DirAccess.make_dir_recursive_absolute(out+"/frames");DirAccess.make_dir_recursive_absolute(out+"/diagnostics");call_deferred("run")
func check(value:bool,label:String):
 checks[label]=value
 if not value:failed=true;push_error(label)
func save_json(path:String,value):
 var f:=FileAccess.open(out+"/"+path,FileAccess.WRITE);assert(f!=null);f.store_string(JSON.stringify(value,"\t",true,true));f.close()
func shot(path:String):
 await RenderingServer.frame_post_draw
 check(root.get_texture().get_image().save_png(out+"/"+path)==OK,"capture_"+path)
func _process(delta:float)->bool:
 if recording:
  elapsed+=delta
  if elapsed>=.10 and not capture_pending:elapsed=0;capture_pending=true;movie_frame.call_deferred()
 return false
func movie_frame():
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out+"/frames/%05d.png"%frames);timestamps.append(Time.get_ticks_msec());frames+=1;capture_pending=false
func sample(label:String):
 await create_timer(1.3).timeout
 var rows:Array=[]
 for i in 240:
  var start:=Time.get_ticks_usec();await process_frame
  if i>=60:rows.append({"wall_frame_ms":(Time.get_ticks_usec()-start)/1000.0,"process_ms":Performance.get_monitor(Performance.TIME_PROCESS)*1000,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"rendered_primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),"rendered_objects":Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),"video_memory_bytes":Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED),"texture_memory_bytes":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)})
 metrics[label]=rows
func complexity()->Dictionary:
 var meshes=app.geometry.find_children("*","MeshInstance3D",true,false);var triangles:=0;var surfaces:=0;var used:Dictionary={};var textures:Dictionary={}
 for n in meshes:
  triangles+=n.mesh.get_faces().size()/3;surfaces+=n.mesh.get_surface_count()
  var m=n.material_override;used[m.get_instance_id()]=true
  if m is StandardMaterial3D and m.albedo_texture!=null:textures[m.albedo_texture.resource_path]=true
  elif m is ShaderMaterial:
   var tex=m.get_shader_parameter("painted_texture")
   if tex!=null:textures[tex.resource_path]=true
 for clip in app.cat.sprite_frames.get_animation_names():
  for i in app.cat.sprite_frames.get_frame_count(clip):
   var tex=app.cat.sprite_frames.get_frame_texture(clip,i)
   textures[tex.atlas.resource_path if tex is AtlasTexture else tex.resource_path]=true
 textures[app.contact.texture.resource_path]=true
 return {"authored_mesh_pieces":app.authored_piece_count,"mesh_instances":meshes.size(),"mesh_triangles":triangles,"environment_surfaces":surfaces,"unique_used_materials":used.size(),"unique_referenced_textures":textures.size(),"texture_references":textures.keys(),"transparent_sprite3d_count":app.geometry.find_children("*","Sprite3D",true,false).size()+2,"animated_sprite3d_count":1,"realtime_lights":2,"shadow_casting_lights":1,"lightmap_baked":false,"ssao_enabled":false,"render_resolution":root.get_visible_rect().size,"renderer":RenderingServer.get_current_rendering_method(),"driver":RenderingServer.get_current_rendering_driver_name(),"device":RenderingServer.get_video_adapter_name(),"version":Engine.get_version_info()}
func checkpoint(label:String):
 record_checkpoint.call_deferred(label)
func record_checkpoint(label:String):
 var path:="depth_"+label+".png"
 if label=="counter_back":path="06_HYBRID_CAT_BEHIND_COUNTER.png"
 elif label=="counter_front":path="05_HYBRID_CAT_FRONT_COUNTER.png"
 elif label=="table_side":path="07_HYBRID_TABLE_DEPTH.png"
 await shot(path);shots.append({"label":label,"xy":app.actor.global_position,"xyz":app.cat.position,"clip":app.cat.animation,"frame":app.cat.frame,"image":path})
func navigate(point:Vector2)->bool:
 var marker:=Marker2D.new();marker.position=point;app.slice.add_child(marker);var accepted:bool=app.actor.navigate_to_marker(marker)
 for i in 1800:
  await physics_frame
  if app.actor.phase==HardeningActor.Phase.IDLE:break
 var okay:bool=accepted and app.actor.phase==HardeningActor.Phase.IDLE and not app.actor.failed_navigation
 marker.queue_free();return okay
func occlusion(label:String,target:Node3D):
 var was_recording:=recording;recording=false
 app.source_sprite.pause();app.cat.pause();app.contact.visible=false
 app.cat.visible=false;target.visible=false;await shot("diagnostics/"+label+"_background.png")
 app.cat.visible=true;await shot("diagnostics/"+label+"_cat_only.png")
 app.cat.visible=false;target.visible=true;await shot("diagnostics/"+label+"_object_only.png")
 app.cat.visible=true;await shot("diagnostics/"+label+"_combined.png")
 app.contact.visible=true;app.source_sprite.play();recording=was_recording
func run():
 DisplayServer.window_move_to_foreground()
 # Original approved baseline, untouched scene and normal camera, same entrance actor root.
 var baseline=load("res://scenes/dev/cafe_visual_recovery/cafe_visual_recovery_v1.tscn").instantiate();root.add_child(baseline)
 var slice=baseline.get_node("CafeInteriorVisualSlice")
 for i in 180:
  await process_frame
  if slice.projection_applied and slice.ready_for_review:break
 check(slice.before==slice.authority(),"baseline_authority")
 var baseline_spawn:Vector2=baseline.actors.get_node("Visitor").global_position
 for point in [Vector2(325,300),Vector2(325,355)]:
  var marker:=Marker2D.new();marker.position=point;slice.add_child(marker)
  var original_actor=baseline.actors.get_node("Visitor");var accepted:bool=original_actor.navigate_to_marker(marker)
  for i in 1800:
   await physics_frame
   if original_actor.phase==HardeningActor.Phase.IDLE:break
  check(accepted and not original_actor.failed_navigation,"baseline_hero_nav_"+str(point));marker.queue_free()
 metrics.baseline_hero_pose=baseline.actors.get_node("Visitor").global_position
 await create_timer(.5).timeout;await shot("01_APPROVED_2D_BASELINE.png");await sample("current_2d")
 var baseline_actor:Vector2=baseline_spawn
 var baseline_camera={"position":baseline.get_node("Camera").global_position,"zoom":baseline.get_node("Camera").zoom,"resolution":root.size}
 baseline.queue_free();for i in 8:await process_frame
 app=load("res://scenes/dev/stylized_fidelity/stylized_cafe_micro_diorama_v1.tscn").instantiate();app.auto_hero=false;root.add_child(app)
 for i in 180:
  await process_frame
  if app.ready_for_review:break
 check(app.ready_for_review,"hybrid_installed")
 check(app.unbatched_triangle_count==app.batched_triangle_count and app.batched_triangle_count>0,"static_batch_triangle_parity")
 check(app.slice.authority()==app.baseline_authority,"hybrid_authority")
 check(app.actor.global_position==baseline_actor,"comparison_same_actor_root")
 check(app.cat.sprite_frames==app.source_sprite.sprite_frames,"exact_existing_spriteframes_resource")
 check(not app.cat.no_depth_test,"depth_test_enabled")
 check(is_equal_approx(app.cat.scale.y*absf(app.camera.global_basis.y.y),1.0),"upright_sprite_preserves_authored_screen_height")
 check(app.cat.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_OFF,"no_card_cast_shadow")
 check(app.contact.rotation_degrees.x==-90,"shadow_lies_on_floor")
 check(app.camera.projection==Camera3D.PROJECTION_ORTHOGONAL and app.camera.keep_aspect==Camera3D.KEEP_WIDTH,"portrait_orthographic_camera")
 for id in ["counter_shell","table_a","chair_a","chair_b","plant"]:
  check(app.groups[id].position==app.project_point(app.authority_world.find_object(StringName(id)).global_position),id+"_root_mapping")
 for point in [Vector2(175,455),Vector2(320,855),Vector2(-320,1270)]:check(app.unproject_point(app.project_point(point)).is_equal_approx(point),"reversible_mapping_"+str(point))
 var screen:Vector2=app.camera.unproject_position(app.project_point(Vector2(251,431)))
 check(app.unproject_point(app.pick(screen)).distance_to(Vector2(251,431))<.001,"camera_pick_inverse_roundtrip")
 check(await navigate(Vector2(325,300)),"hero_approach_real_navigation");check(await navigate(Vector2(325,355)),"hero_pose_real_navigation");await create_timer(.5).timeout;app.get_node("DiagnosticControls").visible=false;await shot("02_LIVE_HYBRID_HERO.png");await sample("hybrid")
 metrics.complexity=complexity();metrics.baseline_camera=baseline_camera;metrics.hybrid_camera={"position":app.camera.position,"rotation_degrees":app.camera.rotation_degrees,"size":app.camera.size,"projection":"orthographic","free_rotation":false}
 for mode in ["ambient_only","key_ambient","key_ambient_practical"]:
  app.set_lighting(mode);await create_timer(.2).timeout;await shot("diagnostics/lighting_"+mode+".png");await sample(mode)
 await shot("09_HYBRID_LIGHTING_CLOSEUP.png")
 for mode in ["camera_facing","upright","fixed_facing"]:
  app.set_cat_mode(mode);await create_timer(.2).timeout;await shot("diagnostics/cat_"+mode+".png")
 app.set_cat_mode("upright")
 for presentation in ["unshaded","ambient_tinted"]:
  app.set_cat_presentation(presentation);await create_timer(.2).timeout;await shot("diagnostics/cat_color_"+presentation+".png")
 for contact_mode in ["blob","card_cast","hybrid_contact"]:
  app.set_contact_mode(contact_mode);await create_timer(.2).timeout;await shot("diagnostics/cat_grounding_"+contact_mode+".png")
 app.set_contact_mode("hybrid_contact");app.set_cat_presentation("ambient_tinted")
 for mode in [SpriteBase3D.ALPHA_CUT_DISABLED,SpriteBase3D.ALPHA_CUT_DISCARD,SpriteBase3D.ALPHA_CUT_OPAQUE_PREPASS]:
  app.cat.alpha_cut=mode;await create_timer(.2).timeout;await shot("diagnostics/alpha_mode_"+str(mode)+".png")
 app.cat.alpha_cut=SpriteBase3D.ALPHA_CUT_OPAQUE_PREPASS
 app.checkpoint.connect(checkpoint);recording=true;app.start_tour()
 while app.touring:await create_timer(.10).timeout
 await create_timer(.15).timeout;recording=false
 check(app.tour_results.size()==6 and app.tour_results.all(func(r):return r.success),"six_original_nav_depth_targets")
 var body_rects:Array=[]
 for id in [&"counter_shell",&"espresso_station"]:body_rects.append(app.authority_world.find_object(id).get_node("PhysicalFootprint").global_bounds())
 var root_in_solid:=false
 for row in app.trace:
  for rect in body_rects:
   if rect.has_point(Vector2(row.xy[0],row.xy[1])):root_in_solid=true
 check(not root_in_solid,"tour_roots_never_enter_counter_solid_body")
 check(app.groups.espresso_station.position==app.project_point(app.authority_world.find_object(&"espresso_station").global_position),"espresso_support_authority_root")
 check(app.trace.any(func(r):return r.clip.begins_with("walk_")),"existing_walk_clip_used")
 check(app.trace.any(func(r):return r.xy!=app.trace[0].xy),"actual_2d_actor_motion")
 await RenderingServer.frame_post_draw
 check(app.cat.animation==app.source_sprite.animation and app.cat.frame==app.source_sprite.frame,"render_frame_clip_parity")
 check(app.cat.position==app.project_point(app.actor.global_position) and app.cat.position.y==0,"root_on_floor")
 check(app.slice.authority()==app.baseline_authority,"navigation_anchors_objects_unchanged")
 check(app.authority_world.session.coins==0 and app.authority_world.session.rewarded_orders.is_empty(),"depth_walk_no_economy_mutation")
 for row in [{"label":"counter_back","point":app.slice.tour_points()[2].point,"object":"counter_shell"},{"label":"counter_front","point":Vector2(230,225),"object":"counter_shell"},{"label":"table_back","point":app.slice.tour_points()[3].point,"object":"table_a"},{"label":"table_front","point":Vector2(175,535),"object":"table_a"}]:
  check(await navigate(row.point),"pixel_proof_nav_"+row.label);await occlusion(row.label,app.groups[row.object])
  if row.label=="counter_front":await shot("05_HYBRID_CAT_FRONT_COUNTER.png")
  if row.label=="counter_back":await shot("06_HYBRID_CAT_BEHIND_COUNTER.png")
 check(await navigate(Vector2(325,300)),"return_hero_approach_real_navigation");check(await navigate(Vector2(325,355)),"return_hero_real_navigation")
 await shot("02_LIVE_HYBRID_HERO.png")
 var camera_transform:Transform3D=app.camera.transform;var camera_size:float=app.camera.size
 app.camera.position=Vector3(4.6,5.4,8.0);app.camera.look_at(Vector3(2.65,.85,1.67));app.camera.size=3.5
 await shot("08_HYBRID_MATERIAL_CLOSEUP.png");await shot("09_HYBRID_LIGHTING_CLOSEUP.png")
 app.camera.transform=camera_transform;app.camera.size=camera_size
 # Same exact scene/materials/camera/light, 2x pixels; no painting, relighting or compositional changes.
 var main_viewport=app.get_viewport()
 var sub:=SubViewport.new();sub.name="DEV_OrthographicBake";sub.size=Vector2i(1008,1792);sub.world_3d=app.get_world_3d();sub.transparent_bg=false;sub.msaa_3d=Viewport.MSAA_4X;sub.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(sub)
 var bakecam:=Camera3D.new();sub.add_child(bakecam);bakecam.projection=Camera3D.PROJECTION_ORTHOGONAL;bakecam.keep_aspect=Camera3D.KEEP_WIDTH;bakecam.size=camera_size;bakecam.transform=camera_transform;bakecam.current=true
 for i in 8:await process_frame
 await RenderingServer.frame_post_draw
 check(sub.get_texture().get_image().save_png(out+"/diagnostics/prerender_full_1008x1792.png")==OK,"same_scene_2x_prerender_saved")
 check(bakecam.transform==app.camera.transform and bakecam.size==app.camera.size,"bake_camera_parity")
 sub.transparent_bg=true
 var e=app.environment.environment;var bg_mode=e.background_mode;e.background_mode=Environment.BG_CLEAR_COLOR
 var old_visibility:Dictionary={}
 for key in app.groups:old_visibility[key]=app.groups[key].visible;app.groups[key].visible=false
 app.cat.visible=false;app.contact.visible=false;app.groups.table_a.visible=true
 bakecam.transform=app.camera.transform;bakecam.position=app.groups.table_a.position+Vector3(0,.35,0)+(app.camera.position-Vector3(2.90,.57,3.3));bakecam.size=2.55
 metrics.modular_camera={"root_px":bakecam.unproject_position(app.groups.table_a.global_position),"image_size":sub.size,"world_span":bakecam.size,"camera_transform":bakecam.transform,"logical_object_id":"table_a","same_gameplay_camera_basis":bakecam.basis==app.camera.basis}
 for i in 8:await process_frame
 await RenderingServer.frame_post_draw
 check(sub.get_texture().get_image().save_png(out+"/diagnostics/table_modular_rgba.png")==OK,"modular_table_alpha_saved")
 for key in app.groups:app.groups[key].visible=old_visibility[key]
 app.cat.visible=true;app.contact.visible=true;e.background_mode=bg_mode;sub.queue_free()
 check(frames>40,"moving_frames_recorded")
 # A real service loop still runs in the hidden authoritative 2D world; spike shows one visitor only.
 app.slice.start_coffee()
 for i in 6500:
  await physics_frame
  if not app.authority_world.loop_active:break
 check(app.authority_world.session.coins==1 and app.authority_world.session.rewarded_orders.size()==1,"original_service_reward_once")
 var receipt=app.authority_world.session.rewarded_orders[0];app.authority_world._on_reward_earned(receipt)
 check(app.authority_world.session.coins==1,"duplicate_service_receipt_guard")
 check(app.slice.authority()==app.baseline_authority,"service_authority_parity")
 save_json("diagnostics/native_proof.json",{"scope":"isolated DEV stylized art-fidelity only","checks":checks,"count":checks.size(),"passed":not failed,"tour":app.tour_results,"trace":app.trace,"shots":shots,"frames":frames,"frame_timestamps_ms":timestamps,"metrics":metrics,"production_publication":false})
 print("STYLIZED FIDELITY NATIVE PROOF ","PASS" if not failed else "FAIL"," checks=",checks.size()," movie_frames=",frames)
 app.queue_free();for i in 12:await process_frame
 quit(1 if failed else 0)
