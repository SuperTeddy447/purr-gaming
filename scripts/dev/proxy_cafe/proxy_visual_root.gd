extends Node2D
## Presentation-only adapter; the parent HardeningActor still owns all movement.
const SOURCE := "res://assets/dev_proxy/pixel_crawler/"
var _actor: HardeningActor
var _sprite: AnimatedSprite2D
var _facing := "down"

func _ready() -> void:
    _actor = get_parent() as HardeningActor
    var frames := SpriteFrames.new()
    for motion in ["idle", "walk"]:
        for direction in ["down", "up", "side"]:
            var key: String = String(motion) + "_" + String(direction)
            frames.add_animation(key)
            frames.set_animation_speed(key, 4.0 if motion == "idle" else 9.0)
            frames.set_animation_loop(key, true)
            var strip := load(SOURCE + key + ".png") as Texture2D
            var count := 4 if motion == "idle" else 6
            for i in count:
                var atlas := AtlasTexture.new()
                atlas.atlas = strip
                atlas.region = Rect2(i * 64, 0, 64, 64)
                frames.add_frame(key, atlas)
    _sprite = AnimatedSprite2D.new()
    _sprite.name = "TemporaryProxySprite"
    _sprite.sprite_frames = frames
    _sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    _sprite.scale = Vector2(2, 2)
    _sprite.position = Vector2(0, -32)
    add_child(_sprite)
    _sprite.play("idle_down")

func _process(_delta: float) -> void:
    if _actor == null:
        return
    var walking := _actor.phase in [HardeningActor.Phase.APPROACH, HardeningActor.Phase.EXIT, HardeningActor.Phase.ROUTE] and _actor.velocity.length_squared() > 4.0
    if walking:
        var v := _actor.velocity
        if absf(v.x) > absf(v.y):
            _facing = "side"
            _sprite.flip_h = v.x < 0.0
        else:
            _facing = "up" if v.y < 0.0 else "down"
            _sprite.flip_h = false
    var desired := ("walk_" if walking else "idle_") + _facing
    if _sprite.animation != desired:
        _sprite.play(desired)
