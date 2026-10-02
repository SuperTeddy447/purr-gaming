extends "res://tests/capture_stylized_fidelity_v1.gd"
func run():
 app=load("res://scenes/dev/stylized_fidelity/stylized_cafe_micro_diorama_v1.tscn").instantiate();app.auto_hero=false;root.add_child(app)
 while not app.ready_for_review:await process_frame
 check(await navigate(Vector2(325,300)),"approach_nav");check(await navigate(Vector2(325,355)),"hero_nav")
 app.get_node("DiagnosticControls").visible=false
 await shot("diagnostics/renderer_hero_"+RenderingServer.get_current_rendering_method()+".png")
 app.camera.position=Vector3(6.5,4.9,7.2);app.camera.look_at(Vector3(4.3,1.4,1.6));app.camera.size=2.9
 for mode in ["ambient_only","key_ambient","key_ambient_practical"]:
  app.set_lighting(mode);await create_timer(.2).timeout;await shot("diagnostics/lamp_close_"+mode+".png")
 await shot("09_HYBRID_LIGHTING_CLOSEUP.png")
 save_json("diagnostics/lighting_close_proof.json",{"passed":not failed,"checks":checks,"scope":"DEV-only actual lamp/contact close-up"})
 app.queue_free();for i in 12:await process_frame
 quit(1 if failed else 0)
