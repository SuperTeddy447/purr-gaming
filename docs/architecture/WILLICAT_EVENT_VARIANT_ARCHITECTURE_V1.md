# Event variant architecture V1

Status: two dev-room proofs; no production event framework.

The base Room owns Architecture, Navigation, WorldObjects, Characters, Foreground, FX, Camera and a separately toggleable EventLayer. An event object is still a WorldObject with stable ID, footprint, slots, FX/focus anchors and ordinary reservation semantics. The room activation controller gates EventLayer visibility, slot enablement, semantic discovery and navigation contribution together. Merely hiding art is insufficient: invisible collision or a stale `inspect` slot would be a bug.

`SeasonalDisplay.tscn` supplies a primitive visual, InspectSlot, EventFX and CameraEventFocus. The base hardening lab toggles it off/on (F10); a cat can discover and use `inspect`, the director can focus its anchor (F11), and removing the object cancels use and updates nav. Base chair/coffee discovery remains valid through the toggle. `world_architecture_hardening_event_room.tscn` inherits the lab with a changed layout and an active event layer; the same actor/slot/controller scripts complete coffee, sit and inspect there. These prove both base-room overlay and separate event room compatibility; they do not prove event scheduling, content streaming or final art.

Production variant data should be a typed Resource or PackedScene composition with room ID, event ID, object instance IDs, activation conditions, assets and conflict policy. Runtime save data records active variant and per-object state. Actor behavior only asks for semantic slots; it does not branch on Sakura/HotSpring/WinterMarket or map coordinates. Future HotSpring can own multiple SoakSlots plus front water occluder and CameraFocus; future GardenPatch can own Dig/Plant/Harvest slots. Neither gameplay feature exists in this task.
