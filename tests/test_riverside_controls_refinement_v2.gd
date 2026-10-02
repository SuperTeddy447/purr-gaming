extends SceneTree
var results:Array=[]
func _initialize():call_deferred("run")
func check(label:String,ok:bool):results.append({"test":label,"passed":ok})
func run():
 var s=load("res://scenes/dev/riverside_refinement_v2/DEV_WILLICAT_RIVERSIDE_3D_ART_REFINEMENT_V2.tscn").instantiate();root.add_child(s)
 for i in 240:await physics_frame
 var b=s.controls.find_children("*","Button",true,false)
 check("three_playable_controls_exist",b.size()==3)
 check("visible_Walk_route_button",b[0].text=="Walk route" and b[0].is_visible_in_tree())
 var p:Vector2=s.actor.position;b[0].pressed.emit()
 for i in 50:await physics_frame
 check("Walk_route_button_moves_protagonist",s.touring and s.actor.position.distance_to(p)>10)
 b[1].pressed.emit();b[2].pressed.emit()
 check("route_debug_and_NPC_width_controls_toggle",s.debug_route.visible and s.npc_cat.visible)
 await RenderingServer.frame_post_draw
 var out:String=OS.get_cmdline_user_args()[0];root.get_texture().get_image().save_png(out.path_join("20_INSTALLED_PLAYABLE_CONTROLS.png"))
 FileAccess.open(out.path_join("diagnostics/installed_controls.json"),FileAccess.WRITE).store_string(JSON.stringify({"checks":results,"passed":results.filter(func(r):return r.passed).size(),"failed":results.filter(func(r):return not r.passed).size()},"  "))
 quit(1 if results.any(func(r):return not r.passed) else 0)
