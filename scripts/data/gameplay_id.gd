class_name GameplayID
extends RefCounted
## Stable semantic IDs for WilliCat gameplay nodes, rooms, stations, and entities.
## Avoids coupling gameplay state or save data to scene node names or file paths.

# Rooms
const ROOM_MAIN_CAFE: StringName = &"room_main_cafe"
const ROOM_BAKERY: StringName = &"room_bakery"
const ROOM_LOUNGE: StringName = &"room_lounge"
const ROOM_TERRACE: StringName = &"room_terrace"
const ROOM_SECOND_FLOOR: StringName = &"room_second_floor"

# Stations & Interaction Points
const STATION_COFFEE: StringName = &"station_coffee_01"
const COUNTER_ORDER: StringName = &"counter_order_01"
const COUNTER_SERVE: StringName = &"counter_serve_01"
const WORKER_IDLE: StringName = &"worker_idle_01"

# Spawns & Exits
const CUSTOMER_SPAWN: StringName = &"customer_spawn_01"
const CUSTOMER_EXIT: StringName = &"customer_exit_01"

# Seats
const SEAT_MAIN_A: StringName = &"seat_main_a"
const SEAT_MAIN_B: StringName = &"seat_main_b"
const SEAT_MAIN_C: StringName = &"seat_main_c"
const SEAT_MAIN_D: StringName = &"seat_main_d"

# Ambient / Cat Idle Points
const AMBIENT_MAIN_A: StringName = &"ambient_main_a"
const AMBIENT_MAIN_B: StringName = &"ambient_main_b"
const AMBIENT_MAIN_C: StringName = &"ambient_main_c"

# Dynamic Sign Surfaces
const SIGN_CAFE_NAME: StringName = &"sign_cafe_name"
const SIGN_HANGING: StringName = &"sign_hanging"
const SIGN_MENU_SLOGAN: StringName = &"sign_menu_slogan"
const SIGN_FREESTANDING: StringName = &"sign_freestanding"
