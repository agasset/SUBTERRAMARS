# Posar el projecte en marxa amb Codex

## Preparació

1. Clona el repositori `https://github.com/agasset/SUBTERRAMARS.git` o obre'n el checkout existent.
2. Obre la carpeta del repositori com a espai de treball a Codex o Godot.
3. Consulta l’estat actual abans de continuar.

El repositori ja conté el projecte Godot i les fites implementades fins ara. Conserva els canvis existents. Les decisions visuals actives són la revisió 1.4 del mestre: mapa superior i exploració isomètrica 2D de sala.

Les imatges de referència aportades per Albert estan sota `docs/referencies_visuals/`.

## Missatge inicial per copiar

Treballa en aquest joc d’exploració de coves de Mart. Llegeix AGENTS.md, docs/SUBTERRA_DOCUMENT_MESTRE.md, docs/GUIA_VISUAL.md, docs/PLA_IMPLEMENTACIO.md i docs/ESTAT_PROJECTE.md.

El disseny vigent és la revisió visual 1.4: mapa general superior i vista d’exploració isomètrica 2D de sala. Les dues representacions fan servir el mateix món procedural, coordenades, màscara transitable i estat. No és simulació 3D ni un escenari fix. El joc final inclourà flora/fauna procedurals, escàner, càmera, recursos i millores senzilles.

Inspecciona primer la carpeta, les instruccions existents i la disponibilitat de Godot. Si no hi ha projecte, crea Godot 4 estable amb GDScript i 2D. Si existeix, preserva els canvis i adapta el que sigui compatible.

El prototip ja inclou P0A i part de P0B: generació de 20 coves, galeries, màscara transitable, obstacles, moviment, boira de guerra i renderer isomètric inicial. No els tornis a crear de zero. Revisa `docs/ESTAT_PROJECTE.md`, executa les comprovacions disponibles i continua amb la validació manual del moviment isomètric i les següents fites del pla.

Prioritza el mapa jugable i integra només el mínim de P0B necessari per comprovar moviment i revelació. La flora, fauna, robot, recursos, progressió i final arribaran per fites. No els simulis amb botons decoratius ni intentis construir tot el joc en aquesta primera sessió.

Pren decisions tècniques de detall sense preguntar-me cada pas. Fes servir recursos provisionals propis. Les referències gràfiques són a `docs/referencies_visuals/`; la topologia i el contingut jugable s'han de generar proceduralment, no copiar les imatges com a fons.

Implementa i executa les comprovacions disponibles. Prova la generació amb una bateria acotada de llavors i comprova arrencada i visuals si l’entorn ho permet. Indica exactament què no hagis pogut provar. Actualitza ESTAT_PROJECTE.md amb implementat, verificat, limitacions i següent fita.

En acabar, explica què funciona i com obrir i jugar el prototip. No et limitis a lliurar un pla.

## Missatge per continuar

Llegeix el mestre 1.4 i l’estat actual. Verifica els fitxers reals, corregeix incidències i reprèn la primera fita pendent del pla. Mantén el mapa general superior i l’exploració isomètrica local sobre les mateixes dades. Implementa el següent bloc executable i actualitza l’estat amb les proves realment fetes.

## Generació procedural i visor

Llegeix també docs/ARQUITECTURA_PROCEDURAL.md. Implementa el visor de llavors amb P0A i una bateria inicial de 50 llavors. Mantén separades dades, representació i simulació. Les referències visuals prioritàries són les dues de SUBTERRA: MARS indicades a GUIA_VISUAL.md.

## Estructura de profunditat confirmada — versió 1.3

20 nivells totals. Biomes: 1–3, 4–6, 7–9, 10–12, 13–15 i 16–18. Els nivells 19 i 20 tenen identitat estructural especial reconeixible, amb coves, espècies i investigacions procedurals. Noms i trets concrets provisionals. Vegeu la secció 24 del mestre. Conservar les garanties de navegació, objectius assolibles i persistència. P0A continua amb un nivell; els tres nivells de prova no substitueixen la campanya de 20.
