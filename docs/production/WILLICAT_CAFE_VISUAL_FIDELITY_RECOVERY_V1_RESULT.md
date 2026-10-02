# WILLICAT CAFE VISUAL FIDELITY RECOVERY V1 — Result

## Review state and authority

The previous café is **HUMAN VISUAL FAIL / TECHNICALLY FUNCTIONAL**. This recovery is an additive **DEV_VISUAL_FRAMING_PROOF** using the existing playable world. It does not revise that human decision or confer production approval.

- **Technical recovery diagnostics: PASS**, with counts and evidence below.
- **Agent visual self-QA: substantially closer to the hero target; remaining differences explicitly recorded.**
- **VISUAL FIDELITY RECOVERY: PASS. HUMAN VISUAL REVIEW: APPROVED.** The explicit human decision establishes this exact recovered café as the visual baseline for WilliCat Café Playable Slice V1; see `WILLICAT_CAFE_VISUAL_FIDELITY_RECOVERY_V1_HUMAN_REVIEW_DECISION.md`.
- Canonical Home geometry, navigation, gameplay transforms, interaction slots, save IDs, existing art sources, accepted Tree Pilot and frozen Factory contracts: unchanged.
- New café production publication and production eligibility: blocked; no production credentials or approvals fabricated.

Reference A is the rejected actual Godot frame. Reference B is the approved hero café, used for composition and visual quality rather than exact geometry. Reference C is the modular asset board. Both supplied reference PNGs remain unchanged and were inspected for QA; no reference pixels were sent to generation. The approved `WILLICAT_JAPANESE_RIVERSIDE_STORYBOOK_V1` calibration supplies visual language; the canonical orange character retains separate identity authority.

## 1. Root causes of the visual failure

| Diagnosis | Evidence | Recovery |
|---|---|---|
| Room read as a long corridor with too much plain floor | Previous full-frame camera zoom about 0.648, centre (320,480); physical ground shown without sufficient presentation foreshortening | Controlled DEV 3/4 ground projection, upright sprite compensation, closer framing |
| Service zone fragmented into independent cabinets | Main counter only about 34% of interior image width; separate espresso/grinder cabinets | Four registered modules at a common material scale; equipment sits on one connected top |
| Upper architecture lacked volume and grouping | Rear architecture about 16.5% of image ROI bounding area | Registered cream/cedar sections, header/sill, shoji, sign, shelves, lamps and plants |
| Furniture felt small and isolated | Table bbox about 2.2% of ROI; no seating ground grouping | Actor-relative shared scale; two planar rugs anchored to existing seating footprints |
| Thin perimeter provided little foreground depth | Weak architectural overlap; props isolated in empty space | Layered front frame, planter clusters within existing blocked envelope, grounded shadows |
| Technical success masked weak composition | Previous navigation and depth tests passed despite human rejection | Separate visual comparison and explicit human approval; no automated beauty score |

The initial audit and comparison were created **before** any new generation. It showed that existing sources were usable; a full art regeneration was not justified.

## 2. Camera and scale findings

**Measured**: the previous screenshot is 640×900 (32:45), not exact 9:16. Recovery project configuration is 576×1024; native proof is 504×896, both exactly 9:16.

**DEV recipe choices, not canonical measurements or calibrated limits**:

- Ground presentation ratio: **0.62**. Camera zoom uses `(z, z × 0.62)`; upright visual children compensate with inverse Y scale. Character and prop painted proportions remain intact. Floor, rugs and longitudinal side planes retain ground projection.
- Actor visual multiplier: **1.25**, applied uniformly to the existing sprite scale and its registered offset. Source PNGs and authored animation frames are unchanged; idle ground contact remains exactly on the actor root.
- Full view centre `(320,365)`; zoom is derived from the viewport using `min((width+22)/656, (height-100)/940)`. These are explicit DEV framing choices, not a permanent camera redesign.
- Visual scale is anchored to the canonical protagonist, not an independently enlarged collection of props.

