class_name HomeCounterSystem
extends Node
## Logical cross-layer assembly for the café counter; adds no gameplay behavior.

@export var counter_back_path: NodePath = ^"../World/BackDecorLayer/CounterBackSlot"
@export var counter_front_path: NodePath = ^"../World/ForegroundOccluderLayer/CounterFrontSlot"
@export var worker_region_path: NodePath = ^"WorkerRegion"
@export var counter_top_prop_anchors_path: NodePath = ^"CounterTopPropAnchors"
@export var interaction_anchors_path: NodePath = ^"../GameplayNodes"

var tint: Color = Color.WHITE


func set_skin_color(color: Color) -> void:
	tint = color
	var back := get_node_or_null(counter_back_path) as HomeAssetSlot
	var front := get_node_or_null(counter_front_path) as HomeAssetSlot
	if back != null:
		back.set_tint(color)
	if front != null:
		front.set_tint(color)
