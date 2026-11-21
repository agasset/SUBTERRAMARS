# SUBTERRA: MARS — Traspàs per al xat de gràfics

Aquest xat és per treballar la direcció artística, els recursos visuals i la seva integració en Godot. El projecte és a `C:/projectes/SubterraMars`. Treballa en català i conserva els canvis pendents del repositori.

## Disseny acordat

- **Mapa general superior.** Xarxa de coves orgàniques i sinuoses, llegible de lluny. Els colors i símbols distingeixen sales escanejades, sales completes, accessos, cobertura i rutes.
- **Exploració isomètrica 2D.** Terra i parets amb relleu, llums locals, explorador petit i elements llegibles durant el moviment. La flora i fauna es componen a partir dels seus trets procedurals.
- **Ciència-ficció fosca en pixel art.** Fons gairebé negre, roca marciana, metall fosc i accents cian i taronja. Els sis biomes i les dues zones finals poden tenir paletes, formes i materials propis.
- **Interfície.** Panells laterals, barres horitzontals de progrés a dalt i fila d’equip a baix. El HUD manté l’escala de lectura quan s’apropa o s’allunya la càmera.

## Referències prioritàries

- [Mapa general de coves](referencies_visuals/Mapa%20de%20Cuevas%20de%20Marte.png)
- [Exploració de sala isomètrica](referencies_visuals/Sala%20isometrica%20Subterra.png)
- [Guia visual](GUIA_VISUAL.md) i [document mestre, seccions 6 i 16](SUBTERRA_DOCUMENT_MESTRE.md)
- [Estat del projecte](ESTAT_PROJECTE.md)

Si el xat no té accés al repositori, adjunta també les dues imatges. Són referències d’estil i composició. El terreny, les galeries i la col·locació d’elements parteixen del món procedural.

## Primer encàrrec | Bases de bioma

Refina la construcció de la sala d’entrada de cada bioma. Es diu **Base – nom del bioma**, i el mapa i el resum la identifiquen amb una icona d’edifici.

- Parteix del mòdul actual amb porta, finestra i antena. Dona-li un acabat de pixel art amb carcassa metàl·lica fosca, llums de servei i accents cian i taronja.
- El mòdul és reutilitzable. Varia l’accent i els detalls segons el bioma, mantenint una silueta de base que es reconegui a tots els estrats.
- La planta es col·loca dins la sala i es projecta amb la mateixa transformació que el terra. La porta i els suports queden arran de roca, amb espai visual al voltant de l’ascensor.
- A l’escala normal de joc s’han de distingir l’entrada i la silueta. Comprova com es llegeix el mòdul amb el zoom d’entrada i amb «Enquadra el mapa».

La implementació actual és a `scripts/main.gd`, a `_draw_biome_base_module`, `_biome_base_footprint` i `_draw_workshop_badge`. El mòdul és un dibuix 2D provisional. Comença per una versió integrada i revisa-la a les sales d’entrada del −1 i el −4 abans d’estendre l’acabat a altres elements.

## Integració

Les dues vistes comparteixen coordenades, llavor, geometria, navegació i estat de descoberta. Conserva aquest contracte quan canviïs els gràfics. Si hi ha sprites o textures, mantén una escala coherent, un punt d’ancoratge a terra i filtratge de veí més proper. Comprova el resultat en una partida i diferencia les proves de renderitzat de la inspecció visual.
