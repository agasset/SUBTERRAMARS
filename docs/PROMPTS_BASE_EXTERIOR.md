# Base exterior pixel art

Eina: ImageGen integrada. Referència d’estil per al paisatge i els mòduls: `assets/sprites/base_coves_oxidades_arran_terra.png`.

Recursos finals:

- `assets/textures/terreny_marcia_isometric.png`: fons actiu de terreny vist des de dalt, en perspectiva isomètrica sense horitzó.
- `assets/textures/paisatge_marcia_exterior.png`: primera proposta de paisatge amb horitzó, substituïda per perspectiva incorrecta; es conserva com a font històrica.
- `assets/sprites/base_exterior_moduls.png`: hàbitat, control, energia solar i equip de servei, separats en un atlas transparent.
- `assets/textures/paviment_base_exterior.png`: textura repetible de plaques metàl·liques amb pols marciana.

Godot conserva l’ascensor i el player com a dibuixos independents, aplica la mateixa projecció de terra al paviment i als llums, i reparteix petites roques decoratives segons la llavor. No substitueix cap cova o navegació procedural per una imatge.

## Correcció de perspectiva del fons

Generada amb ImageGen integrada a partir de `assets/sprites/base_exterior_moduls.png`, utilitzat només com a referència de càmera i estil. Prompt:

Create a replacement environment-only backdrop for this 2D pixel-art Mars game. The attached image of base modules is a CAMERA/PERSPECTIVE and pixel-art style reference only; do NOT include the buildings or manufactured objects. STRICT ORTHOGRAPHIC 2:1 ISOMETRIC VIEW looking DOWN from above at Martian ground, like an isometric strategy game terrain field. Entire wide 16:10 canvas filled with ground, uniform scale at top and bottom, parallel axes, no vanishing point, NO HORIZON, NO SKY, NO SUN, NO distant landscape. Detailed crisp hand-crafted pixel clusters, palette of muted dark rust-red sand, dusty ochre stones and charcoal basalt with upper-left ambient light matching the module reference. Broad flat empty ground clearing in the central 70% of frame, suitable to place separate base sprites. Low broken rocky shelves and scattered small isometric boulders only near outer corners and side edges, no tall cliffs or objects obscuring center. All rock top planes flattened into 2:1 diamond footprints, visible shaded vertical sides, same overhead angle as reference building roofs. Subtle shallow erosion cracks and windblown dust on level ground, no converging ridges, no ground shrinking toward top. No buildings, no pads, no ruins, no roads, no vehicles, no plants, no text, no HUD. A seamless-looking continuous isometric terrain environment, NOT a cinematic landscape painting and NOT a floating island.

## Paisatge marcià

Production background layer for SUBTERRA MARS 2D pixel-art game, wide 16:10 composition. Detailed hand-drawn crisp pixel art with individually visible pixel clusters and restrained dithering, NOT vector, NOT low-poly, NOT smooth painting. Dark cinematic Martian landscape at late dusk: dusty burgundy sky taking upper third, a SMALL pale distant sun high right, layered rust-red mesas, eroded cliffs and distant mountain ridges across horizon around 35% height, atmospheric dust between ridges. Lower two-thirds is gently sloping rust-brown rocky dusty ground viewed from above in 2.5D, pebbles, weathered rock shelves at sides and corners. Reserve broad QUIET LEVEL OPEN CLEARING in central lower area, around center x50%, y65%, for game modules to be placed later; no large boulders in clearing. Edges darker to frame play area; subtle orange dusk edge highlights, desaturated dark rocks. Same detailed pixel-art shading as attached base reference. No buildings, NO base, no platforms or manufactured pads, no astronauts, no vehicles, no lights, no cables, NO text, NO HUD, NO circles, no road, no flora. Environment art only, never an entire game screenshot.

## Mòduls independents

Production sprite atlas for SUBTERRA MARS surface base, match the attached dark metal building's detailed crisp pixel-art style, shading and cyan/orange accents. EXACTLY 2 columns x 2 rows, FOUR equal square cells on perfectly transparent background, no labels/grid. Same isometric 2:1 ground perspective, visible top and two faces, upper-left lighting. Each entire module centered with 12% transparent padding, ground contact bottom at85% of own cell. Cell top-left: broad rectangular low HABITAT building, dark charcoal metal with light dusty steel inset plates, three cyan windows, visible airlock door in front, roof vents, small oxygen tanks at side and rivets; no tall tower. Cell top-right: broad rectangular low COMMAND/RESEARCH building, matching habitat scale, orange door frame, cyan service windows, rooftop comms antenna mast and small satellite dish. Cell bottom-left: TWO linked blue-black solar panel wings on short sturdy tilted supports, small battery cabinet between them, clearly seen in same isometric angle. Cell bottom-right: compact utility cluster of sealed cargo crates, two oxygen tanks, short machine service unit with cyan status lamp. Small service feet sit directly on ground, no raised ground tile under any module, no terrain, no pedestals. Detailed hand-crafted pixel clusters not vectors or smooth 3D. No letters or numbers, no text, no characters, no environment, no cast shadows outside sprites. All four separate wholly contained in their own cell.

## Paviment de servei

A seamless repeating square material texture for a dark sci-fi Mars base service walkway, detailed pixel art. Orthographic top-down flat surface, no isometric perspective baked in. Dark charcoal steel rectangular deck plates, subtle scuffs, tiny rivet bolts at corners, sparse rust-orange Martian dust gathered in seams, thin dark grooves, muted steel highlights. Quiet low-contrast dark material so buildings and astronaut remain readable. Small consistent pixel clusters matching detailed game sprite style. Tileable on all four edges, uniform lighting, no large focal object, no border, no text, no symbols, no lights, no glow, no raised platform or terrain, no 3D render. Opaque texture.

