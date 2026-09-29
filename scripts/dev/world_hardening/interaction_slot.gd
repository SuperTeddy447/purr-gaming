@tool
class_name HardeningInteractionSlot
extends Node2D
## Atomic single-threaded reservation. Actor ids avoid retaining freed actors.

signal reserved(actor_id: int)
signal occupied(actor_id: int)
signal released(actor_id: int, reason: StringName)

@export var action_type: StringName = &"inspect"
@export var allowed_categories := PackedStringArray(["cat", "customer", "worker"])
@export_range(1, 8) var capacity := 1
@export var enabled := true:
	set(value):
		enabled = value
		if not value and is_inside_tree():
			release_all(&"disabled")
@export_range(-10, 10) var priority := 0
@export_range(0.05, 10.0) var action_duration := 0.8
@export var facing_policy: StringName = &"toward_action"
@export var character_action: StringName = &"Inspect"
@export var object_action: StringName = &"Active"
@export var fx_trigger: StringName = &""
@export var camera_shot_id: StringName = &""
@export var tags := PackedStringArray()

var _holders: Dictionary = {} # instance id -> reserved/occupied
var _actor_refs: Dictionary = {} # instance id -> WeakRef


func _object_owner() -> HardeningWorldObject:
	var node: Node = get_parent()
	while node != null:
		if node is HardeningWorldObject:
			return node as HardeningWorldObject
		node = node.get_parent()
	return null


func accepts(actor: Node) -> bool:
	if not enabled or actor == null or not is_instance_valid(actor):
		return false
	if not actor.is_inside_tree() or not actor.has_method("actor_category"):
		return false
	if not allowed_categories.has(String(actor.actor_category())):
		return false
	var id := actor.get_instance_id()
	if _holders.has(id):
		return true
	if _holders.size() >= capacity:
		return false
	var world_object := _object_owner()
	return world_object == null or world_object.can_accept_actor(actor)


func reserve(actor: Node) -> bool:
	if not accepts(actor):
		return false
	var id := actor.get_instance_id()
	if _holders.has(id):
		return true
	var world_object := _object_owner()
	if world_object != null and not world_object.claim_actor(actor):
		return false
	_holders[id] = &"reserved"
	_actor_refs[id] = weakref(actor)
	actor.tree_exiting.connect(_on_actor_exiting.bind(id), CONNECT_ONE_SHOT)
	reserved.emit(id)
	return true


func occupy(actor: Node) -> bool:
	if actor == null or not is_instance_valid(actor):
		return false
	var id := actor.get_instance_id()
	if _holders.get(id, &"") != &"reserved":
		return false
	_holders[id] = &"occupied"
	occupied.emit(id)
	return true


func release(actor: Node, reason: StringName = &"complete") -> void:
	if actor != null and is_instance_valid(actor):
		_release_id(actor.get_instance_id(), reason)


func _on_actor_exiting(id: int) -> void:
	_release_id(id, &"actor_removed")


func _release_id(id: int, reason: StringName) -> void:
	if not _holders.has(id):
		return
	var ref: WeakRef = _actor_refs.get(id)
	var actor: Node = ref.get_ref() if ref != null else null
	if actor != null and is_instance_valid(actor):
		var callback := _on_actor_exiting.bind(id)
		if actor.tree_exiting.is_connected(callback):
			actor.tree_exiting.disconnect(callback)
	_holders.erase(id)
	_actor_refs.erase(id)
	var world_object := _object_owner()
	if world_object != null:
		world_object.release_actor(id)
	released.emit(id, reason)


func release_all(reason: StringName = &"cancel") -> void:
	for id in _holders.keys():
		_release_id(id, reason)


func is_reserved_by(actor: Node) -> bool:
	return actor != null and is_instance_valid(actor) and _holders.has(actor.get_instance_id())


func is_occupied_by(actor: Node) -> bool:
	return actor != null and is_instance_valid(actor) and _holders.get(actor.get_instance_id(), &"") == &"occupied"


func use_count() -> int:
	return _holders.size()


func approach_anchor() -> Marker2D:
	return $ApproachAnchor as Marker2D


func action_anchor() -> Marker2D:
	return $ActionAnchor as Marker2D


func exit_anchor() -> Marker2D:
	return $ExitAnchor as Marker2D


func _exit_tree() -> void:
	release_all(&"object_removed")


func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, 5, Color(0.2, 0.7, 0.85, 0.8))
