extends SceneTree
var w
var s
var out:String
var recording:=false
var elapsed:=0.0
var frames:=0
var trace:Array=[]
var timings:Array=[]
var checks:Dictionary={}
var serving_captured:=false
var steam_captured:=false
var seating_captured:=false
var ordering_captured:=false
func _initialize():
 out=OS.get_cmdline_user_args()[0];DirAccess.make_dir_recursive_absolute(out+"/frames");call_deferred("run")
func save_json(name:String,value):
 var f=FileAccess.open(out+"/"+name,FileAccess.WRITE);f.store_string(JSON.stringify(value,"\t",true,true));f.close()
func capture(name:String):
 await RenderingServer.frame_post_draw
 assert(root.get_texture().get_image().save_png(out+"/"+name)==OK)
func _process(delta:float)->bool:
 if not recording:return false
 elapsed+=delta
 var row={"time_ms":Time.get_ticks_msec(),"phase":s.ui_status.text,"process_ms":Performance.get_monitor(Performance.TIME_PROCESS)*1000,"actor_positions":{}}
 for name in ["Visitor","Worker","Customer"]:
  var a=w.actors.get_node(name);row.actor_positions[name]=[a.global_position.x,a.global_position.y]
 trace.append(row)
 if elapsed>=.1:
  elapsed=0;timings.append(Time.get_ticks_msec());capture.call_deferred("frames/%05d.png"%frames);frames+=1
 return false
func checkpoint(label:String):
 capture.call_deferred("depth_"+label+".png")
func worker_action(_slot):
 if w.actors.get_node("Worker").last_action==&"work_coffee" and not steam_captured:
  steam_captured=true;steam_shot.call_deferred()
 if w.actors.get_node("Worker").last_action==&"serve" and not serving_captured:
  serving_captured=true;serve_shot.call_deferred()
func steam_shot():
 await create_timer(.3).timeout;await capture("06_coffee_steam.png")
func serve_shot():
 await capture("02_actor_behind_counter.png")
 # Fixed-pose renders establish actual pixel ownership, not merely Y coordinates.
 await occlusion("counter",w.actors.get_node("Worker"),w.find_object(&"counter_shell").get_node("InteriorReviewVisualRoot"))
func guest_action(_slot):
 if w.actors.get_node("Customer").last_action==&"order" and not ordering_captured:
  ordering_captured=true;order_shot.call_deferred()
 if w.actors.get_node("Customer").last_action==&"sit" and not seating_captured:
  seating_captured=true;seat_shot.call_deferred()
func order_shot():
 await capture("03_actor_in_front_of_counter.png")
 await occlusion("counter_front",w.actors.get_node("Customer"),w.find_object(&"counter_shell").get_node("InteriorReviewVisualRoot"))
func seat_shot():
 await create_timer(.4).timeout
 checks.seat_shadow_stays_at_ground=is_equal_approx(s.avatars.Customer.get_node("ContactShadow").global_position.y,w.actors.get_node("Customer").global_position.y-4.0)
 await capture("08_customer_seated.png")
func occlusion(label:String,actor:CanvasItem,object:CanvasItem):
 var was_recording:=recording;recording=false
 var original_physics=actor.is_physics_processing();actor.set_physics_process(false)
 s.set_process(false);s.polish.visible=false
 var avatar=s.avatars[String(actor.name)];avatar.set_process(false);var anim=avatar.find_children("*","AnimatedSprite2D",true,false)[0];var was_playing=anim.is_playing();anim.pause()
 var other_visibility:Dictionary={}
 for other in w.actors.get_children():
  if other!=actor and other is CanvasItem:other_visibility[other]=other.visible;other.visible=false
 actor.visible=false;object.visible=false;await capture(label+"_background.png")
 actor.visible=true;await capture(label+"_actor_only.png")
 actor.visible=false;object.visible=true;await capture(label+"_object_only.png")
 actor.visible=true;await capture(label+"_combined.png")
 for other in other_visibility:other.visible=other_visibility[other]
 if was_playing:anim.play()
 avatar.set_process(true);s.polish.visible=true;s.set_process(true);actor.set_physics_process(original_physics);recording=was_recording
func run():
 w=load("res://scenes/dev/cafe_interior_slice/cafe_interior_slice_v1.tscn").instantiate();root.add_child(w);s=w.get_node("CafeInteriorVisualSlice")
 for i in 120:
  await process_frame
  if s.ready_for_review:break
 assert(s.ready_for_review)
 await create_timer(.5).timeout;await capture("01_full_playable_slice.png")
 checks.authority_installed=s.before==s.authority()
 s.tour_checkpoint.connect(checkpoint)
 w.actors.get_node("Worker").action_started.connect(worker_action)
 w.actors.get_node("Customer").action_started.connect(guest_action)
 recording=true;s.walk_button.pressed.emit()
 while s.touring:await create_timer(.1).timeout
 checks.all_tour_targets_reached=s.tour_results.size()==6 and s.tour_results.all(func(r):return r.success)
 await occlusion("table_front",w.actors.get_node("Visitor"),w.find_object(&"table_a").get_node("InteriorReviewVisualRoot"))
 # Repeat the same real nav route to the behind-table proof target, no actor teleport.
 var marker=Marker2D.new();marker.position=s.tour_points()[3].point;s.add_child(marker)
 var actor=w.actors.get_node("Visitor");assert(actor.navigate_to_marker(marker))
 while actor.phase!=HardeningActor.Phase.IDLE:await create_timer(.1).timeout
 await occlusion("table_back",actor,w.find_object(&"table_a").get_node("InteriorReviewVisualRoot"));marker.queue_free()
 s.view_button.pressed.emit();await create_timer(.3).timeout;await capture("07_gameplay_scale.png")
 s.coffee_button.pressed.emit()
 while w.loop_active:await create_timer(.1).timeout
 await create_timer(.3).timeout;await capture("09_coffee_complete.png")
 recording=false
 checks.service_one_reward=int(w.session.coins)==1 and w.session.rewarded_orders.size()==1
 checks.coffee_completion_fx_once=s.polish.completion_count==1
 checks.steam_visible=s.polish.active_frames>0 and steam_captured
 checks.serving_behind_counter_captured=serving_captured
 checks.seating_captured=seating_captured
 checks.ordering_front_counter_captured=ordering_captured
 checks.authority_after=s.before==s.authority()
 checks.actual_actor_motion=trace.any(func(r):return r.actor_positions.Visitor!=trace[0].actor_positions.Visitor)
 checks.frames_recorded=frames>100
 save_json("native_runtime_proof.json",{"scope":"DEV_REVIEW_CANDIDATE","checks":checks,"check_count":checks.size(),"passed":checks.values().all(func(v):return v),"tour":s.tour_results,"phases":s.phase_history,"bindings":s.generated_bindings,"frames":frames,"frame_timestamps_ms":timings,"trace":trace,"canonical_integration_proof_executed":false})
 print("NATIVE CAFE CHECKS ",checks.size()," ","PASS" if checks.values().all(func(v):return v) else "FAIL")
 w.queue_free();await process_frame;quit(0 if checks.values().all(func(v):return v) else 1)
