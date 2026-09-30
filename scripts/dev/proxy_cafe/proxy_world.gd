extends PlaceholderWorld
const PROXY_CAFE := preload("res://scenes/dev/proxy_cafe/proxy_main_cafe.tscn")
const GARDEN := preload("res://scenes/dev/playable_placeholder/back_garden.tscn")

func _scene_for(room_id: StringName) -> PackedScene:
    match room_id:
        &"home_cafe_main": return PROXY_CAFE
        &"home_cafe_garden": return GARDEN
    return null
