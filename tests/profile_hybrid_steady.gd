extends "res://tests/capture_hybrid_diorama_v1.gd"
func run():
 DisplayServer.window_move_to_foreground()
 var baseline=load("res://scenes/dev/cafe_visual_recovery/cafe_visual_recovery_v1.tscn").instantiate();root.add_child(baseline)
 var slice=baseline.get_node("CafeInteriorVisualSlice")
 while not slice.projection_applied:await process_frame
 await create_timer(3).timeout;await sample("current_2d")
 baseline.queue_free();for i in 10:await process_frame
 app=load("res://scenes/dev/hybrid_diorama/hybrid_cafe_diorama_v1.tscn").instantiate();root.add_child(app)
 while not app.ready_for_review:await process_frame
 await create_timer(3).timeout;await sample("hybrid")
 for mode in ["ambient_only","key_ambient","key_ambient_practical"]:
  app.set_lighting(mode);await sample(mode)
 metrics.complexity=complexity()
 save_json("diagnostics/steady_performance.json",{"metrics":metrics,"method":"one Godot diagnostic process; no image readback/movie while sampling; 3 seconds scene warmup; 1.3 seconds condition settling; 240 frames per condition, discard first 60; desktop vsync/compositor frame pacing, not phone or GPU certification"})
 app.queue_free();for i in 12:await process_frame
 quit()
