# WilliCat Home Environment V3 — art direction V1

**Status: production-direction brief, not final-asset approval.** Spatial authority is the accepted [Staggered Salon scene](../../scenes/dev/home_v3_level_design_pass_01.tscn) and its [layout lock](../design/WILLICAT_HOME_V3_LAYOUT_LOCK_V1.md). This brief defines how to dress that room without changing its gameplay. No older café picture is a placement, collision or occlusion reference. Character identity remains with `WILLICAT_ORANGE_PROTAGONIST_FINAL_MASTER_V1`; relative family scale remains with `WILLICAT_CHARACTER_FAMILY_FINAL_SCALE_CHECK_V1`. Neither character asset is recreated here.

The named character master/scale-sheet files were not found in the current repository audit. Obtain the approved originals before final asset generation or final scale judgment; do not substitute the small greybox actor circles or an older concept character.

## Story, style and viewing hierarchy

A modest café is becoming a beloved home for cats and returning customers. It should look lovingly maintained, personal, lived in and capable of growing—not luxury-perfect, corporate, sterile, cluttered or like a theme park. Aim for roughly **half miniature-diorama clarity, half illustrated-storybook warmth**: believable object relationships and concise silhouettes, with matte brush/print softness and small handmade irregularities. Avoid glossy 3D, photoreal textures, flat vector UI, generic furniture-pack consistency and hard black/gold Art Deco spectacle.

First read: **cat/character life**. Second: active coffee/customer moments. Third: interactive furniture. Fourth: the café's architectural character. Last: small decoration. At 540×960 portrait framing, a cat's face/pose and floor contact must not disappear into wood grain, foliage, lighting or high-contrast trim. The camera remains elevated 3/4, soft-perspective, isometric-lite with no free rotation; do not turn the room into straight-on dollhouse scenery or full top-down tiles merely to simplify art.

## Palette, material and architecture

Use warm natural wood, creamy plaster/paint, muted deep jade, restrained aged brass, ceramic, soft textiles, plants and pastries. Establish one material family across fixed architecture and reusable objects, but give movable props their own silhouettes and roots. Light should be warm storybook daylight with soft directional emphasis from the window; task lights and warm interior accents may support evenings. Keep value contrast strongest around characters and active machines, then quieter on fixed walls and floor. Prefer painted/baked illumination as the base. Any real-time 2D lamp/window/event lights must be subtle optional accents and later profiled on mobile; no stack of lights should be necessary for the room to read.

The fixed room base can use shallow arches, gentle geometric trim, rounded corners, modest jade window/service frames, thin brass details and warm joinery. Soften Art Deco symmetry with hand-made shelving, imperfect ceramics and textiles. Represent the back/service wall and partial side boundaries strongly enough to make a miniature place, but keep their visual heights low/open enough for an elevated camera to see cats, seats and slots. The accepted walkable polygon and object footprints—not illustrated floor shadows—determine playable space.

## Spatial moments to design around

### One coherent service operation

CounterShell, POS, PastryCase, EspressoStation and GrinderStation must visually belong to one café workflow while staying **five separate gameplay scenes**. Unite them with a shared cabinetry datum, countertop material, service-wall trim, shallow shelving rhythm and warm task lighting. Counter/POS/Pastry form the customer-facing left bay; Espresso/Grinder form a connected preparation bay to the right. Use visual connectors in the **fixed architecture** or non-interactive micro-decor, not a single baked texture that would break object movement or independent interaction. Leave a quiet background behind Worker/Espresso so Brew and Cup focus remain legible. Counter front lip is its own registered visual piece and must cover a worker behind it without per-action z changes.

### Signature window corner

The right-side WindowPerch + Plant composition is the emotional landmark. Draw a clear window silhouette and soft daylight/rain background, then a comfortable, separate perch with an unobstructed cat silhouette at WatchSlot. Plant foliage can frame the scene but not bury the cat, camera marker or Sniff interaction. Keep a low-detail patch where a slow blink, daylight/rain mood, seasonal window story or tiny head FX could read. Fixed window belongs to the room; movable perch and plant stay separate object assets.

### Sheltered bed nook and scratch relationship

CatBed beside the first seating island needs perceived shelter: low shelf, folded textile, quiet wall recess or warm edge lighting, without creating a new navigation wall or attaching bed art to room pixels. A reusable bed can have back/cushion and a shallow front rim; a cat must visibly settle *inside* it, while Rest/Sleep anchors remain unchanged. ScratchPost near the left entry transition should feel anchored to a wall/shelf end/structural trim, not a pole adrift. Architectural framing is primarily room-base art; ScratchPost remains a separate interactable object with a visible cat approach. Neither treatment may narrow the proven route.

### Customer seating and entry

