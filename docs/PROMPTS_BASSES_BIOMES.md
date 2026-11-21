# Basses i esquerdes per bioma

Eina integrada image_gen, primer generació i després neteja de l’alfa. Recurs actiu: `assets/sprites/basses_biomes.png`. Atles de quatre columnes i dues files, ordre: oxidat, cristal·lí, glacial, jardins, geotèrmic, abissal, Llindar, Nucli. Els sprites es projecten sobre una planta 2D de sala; no són fons ni geometria fixa.

## Generació

Game sprite atlas exactly 4 columns x 2 rows, 8 equal cells, transparent background, no labels. Each cell a single low flat rock depression containing a small irregular pool of liquid and one narrow fissure extending from it. Top-down overhead view, NOT isometric perspective: the game projects the flat texture onto its isometric ground. Detailed crisp pixel art, subtle broken stone rims, shallow dark hole under reflective liquid, irregular organic silhouette, no tall rocks or flora or icons. Cell order: rusty Mars basalt with muted turquoise brine; violet crystalline slate with pale cyan violet liquid; blue glacial rock with dark icy blue meltwater and thin ice edge; mossy olive basalt with dark green water; charcoal geothermal basalt with small dull orange hot liquid; dark purple biological abyss with dim violet cyan liquid; graphite bronze threshold rock with dark amber mineral fluid; dark teal core rock with turquoise fluid. Single isolated ground patch fills 80% cell, clear transparent gap between cells. Stone edges blend with biome ground, thin highlights and a few chunky pixel ripples. No scenery, no UI, no text, no glowing haze.

## Neteja de l’atles

Clean this game sprite atlas. Preserve EXACT 4-column 2-row layout, all 8 pools/cracks, their rock rims, internal pixels, liquid colors, dimensions and positions. Remove ALL gray/white haze, smoky fringe, translucent glow, and speckled background BETWEEN and around sprites. Outside the solid outer rock rim must be fully alpha zero. Hard crisp transparent cutout around each isolated patch, no glow or shadow extending beyond rock. Do not add or change any objects. Genuine transparent background.
