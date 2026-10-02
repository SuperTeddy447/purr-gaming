# WilliCat stylized art fidelity — DEV only

- Open `OpenStylizedDiorama.command`: live 3D micro-diorama; exact original orange sprites and Vector2 navigation. Click the floor or choose **Depth walk**. The automatic first walk enters the presented floor region; the tour visits six existing café targets.
- Open `OpenPreRenderedComparison.command`: actual 2D display of the exact same scene baked at 1008×1792, with a return-to-live button. **Static comparison only**, including the baked cat pose; it is not a moving 2D gameplay solution.
- `run.py --renderer gl_compatibility` selects the fallback for inspection. Primary art/profiling evidence uses Mobile/Metal; renderer appearance differs.

The launcher reuses the existing Asset Forge Python environment if the default Python lacks NumPy; it installs no dependency.

Each launch verifies the existing 164-file café approval binding and prepares a fresh `/private/tmp` copy through the existing Hybrid/Café tooling. Existing projects, repository destinations, path traversal and DEV input symlinks are rejected. The copy has a separate DEV save namespace. No production configuration, world coordinates, Factory gates or source art are changed.

Recipes: `tests/capture_stylized_fidelity_v1.gd`, `capture_prerendered_fidelity_v1.gd`, `profile_stylized_fidelity_v1.gd`, `capture_fidelity_lighting_v1.gd`. Their output directory is a DEV diagnostic location; they are not protected production publisher tools.
