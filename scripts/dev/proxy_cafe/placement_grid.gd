class_name ProxyPlacementGrid
extends RefCounted
## A logical 32-world-unit placement grid independent of floor artwork.
const CELL_SIZE := 32
var occupied: Dictionary = {}
var cell_bounds := Rect2i(0, 0, 20, 32)

func world_to_cell(world: Vector2) -> Vector2i:
    return Vector2i(floori(world.x / CELL_SIZE), floori(world.y / CELL_SIZE))

func cell_to_world(cell: Vector2i) -> Vector2:
    return Vector2(cell * CELL_SIZE) + Vector2.ONE * (CELL_SIZE * 0.5)

func snap_to_cell(world: Vector2) -> Vector2:
    return cell_to_world(world_to_cell(world))

func can_place(origin: Vector2i, footprint: Vector2i, clearance: int = 0) -> bool:
    for y in range(origin.y - clearance, origin.y + footprint.y + clearance):
        for x in range(origin.x - clearance, origin.x + footprint.x + clearance):
            var cell := Vector2i(x, y)
            if not cell_bounds.has_point(cell) or occupied.has(cell):
                return false
    return true

func occupy(id: StringName, origin: Vector2i, footprint: Vector2i, clearance: int = 0) -> bool:
    if not can_place(origin, footprint, clearance):
        return false
    for y in range(origin.y, origin.y + footprint.y):
        for x in range(origin.x, origin.x + footprint.x):
            occupied[Vector2i(x, y)] = id
    return true
