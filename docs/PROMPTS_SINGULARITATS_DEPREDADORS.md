# Singularitats i depredadors — 20/11/2026

Generats amb l’eina integrada de la skill imagegen, sense CLI ni API externa. Es conserven els PNG RGBA originals i la seva transparència.

## Singularitats

Fitxer: `assets/sprites/singularitats_biomes.png`, 1536 × 1024, quatre columnes i dues files de 384 × 512. Ordre: Coves oxidades, Cavernes cristal·lines, Galeries glacials, Jardins subterranis, Fractures geotèrmiques, Abisme biològic, Llindar i Nucli. La identitat del bioma segueix l’ordre de campanya desat.

Prompt:

Production sprite atlas for SUBTERRA MARS detailed dark sci-fi 2D isometric PIXEL ART caves, crisp pixel clusters matching textured game rocks, not smooth digital painting. Transparent RGBA background NO scenery NO UI NO text NO colored haze. Canvas1536x1024 exactly4columns2rows equal384x512cells, 8 COMPLETELY DIFFERENT unique natural landmarks, one isolated sprite centered in eachcell with generous transparent margins, foot at90percent cellheight. Read order left-to-right top-to-bottom: rust caves gigantic ancient branching iron oxide coral arch; crystal caves fan-shaped radiant cyan quartz geode splitting purple bedrock; icy caves a frozen spiral ice cascade with hanging icicles on blue rock; subterranean gardens enormous umbrella mushroom with cascading luminous spore tendrils and moss; geothermal caves a black basalt fumarole chimney with tiny restrained ember-red steam particles; biological abyss a large organic translucent violet egg membrane with turquoise microbial veins on rock; threshold mysterious naturally eroded concentric golden stone rings raised obliquely from ochre rock; Martian core a fractured floating pale-cyan mineral prism just above a dark magnetic stone cradle. Each object unique silhouette/material, no repeated pillar shapes. Same 2.5D elevated isometric camera ground plane halfheight, pixelated edge steps, readable at small game scale. Keep every background pixel alpha0, only sprites opaque, no glow clouds.

## Depredadors

Fitxer: `assets/sprites/depredadors_isometrics.png`, 1536 × 1024, quatre columnes i quatre files de 384 × 256. Columnes SE, SW, NW, NE; files mantis cuirassada, escorpí de geoda, salamandra de glaç i assetjador aràcnid. Quatre siluetes amb variants de família per als vuit perfils. Ancoratge al peu i escala de món; no és una escena fixa.

Prompt:

Create a production game sprite atlas of four alien cave PREDATORS for SUBTERRA MARS, dark science fiction textured PIXEL ART matching hand pixelated isometric game rocks. Transparent RGBA no background no color haze no text no grid.1536x1024, exact4columns4rows equal384x256cells, each isolated animal fully contained with generous transparent margins, foot ground contact at82percent cellheight. Columns show SAME creature from four consistent isometric elevated directions: southeast facing down-right, southwest facing down-left, northwest facing up-left, northeast facing up-right. Rows are four COMPLETELY DISTINCT creatures: row1 rusty red armored six-legged mantis crab with enormous cutting forelimbs; row2 violet crystal scorpion with cyan facets and curled venom tail; row3 pale blue-white cave salamander predator with powerful jaws and jagged ice crest, fourlegs; row4 black-violet arachnid stalker with long angular legs and turquoise glowing sensory organs. Fierce but no gore. Strong asymmetrical silhouettes, faceted shells and sharp stepped pixel edges, restrained limited palettes, detailed pixel clusters, no smooth blur. Correct matching isometric perspective in ALL16 sprites, same animal scale per row. Opaque animal pixels, all surroundings alpha0, feet on consistent ground baseline.

## Altres recursos

Les goteres i llacs reutilitzen els atlas d’ambientació i basses ja generats, amb regions, mides i projeccions ajustades en Godot. Les icones de projector i escut són SVG de graella 16 × 16, afegits al sistema d’icones natiu de la interfície. El paquet recuperable reutilitza el mòdul de caixes del mateix atlas exterior.
