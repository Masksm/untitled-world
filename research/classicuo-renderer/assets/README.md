# Original Sprite Atlas

`original-sprite-atlas.svg` is an original set of geometric, pixel-style placeholder illustrations made for the Untitled World renderer research branch. It is not extracted from Ultima Online, Outlands, or ClassicUO.

## Atlas regions (SVG viewBox 512 x 256)

- Grass tile: x=8, y=8, w=128, h=72
- Tree: x=160, y=5, w=100, h=124
- Rock: x=280, y=28, w=100, h=70
- Cabin: x=8, y=112, w=140, h=120
- Traveller: x=168, y=145, w=70, h=105
- Bush: x=286, y=128, w=91, h=60

The prototype currently draws the tree, rock, cabin and traveller regions with Canvas `drawImage`. Terrain is still procedurally drawn, and the atlas grass tile is reserved for the next terrain-texture pass. These are prototype assets, not final production artwork.

When replacing or expanding these assets, keep a source/author/licence record for each external asset. Do not add game client archives or copyrighted game sprites without permission.
