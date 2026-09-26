class_name SliceRewardState
extends RefCounted
## Session-only counter for this prototype loop.

signal reward_added(amount: int, total: int, order_id: StringName)

var coins: int = 0
var rewarded_order_instances: Dictionary = {}


func add_reward(amount: int, order_instance_id: StringName) -> bool:
	if order_instance_id == &"" or rewarded_order_instances.has(order_instance_id):
		return false
	rewarded_order_instances[order_instance_id] = true
	coins += amount
	reward_added.emit(amount, coins, order_instance_id)
	return true
