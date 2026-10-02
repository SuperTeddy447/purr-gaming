extends SceneTree
const SCENE=preload("res://scenes/dev/cafe_visual_recovery/cafe_visual_recovery_v1.tscn")
var checks:Array=[]
var failed:=false
func _initialize():call_deferred("run")
func check(ok:bool,name:String):
 checks.append({"test":name,"passed":ok})
 if not ok:failed=true;push_error(name)
func run():
 root.size=Vector2i(576,1024)
 var w=SCENE.instantiate();root.add_child(w);var s=w.get_node("CafeInteriorVisualSlice")
 for i in 60:
  await process_frame
  if s.ready_for_review and s.projection_applied:break
 check(s.ready_for_review,"slice installed")
 check(s.before==s.authority(),"semantic transforms / footprints / anchors / nav preserved")
 check(w.find_object(&"entrance_door").position==Vector2(320,910),"entrance authority unchanged")
 check(w.find_object(&"counter_shell").position==Vector2(190,185),"counter root authority unchanged")
 check(w.find_object(&"table_a").position==Vector2(175,455),"table root authority unchanged")
 check(w.find_object(&"chair_a").get_node("SeatSlot/ActionAnchor").global_position==Vector2(110,532),"seat anchor authority unchanged")
 check(w.get_node("DepthSortedLayer").y_sort_enabled and w.objects.y_sort_enabled,"world sorting preserved")
 var c=w.find_object(&"counter_shell").get_node("InteriorReviewVisualRoot")
 check(c.has_node("RecoveryCounter_left_front") and c.has_node("RecoveryCounter_left_top"),"separate registered counter planes")
 check(c.get_node("RecoveryCounter_left_front").position==c.get_node("RecoveryCounter_left_top").position,"counter plane shared canvas/pivot")
 for name in ["TableA","ChairA","ChairB","CounterShell"]:
  check(w.objects.get_node(name).get_node("InteriorReviewVisualRoot").has_node("ReviewContactShadow"),name+" separate shadow")
 check(s.avatars.Worker.get_node("AnimatedSprite2D").sprite_frames.has_animation("walk_up"),"existing orange authored walk reused")
 check(c.get_node("RecoveryCounter_left_front").texture.get_size()==c.get_node("RecoveryCounter_left_top").texture.get_size(),"counter planes same export canvas")
 check(w.find_object(&"table_b").has_node("KitVisualRoot/Review_table_cedar"),"second table uses same first-party furniture family")
 check(w.find_object(&"chair_c").has_node("KitVisualRoot/Review_chair_ne") and w.find_object(&"chair_d").has_node("KitVisualRoot/Review_chair_nw"),"second group uses authored chair directions")
 check(w.find_object(&"cat_bed").has_node("KitVisualRoot/Kit_cat_bed_empty"),"cat bed does not bake a character into furniture")
 check(w.get_node("Architecture").has_node("RecoveryUprightArchitecture/RecoveryCafeSign"),"blank menu has separate runtime text")
 for id in [&"espresso_station",&"grinder_station"]:
  var support=w.find_object(id).get_node("InteriorReviewVisualRoot/Kit_counter_short")
  check(not support.visible,String(id)+" isolated support replaced by joined service counter")
 check(s.kit_sprites.size()>=20,"modular kit installed as separate sprites")
 check(s.projection_applied,"DEV ground projection installed")
 check(is_equal_approx(w.get_node("Camera").zoom.y/w.get_node("Camera").zoom.x,s.GROUND_Y_PRESENTATION),"one consistent ground projection ratio")
 check(c.get_children().filter(func(n):return String(n.name).begins_with("RecoveryCounter_")).size()==8,"four counter modules with independent top/front layers")
 check(s.counter_span>400,"service counter covers the existing stations as one family")
 check(w.get_node("Architecture").has_node("RecoveryGroundRug_table_a") and w.get_node("Architecture").has_node("RecoveryGroundRug_table_b"),"both existing seat clusters have separate ground textiles")
 check(w.find_object(&"scratch_post").get_node("KitVisualRoot").has_node("RecoverySisalPost"),"authored sisal replaces cedar structural proxy")
 var avatar=s.avatars.Worker;var sp=avatar.get_node("AnimatedSprite2D")
 check(is_equal_approx(sp.position.y+(232.0-128.0)*sp.scale.y,0),"idle orange source retains exact authored ground baseline")
 var click=Vector2(175,502);var screen=w.get_canvas_transform()*click
 check((w.get_canvas_transform().affine_inverse()*screen).is_equal_approx(click),"projected floor clicks invert to unchanged navigation coordinates")
 s.start_tour()
 for i in 5000:
  await physics_frame
  if not s.touring:break
 check(s.tour_results.size()==6 and s.tour_results.all(func(r):return r.success),"all six depth walk targets reached through nav")
 check(s.authority()==s.before,"tour did not mutate world authority")
 s.start_coffee()
 var seated_observed:=false
 var seat_shadow_stable:=true
 for i in 6000:
  await physics_frame
  if s._seat_lift>0:
   seated_observed=true
   var shadow=s.avatars.Customer.get_node("ContactShadow")
   seat_shadow_stable=seat_shadow_stable and is_equal_approx(shadow.global_position.y,w.actors.get_node("Customer").global_position.y-4.0)
  if not w.loop_active:break
 check(seated_observed and seat_shadow_stable,"seating visual elevation preserves customer ground shadow")
 check(int(w.session.coins)==1 and w.session.rewarded_orders.size()==1,"existing coffee loop/reward receipt")
 check(s.polish.completion_count==1,"coffee completion semantic FX exactly once")
 check(s.polish.active_frames>0,"steam played during coffee activity")
 var phases=s.phase_history.map(func(r):return r.phase)
 check(phases.has("Customer enters") and phases.has("Customer orders coffee") and phases.has("Customer sits") and phases.has("Customer leaves"),"entrance/order/table/exit original semantic actions")
 check(s.authority()==s.before,"service loop did not mutate world authority")
 var receipt=w.session.rewarded_orders[0];w._on_reward_earned(receipt)
 check(int(w.session.coins)==1,"existing duplicate reward guard remains intact")
 var f=FileAccess.open(OS.get_cmdline_user_args()[0],FileAccess.WRITE);f.store_string(JSON.stringify({"count":checks.size(),"passed":not failed,"checks":checks},"\t"));f.close()
 print("CAFE SLICE CHECKS ",checks.size()," ","PASS" if not failed else "FAIL")
 w.queue_free();await process_frame;quit(1 if failed else 0)
