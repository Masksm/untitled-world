# ClassicUO source reconnaissance

Research date: 2026-10-27

## Confirmed upstream facts

- Repository: https://github.com/ClassicUO/ClassicUO
- Licence file currently fetched from upstream: `LICENSE.md`, SPDX headers in inspected source include BSD-2-Clause. The current repository-level licence text is BSD 2-Clause. Check file-specific headers and dependency licences before copying code.
- `src/ClassicUO.Client/Game/UI/Gumps/WorldViewportGump.cs` defines `WorldViewportGump`, a UI gump responsible for the world viewport's framing/interaction and connected to `GameScene`.
- `src/ClassicUO.Renderer/TextureAtlas.cs` implements a texture atlas and `AddSprite(...)`, packing sprite pixel data into GPU textures. This is a useful performance concept for a browser renderer, though implementation APIs differ.
- `src/ClassicUO.Renderer/Gumps/Gump.cs` uses `TextureAtlas` and `GumpsLoader` to retrieve cached gump sprites by index. This shows a separation between asset decoding, atlas/cache and UI rendering.
- `src/ClassicUO.Assets/GumpsLoader.cs` handles loading gump asset entries from client data files.
- Upstream code is C# and uses FNA/XNA graphics APIs. The browser prototype in this repository is plain HTML Canvas, CSS and JavaScript, so copying the client wholesale would not be a sensible direct integration.
- The upstream project does not bundle copyrighted Ultima Online client art/data. The research prototype therefore uses original shapes and colours only.

## Translation to our browser game

1. **World viewport:** keep the canvas as the single world viewport; add camera offset/zoom later, separate from UI overlays.
2. **Terrain:** render tile layers in a deterministic order and cache terrain tiles when possible.
3. **Sprites:** use a manifest of sprite metadata and atlas regions when we have original or properly licensed art. Avoid one draw call per decorative detail where batching is practical.
4. **Depth:** sort world entities by their ground-foot position (the point where the object touches the tile), not by sprite top-left. Draw UI gumps after world entities so windows remain on top.
5. **Assets:** isolate sprite loading/decoding from game state. Rendering should consume state snapshots and must not directly mutate Supabase data.
6. **Integration:** preserve the existing main-branch game and backend. Only port concepts that can be tested in the browser prototype.

## Prototype

`prototype.html` is an isolated browser-only experiment with isometric diamond terrain, simple original tree/rock/cabin/person shapes, ground-position sorting, a draggable classic-style status panel, and controls for the grid and test character. Its status bars are mock values, and it is not wired to live game state. It must not be mistaken for the deployed game.

## Next engineering steps

- Compare this prototype against the current `index.html` renderer in a browser.
- If the scene geometry looks correct, extract renderer functions into a separate JS module before replacing the current inline renderer.
- Add camera following and tile/entity coordinate transforms.
- Introduce licensed sprite assets only after their exact licence and attribution requirements are recorded.
- Test on mobile Safari as the user primarily develops and tests from a phone.