| Visual component | Recovery display width before screen zoom | Relation to actor idle visible width | Basis |
|---|---:|---:|---|
| Protagonist idle alpha bounds | 68×89.25 | 1.00 | Existing 160×210 alpha bounds at source scale 0.34 × 1.25 |
| Main counter total canvas span | 496 | 7.29 | Existing counter west footprint edge +14 to existing grinder east footprint edge +9; visual-only endpoints |
| Primary / secondary table canvas | 176 / 168 | 2.59 / 2.47 | Common actor-derived furniture family recipe |
| Chair canvas | 73 | 1.07 | Authored NE/NW views, common registration |
| Espresso / grinder / POS canvas | 104 / 42 / 40 | 1.53 / 0.62 / 0.59 | Shared counter contact plane |
| Main planter / empty cat bed / sisal post canvas | 112 / 167 / 49 | 1.65 / 2.46 / 0.72 | Registered existing gameplay roots |
| Door walkable opening | Existing 64 world units | Not an art-scale target | Existing aperture authority, unchanged |
| Rear wall/window/shelves | Recipe dimensions in recovery script | Shared projection and source family | Art mounting dimensions, not invented Home measurements |

Canvas widths include alpha margins; the actor comparison uses visible alpha bounds. Ratios are inspectable recipe relationships, not universal tolerances. Gameplay collision scale and movement speed do not change. Floor click inversion is tested against the unchanged world coordinate transform.

## 3. Reused assets

Existing first-party café floor, counter, cream wall modules, cedar post material, shoji, blank menu, shelves, ceramics, framed art, lamps, hanging plants, planter, authored NE/NW chairs, round table, espresso, grinder, POS, tea tray, small flowers, empty cat bed, entrance frame, contact shadows and restrained coffee FX were composed from the previous slice/kit. The orange protagonist uses its existing animation family.

No existing source was repainted, renamed or replaced. Prior rejected screenshots and result documentation remain available.

## 4. Replaced/generated visual roles

| Change | Source treatment |
|---|---|
| Plain architectural pole used as scratch post replaced by an actual sisal-post visual | One new family-sheet cell; original pole source remains intact |
| Main and entry rugs added | Two new family-sheet cells, not giant room artwork |
| Isolated station cabinets suppressed | Equipment preserved and registered onto joined service counter |
| Counter top/front modules, blank sign mounting plane, cedar structural material | Deterministic derivatives of existing sources |
| Counter top warmed to cedar-family honey tone | DEV runtime modulation only; source pixels unchanged |

The new family uses explicit role mapping, unequal-gutter Forge strip detection, safe extraction, `FLOOR_CONTACT_BOTTOM_CENTER` packaging and premultiplied resize. Original source edges are transparent and complete. Forge intentionally removes bottom padding for floor-contact registration; top/left/right padding is retained. Contact on the bottom baseline is not evidence of clipped source art.

## 5. Generation counts and traceability

- **This task: 1 image-generation call, 1 family sheet, 3 semantic assets, 0 regeneration calls.**
- Source: `assets/dev_review/cafe_visual_recovery_v1/source/textile_catlife_family_v1.png`, 2172×724 RGBA, preserved byte-for-byte.
- Runtime exports: **13 PNGs** = 3 new asset exports + 10 deterministic derivatives. Of the derivatives, the aligned counter and independent countertop material patch are retained analysis/preparation helpers; the latter is not used in the final scene.
- Exact prompt, source hash, input/reference boundaries, role rectangles, Forge reports and toolchain receipt are beside the source. Provider model/seed unavailable from the tool result are marked unavailable rather than invented.
- `build.py` reproduces all 13 exports identically from immutable inputs. It never invokes generation.
- DEV use follows the explicit task authorization. Production/publication rights review remains unresolved/not approved by this task; no new blanket legal permission is asserted.

## 6. Counter recovery

The service anchor is now one joined cedar front with honey-toned top. Left end, two middle segments and right end share one scale, exact common contact Y and top/front partition. Eight sprites form four modules; a whole small counter is not horizontally stretched into a large unrelated object.

Equipment registration distinguishes the projected ground-root delta from the uncompressed height above the counter. Espresso, grinder, POS, ceramics and flowers remain separate reusable assets. The pastry display remains a compact existing-root extension. The worker is naturally hidden by the front body; the countertop layer remains behind the worker. Its full-body occluder ROI owns 100% of the measured overlapping pixels in the fixed-pose proof.

## 7. Architecture recovery

Two modular rear cream/cedar wall sections now share a header, sill and structural posts. Shoji, engine-rendered editable signage, ceramic shelves, framed art, two practical lamps and a hanging plant form a coherent rear band. Longitudinal side faces follow the existing room envelope; they are ground planes, not billboarded sprites.

