# ClassicUO Renderer Research

This branch is a safe research area for studying ClassicUO before making any changes to Untitled World's live game.

## Upstream project

- Repository: https://github.com/ClassicUO/ClassicUO
- Upstream documentation: https://github.com/ClassicUO/ClassicUO#readme
- Purpose: open-source implementation of the Ultima Online Classic Client.
- Technology: C# with the FNA/XNA framework. This is not a drop-in JavaScript renderer for our current browser game.
- Asset warning: upstream states it does not distribute copyrighted Ultima Online game assets. Do not copy original UO, Outlands, or other shard artwork into this repository unless we have permission or a licence that clearly allows it.
- Licence: upstream README describes the code as BSD 4-Clause. Verify the repository's current LICENSE and each dependency's licence before copying or adapting code. Preserve required copyright and licence notices.

## What we are investigating

1. **Terrain rendering** — land tiles, isometric projection, textures, hue and shading.
2. **World objects** — static objects, trees, rocks, buildings and sorting objects by depth.
3. **Characters and animation** — sprite atlases, direction-specific frames, animation timing and equipment layers.
4. **Classic UI windows** — movable gumps, status bars, backpack contents, labels and window layering.
5. **Asset loading** — how client data files are decoded and mapped to graphics IDs.
6. **Browser fit** — which ideas can be recreated in our HTML/CSS/JavaScript renderer without porting the C#/FNA client wholesale.

## Planned source investigation

Start with these upstream areas and confirm their current paths before quoting or adapting code:

- src/ClassicUO.Client/Game/WorldViewportGump.cs — viewport and world display.
- src/ClassicUO.Client/Game/Managers/World and related rendering classes — world state and drawing flow.
- src/ClassicUO.Client/ rendering and UI classes — terrain, static objects, mobiles and gumps.
- README.md, LICENSE.md, and .gitmodules — project licence and third-party dependencies.

Upstream paths can move. Record the exact source URL, commit, file path, licence and the lesson learned in notes before adapting anything.

## Integration rules for Untitled World

- Keep the live game on main; conduct experiments on this branch.
- Do not replace the existing index.html renderer until a tested replacement is ready.
- Preserve existing Supabase integration, character/resource state and game actions.
- Do not add copyrighted game data files, extracted sprites, client archives or Outlands assets.
- Prefer implementing the rendering techniques in our existing browser stack and using original or permissively licensed art.
- Treat this folder as research notes, not as a vendored copy of ClassicUO. A real source import or submodule must retain upstream history and licence notices.

## First milestone

Document the terrain-to-sprite rendering pipeline and create a small browser prototype using original placeholder art. Compare its visual result with the current isometric renderer before connecting it to live game state.
