# WilliCat asset-kit reference research V1

Scope: production principles only. No pack was downloaded, imported, bought, or copied into WilliCat. Current playable baseline is documented in [the placeholder result](../production/WILLICAT_PLAYABLE_PLACEHOLDER_RESET_V1_RESULT.md).

## KayKit Dungeon Pack — transferable principles

[The creator's pack page](https://kaylousberg.itch.io/kaykit-dungeon-pack) describes a modular low-poly 3D library of more than 200 pieces, including walls, floors, stairs, doors, and props. It offers FBX, glTF and OBJ formats and a shared 1024×1024 gradient atlas that can be downsampled for lower-end targets. The page calls the pack CC0 and usable commercially without attribution, while separately asking users not to resell unmodified copies or claim authorship. Confirm the exact downloaded version and its included license before importing any files.

Lessons for WilliCat: (1) establish one world-unit scale and consistent floor-contact pivots; (2) separate repeatable architectural modules from individual furniture and interactable props; (3) ship variation by a controlled family of compatible pieces, not one bespoke room image; (4) keep material/palette coherence at kit level; (5) author previews and variants with identical framing; (6) keep texture/material count and draw-call implications visible in mobile QA. A kit's fantasy art direction and its 3D runtime format are *not* recommendations for WilliCat. Godot import, orientation, collision, interaction points, and illustrated-style compatibility require independent proof.

## Asset Pack Preview Generator — catalog lesson

[The maintainer repository](https://github.com/aitordsgn03/Asset-Pack-Preview-Generator) describes a Godot pipeline that renders model previews and JSON metadata (including vertex count, author, license and preview path), then an Astro site that filters/browses them. This demonstrates a useful division: source file → deterministic preview/metadata → searchable presentation. Its website is not a dependency or a UX template. Repository README and file listing were inspectable; deeper source pages were unavailable during this review, so this is a README-level architecture study, not a verified analysis of its implementation.

For WilliCat, a catalog should answer: *what assets exist, may we use them, what gameplay role can they fill, and how do they look at the project camera?* A generated thumbnail/index is valuable; a second full web application is premature. Preview generation must not approve gameplay dimensions or license compliance by itself. The catalog proposal is [here](../architecture/WILLICAT_ASSET_CATALOG_ARCHITECTURE_V1.md).

## Recommendation and non-goals

The asset-kit method is appropriate for WilliCat's café, furniture, and future rooms even if the final pixels stay illustrated 2D. The first implementation should use the existing playable placeholder world, not a new room. AI may generate isolated prop candidates, character/animation references, texture ideas, and limited decorative variants; each is registered and reviewed as an asset. AI must not author the whole room as the spatial authority, place gameplay markers, determine navigation, or invent layout from a concept image.