Old architecture is suppressed before rebuilding the DEV visuals, avoiding duplicate lamps/wall overlays. Repeated decorations use explicit metadata for projection membership; engine-generated duplicate node names cannot silently omit a billboard or flatten a side plane.

No opaque room background, new wall collision, door width, gameplay blocker or alternate café layout was created.

## 8. Furniture and floor recovery

The primary table plus two authored-direction chairs was grouped first, then the same family rules applied to the second seating cluster. Each rug maps a planar textile onto the union of the existing table/chair footprints with recorded DEV visual margins. Table ground contact follows its existing footprint front edge; chair visual adjustments are only `(±6,-4)` local recipe offsets, with unchanged chair roots and seat markers.

Centrepieces remain restrained; cat bed, real scratching post and planter form a cat-life group. The floor is quieter warm cedar, not a newly busier texture. High richness stays in the service band, medium in seating/entrance, low in the walking corridor.

## 9. Depth and grounding recovery

- **Back:** cream wall, window, sign, shelves, lamps and rear hanging plants.
- **Middle:** separate service equipment, worker/customer, table groups, planter and cat-life props.
- **Front:** counter front, table/chair edges, entrance structure and planters in existing blocked wall areas.

Y-sort stays on existing gameplay roots. Only visual children compensate for presentation projection. Contact shadows use the ground projection and registered contact positions; they do not inherit the uncompressed upright sprite height. Coffee steam follows a separate DEV visual emitter while the canonical marker stays unchanged.

Six real navigation targets demonstrate entrance, counter front/back, table back/side/front. Four fixed-pose background/actor/object/combined sets identify pixel ownership, beyond merely checking actor Y. Front body of counter and table-back correctly occlude; actor-front views render ahead. The movie includes actual actor movement and the complete service cycle, not an empty-room proof or edited sprite translation.

## 10. Before/after comparison and visual limitations

| Composition estimate | Before | Recovery | Hero target |
|---|---:|---:|---:|
| Unoccluded plain floor / room ROI | 52.4% | 31.0% | 22.6% |
| Counter width / room ROI width | 33.8% | 75.2% | 67.5% |
| Counter body bbox / ROI area | 2.3% | 8.2% | 9.4% |
| Primary table bbox / ROI area | 2.2% | 4.4% | 4.3% |
| Rear architecture bbox / ROI area | 16.5% | 30.3% | 32.3% |
| Visible protagonist bbox / ROI area | 0.6% | 0.9% | 1.3% |

**ESTIMATED** manual ROI/polygon coverage and rectangle exclusions; measured coordinates are recorded in JSON. Bounding boxes include air, actor poses differ, rug coverage counts as occupied floor, crops differ. These are conservative composition diagnostics, not semantic segmentation, calibrated thresholds or a beauty score.

| Hero-fidelity question | Agent comparison |
|---|---|
| Counter equally important? | Much stronger continuous anchor; wider than hero in relative image terms, similar body area |
| Upper wall rich/deep? | Much closer architectural coverage; shelves/material layering present |
| Furniture believable? | Primary table area close to hero estimate; consistent actor-relative family, genuine grouped seats |
| Protagonist appropriately scaled? | Full painted proportions preserved and enlarged coherently; visible walking evidence included |
| Intimate rather than cavernous? | Clear improvement through ground foreshortening and reduced plain floor |
| Back/middle/front layers? | Actual renderer and pixel-ownership proofs support all three |
| Wood/plaster/greenery cohesive? | Existing family reused, coherent cream/cedar/sage; warm practical lights |
| One illustrated world? | Stronger consistency and grouping; no unrelated high-detail art regeneration |
| Same visual family as hero? | Human review approved compatibility with WILLICAT_JAPANESE_RIVERSIDE_STORYBOOK_V1 |

**Remaining visible differences:** hero has denser flowers, more bespoke pastry/shelf contents, an upholstered seating nook, a richer exterior threshold and stronger authored illumination. This proof has simpler mirrored chair pairs and repeatable round tables, quieter illumination, and a smaller existing entrance aperture. The human accepts these differences as next-pass polish. Visual fidelity recovery is PASS and human visual review is APPROVED for this baseline; this does not claim exact hero fidelity, equal visual polish or a production-ready art kit. The Hero Target is a POLISH / MOOD ceiling, with no one-to-one object-density or composition requirement. Hero sunlight is not baked into reusable props. Canonical spatial constraints remain more important than copying hero geometry.

## 11. Gameplay regressions and evidence identity

