# WILLICAT AGENT BOOTSTRAP V1

**WELCOME NEW AGENT.**
This is the canonical onboarding document for the WilliCat project. Read this before touching any production files. This repository contains months of deprecated prototypes, legacy tests, and locked architecture. Do not trust your pre-trained memory of older WilliCat versions.

## 1. PROJECT NORTH STAR
WilliCat is a collectible-cat living café where cats actually work, rest, explore, interact with furniture, and develop recognizable routines. The environment is a behavioral world, not merely a background.
**Anti-Clone Rule:** If cats could be replaced by generic human workers without materially changing the game, the system is not using WilliCat identity enough. It is feline-first.

## 2. SOURCE-OF-TRUTH HIERARCHY
Conflicts are resolved in this explicit order of authority:
1. **GODOT SCENE / LEVEL DATA**: The spatial and gameplay source of truth (e.g., foot coordinates, collisions).
2. **WORLD / ARCHITECTURE CONTRACTS**: The system behavior truth (e.g., InteractionSlots).
3. **CHARACTER MASTER REFERENCES**: The character identity truth (e.g., Orange Protagonist).
4. **VISUAL TARGET**: The environment visual-direction truth (mood, aesthetic).
5. **LIGHTING CONTRACT**: Baked-vs-runtime lighting truth.
6. **ASSET FORGE**: The processing and validation pipeline truth.
7. **AI GENERATED ART**: Visual input only. **NEVER** world-layout or spatial authority.

