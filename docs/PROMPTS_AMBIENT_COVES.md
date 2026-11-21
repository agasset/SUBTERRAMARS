# Ambientació de coves — 20/11/2026

Recursos creats amb l’eina integrada d’imatges de la skill imagegen, amb transparència conservada. No s’ha utilitzat l’API ni la CLI externa. Integrats a `assets/sprites/ambient_coves_1.png` i `assets/sprites/ambient_coves_2.png`, dues imatges RGBA de 1536 × 1024.

## Prompt del primer atlas

Create a production sprite atlas for SUBTERRA MARS dark sci-fi cave 2D pixel art isometric game. Transparent background. Exactly 4 columns x 4 rows equal cells, canvas 1536x1024. No text, no grid lines. Each isolated object fully inside its cell with generous transparent margins, contact at 82% cell height. Crisp pixel clusters, detailed hand pixelated rock facets, hard stepped edges, no smooth painted blur. Isometric elevated 2.5D view, ground diamond projected horizontal and compressed to half height. Columns represent: 1 iron rust orange/brown cave; 2 crystalline purple with cyan quartz; 3 icy blue cave; 4 lush subterranean dark green cave. Rows represent: row1 small glowing quartz clusters on small natural ground rock (distinct biome colors); row2 tall imposing irregular stalagmite pillar on broad rocky foot, silhouette asymmetric (distinct biome materials); row3 shallow dark blind natural rocky pit with rough irregular layered rim, dark bottom, no tunnel exit, isometric ground hole; row4 dripping mineral formation: thin hanging rocky point and several discrete water droplets above a small puddle on ground, a tall isolated composition. All16 assets detailed consistent pixel art, luminosity restrained so terrain remains readable. Single sprite sheet, isolated transparent assets, absolutely no backdrop, no UI, no characters.

Edició final del primer atlas:

EDIT this exact sprite sheet. Preserve all 16 sprites exactly, their positions and proportions. Remove ALL dark colored background and ALL broad colored glow haze between sprites. Make every background pixel fully transparent alpha0. Keep only the crisp pixel art objects, small crystal highlights, water droplets and rocky rims. Keep dark inside the pit holes opaque. No black/colored background, no fog, no ambient backdrop. This must be a truly transparent PNG atlas usable over game terrain. Preserve4x4 equalcell layout and1536x1024size.

## Prompt del segon atlas

Production transparent 2D isometric pixel-art sprite atlas for dark sci-fi Martian caves. 1536x1024 canvas exactly4columns x4rows equal384x256cells. NO TEXT NO GRID NO BACKGROUND. Isolated assets within each cell, transparent margins, ground contact82percent cellheight. Crisp pixelclusters richly faceted rocks, not smooth rendering. Columns: geothermal cave dark basalt with restrained ember red cracks; biological abyss dark violet with turquoise organic mineral crust; ancient threshold dark ochre rock with gold mineral inclusions; final Martian core charcoal with pale cyan alien crystal seams. Rows: 1 small glowing quartz/mineral clusters on natural foot;2 large tall asymmetrical stalagmite pillar;3 blind natural dark shallow pit with jagged layered rim in compressed isometric ground plane (no door no tunnel exit);4 narrow hanging rock tip plus discrete droplets falling to tiny ground puddle. All16 distinct isolated sprites same 2.5D isometric camera, ground horizontal diamond halfheight. Consistent detailed pixelart style with rock textures, no UI no characters, genuine transparent background.

Edició final del segon atlas:

Edit exact atlas preserve16objects andpositions pixelart. Remove colored backdrop and all wide glow haze entirely to alpha0. Only hard crisp pixelart stone and droplets remain opaque. In pit interiors keep dark opaque. True transparent PNG sprite sheet NO painted background NO colored rectangles NO glow clouds. Maintain1536x1024layout4columns4rows.

## Integració

El generador d’imatges va distribuir les alçades de manera desigual. Les regions reals es llegeixen amb les franges Y 0–180, 180–510, 510–730 i 730–1024; quatre columnes de 384 píxels. Les peces verticals tenen ancoratge inferior; els forats s’ancoren al centre del pla de terra. Veí més proper, escala de món lligada al zoom. Els petits cristalls són ambientals; els jaciments de ferro, quars i magnetita mantenen els seus sprites i interaccions.

El relleu de parets i terra reutilitza els materials existents i geometria 2D de representació. No s’han generat fons fixos ni un món 3D.