| Executed verification | Count | Result |
|---|---:|---|
| Recovery Godot registration/service/navigation assertions | 39 | PASS |
| Native recovery portrait/proportion/walking/service/authority checks | 14 | PASS |
| Continuous Home walking/service/save-load assertions | 28 | PASS |
| Proxy café service/reward/save-load assertions | 49 | PASS |
| World architecture actor/navigation/slot regressions | 172 | PASS |
| Existing Forge static-prop/core unit tests | 35 | PASS |
| New source/registration/partition/export-reproduction diagnostics | 8 | PASS |
| Fixed-pose pixel-ownership cases | 4 | PASS |
| **Executed checks total** | **349** | **PASS** |
| Additional canonical spatial parity entries | 39 compared entries | PASS; entries are not counted as 39 extra tests |

No counts were inferred from files: regression scripts printed each executed assertion, and diagnostics record their actual checks. Sandbox regression scripts that test movable objects act only inside temporary test instances; they do not edit scene files or authoritative saved coordinates.

Protected-file parity compares **all 3,451 pre-existing repository files** captured before this task, excluding volatile caches/Git internals: all remain byte-identical. New files are additive under DEV assets/scenes/scripts/tools, tests, review evidence and this report. The proof-input identity receipt verifies the final exercised script, scene and all runtime PNG hashes against the delivered files. No commit, push or production publication was performed.

Native screenshot capture incurs readback/PNG overhead; its recorded process time is **not** evidence of mobile performance or normal uncaptured FPS. Mobile benchmarking is not claimed. This DEV proof does not replace frozen canonical integration gates.

## 12. Evidence and next permitted step

Primary evidence directory: `artifacts/prototype_review/cafe_visual_fidelity_recovery_v1/`.

1. `01_CURRENT_BEFORE.png` — unmodified rejected Godot screenshot.
2. `02_RECOVERED_FULL_SLICE.png` — actual recorded walking frame, no actor teleport/retouching.
3. `03_HERO_TARGET_SIDE_BY_SIDE.png` — recovery vs original supplied hero, aspect preserved.
4. `04_COUNTER_CLOSE.png` — crop only from native service-focused frame.
5. `05_SEATING_CLOSE.png` — crop only from native seating-focused frame.
6. `06_DEPTH_FRONT_BACK.png` — four actual native counter/table views.
7. `07_GAMEPLAY_SCALE.png` — full native view after real table-front navigation.

Additional evidence: `AUDIT_BEFORE_VS_HERO.png`, `BEFORE_AFTER_HERO.png`, `composition_audit_before.json`, `composition_audit_before_after.json`, `gallery_selection.json`, `MOVING_CHARACTER_CAFE_PROOF.mp4`, `MOVING_CHARACTER_CAFE_PROOF.gif`, and `diagnostics/` with native proof/trace, fixed-pose component images, exact identity receipts, executed logs, processing/pixel checks, movie timing and protected-file parity.

The MP4 is a native 504×896 runtime capture assembled with actual sample timestamps. Inspection pauses hold the last frame; navigation is not sped up. The GIF is a smaller preview, not the source evidence. Full sampled frame set remains in the isolated capture directory recorded in diagnostics.

Human launcher: `tools/willicat_cafe_recovery/OpenCafeRecoveryReview.command`. It always prepares a new isolated project and keeps canonical Home/camera sources untouched. Review floor walking, depth tour and coffee service directly.

**Human review completed: TECHNICAL PASS / VISUAL FIDELITY RECOVERY PASS / HUMAN VISUAL REVIEW APPROVED.** The current recovered café is the baseline for subsequent visual polish. Richer ambient lighting, foreground dressing, plant life, subtle service-area detail and atmospheric effects belong to the NEXT POLISH PASS. Do not regenerate the current café kit or restart Visual Fidelity Recovery. This recording task does not begin that polish pass or authorize production publication.

Decision record: `diagnostics/human_visual_review_approved_v1.json` in the evidence directory; exact source/runtime/inherited-asset and reviewed-evidence hashes are bound there. Native technical captures and the rejected before image remain unchanged. Approval is recorded from the explicit human conversation message; it does not fabricate authenticated production publisher credentials.

WILLICAT CAFE VISUAL FIDELITY RECOVERY V1
— HUMAN VISUAL REVIEW APPROVED
— BASELINE FOR SUBSEQUENT VISUAL POLISH
