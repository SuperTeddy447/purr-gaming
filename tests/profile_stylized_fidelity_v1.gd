extends "res://tests/capture_stylized_fidelity_v1.gd"
func run():
 DisplayServer.window_move_to_foreground()
 var baseline=load("res://scenes/dev/cafe_visual_recovery/cafe_visual_recovery_v1.tscn").instantiate();root.add_child(baseline)
 while not baseline.get_node("CafeInteriorVisualSlice").projection_applied:await process_frame
 await create_timer(3).timeout;await sample("approved_2d")
 baseline.queue_free();for i in 12:await process_frame
 app=load("res://scenes/dev/hybrid_diorama/hybrid_cafe_diorama_v1.tscn").instantiate();root.add_child(app)
 while not app.ready_for_review:await process_frame
 await create_timer(3).timeout;await sample("previous_hybrid")
 var previous_complexity:Dictionary={"mesh_instances":app.geometry.find_children("*","MeshInstance3D",true,false).size(),"mesh_triangles":app.batched_triangle_count}
 app.queue_free();for i in 12:await process_frame
 app=load("res://scenes/dev/stylized_fidelity/stylized_cafe_micro_diorama_v1.tscn").instantiate();app.auto_hero=false;root.add_child(app)
 while not app.ready_for_review:await process_frame
 await navigate(Vector2(325,300));await navigate(Vector2(325,355))
 await create_timer(3).timeout;await sample("stylized_hybrid")
 for mode in ["ambient_only","key_ambient","key_ambient_practical"]:app.set_lighting(mode);await sample(mode)
 metrics.complexity=complexity();metrics.previous_complexity=previous_complexity
 app.queue_free();for i in 12:await process_frame
 var baked=load("res://scenes/dev/stylized_fidelity/prerendered_cafe_comparison_v1.tscn").instantiate();root.add_child(baked)
 await create_timer(3).timeout;await sample("prerendered_static_2d")
 save_json("diagnostics/steady_performance.json",{"metrics":metrics,"method":"one Godot process; 3s scene warmup; 1.3s settling; 240 frames discard 60; no screenshot/movie readback; desktop compositor/vsync time, not GPU timer/phone certification; static baked still is not equivalent moving gameplay"})
 baked.queue_free();for i in 12:await process_frame
 quit()