## 3. CURRENT LOCKED STATE
The following project milestones are currently established. Do not alter them without explicit human permission:
- **Production World Architecture**: [LOCKED](file:///Users/teddywoot/willi-cat/docs/architecture/WILLICAT_PRODUCTION_WORLD_ARCHITECTURE_V1.md)
- **Home V3 Staggered Salon Layout**: [LOCKED](file:///Users/teddywoot/willi-cat/docs/design/WILLICAT_HOME_V3_LAYOUT_LOCK_V1.md)
- **InteractionSlot System**: [LOCKED](file:///Users/teddywoot/willi-cat/docs/architecture/WILLICAT_INTERACTION_SLOT_CONTRACT_V1.md)
- **World Atmosphere Architecture**: [PROOFED](file:///Users/teddywoot/willi-cat/docs/architecture/WILLICAT_WORLD_ATMOSPHERE_ARCHITECTURE_V1.md)
- **Real-Art Lighting Proof**: [PROOFED](file:///Users/teddywoot/willi-cat/docs/production/WILLICAT_HOME_V3_REAL_ART_LIGHTING_PROOF_REVISION_RESULT_V1.md)
- **Character Visual Identity**: [LOCKED](file:///Users/teddywoot/willi-cat/docs/references/characters/WILLICAT_ORANGE_PROTAGONIST_FINAL_MASTER_V1.png)
- **Character Family Scale**: [LOCKED](file:///Users/teddywoot/willi-cat/docs/references/family/WILLICAT_CHARACTER_FAMILY_FINAL_SCALE_CHECK_V1.png)
- **Environment Art Direction**: [PROVISIONAL](file:///Users/teddywoot/willi-cat/docs/art/WILLICAT_HOME_ENVIRONMENT_V3_ART_DIRECTION_V1.md) (Final art pending generation)
- **Character Runtime Architecture**: [PROVISIONAL](file:///Users/teddywoot/willi-cat/docs/architecture/WILLICAT_CHARACTER_RUNTIME_PRODUCTION_CONTRACT_V1.md)

## 4. DEPRECATED WORKFLOWS (DO NOT REVIVE)
The following approaches were tested and rejected. **DO NOT REVIVE THEM**:
- **Concept Image as Gameplay Coordinate Truth:** AI images cannot dictate collision or layout. Godot is the spatial authority.
- **Full Café Image → Cut Sprites:** You cannot paint an entire café and cut it up. Assets must be component-based with transparent pads and root registration.
- **Hard-coded Map Vector2 Destinations:** Characters cannot embed map-specific (x, y) coordinates.
- **Global Gameplay Markers:** Markers detached from the objects they belong to break when furniture moves.
- **State-specific Z-Index Hacks:** Using `z_index` changes to fake occlusion is forbidden. We use Godot's Y-Sort from floor-contact roots.
- **Baked Permanent Lighting:** Art must not have long cast shadows or day/night tints baked into the PNG.
- **Texture Canvas == World Display Size:** Assets are independently cropped and padded.
- **Animation Owning Gameplay State:** Animations present state; they do not dictate rewards or task completion.
- **Old Home V2/Mochi Architecture:** Legacy code exists for reference only.

## 5. WORLD OBJECT CONTRACT
World objects (chairs, beds, stations) own their own geometry and logic:
- Floor footprints and collisions
- `InteractionSlots` (semantic markers for actions)
- Camera focus anchors (`Marker2D`)
- FX anchors
**Workflow:** Actors request semantic actions (e.g., `request_interaction("sit")`), which the room resolves to a compatible slot. The actor reserves, approaches, occupies, performs, exits, and releases the slot.

## 6. HOME V3 (STAGGERED SALON)
The canonical scene is `home_v3_level_design_pass_01.tscn` (Staggered Salon layout).
- **Features:** Left-side service zone (Counter, POS, Espresso), two staggered table islands, a signature right-side window perch, a sheltered cat-bed nook, and an event-capable area near the entrance.
- **Rule:** Godot layout is the spatial authority. Visual targets (like V2_1) do not dictate the exact furniture count or transforms.

## 7. ENVIRONMENT ART
**Core Direction:** Character-first living café. Handcrafted storybook style, softened Art Deco, creamy plaster, jade paint, warm wood.
**Rule:** Assets are component-based. The room base, service items, and furniture are exported independently with floor-contact roots. Art generation is currently paused/provisional pending final device performance profiles.

## 8. LIGHTING / ATMOSPHERE
**Formula:** `Location × Season × TimeOfDay × Weather × Event`
- Static art retains intrinsic shading and soft AO.
- The Godot runtime applies CanvasModulate (day/night), PointLight2D (lamps), weather effects, and contact shadows.
- Region identity (e.g., Japan vs. Thailand) relies on distinct assets (foliage, decor), not stereotypical screen-wide color filters.

## 9. CHARACTER IDENTITY
**Rule:** Feline First → Mascot Second → Costume Third.
The Orange Protagonist is the final master. The Family Scale check dictates relative sizes. Do not recreate character art or rely on old Mochi reference art for final identity.

## 10. CHARACTER RUNTIME
- **Root:** Floor-contact/feet root. Assets must not drift across animation frames.
- **Facing:** 4-Directional (Up, Down, Left, Right).
- **Mirroring:** Opt-in per cat. The protagonist's asymmetrical features mean mirrored clips must be carefully validated.
- **Outfits:** Layered outfits are a hypothesis and require registration proofs before adoption. Do not build them yet.
- **Movement:** In-place animation + `CharacterBody2D` velocity via `NavigationAgent2D`.
- **Lighting:** Standard CanvasItem lighting + lightweight root blob shadow.

## 11. ASSET FORGE
Asset Forge is the deterministic processing pipeline.
- **DO:** Validate roots, resize/normalize, check alpha/padding, enforce metadata.
- **DO NOT:** Decide world layouts, own gameplay coordinates, redesign assets, or act as a lighting engine.

## 12. MODEL / AGENT RESPONSIBILITIES
- **Architect / Reasoning Agent:** System design, research, contracts, PR review, architectural consistency.
- **Implementation Agent:** Godot GDScript implementation, test writing, scene integration.
- **Image Model:** Visual target brainstorming, controlled production asset generation (via prompt).
- **Asset Forge:** Deterministic pixel processing and QA.
- **Human:** Final visual approval, gameplay judgment, production locks.

## 13. TASK ROUTER
When assigned a task, read only the relevant files:
- **WORLD ARCHITECTURE:** Read `WILLICAT_PRODUCTION_WORLD_ARCHITECTURE_V1.md`, `WILLICAT_PRODUCTION_ARCHITECTURE_LOCK_ADR_V1.md`
- **HOME ART:** Read `WILLICAT_HOME_ENVIRONMENT_V3_ART_DIRECTION_V1.md`, `WILLICAT_HOME_V3_ART_HANDOFF_SPEC_LOCK_V1.md`, `WILLICAT_HOME_V3_LAYOUT_LOCK_V1.md`
- **CHARACTER RUNTIME/ANIMATION:** Read `WILLICAT_CHARACTER_RUNTIME_PRODUCTION_CONTRACT_V1.md`, `WILLICAT_CHARACTER_ANIMATION_PRODUCTION_PLAN_V1.md`
- **LIGHTING:** Read `WILLICAT_WORLD_ATMOSPHERE_ARCHITECTURE_V1.md`, `WILLICAT_HOME_V3_LIGHTING_ART_CONTRACT_V2.md`
- **INTERACTIONS/NAVIGATION:** Read `WILLICAT_INTERACTION_SLOT_CONTRACT_V1.md`, `WILLICAT_NAVIGATION_FOOTPRINT_STRATEGY_V1.md`

## 14. ACTIVE WORK / DO-NOT-TOUCH
**Current Active Parallel Task:** `WILLICAT_HOME_V3_PRODUCTION_ART_BATCH_A_PREP_V1`
**Procedure before starting any work:**
1. Check `git status` to see what is currently staged/modified by other agents.
2. Search docs for active tasks.
3. NEVER modify active WIP files belonging to another agent.
4. If in doubt, branch or work in isolated lab scenes.

## 15. NEW MODEL ONBOARDING PROCEDURE
1. **READ** `WILLICAT_AGENT_BOOTSTRAP_V1.md` (this file).
2. **CONSULT** `WILLICAT_CANONICAL_DOC_INDEX_V1.json` to find task-specific docs.
3. **READ** only the canonical task-specific docs.
4. **INSPECT** the live repository scenes related to the task.
5. **RESTATE** the current invariants to the user to confirm alignment.
6. **IDENTIFY** active parallel work and avoid conflicts.
7. **RESEARCH** Godot 4.7 documentation if the task requires API freshness.
8. **IMPLEMENT/REPORT** within the requested boundary.

## 16. AGENT STOP CONDITIONS
**STOP IMMEDIATELY AND ASK THE USER IF THE TASK:**
- Requires hard-coding map coordinates into scripts.
- Requires breaking object-owned interaction/focus slots.
- Requires moving locked Home layout geometry.
- Involves generated art that violates its alpha padding/root contract.
- Requires baking directional runtime lighting into permanent PNG art.
- Requires overwriting another agent's active WIP files.
- Lacks authoritative documentation for a major system change.

## 17. DOCUMENT MAP
Refer to `docs/architecture/WILLICAT_CANONICAL_DOC_INDEX_V1.json` for a machine-readable index of all authoritative files, paths, and lock status.
