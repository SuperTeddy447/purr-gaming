extends SceneTree
## Guards production slot ownership and the temporary visual-master comparison mode.

const HOME_SCENE: String = "res://scenes/home/home_scene.tscn"
const LEGACY_REFERENCE: String = "res://docs/references/WILLICAT_HOME_CAMERA_PROTOTYPE_V2_1.png"
const VISUAL_MASTER: String = "res://docs/references/home/WILLICAT_HOME_ENVIRONMENT_STYLE_LOCK_V1.png"
const EXPECTED_SIZE: Vector2 = Vector2(941, 1672)


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var home: HomeScene = (load(HOME_SCENE) as PackedScene).instantiate() as HomeScene
	root.add_child(home)
	await process_frame

	var world: Node2D = home.get_node("World") as Node2D
	var legacy: Sprite2D = world.get_node("StructuralBase/DEV_REFERENCE_ONLY") as Sprite2D
	var master: Sprite2D = world.get_node("StructuralBase/DEV_VISUAL_MASTER") as Sprite2D
	if legacy.texture.resource_path != LEGACY_REFERENCE or legacy.visible:
		_fail("Existing R-controlled V2.1 reference must remain unchanged but hidden in the modular default view")
		return
	if master.texture.resource_path != VISUAL_MASTER or master.visible or master.centered or \
		master.position != Vector2.ZERO or master.scale != Vector2.ONE:
		_fail("Temporary style master must start hidden, at native 1:1 size and origin")
		return
	if master.texture.get_size() != EXPECTED_SIZE or legacy.texture.get_size() != EXPECTED_SIZE:
		_fail("Visual master and legacy reference must share the exact 941x1672 alignment canvas")
		return
	print("[PASS] Locked style master is referenced unchanged and aligned 1:1 with the legacy 941x1672 canvas.")

	var f6: InputEventKey = InputEventKey.new()
	f6.keycode = KEY_F6
	f6.pressed = true
	Input.parse_input_event(f6)
	await process_frame
	var modular_slot: CanvasItem = home.get_node("World/StructuralBase/HomeBakedBaseSlot") as CanvasItem
	var mochi: CanvasItem = home.get_node("World/DepthSortedLayer/MochiScaleTestDEV") as CanvasItem
	if not master.visible or modular_slot.visible or not mochi.visible:
		_fail("F6 must show only the locked environment master while keeping runtime characters visible")
		return
	Input.parse_input_event(f6)
	await process_frame
	if master.visible or not modular_slot.visible:
		_fail("F6 must restore the modular composition")
		return
	print("[PASS] F6 compares the locked master against the modular Home composition without hiding runtime actors.")

	var required_slots: Array[NodePath] = [
		NodePath("World/StructuralBase/HomeBakedBaseSlot"),
		NodePath("World/StructuralBase/HomeBakedBaseSlot/EntranceDoorwayPlateSlot"),
		NodePath("World/RoomSkinLayer/FloorSkinSlot"),
		NodePath("World/RoomSkinLayer/WallSurfaceSkinSlot"),
		NodePath("World/RoomSkinLayer/RoomThemeOverlaySlot"),
		NodePath("World/BackDecorLayer/CounterBackSlot"),
		NodePath("World/BackDecorLayer/EspressoStationSlot"),
		NodePath("World/BackDecorLayer/PastryDisplaySlot"),
		NodePath("World/BackDecorLayer/POSSlot"),
		NodePath("World/DepthSortedLayer/Table1Slot"),
		NodePath("World/DepthSortedLayer/Table2Slot"),
		NodePath("World/DepthSortedLayer/ChairTable1LeftSlot"),
		NodePath("World/DepthSortedLayer/ChairTable2LeftSlot"),
		NodePath("World/DepthSortedLayer/ChairTable2RightSlot"),
		NodePath("World/DepthSortedLayer/EntranceDoorLeftLeafSlot"),
		NodePath("World/DepthSortedLayer/EntranceDoorRightLeafSlot"),
		NodePath("World/ForegroundOccluderLayer/CounterFrontSlot"),
		NodePath("World/ForegroundOccluderLayer/EntranceForegroundSlot"),
		NodePath("World/ForegroundOccluderLayer/ForegroundPlantsSlot"),
		NodePath("World/FXLayer/CoffeeSteamSlot"),
		NodePath("World/FXLayer/EspressoActionFXSlot"),
		NodePath("World/FXLayer/ServeFeedbackSlot"),
		NodePath("World/FXLayer/PastryHighlightSlot")
	]
	for slot_path in required_slots:
		var slot: Node = home.get_node_or_null(slot_path)
		if slot == null or not slot.is_in_group(&"production_asset_slot"):
			_fail("Missing explicitly owned production asset slot: %s" % String(slot_path))
			return
	print("[PASS] Production slots exist under the locked Home layer owners.")

	var depth_layer: Node2D = world.get_node("DepthSortedLayer") as Node2D
	var table_1: Node2D = depth_layer.get_node("Table1") as Node2D
	var table_1_slot: Node2D = depth_layer.get_node("Table1Slot") as Node2D
	var table_2: Node2D = depth_layer.get_node("Table2") as Node2D
	var table_2_slot: Node2D = depth_layer.get_node("Table2Slot") as Node2D
	var counter_front: Node2D = world.get_node("ForegroundOccluderLayer/CounterFrontOccluder") as Node2D
	var counter_front_slot: Node2D = world.get_node("ForegroundOccluderLayer/CounterFrontSlot") as Node2D
	if not depth_layer.y_sort_enabled or table_1_slot.position != table_1.position or \
		table_2_slot.position != table_2.position or \
		(depth_layer.get_node("ChairTable1LeftSlot") as Node2D).position != \
		(depth_layer.get_node("ChairTable1_Left") as Node2D).position or \
		(depth_layer.get_node("ChairTable2LeftSlot") as Node2D).position != \
		(depth_layer.get_node("ChairTable2_Left") as Node2D).position or \
		(depth_layer.get_node("ChairTable2RightSlot") as Node2D).position != \
		(depth_layer.get_node("ChairTable2_Right") as Node2D).position or \
		counter_front_slot.position != counter_front.position or \
		world.get_node("DepthSortedLayer/EntranceDoorLeftLeafSlot").get_parent() != depth_layer:
		_fail("Depth-sensitive slots must retain existing floor-contact anchors and the locked Y-sort owner")
		return
	if int(depth_layer.z_index) != 50 or int(world.get_node("BackDecorLayer").z_index) != 20 or \
		int(world.get_node("ForegroundOccluderLayer").z_index) != 80:
		_fail("Production slots must not change the locked counter/depth layer ordering")
	print("[PASS] Table/door leaf slots use DepthSortedLayer; counter foreground slot remains in the existing occluder layer.")

	for surface_name in ["CafeNameSurface", "HangingSignSurface", "MenuSloganSurface", "FreestandingSignSurface"]:
		var sign: DynamicSign = home.get_node("DynamicSignage/" + surface_name) as DynamicSign
		if not sign.debug_placeholder_text.is_empty() or not sign.get_text().is_empty():
			_fail("Dynamic sign %s must remain blank until runtime content is assigned" % surface_name)
			return
	print("[PASS] All four runtime sign surfaces are blank and no text is baked into the new environment master.")

	home.queue_free()
	await process_frame
	print("--- ALL HOME PRODUCTIONIZATION PASS 01 CHECKS PASSED ---")
	quit(0)


func _fail(message: String) -> void:
	printerr("[FAIL] " + message)
	quit(1)
