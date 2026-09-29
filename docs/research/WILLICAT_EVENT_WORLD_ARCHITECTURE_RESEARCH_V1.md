# Event-world architecture research V1

Status: compatibility proof, not a seasonal content system.

The [PackedScene](https://docs.godotengine.org/en/4.7/classes/class_packedscene.html) model allows a base Room scene and an inherited or separately composed event Room to reuse object and actor scenes; the repository's inherited event-room test demonstrates this use. Godot's [CanvasItem visibility](https://docs.godotengine.org/en/4.7/classes/class_canvasitem.html) is visual only; hiding an EventLayer does not by itself remove collision, navigation geometry or semantic destinations. The room must gate all three explicitly.

WilliCat therefore separates two forms:

1. Base-room overlay: an EventLayer contains temporary PackedScene props, event FX, semantic slots and camera anchors. Toggle updates visibility, slot enablement and navigation contribution together. Base lookup continues to work. The hardening lab's SeasonalDisplay provides `InspectSlot`, FX placeholder and `CameraEventFocus`.
2. Separate event room/zone: another Room scene instances the **same** actor, slot, station, furniture, camera and navigation components but supplies different authored transforms. `world_architecture_hardening_event_room.tscn` inherits the lab and starts with its event variant active. The same worker/customer/cat script completes coffee/sit/inspect there.

An activation flag in the isolated lab is deliberately not an event scheduler. Production will need a typed EventVariant definition, room-scoped stable IDs, conflict rules for overlapping variants, content loading/unloading, save state and telemetry/QA. Character controllers must never branch on event name or map coordinates; they request semantic capabilities.

Future HotSpring can be a WorldObject with multiple capacity-1 SoakSlots, entry/exit anchors, a front water occluder, FX anchors and a focus marker; room reservation/actor binding already supports that shape, but water depth and multiplayer occupancy are **not** tested. A DigPatch/GardenPatch can expose Dig/Plant/Harvest slots plus state/loot/FX anchors without changing generic navigation. No farming or hot-spring gameplay was implemented.