The two staggered table islands should share a family language but have different surrounding context: one nearer the bed, the other nearer the plant/event side. Vary rug weave, lamp/ceramic accent or wall relationship, not seat topology or chair scale. All four chairs stay individually movable; never bake chairs or characters into table art. Keep tabletops calm enough for sitting cats/customers and possible order/serve feedback to read.

Door art should clearly mark spawn, leave and story threshold. A small welcome sign and warm frame are appropriate, but the actual doorway and three invisible WaitSlots must stay visually open. No planters, tall arch legs, menu stands, mat bevels or leaf swing may close the central passage or hide a character crossing it.

### Event-capable niche

The right-side seasonal footprint is a modest stage within the café, not a detached event room. Base architecture should feel complete with EventLayer OFF: for example a quiet inset, floor border or small wall display surface. SeasonalDisplay ON may host Sakura, winter, lantern, pastry or visitor/story skins, but every variant retains the same root/footprint/InspectSlot/CameraFocus/FX contract and respects the entrance lane. Swap the content object and its local skin; do not repaint or re-author the whole room per season.

## Floor, boundary, depth and screen-space discipline

Replace temporary greybox rectangles with subtle material zoning: consistent wood direction or restrained inset borders, sparse rugs under the seating islands, a slightly distinct but coherent service floor and a threshold treatment. Avoid loud repeating tiles or high-contrast floor motifs under small cats. Floor pattern may imply use but cannot conceal a blocked path or fake a gameplay footprint. Fixed window/service wall/trim belong in Room Architecture. Reusable interactive objects remain PackedScenes with transparent standalone art. Only spatially justified front pieces are occluders; an oversized foreground wash that hides actor feet is invalid.

Each object exports around its **floor-contact root** with consistent elevated 3/4 facing. Include transparent padding for ears, high shelves, steam and foliage so the silhouette does not clip; padding is not collision. Where a character crosses an object, produce registered Back and Front layers on one local canvas; CounterFront is required, bed rim and chair/table edges are conditional on visual QA. Preserve Y-sort ancestry and no per-state actor z-index hack. CameraDirector's World, Brew, Cup, Cat Emotion and Event shots must all be reviewed at 9:16 and tall-phone sizes with final art; do not compensate for bad art by hard-coding new map pixels.

## Dynamic surfaces, FX and variants

Reserve a clean main café-name surface, optional secondary sign and a small menu/feature board. Runtime text owns the player café name and changing offers; never bake a particular final name into the environment. Surfaces should survive readable localization and stay clear of cat silhouettes/door actions.

Leave negative space and correct attachment for Espresso SteamFX/BrewFX/CupRevealFX, cat Heart/Purr/Head/Feet FX, Bed SleepFX and EventFX. These attach to existing object/actor markers and must remain visible against the backdrop without requiring glossy production effects. Base material should allow morning, rainy daylight, warm evening, autumn, winter, Sakura and lantern-night variants. Keep explicitly seasonal props and light cues out of canonical base sprites; use replaceable overlays/skins and restrained graded lighting later.

## Component production, batches and rejection criteria

Production hierarchy is: **room base** (floor/fixed walls/fixed window/trim), **reusable world objects**, **local back/front occluders where necessary**, then **runtime characters/signage/FX/event content**. Never create one café painting and reverse-cut it into gameplay pieces. The [locked object handoff](../production/WILLICAT_HOME_V3_ART_HANDOFF_SPEC_LOCK_V1.md) specifies every object asset's size, root, footprint, slot, camera/FX and transparency contract.

Recommended risk-first batches:

1. **Spatial/material foundation:** floor, low fixed boundaries, signature window structure and service-wall connectors. Prove camera/clearance/value hierarchy with placeholders or paintovers that do not alter scene transforms.
2. **High-risk gameplay silhouettes:** CounterShell split, Espresso, PastryCase, tables and chairs. These establish occlusion, scale, service cohesion and seat readability; validate in Godot before producing decorative variants. POS/Grinder complete the service family here.
3. **Cat-life objects:** WindowPerch, CatBed, Plant, ScratchPost. Validate cat silhouette, owned action position and bed/perch occlusion against the first batch.
4. **Threshold/identity/season:** Entrance, runtime sign surfaces and base event framework. Validate both Event OFF/ON, door crossing and portrait safe area before creating seasonal skins.

Every batch follows `locked Godot object → art contract → artist/generator → Asset Forge normalization/QA → Godot visual replacement → runtime captures → human review`. Provider choice (manual art, OpenAI image generation, SpriteCook or another provider) does not change the Godot contract. Asset Forge processes pixels and registration; it never chooses a world coordinate. Reject an asset if it changes a slot/root/footprint, closes an apparently open route, makes cat or coffee action too small/hidden, bakes another gameplay object into it, breaks moving-furniture coherence, conflicts with the 3/4 camera or leaves the matte WilliCat visual universe. Any true spatial contradiction returns to explicit layout re-review; art does not silently unlock it.
