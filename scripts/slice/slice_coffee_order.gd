class_name SliceCoffeeOrder
extends Resource
## The only order in Vertical Slice 001; not a recipe or order database.

@export var order_id: StringName = &"order_coffee_basic_01"
@export_range(1, 100, 1) var reward_coins: int = 5
