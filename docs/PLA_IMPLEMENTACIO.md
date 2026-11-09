# Pla d’implementació per a Codex

## Primera entrega

Implementar P0A executable: un nivell amb 20 coves, geometria orgànica procedural, connexions transitables, una unitat i mapa general superior. P0B afegeix una vista d’exploració local isomètrica 2D derivada de les mateixes dades de la sala. El descobriment local i clic per moure validen que totes dues representacions són jugables.

| Fita | Contingut | Acceptació |
| --- | --- | --- |
| P0A Mapa jugable | 20 coves de mides diferents, llavor editable, nova partida, mapa fosc, panells, zoom, arrossegament, selecció i posició d’unitat | Mateixa llavor reprodueix dades; xarxa transitable; càmera no teletransporta |
| P0B Investigació de sala | Interior isomètric 2D de la geometria procedural, navegació per clic, obstacles, abast d’escàner i informació parcial | Canviar de vista manté coordenades, obstacles, estat i boira de guerra; clic isomètric navega sobre la mateixa màscara |
| P0C Flora i fauna | Receptes visuals combinables, un patró de flora i un de fauna amb variants, moviment local, escaneig, marcador i catàleg lateral | Espècie estable i reconeixible; recompensa única |
| P0D Expedició | Base, preparació simple, oxigen, bateria, un robot, punts i una millora | Sortir, descobrir, tornar i millorar; unitats persisteixen |
| P0E Roguelite | Fracàs, material recuperable, perfil persistent i nova xarxa | Recuperació única; món estable entre sortides; catàleg i millores entre mons |
| P0F Profunditat | Tres nivells provisionals de prova, diversos accessos i final simple garantit | Progressió sense bloquejos circulars i tornada vàlida |

Guardar estat bàsic aviat; ampliar-lo a cada fita. No ajornar la persistència fins al final. Objectiu final de 20–40 coves per nivell; partida completa de 20 nivells.

## Estructura suggerida

project.godot a l’arrel. scenes/ per interfície i món 2D; scripts/ per generació, navegació i eines; data/ per paràmetres; assets/ per sprites; docs/ per disseny i estat; tests/ per lògica significativa.

Un model de món per nivell alimenta dos renderers 2D: xarxa superior i sala isomètrica. Les capes poden ser nodes separats, però no han de crear dos mons ni duplicar l’estat. No necessita un autoload per cada funció.

## Generació i navegació

Genera graf, posicions i formes orgàniques amb intents acotats. Construeix galeries contínues. Valida sobre la màscara transitable, no només sobre el graf. La representació simplificada i la navegació han de provenir de les mateixes dades.

Separa RNG de món, espècies i comportaments. Desa llavor, versions i disposició. No regenerar en entrar a una sala o canviar zoom. La fauna conserva identitat i posició encara que no es dibuixi.

## Controls de treball

Proposta inicial: clic esquerre per seleccionar; clic dret per ordre de moviment; roda per zoom; botó central o espai amb arrossegament per pan; escàner a barra d’eines amb drecera configurable. Són valors d’implementació revisables. Escanejar un objectiu ha de requerir unitat amb abast i una acció llegible.

Clicar una cova pot centrar i ampliar. La selecció i el moviment s’han de distingir visualment. No es donen ordres des de botons UI ni en acabar un arrossegament.

## Proves

Bateria inicial de 50 llavors: determinisme, quantitat de coves, connectivitat física, varietat i generació de reserva. Quan existeixi progressió, comprovar requisits assolibles sense dependències circulars.

Proves visuals: mapa superior, projecció isomètrica, conversió clic-pantalla a món, estabilitat de posició en canviar de vista, ocultació, sprites, lectura de panells, selecció i pathfinding sense travessar parets. Els tests de graf no acrediten que la geometria es pugui recórrer.

A cada fita comprovar càrrega del projecte i errors de Godot. Més endavant: desament atòmic, restauració coherent, escaneig sense doble recompensa, material recuperat una vegada i canvi de món preservant perfil.

Si Godot o la pantalla no estan disponibles, completa el que sigui possible, registra què no s’ha provat i dona instruccions curtes per comprovar-ho. No afirmis que un joc és fluid o divertit sense observar-lo.

## Límits

No implementar geometria/simulació 3D, combat, ecologia complexa, genètica, indústria, mons infinits, generació de models per IA, connexions externes obligatòries ni multijugador. La projecció isomètrica de la sala és 2D. La ciència del joc és trobar i escanejar flora i fauna.

## Generació procedural i visor

Llegeix també docs/ARQUITECTURA_PROCEDURAL.md. Implementa el visor de llavors amb P0A i una bateria inicial de 50 llavors. Mantén separades dades, representació i simulació. Les referències visuals prioritàries són les dues de SUBTERRA: MARS indicades a GUIA_VISUAL.md.

## Estructura de profunditat confirmada — versió 1.3

20 nivells totals. Biomes: 1–3, 4–6, 7–9, 10–12, 13–15 i 16–18. Els nivells 19 i 20 tenen identitat estructural especial reconeixible, amb coves, espècies i investigacions procedurals. Noms i trets concrets provisionals. Vegeu la secció 24 del mestre. Conservar les garanties de navegació, objectius assolibles i persistència. P0A continua amb un nivell; els tres nivells de prova no substitueixen la campanya de 20.

## Fita posterior P0G — Campanya i biomes

Expandir el recorregut abreujat de P0F a 20 nivells. Implementar sis perfils de bioma de tres nivells i dos perfils especials, investigacions procedurals resolubles i persistència. Verificar fronteres de bioma, final al 20, variació per llavor i identitat recognoscible dels dos perfils especials.
