extends SceneTree
## Critical architecture gates for the isolated hardening room.

const LAB := preload("res://scenes/dev/world_architecture_hardening_lab.tscn")
const EVENT_ROOM := preload("res://scenes/dev/world_architecture_hardening_event_room.tscn")
const ACTOR := preload("res://scenes/dev/world_hardening/actor.tscn")

var _ok := true


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var world := LAB.instantiate() as HardeningWorld
	root.add_child(world)
	await physics_frame
	await physics_frame
	var table := world.find_object(&"table")
	var footprint := table.get_node("PhysicalFootprint") as HardeningFootprint
	var nav := world.navigation
	_check(nav.navigation_polygon != null and nav.navigation_polygon.get_polygon_count() > 0,
		"Navigation mesh missing")
	_check(footprint.footprint_size.x < 150.0, "Footprint mistakenly uses full artwork bounds")
	var start := (world.actors.get_node("CustomerA") as HardeningActor).global_position
	var target := (world.get_node("CrossTableTarget") as Marker2D).global_position
	var path := PackedVector2Array()
	for frame in 30:
		path = NavigationServer2D.map_get_path(nav.get_navigation_map(), start, target, true)
		if path.size() >= 3:
			break
		await physics_frame
	print("HARDENING nav iteration=%d map=%s regionmap=%s worldmap=%s nearest=%s/%s" % [
		NavigationServer2D.map_get_iteration_id(nav.get_navigation_map()), str(nav.get_navigation_map()),
		str(NavigationServer2D.region_get_map(nav.get_rid())), str(world.get_world_2d().navigation_map),
		str(NavigationServer2D.map_get_closest_point(nav.get_navigation_map(), start)),
		str(NavigationServer2D.map_get_closest_point(nav.get_navigation_map(), target))])
	print("HARDENING nav regions=%s vertices=%s enabled=%s map_active=%s region_iteration=%d region_point=%s" % [
		str(NavigationServer2D.map_get_regions(nav.get_navigation_map())),
		str(nav.navigation_polygon.get_vertices().slice(0, 12)), str(nav.enabled),
		str(NavigationServer2D.map_is_active(nav.get_navigation_map())),
		NavigationServer2D.region_get_iteration_id(nav.get_rid()),
		str(NavigationServer2D.region_get_closest_point(nav.get_rid(), start))])
	print("HARDENING table path=%s footprint=%s" % [str(path), str(footprint.global_bounds())])
	_check(path.size() >= 3, "Table path did not bend around obstacle")
	var path_length := 0.0
	for i in range(1, path.size()):
		path_length += path[i - 1].distance_to(path[i])
		_check(not _segment_enters_rect(path[i - 1], path[i], footprint.global_bounds().grow(2.0)),
			"Nav path crosses table physical footprint")
	_check(path_length > start.distance_to(target) + 2.0,
		"Table path is effectively the direct line")
	var probe := world.actors.get_node("CustomerA") as HardeningActor
	_check(probe.navigate_to_marker(world.get_node("CrossTableTarget")), "Could not start table probe")
	await _wait_idle(probe, 500)
	_check(not probe.failed_navigation and probe.global_position.distance_to(target) < 12.0,
		"Actor did not navigate around table")
	for point in probe.path_trace:
		_check(not footprint.global_bounds().grow(1.0).has_point(point),
			"Actor feet entered table footprint")

	var chair_a := world.find_object(&"chair_a")
	var chair_b := world.find_object(&"chair_b")
	var seat_a := chair_a.get_node("SeatSlot") as HardeningInteractionSlot
	var seat_b := chair_b.get_node("SeatSlot") as HardeningInteractionSlot
	var customer_a := world.actors.get_node("CustomerA") as HardeningActor
	var customer_b := world.actors.get_node("CustomerB") as HardeningActor
	_check(seat_a.reserve(customer_a), "Customer A could not reserve Chair A")
	_check(not seat_a.reserve(customer_b), "Capacity-1 Chair A double-reserved")
	_check(seat_b.reserve(customer_b), "Customer B could not reserve Chair B")
	_check(seat_a.occupy(customer_a), "Customer A could not occupy Chair A")
	_check(not seat_a.occupy(customer_b), "Customer B occupied Chair A")
	seat_a.release(customer_a)
	seat_b.release(customer_b, &"cancel")
	_check(seat_a.use_count() == 0 and seat_b.use_count() == 0,
		"Chair release/cancel leaked reservation")

	var bed := world.find_object(&"cat_bed")
	var rest := bed.get_node("RestSlot") as HardeningInteractionSlot
	var sleep := bed.get_node("SleepSlot") as HardeningInteractionSlot
	var cat_a := world.actors.get_node("CatA") as HardeningActor
	var cat_b := world.actors.get_node("CatB") as HardeningActor
	_check(rest.reserve(cat_a), "Cat A could not reserve bed")
	_check(not rest.reserve(cat_b), "Bed RestSlot double-reserved")
	_check(not sleep.reserve(cat_b), "Shared bed capacity bypassed via SleepSlot")
	rest.release(cat_a)
	var temporary := ACTOR.instantiate() as HardeningActor
	temporary.category = "cat"
	world.actors.add_child(temporary)
	temporary.bind_world(world)
	_check(rest.reserve(temporary), "Temporary actor could not reserve bed")
	temporary.queue_free()
	await process_frame
	_check(rest.use_count() == 0 and bed.shared_use_count() == 0,
		"Actor removal leaked bed reservation")
	_check(rest.reserve(cat_a), "Bed not available after actor removal")
	rest.enabled = false
	_check(rest.use_count() == 0, "Disabling object slot did not release actor")
	rest.enabled = true
	_check(not world.find_object(&"espresso_station").get_node("CoffeeActionSlot").reserve(cat_a),
		"Cat reserved worker-only coffee slot")
	_check(cat_a.request_interaction_on(&"cat_bed", &"sleep"),
		"Interrupted-action probe could not reserve SleepSlot")
	cat_a.cancel_action(&"test_interrupt")
	_check(sleep.use_count() == 0 and bed.shared_use_count() == 0,
		"Interrupted action left bed reserved")
	var chair_b_authored := chair_b.global_position
	_check(world.move_object(&"chair_b", Vector2(-180, -180)),
		"Navigation-failure probe could not stage inaccessible chair")
	await physics_frame
	_check(customer_b.request_interaction_on(&"chair_b", &"sit"),
		"Navigation-failure probe could not reserve chair")
	for frame in 450:
		if customer_b.phase == HardeningActor.Phase.IDLE:
			break
		await physics_frame
	_check(customer_b.phase == HardeningActor.Phase.IDLE and customer_b.failed_navigation
		and seat_b.use_count() == 0,
		"Navigation failure did not release inaccessible Chair B")
	_check(world.move_object(&"chair_b", chair_b_authored),
		"Navigation-failure probe did not restore Chair B")
	await physics_frame

	# Reset the probe actor near its authored starting point; this is test staging,
	# not generic behavior or an authored destination constant.
	probe.global_position = start
	_check(world.run_multi_agent_demo(), "Multi-agent requests/alternates failed")
	for frame in 1000:
		if not world.demo_running:
			break
		await physics_frame
	_check(not world.demo_running and world.all_reservations_clear(),
		"Multi-agent demo failed to complete or release")
	_check(world.actors.get_node("CatB").last_action == &"sniff",
		"Second cat did not choose alternate sniff action")
	_check((world.actors.get_node("Worker") as HardeningActor).last_action == &"work_coffee",
		"Worker never performed coffee action")

	var espresso := world.find_object(&"espresso_station")
	var counter := world.find_object(&"counter_shell")
	var order_before := (counter.get_node("OrderPoint") as Marker2D).global_position
	var anchors := ["CoffeeActionSlot/ActionAnchor", "SteamFXAnchor", "CupSpawnAnchor",
		"CameraBrewFocus", "CameraCupReveal"]
	var before := []
	for name in anchors:
		before.append((espresso.get_node(name) as Node2D).global_position)
	var revision := nav.revision
	var espresso_move := Vector2(-30, 19)
	_check(world.move_object(&"espresso_station", espresso.global_position + espresso_move),
		"Espresso move rejected")
	await physics_frame
	_check(nav.revision > revision, "Navigation did not update after espresso move")
	for i in anchors.size():
		_check((espresso.get_node(anchors[i]) as Node2D).global_position.is_equal_approx(before[i] + espresso_move),
			"Espresso-owned anchor failed to follow: %s" % anchors[i])
	_check((counter.get_node("OrderPoint") as Marker2D).global_position.is_equal_approx(order_before),
		"Counter OrderPoint incorrectly moved with Espresso")
	for tuple in [[&"chair_a", "SeatSlot/ActionAnchor"], [&"cat_bed", "RestSlot/ActionAnchor"],
		[&"plant", "SniffSlot/ActionAnchor"]]:
		var object := world.find_object(tuple[0])
		var slot_anchor := object.get_node(tuple[1]) as Marker2D
		var object_footprint := object.get_node("PhysicalFootprint") as HardeningFootprint
		var anchor_before := slot_anchor.global_position
		var collision_before := object_footprint.global_position
		var delta := Vector2(15, -9)
		_check(world.move_object(tuple[0], object.global_position + delta),
			"Object move rejected: %s" % tuple[0])
		await physics_frame
		_check(slot_anchor.global_position.is_equal_approx(anchor_before + delta),
			"Owned slot failed to follow %s" % tuple[0])
		_check(object_footprint.global_position.is_equal_approx(collision_before + delta),
			"Collision/footprint failed to follow %s" % tuple[0])
		_check(world.find_object(tuple[0]) == object, "Semantic lookup failed after move")
	_check(customer_a.request_interaction_on(&"chair_a", &"sit"),
		"Customer could not use relocated Chair A")
	_check(cat_a.request_interaction_on(&"cat_bed", &"rest"),
		"Cat could not use relocated CatBed")
	_check(cat_b.request_interaction_on(&"plant", &"sniff"),
		"Cat could not use relocated Plant")
	var moved_worker := world.actors.get_node("Worker") as HardeningActor
	_check(moved_worker.request_interaction_on(&"espresso_station", &"work_coffee"),
		"Worker could not use relocated EspressoStation")
	for frame in 800:
		if customer_a.phase == HardeningActor.Phase.IDLE and cat_a.phase == HardeningActor.Phase.IDLE \
				and cat_b.phase == HardeningActor.Phase.IDLE and moved_worker.phase == HardeningActor.Phase.IDLE:
			break
		await physics_frame
	_check(customer_a.phase == HardeningActor.Phase.IDLE and not customer_a.failed_navigation,
		"Relocated Chair A route did not complete")
	_check(cat_a.phase == HardeningActor.Phase.IDLE and not cat_a.failed_navigation,
		"Relocated CatBed route did not complete")
	_check(cat_b.phase == HardeningActor.Phase.IDLE and not cat_b.failed_navigation,
		"Relocated Plant route did not complete")
	_check(moved_worker.phase == HardeningActor.Phase.IDLE and not moved_worker.failed_navigation,
		"Relocated Espresso route did not complete")
	_check(world.all_reservations_clear(), "Relocated object actions leaked reservations")
	var chair_placement := Vector2(100, 545)
	_check(not world.validate_placement(&"chair_a", table.global_position),
		"Placement accepted overlap with table footprint")
	_check(not world.validate_placement(&"chair_a", Vector2(-100, -100)),
		"Placement accepted outside room bounds")
	_check(world.validate_placement(&"chair_a", chair_placement, PI / 8.0),
		"Valid rotated chair placement rejected")
	var chair_anchor_before_rotation := seat_a.action_anchor().global_position
	_check(world.place_object(&"chair_a", chair_placement, PI / 8.0),
		"Rotated chair placement failed")
	await physics_frame
	_check(is_equal_approx(chair_a.global_rotation, PI / 8.0)
		and not seat_a.action_anchor().global_position.is_equal_approx(chair_anchor_before_rotation),
		"Rotation did not carry owned slot")
	var saved_chair := {}
	for record in world.placement_snapshot():
		if record["id"] == "chair_a":
			saved_chair = record
	_check(saved_chair.get("id", "") == "chair_a"
		and saved_chair.get("position", Vector2.ZERO).is_equal_approx(chair_placement)
		and is_equal_approx(saved_chair.get("rotation", 0.0), PI / 8.0),
		"Stable-id placement snapshot lost transform")

	var camera := world.get_node("Camera") as Camera2D
	var director := world.camera_director
	await _wait_camera_idle(director, 360)
	var controls := world.camera_input
	var hud := world.get_node("HUD") as CanvasLayer
	camera.global_position = Vector2(281, 439)
	camera.zoom = Vector2(1.31, 1.31)
	var camera_before := camera.global_position
	var zoom_before := camera.zoom
	var limits_before := [camera.limit_left, camera.limit_right, camera.limit_top, camera.limit_bottom]
	var hud_before := (hud.get_node("Status") as Control).position
	var shot := HardeningCameraShot.new()
	shot.shot_id = &"test_brew"
	shot.zoom = 2.4
	shot.transition_in = 0.08
	shot.hold_duration = 0.12
	shot.transition_out = 0.08
	_check(director.request_shot(espresso.get_node("CameraBrewFocus"), shot),
		"Brew focus rejected")
	_check(not controls.pan_by(Vector2(40, 0)) and not controls.zoom_by(1.1),
		"Player input fought focus shot")
	await _wait_camera_idle(director, 360)
	_check(camera.global_position.is_equal_approx(camera_before), "Camera position drift after focus")
	_check(camera.zoom.is_equal_approx(zoom_before), "Camera zoom drift after focus")
	_check(controls.input_enabled, "Gameplay input not restored")
	_check([camera.limit_left, camera.limit_right, camera.limit_top, camera.limit_bottom] == limits_before,
		"Camera limits changed")
	_check((hud.get_node("Status") as Control).position.is_equal_approx(hud_before),
		"CanvasLayer HUD moved with world camera")
	_check(controls.pan_by(Vector2(7, 0)) and controls.zoom_by(1.02),
		"Gameplay camera did not resume pan/zoom")
	shot.hold_duration = -1.0
	shot.shot_id = &"cancel_test"
	_check(director.request_shot(espresso.get_node("CameraBrewFocus"), shot), "Cancel shot rejected")
	director.cancel(&"test_cancel")
	_check(director.mode == HardeningCameraDirector.Mode.GAMEPLAY and controls.input_enabled,
		"Cancellation left director stuck")
	var original_after_cancel := camera.global_position
	var lower := HardeningCameraShot.new()
	lower.shot_id = &"low_priority"
	lower.priority = 10
	lower.hold_duration = -1.0
	var higher := HardeningCameraShot.new()
	higher.shot_id = &"high_priority"
	higher.priority = 50
	higher.hold_duration = -1.0
	_check(director.request_shot(espresso.get_node("CameraBrewFocus"), lower),
		"Low-priority shot did not start")
	_check(director.request_shot(espresso.get_node("CameraCupReveal"), higher),
		"Higher-priority shot could not interrupt")
	_check(not director.request_shot(espresso.get_node("CameraBrewFocus"), lower),
		"Lower-priority shot interrupted higher-priority shot")
	director.cancel(&"priority_test")
	_check(camera.global_position.is_equal_approx(original_after_cancel) and controls.input_enabled,
		"Priority interruption lost gameplay camera state")
	var temporary_focus := Marker2D.new()
	world.add_child(temporary_focus)
	temporary_focus.global_position = espresso.get_node("CameraBrewFocus").global_position
	_check(director.request_shot(temporary_focus, lower), "Temporary focus rejected")
	temporary_focus.queue_free()
	await process_frame
	_check(director.mode == HardeningCameraDirector.Mode.GAMEPLAY and controls.input_enabled,
		"Freed focus anchor left camera stuck")
	var emotion := HardeningCameraShot.new()
	emotion.shot_id = &"emotion_compatibility"
	emotion.transition_in = 0.08
	emotion.hold_duration = -1.0
	emotion.follow_target = true
	var emotion_anchor := customer_a.get_node("CameraEmotionFocus") as Marker2D
	_check(director.request_shot(emotion_anchor, emotion),
		"Character-owned emotion focus rejected")
	for frame in 120:
		if director.is_holding():
			break
		await process_frame
	customer_a.global_position += Vector2(12, 0)
	await process_frame
	_check(director.is_holding() and camera.global_position.is_equal_approx(emotion_anchor.global_position),
		"Camera did not follow moving character-owned focus anchor")
	director.cancel(&"emotion_done")
	_check(director.mode == HardeningCameraDirector.Mode.GAMEPLAY,
		"Emotion shot did not restore gameplay ownership")

	world.set_event_active(true)
	_check(world.find_object(&"seasonal_display") != null and world.all_slots(&"inspect").size() == 1,
		"Event object/slot not semantically discoverable")
	_check(world.focus_event(), "Event camera focus rejected")
	await _wait_camera_idle(director, 360)
	_check(director.mode == HardeningCameraDirector.Mode.GAMEPLAY,
		"Event camera failed to restore")
	_check((world.actors.get_node("CatB") as HardeningActor).request_interaction(&"inspect"),
		"Event interaction could not start")
	await _wait_idle(world.actors.get_node("CatB"), 500)
	_check(world.all_reservations_clear(), "Event interaction leaked reservation")
	world.set_event_active(false)
	_check(world.find_object(&"seasonal_display") == null and world.all_slots(&"inspect").is_empty(),
		"Event object survived off state in semantic registry")
	_check(world.find_object(&"chair_a") != null, "Base semantic registry broke after event toggle")
	world.set_event_active(true)
	var event_display := world.find_object(&"seasonal_display")
	_check((world.actors.get_node("CatB") as HardeningActor).request_interaction_on(
		&"seasonal_display", &"inspect"), "Event slot reserve failed before object removal")
	var before_removal_revision := nav.revision
	event_display.queue_free()
	await process_frame
	for frame in 30:
		if (world.actors.get_node("CatB") as HardeningActor).phase == HardeningActor.Phase.IDLE:
			break
		await physics_frame
	_check((world.actors.get_node("CatB") as HardeningActor).phase == HardeningActor.Phase.IDLE,
		"Object removal did not cancel actor interaction")
	_check(world.all_slots(&"inspect").is_empty(), "Removed event object remained discoverable")
	_check(nav.revision > before_removal_revision, "Object removal did not update navigation")

	var base_table_position := table.global_position
	var base_actor_script: Script = (world.actors.get_node("Worker") as HardeningActor).get_script()
	world.queue_free()
	await process_frame
	var event_room := EVENT_ROOM.instantiate() as HardeningWorld
	root.add_child(event_room)
	await physics_frame
	await physics_frame
	_check(event_room.event_active and event_room.find_object(&"seasonal_display") != null,
		"Separate event room did not activate variant")
	_check(not event_room.find_object(&"table").global_position.is_equal_approx(base_table_position),
		"Separate event room reused base placement")
	_check((event_room.actors.get_node("Worker") as HardeningActor).get_script() == base_actor_script,
		"Event room does not reuse generic actor script")
	var event_worker := event_room.actors.get_node("Worker") as HardeningActor
	var event_customer := event_room.actors.get_node("CustomerA") as HardeningActor
	var event_cat := event_room.actors.get_node("CatC") as HardeningActor
	_check(event_worker.request_interaction(&"work_coffee"),
		"Event-room worker could not find station")
	_check(event_customer.request_interaction(&"sit"),
		"Event-room customer could not find seat")
	_check(event_cat.request_interaction(&"inspect"),
		"Event-room cat could not find event slot")
	for frame in 650:
		if event_worker.phase == HardeningActor.Phase.IDLE \
				and event_customer.phase == HardeningActor.Phase.IDLE \
				and event_cat.phase == HardeningActor.Phase.IDLE:
			break
		await physics_frame
	_check(event_worker.phase == HardeningActor.Phase.IDLE and not event_worker.failed_navigation
		and event_customer.phase == HardeningActor.Phase.IDLE and not event_customer.failed_navigation
		and event_cat.phase == HardeningActor.Phase.IDLE and not event_cat.failed_navigation,
		"Shared actors failed in second event room")
	_check(event_room.all_reservations_clear(), "Event-room reservations leaked")
	await _wait_camera_idle(event_room.camera_director, 360)
	var exit_reasons: Array[StringName] = []
	event_room.camera_director.shot_ended.connect(
		func(_shot_id: StringName, reason: StringName) -> void: exit_reasons.append(reason))
	var exit_shot := HardeningCameraShot.new()
	exit_shot.shot_id = &"scene_exit_probe"
	exit_shot.hold_duration = -1.0
	_check(event_room.camera_director.request_shot(
		event_room.find_object(&"espresso_station").get_node("CameraBrewFocus"), exit_shot),
		"Scene-exit focus did not start")
	event_room.queue_free()
	await process_frame
	_check(exit_reasons.has(&"scene_exit"), "Scene exit failed to release camera ownership")
	if _ok:
		print("--- WORLD ARCHITECTURE HARDENING V1 PASSED ---")
	quit(0 if _ok else 1)


func _wait_idle(actor: HardeningActor, limit: int) -> void:
	for frame in limit:
		if actor.phase == HardeningActor.Phase.IDLE:
			return
		await physics_frame
	_check(false, "Actor timed out: %s" % actor.name)


func _wait_camera_idle(director: HardeningCameraDirector, limit: int) -> void:
	for frame in limit:
		if director.mode == HardeningCameraDirector.Mode.GAMEPLAY:
			return
		await process_frame
	_check(false, "CameraDirector timed out")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_ok = false
		push_error(message)


func _segment_enters_rect(a: Vector2, b: Vector2, rect: Rect2) -> bool:
	var steps := maxi(1, ceili(a.distance_to(b) / 2.0))
	for i in range(steps + 1):
		if rect.has_point(a.lerp(b, float(i) / float(steps))):
			return true
	return false
