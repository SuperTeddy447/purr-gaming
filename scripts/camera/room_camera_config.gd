class_name RoomCameraConfig
extends Resource
## Configuration resource for room-specific camera boundaries, framing, and zoom limits.
## Allows future rooms (Bakery, Lounge, Terrace) to provide their own camera settings
## without modifying the CameraController script or gameplay logic.

@export_group("Framing & Position")
@export var default_camera_position: Vector2 = Vector2(470.5, 836.0)

@export_group("Zoom Limits")
@export_range(0.5, 1.0, 0.01) var design_min_zoom: float = 0.82
@export_range(0.8, 1.5, 0.01) var default_zoom: float = 1.0
@export_range(1.0, 2.5, 0.01) var max_zoom: float = 1.35

@export_group("World Pan Bounds")
## World boundary rectangle outside of which the camera cannot pan.
## Room-specific drawable extents; the default values use the reference design coordinate space.
@export var pan_bounds: Rect2 = Rect2(0, 0, 941, 1672)
