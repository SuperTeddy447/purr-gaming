# WILLICAT GAME WORLD & PRODUCT NORTH STAR V1

## 1. Primary Product Definition
**Genre:** Cozy Character-Collection Café Life-Sim + Light Management + Spatial Decoration.
**Player Fantasy:** You are curating a warm, bustling café that serves as a sanctuary for highly characterful cats. It is a living diorama where management mechanics are driven by the unpredictable, delightful behavior of felines.

## 2. WilliCat Differentiation: "Feline First"
If cats can be replaced by generic human workers, the game fails. Cats materially affect the game world:
- **Café Work & Routines:** A cat might abandon the espresso machine to sleep in a sunbeam, forcing the player to assign another cat or wait.
- **Customer Experience:** Customers might tip more if a cat sits on their lap, or get annoyed if a cat knocks over their coffee.
- **Decoration:** Decorating isn't just for stats; cats have specific preferences (e.g., thick coats prefer cold floors; hairless cats hoard near the heater).
- **Exploration:** Cats bring back items, lore, or new customers from off-screen excursions based on their personality.

## 3. World Fantasy & Expansion Model
**The Fantasy:** Starting with a tiny, modest café, building it into a thriving, multi-level sanctuary, and eventually expanding to new towns and neighborhoods.
**Expansion Model:** **Hybrid (Visible Multi-Room Building).**
- *Why:* Separate disconnected rooms break the "living world" illusion. A scrolling open location lacks interior coziness. A visible, connected building (scrolling vertically/horizontally) fits mobile portrait perfectly, allowing players to watch a cat walk from the downstairs café up the stairs to the rooftop garden.

## 4. Home Café Structure
The long-term conceptual structure for the primary Home building:
1. **Main Café:** The bustling service core (coffee, pastries, seating).
2. **Upstairs Lounge:** A quiet, low-service sanctuary for cats to rest, sleep, and interact purely with each other.
3. **Garden / Terrace:** An outdoor expansion highlighting weather, exterior plants, and street-side interactions.
*(Avoid feature bloat like a separate "Roastery" unless it introduces entirely new feline behaviors).*

## 5. Other Locations
A future second location (e.g., a coastal town or snowy mountain cabin) must differ fundamentally:
- **Architecture & Aesthetics:** Different fixed-room shells and lighting profiles.
- **Local Systems:** Unique local ingredients or customer types.
- **Seasonal Behavior:** Cats reacting differently (e.g., seeking warmth in the mountain cabin).
*Core management systems remain reusable, but the spatial and emotional context shifts.*

## 6. Decoration Philosophy
**Aesthetic Place-Making with Light Synergy.**
- **Fixed vs. Movable:** Architecture (walls, windows) is fixed but skinnable (wallpapers/trims). Furniture (chairs, tables, beds) is fully modular on a grid-less or fine-grid system.
- **Theme Sets:** Yes, to encourage collection, but mixed-and-matched rooms should still look beautiful.
- **Gameplay Impact:** Decoration affects gameplay (e.g., a high-tier cat tree attracts rare cats), but we avoid *punishing* optimization pressure. Players should not be forced to make an ugly, cluttered room just to maximize profits (the "Animal Restaurant" trap).

## 7. Camera & World Presentation
- **Gameplay Camera:** Stable, elevated 3/4 isometric-lite. Allows clear viewing of floor paths, furniture, and cat faces.
- **Navigation:** Smooth vertical/horizontal swipe panning between connected rooms in the building.
- **Director Camera:** The `CameraDirector` system overrides for close-up emotional beats (dialogue, discovering a new cat, serving a perfect coffee) without giving the player free 3D rotation.

## 8. Integrated Core Loop
1. **Manage & Serve:** Fulfill customer orders (affected by feline chaos/charm) to earn resources.
2. **Expand & Decorate:** Spend resources to unlock new furniture, rooms, or upgrade stations.
3. **Attract & Collect:** New decor and room unlocks attract new cats with unique identities and stories.
4. **Bond & Routine:** Cats interact with the new space, establish routines, and unlock narrative milestones, feeding back into better service capability.
*(One integrated loop, not six disconnected menus).*

## 9. Long-Term Progression Layers
Meaningful player motivation scales through:
1. **CAT:** Unlocking and bonding with individual cats.
2. **ROOM:** Optimizing and decorating a single space (Main Café).
3. **BUILDING:** Unlocking the Upstairs Lounge and Garden (visible architectural expansion).
4. **LOCATION:** Unlocking a completely new biome/town (multi-month goal).

## 10. The Screenshot North Star
*"What does a screenshot of WilliCat look and feel like that no one would confuse with competitors?"*
**The Vision:** A warm, painterly, soft-perspective cross-section of a bustling, multi-level café where highly characterful cats are visibly doing cat things—sleeping on espresso machines, batting at hanging plants, loafing on rugs—while customers happily coexist with the chaos. It looks like a high-end, lovingly crafted storybook illustration brought to life, completely free of aggressive UI pop-ups or rigid tile-grid aesthetics.
