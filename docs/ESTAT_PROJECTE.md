# Estat de traspàs

9 de novembre de 2026 · Disseny 1.4

## Existeix

Document mestre amb els sis blocs i la revisió visual aprovada, guia visual, AGENTS.md, pla de fites i missatge inicial per a Codex.

## Implementació P0A i P0B

El paquet 1.3 s'ha extret a l'arrel del projecte i s'ha creat un prototip Godot 4 amb `project.godot`, escena principal i scripts propis. El projecte inclou un generador d'un nivell amb 20 coves, formes orgàniques, galeries, llavor editable i visor de llavors. El mapa general és superior; la vista d'exploració de sala és isomètrica 2D i reutilitza dades, coordenades, estat i màscara del mateix món.

P0B inclou màscara de terreny, obstacles, revelació local progressiva, escàner local i línia de visió. Encara no hi ha flora/fauna, recursos d'expedició, desament de partida ni progressió.

La vista normal del jugador només mostra coves visitades i sortides escanejades. El control «Mapa complet (dev)» revela la topologia generada per a inspecció; les ordres de moviment del mode jugador només poden seguir cel·les ja revelades.

## Verificació P0A

- Godot 4.6.2 stable carrega i inicialitza l'escena principal en mode headless.
- Bateria `scripts/seed_validation.gd`: 50 llavors, 20 coves per llavor, entrada vàlida, graf connectat i repetició determinista dins la mateixa execució. Resultat: 50/50 aprovades; informe a `reports/seed_validation_50.json`.
- La màscara rasteritza cambres i galeries en 220 × 150 cel·les. Les 50 llavors han passat connectivitat física, punts d'aparició i ruta de l'entrada fins a la cova més llunyana.
- P0B afegeix obstacles de roca deterministes, que es descarten si trenquen connectivitat; descobriment local i línia de visió bloquejada per parets/roques. L'escàner de sala revela el terreny visible de la cova actual, marca les seves sortides i pinta una petita zona d'arribada al començament de cada sala connectada; la resta de la cova veïna roman oculta. En zoom d'investigació es mantenen dibuixades les coves ja visitades; la cova actual i la capa d'informació revelada defineixen el detall visible.
- Les mateixes 50 llavors passen comprovacions de camí, bloqueig d'obstacles, línia de visió i abast de l'escàner restringit a la sala actual. Canviar les dades de càmera no modifica la posició ni la màscara descoberta.
- Les 50 llavors també validen una ordre sobre una boca coneguda, el trajecte transitable fins a la sala veïna i la continuació cap al seu interior després d'escanejar-la.
- La vista de jugador amaga les coves no visitades, les connexions no descobertes i el recompte total; el mapa de desenvolupament revela tota la xarxa sota una acció explícita. Les ordres a cel·les desconegudes queden bloquejades. Les 50 llavors validen visibilitat del mapa normal i del mode de desenvolupament.
- Les sortides escanejades es representen com boques de galeria pintades a la paret de la cova, en lloc de fletxes. Amb clic dret sobre una boca coneguda, l'explorador rep una ordre cap a la cel·la transitable revelada més propera de dins la sala. Els robots encara no són unitats implementades; podran reutilitzar aquest punt d'accés quan s'afegeixin. Si l'ordre s'ha donat sobre una boca coneguda i hi ha ruta, l'explorador travessa la galeria, entra a la cova connectada i continua fins al seu interior. En arribar no s'escaneja la nova sala automàticament; cal prémer «Escàner sala». El trajecte només s'habilita per la sortida escanejada; les altres coves i galeries continuen ocultes.
- La geometria es representa des de dades de món; el zoom/pan només canvia càmera i no modifica la posició de la unitat.
- Captura real del viewport Godot generada amb renderitzador OpenGL: `reports/prototip_screenshot.png`. Revisió visual: mapa, panells laterals, visor de capes i barra d'eines visibles; es van corregir els panells que s'estiraven/ancoraven incorrectament.
- `reports/mapa_complet_dev.png` mostra la mateixa llavor amb l'acció de desenvolupament activada; en mode jugador `reports/prototip_screenshot.png` només mostra la sala inicial i les seves dues sortides escanejades.
- Captura actualitzada després del canvi visual: `reports/prototip_screenshot.png`; les sortides s'hi veuen com galeries curtes pintades.
- No s'ha fet encara una sessió manual de joc amb entrades de ratolí/teclat; les comprovacions d'interacció s'han fet per la lògica del prototip i la captura del viewport.

## Fitxers principals

- `project.godot`
- `scenes/main.tscn`
- `scripts/main.gd`
- `scripts/world_generator.gd`
- `scripts/seed_validation.gd`
- `reports/seed_validation_50.json`

## Com executar

Obrir `C:\projectes\SubterraMars\project.godot` amb Godot 4 i prémer F6/F5. Per les comprovacions de dades: `godot --headless --path C:\projectes\SubterraMars --script res://scripts/seed_validation.gd`.

## Decisions recents que prevalen

Revisió visual 1.4 aprovada: mapa general superior i vista isomètrica 2D en entrar/inspeccionar una sala. No és un món 3D ni una escena fixa; totes dues vistes reutilitzen les dades procedurals. Nom confirmat: SUBTERRA: MARS. 20 nivells confirmats.

## Proposta de disseny pendent

Albert proposa que les millores de l'escàner permetin detectar progressivament més enllà de les sortides de la cova actual. La distància, els límits i quina informació s'hi revela encara no estan decidits. El prototip `p0b-2` manté l'escaneig limitat a l'interior visible de la sala actual i les seves sortides; no s'ha canviat el comportament implementat.

## Plantilla per a la següent actualització

Fita implementada:
Fitxers principals:
Com executar:
Proves executades i resultat:
No verificat:
Errors o limitacions:
Següent fita:

## Actualització 1.3

Nom i dues referències visuals confirmats. Arquitectura procedural i visor especificats. Aquesta actualització afegeix documentació, no implementació Godot. Les proves del generador continuen pendents.

## Estructura de profunditat confirmada — versió 1.3

20 nivells totals. Biomes: 1–3, 4–6, 7–9, 10–12, 13–15 i 16–18. Els nivells 19 i 20 tenen identitat estructural especial reconeixible, amb coves, espècies i investigacions procedurals. Noms i trets concrets provisionals. Vegeu la secció 24 del mestre. Conservar les garanties de navegació, objectius assolibles i persistència. P0A continua amb un nivell; els tres nivells de prova no substitueixen la campanya de 20.

## Actualització 1.3

Consolidats els 20 nivells, els sis grups de biomes i la generació especial de 19–20. Verificació documental i integritat del paquet; encara sense codi Godot ni proves de generació executades. Següent pas: implementar P0A.

## Actualització de desenvolupament P0A

P0A completat a nivell de prototip. P0B inclou màscara transitable, obstacles compatibles amb connectivitat, camins visuals, revelació local i escàner limitat a la cova actual. El mode jugador mostra només coves visitades/sortides descobertes i impedeix ordres a terreny desconegut. «Mapa complet (dev)» revela la topologia per inspecció. Godot 4.6.2 ha carregat l'escena; 50 llavors aprovades, incloent-hi l'abast local de l'escàner i el filtratge del mapa. Captures a `reports/prototip_screenshot.png` i `reports/mapa_complet_dev.png`. No verificat: sessió interactiva manual completa, flora/fauna ni persistència. Següent: validar controls en una sessió de joc i començar P0C.

## Actualització visual d'accessos a cova

S'han substituït les fletxes de sortida per boques de galeria pintades que interrompen el contorn. El clic dret a prop d'una sortida coneguda envia l'explorador a una cel·la transitable i revelada de la sala. Godot 4.6.2: bateria headless de 50 llavors aprovada; captura OpenGL actualitzada. Limitació: cap robot seleccionable encara, per tant les ordres a robot són futures.


## Actualització de trànsit entre coves

Una ordre a una boca coneguda ara encadena el desplaçament per la galeria fins a una cel·la d'arribada dins la sala veïna; en detectar l'entrada, s'escaneja la nova cova i l'explorador continua fins al seu interior. El descobriment del corredor i del punt d'arribada només s'aplica a la sortida escanejada. Verificació: seed_validation.gd aprovat amb 50/50 llavors, incloent-hi comprovació de pas i navegació a la sala següent. Captura del viewport regenerada. Després d'un primer signal 11 en execució concurrent, el llançament headless independent s'ha repetit i ha acabat correctament amb codi 0 (--quit-after 5).


## Actualització de memòria del mapa i escàner

Les coves visitades ja no desapareixen quan el zoom passa a vista d'investigació. En prémer «Escàner sala», la càmera centra la cova actual i puja com a mínim a zoom 1.5 perquè es vegi el terreny escanejat; les zones desconegudes continuen cobertes. Verificació: bateria de 50 llavors aprovada, incloent-hi persistència visual de sales visitades en zoom i centrat/zoom de l'escàner. Captures regenerades amb OpenGL.


## Actualització de persistència dels enllaços

Les galeries descobertes ara es dibuixen a qualsevol nivell de zoom i continuen visibles quan s'entra a la sala connectada i després se n'allunya. Només es dibuixa un corredor si se n'ha escanejat almenys una sortida; la capa d'informació desconeguda continua tapant els trams no revelats. Verificació: seed_validation.gd aprovat 50/50, comprovant en zoom d'investigació que l'enllaç d'entrada persisteix després d'escanejar la sala de destí. Captures regenerades amb OpenGL.


## Actualització de vista prèvia de sala connectada

En escanejar una cova, també es pinten les cel·les inicials revelades dins les sales veïnes connectades, a continuació del tram de galeria. El marc de càmera prioritza la cova actual i la sala veïna més propera perquè el jugador pugui percebre la continuïtat. No es dibuixa el contorn de la sala inexplorada i el seu centre continua ocult. Verificació: bateria de 50 llavors aprovada; cada sortida escanejada revela el punt d'arribada però no el centre de la sala. Captura OpenGL regenerada a eports/prototip_screenshot.png.


## Actualització dels contorns revelats

Les coves completament escanejades mantenen el contorn complet. Per a una sala veïna encara no explorada, només es dibuixen els petits trams del contorn adjacents a cel·les revelades del seu inici; no es mostra la silueta completa. Verificació: 50/50 llavors; totes les sortides escanejades tenen cel·les inicials revelades i almenys un tram de contorn visible, amb el centre de la sala encara ocult. Captura OpenGL regenerada.


## Correcció: contorn només després d'escanejar

Es retira el contorn parcial de les sales veïnes. Abans d'escanejar una sala, no es dibuixa cap part del seu contorn, encara que el terra inicial sigui visible. Després de l'escaneig, la sala passa a visitada i es dibuixa el contorn complet com a les altres coves. Verificació: seed_validation.gd aprovat 50/50; confirma que les sales veïnes no es dibuixen com explorades abans de l'escaneig i sí després.


## Correcció: entrada a sala sense escaneig automàtic

L'entrada del jugador a una sala connectada només actualitza la seva ubicació. No marca la sala com a explorada, no pinta el contorn i no activa l'escàner. En prémer «Escàner sala», es revela la sala completa i es dibuixa el contorn. Verificació: seed_validation.gd aprovat 50/50, comprovant entrada sense contorn seguida d'escaneig explícit; captura i arrencada headless regenerades correctament.


## Actualització de les ordres a sala

El clic dret sobre una sala visitada o sobre la porció inicial revelada d'una sala veïna ara resol el punt clicat al punt transitable conegut més proper dins la sala i calcula la ruta. Això evita que l'ordre falli perquè el cursor cau sobre una cel·la desconeguda o no transitable. Les sortides no escanejades i les cel·les ocultes continuen sense ser destins vàlids. Verificació: bateria 50/50; cada sala veïna accessible s'ha seleccionat pel centre i s'ha validat un camí només per cel·les transitables/revelades. Arrencada headless i captura OpenGL correctes.


## Correcció de clics al costat del panell

La franja dreta de la finestra ja no es tracta sencera com a interfície; només els rectangles reals dels panells bloquegen ordres de mapa. Això permet clicar sales revelades situades sota o al costat del panell dret. La resolució del destí continua triant la cel·la transitable revelada més propera dins la sala. Verificació: seed_validation.gd aprovat amb 51 llavors (0–49 i la llavor reproduïda 134027), incloent-hi prova que una coordenada de mapa a la dreta del panell accepta clics i la coordenada sobre el panell queda bloquejada. Arrencada headless i captura OpenGL correctes.


## Descoberta de sortides per proximitat

Quan l'explorador s'acosta a la boca d'una galeria, aquesta sortida i el seu enllaç es marquen automàticament, encara que no s'hagi activat l'escàner. Només es descobreix la boca a la qual s'ha arribat; això no marca la sala com escanejada ni dibuixa el seu contorn complet. Verificació: bateria de 51 llavors aprovada, incloent-hi detecció per proximitat, permanència del contorn ocult i sense revelar el centre de la sala veïna. Arrencada headless i captura OpenGL correctes.


## Actualització de galeries orgàniques

El generador passa a p0b-2: cada connexió es construeix com una corba procedural suau i determinista, amb amplada variable segons la mida de les sales (aprox. 24–48 unitats). També s'ha afegit una neteja de cel·les transitables aïllades de la rasterització. Verificació: bateria de 51 llavors aprovada (inclosa 134027), amb comprovació explícita de curvatura i diversitat d'amplades, connectivitat de màscara, camins i escàner. Captura OpenGL regenerada.


## Correcció visual de les boques de galeria

S'elimina la franja rectangular que se superposava a la sortida. El contorn de la sala ara deixa una obertura ajustada a l'amplada de la galeria, retallant només el tram necessari de cada costat del polígon. En descobrir o escanejar una sortida, també es revela una petita zona de transició a la boca per evitar talls de boira de guerra en forma d'escala. Els clics dins d'una sala veïna revelada prioritzen la sala abans que la detecció de proximitat a la sortida. Verificació: bateria `seed_validation.gd` aprovada amb 51/51 llavors; captura interactiva amb OpenGL regenerada.


## Selecció amb vista d'anàlisi propera

En clicar una sala visible, aquesta queda seleccionada i la càmera l'enquadra en vista propera (`zoom >= 1.25`). La selecció només canvia càmera i resaltat; no mou l'explorador ni revela cel·les. La ruta queda com a indicació visual i continua calguent una ordre de moviment explícita per desplaçar-se. Verificació: bateria `seed_validation.gd` aprovada amb 51/51 llavors i arrencada/captura OpenGL regenerades.


## Selecció de sales abans de l'escaneig

El clic també selecciona un fragment inicial de sala que ja s'hagi revelat al mapa encara que la sala continuï inexplorada. La càmera se centra en el fragment visible, el ressalta suaument i entra en vista propera; no s'infereix ni es dibuixa el contorn complet, no s'afegeixen cel·les revelades i no es calcula cap ruta fins al centre ocult. La selecció continua sense moure l'explorador. Verificació: bateria `seed_validation.gd` aprovada amb 51/51 llavors; arrencada headless correcta.


## Escàner sense canvi de càmera

L'escàner ja no fa zoom ni centra les sortides quan s'activa. El botó només s'habilita després de seleccionar amb clic la sala on és l'explorador; clicar una sala veïna no permet escanejar-la a distància. Verificació: prova d'interacció puntual confirma que una sala veïna visible es pot seleccionar sense revelar ni moure, que l'escàner queda deshabilitat per a aquella sala i que, en seleccionar la sala actual, escaneja sense alterar zoom ni càmera; bateria general 51/51 aprovada.


## Augment de la vista d'anàlisi

La selecció d'una sala entra en un mode d'anàlisi diferenciat sobre el mateix mapa superior: canvia la capçalera a «ANÀLISI DE SALA», substitueix els controls de llavor per «TORNA AL MAPA», amaga panells de mapa i mostra les eines de la sala. El contorn conegut s'ajusta automàticament perquè ompli aproximadament el 84% de l'àrea disponible; un fragment inexplorat centra i amplia només les cel·les visibles. Esc i «TORNA AL MAPA» retornen a l'escala general. El zoom manual arriba fins a 8×. Verificació: bateria 51/51 aprovada; prova visual OpenGL confirma zoom 5.28× amb la sala ocupant la vista sense que els panells laterals la tapin. Captura a `reports/mode_analisi_sala.png`.


## Mode d'exploració local de sala

En seleccionar una sala s'entra a «EXPLORACIÓ DE SALA». La representació deixa d'ensenyar les altres cambres i els elements aliens; només mostra la cambra seleccionada (o el fragment que ja s'hagi revelat si no s'ha explorat), l'explorador, els obstacles locals coneguts i trams curts de les seves sortides descobertes. La resta de la xarxa no es regenera ni es perd: «TORNA AL MAPA» o Esc retorna a la vista general. El mode de desenvolupament tampoc no força la revelació d'altres sales dins d'aquesta vista. Verificació: `seed_validation.gd` comprova l'aïllament de sala, la boira de guerra i els trams de galeria; bateria 51/51 aprovada. Captura OpenGL actualitzada a `reports/mode_analisi_sala.png`.


## Actualització visual 1.4 — renderer isomètric procedural

Albert ha aprovat les dues referències visuals com a format real: mapa de xarxa superior i vista isomètrica 2D per explorar una sala. Les instruccions visuals antigues queden supersedides; es conserven les 51 respostes històriques del mestre.

`main.gd` projecta contorn, terra revelat, parets, obstacles, sortides conegudes i explorador en isomètric. El renderer llegeix la mateixa geometria, màscara transitable, coordenades, estat i boira de guerra que el mapa superior. La conversió de pantalla a món és inversible i s'ha comprovat sobre centres i punts del contorn; canviar de vista no regenera ni mou la unitat. El terra i sprites són encara geometria provisional; flora, fauna, robot, llums i recursos com a entitats procedurals encara no estan implementats.

Verificació: `seed_validation.gd` aprovat amb 51/51 llavors, inclosa la prova de projecció isomètrica d'anada/tornada. Captura del renderer amb OpenGL generada a `reports/mode_analisi_sala.png`; és una comprovació visual de prototip, no una sessió manual de joc. Següent pas: provar moviment amb clic dins la vista isomètrica i millorar parets, materials i contingut procedural de sala.

## Sortides de sala isomètriques

Les sortides descobertes ja no es dibuixen com a punts: es representen com galeries amb paviment i murs laterals, seguint la corba procedural original des de la boca de la sala. El renderitzat respecta la màscara revelada i s'atura al límit d'una sala veïna inexplorada. Verificació: `seed_validation.gd` aprovat amb 51/51 llavors; captura OpenGL actualitzada a `reports/mode_analisi_sala.png` i inspeccionada. No s'ha fet una sessió manual de moviment dins del joc.

## Ajust del llindar isomètric i visibilitat del jugador

La revisió de captura va mostrar que dibuixar el corredor sencer sobre la cambra el feia desencaixar de la boca i podia creuar visualment el jugador. Ara la cambra retalla el mur a la sortida i només hi dibuixa un tram curt de galeria des de la posició exacta de la boca; el paviment s'ordena sota la cambra i la unitat es dibuixa al davant tant dins la sala com dins aquest tram. La generació procedural i les rutes no s'han canviat. Verificació: `seed_validation.gd` aprovat amb 51/51 llavors; captures OpenGL revisades, inclosa `reports/sortida_isometrica.png` amb l'explorador al llindar. Encara no s'ha fet una sessió manual amb clics de moviment.

## Retorn automàtic al mapa en sortir de la sala

Quan l'explorador travessa el límit de la sala seleccionada cap a una galeria, la vista isomètrica retorna al mapa general i centra la càmera en la seva posició. L'ordre de moviment i la ruta continuen actives, de manera que el jugador es veu recórrer el mapa i pot arribar a la sala següent. La transició no s'activa només per seleccionar o enfocar una altra cambra. Verificació: bateria `seed_validation.gd` aprovada amb 51/51 llavors; ara inclou una prova de sortida de cambra i retorn automàtic al mapa. No s'ha fet una sessió manual de clics.

## Transició amb el túnel visible

S'ha corregit el canvi prematur de vista: després de creuar la paret, el jugador continua veient i recorrent el tram isomètric curt del túnel; només en deixar-lo torna al mapa general. El mapa se centra en el jugador amb zoom 1.1 per mostrar la cambra propera i el corredor descobert, en lloc de saltar a l'escala global 0.62 durant la sortida. Verificació: `seed_validation.gd` aprovat amb 51/51 llavors i comprovació que el mode isomètric es manté dins del tram, després torna al mapa amb el corredor dibuixat. Captura OpenGL a `reports/transicio_mapa_tunel.png` (map_mode=true, corridor_visible=true).

## Sortida manual del mode d'inspecció

S'ha retirat el canvi automàtic de vista en travessar una boca. La inspecció es manté activa mentre el jugador recorre el corredor; en prémer «SURT D'INSPECCIÓ» (o Esc) es torna al mapa general, centrat i amb zoom 1.1. El jugador continua dibuixat al corredor connectat mentre la inspecció és activa. Verificació: `seed_validation.gd` aprovat amb 51/51 llavors; la prova mou l'unitat pel tram, comprova que la vista no canvia automàticament i activa la sortida manual, validant que el túnel queda visible al mapa.

## El jugador ha de canviar de vista abans de sortir de la sala

En mode d'inspecció, la ruta de moviment queda retallada al contorn transitable de la sala seleccionada i cada pas de moviment comprova el límit abans d'actualitzar la posició. Si una ordre intenta travessar una sortida, el jugador s'atura a l'última posició interior i apareix l'avís «SURT D'INSPECCIÓ PER TRAVESSAR LA SORTIDA». Cal prémer «SURT D'INSPECCIÓ» (o Esc) per canviar al mapa; aleshores es pot continuar el moviment pel túnel sense perdre l'estat ni la posició del món. Verificació: `seed_validation.gd` aprovat amb 51/51 llavors, incloent moviment dins la sala, bloqueig del límit, canvi al mapa i moviment posterior. Captura OpenGL revisada a `reports/transicio_mapa_tunel.png`; el personatge roman dins la sala fins al canvi de vista.

## Detecció propera i terra de sala

En acostar-se a menys de 80 unitats del perímetre d'una cova encara no explorada, l'explorador en detecta un senyal aproximat. El marcador es pot seleccionar per obrir-ne la vista local, però no mostra el contorn real ni marca la sala com escanejada; el contorn complet continua reservat a l'escàner. La sala escanejada ara omple el terra sota tota la seva silueta i utilitza soroll i detalls de roca deterministes per llavor, sense el mosaic de rombes. Les galeries locals s'han rebaixat per no tapar la boca de sortida. Verificació: 51/51 llavors, inclosa detecció pròxima, selecció del senyal sense escaneig i distinció entre sala detectada i explorada. Captures OpenGL revisades: `reports/deteccio_cova_proximitat.png` i `reports/mode_analisi_sala.png`.
## Continuïtat de sortides a la vista isomètrica

S'ha ajustat la geometria de les galeries locals perquè la seva amplada compensi la projecció isomètrica, el paviment comenci més enllà de la paret i el tram segueixi la tangent del corredor procedural amb una corba suau. Els laterals ara es dibuixen com parets baixes contínues, i les obertures de paret/contorn es calculen amb l'amplada projectada de la mateixa galeria. Això és una millora del renderer de dades existents: no modifica el graf, les màscares ni la navegació. Verificació: Godot 4.6.2 ha carregat scripts i escena en mode editor sense errors; `seed_validation.gd` aprovat amb 51/51 llavors. S'ha regenerat la captura `reports/sortida_isometrica.png`. Limitació: la comprovació visual feta en aquest entorn va mostrar les galeries i parets però no va reproduir de manera fiable la captura interactiva de llindar; cal revisar el joc amb el zoom i una ordre de moviment real abans de donar el model visual per acabat.
## Continuïtat del pla del paviment a les sortides

S'ha corregit el càlcul transversal de les galeries isomètriques: els laterals del terra es calculen perpendiculars a la tangent projectada i es converteixen a coordenades del món amb la inversa de la projecció. Això evita que la boca es dibuixi com una plataforma desplaçada respecte del pla del paviment de la sala. La planta del camí no rep cap desplaçament vertical; l'alçada queda només als paraments laterals. La màscara, el graf i la navegació no canvien. Verificació: càrrega de l'escena Godot 4.6.2 sense errors, bateria `seed_validation.gd` 51/51 i `git diff --check` net. No s'ha fet una nova captura interactiva del llindar; cal revisar visualment el joc en execució abans de considerar el detall acabat.
## Correcció de la unió entre túnel i paviment de sala

La revisió de la captura va trobar la causa concreta de la separació: el tall calculat per obrir el mur a la sortida no s'afegia a la llista de segments; per tant el mur seguia tapat i el paviment del túnel semblava una plataforma a part. S'ha restaurat l'aplicació del tall. El tram de terra ara comença 10 unitats dins la sala i segueix la corba procedural existent, de manera que se superposa al paviment de la cambra abans de sortir. La validació inclou que el primer punt del tram sigui dins del contorn i que el segment inicial passi per la boca. Verificació: Godot 4.6.2 carrega sense errors; bateria de 51 llavors aprovada; `git diff --check` net. Pendent: una revisió manual de captura en execució per confirmar l'aspecte final.
## Galeries coplanàries amb el terra de sala

La captura posterior ha mostrat que els paraments laterals de la galeria es dibuixaven com cares verticals altes, donant la impressió que el camí s'elevava del paviment. S'han eliminat aquestes extrusions: el túnel es representa com una superfície de terra dins la mateixa projecció isomètrica de la sala, amb línies de contorn planes només a la part exposada més enllà del llindar. El tram interior se superposa al paviment i no hi afegeix vores visibles. Verificació: Godot 4.6.2 importa i carrega l'escena sense errors; bateria de llavors `seed_validation.gd` 51/51 aprovada i `git diff --check` net. No s'ha pogut verificar una captura renderitzada nova en aquesta execució; la revisió visual en el joc continua pendent.
## Extensió del terra de sala cap a les coves connectades

S'ha refet la representació de les sortides conegudes: el polígon de terra de la cambra es combina en coordenades del món amb les franges de galeria de totes les boques visibles, i es dibuixa com una única superfície coplanària amb textura ancorada al món. Els contorns de galeria comencen fora del llindar; no es creen peces amb alçada pròpia ni laterals elevats. La generació, el graf i la màscara transitable no canvien. Verificació: càrrega Godot 4.6.2 sense errors i bateria `seed_validation.gd` 51/51 aprovada; s'ha observat la vista en execució Godot 4.7.2. Limitació: l'escàner de la prova manual no va acceptar l'acció perquè el joc de prova no reconeixia la sala seleccionada com la del jugador; cal confirmar en una partida interactiva que la superfície completa es veu com es vol després d'escanejar les sortides.
## Mateixa alçada visual per a totes les sales

El món no assigna una coordenada Z a les cambres: les plantes de sala i galeria comparteixen les mateixes coordenades Vector2 i la mateixa projecció isomètrica. La sensació d'alçada diferent venia de les parets del darrere, que s'extrudien cap amunt de la pantalla mentre les del davant baixaven. Ara les vores posteriors només segueixen el contorn del terra; el gruix de paret es dibuixa amb una profunditat constant cap avall a les vores frontals. Això manté les sales i les galeries al mateix pla visible sense aplanar les direccions del món. Verificació: càrrega de Godot 4.6.2 sense errors, bateria `seed_validation.gd` 51/51 i `git diff --check` net. No s'ha fet una nova prova visual interactiva després d'aquest ajust.

## Galeries integrades al paviment de la sala

Correcció d'abast: l'ajust anterior de l'alçada de les parets de la sala no tractava el que demanava Albert. S'ha restaurat el dibuix anterior de les parets i s'ha canviat només el renderer de galeries: ara dibuixa l'extensió de la galeria com a part del mateix paviment texturat i projectat que la sala, sense traçar vores pròpies que semblaven graons o rampes. La geometria, ruta i amplada continuen venint del corredor procedural, en les mateixes coordenades 2D del món; no s'han aplanat les direccions del mapa ni s'han canviat graf, màscara o navegació. Verificació: importació/càrrega headless amb Godot 4.6.2, bateria `seed_validation.gd` 51/51 i `git diff --check` correctes. Limitació: no s'ha fet captura visual interactiva després del canvi; cal revisar en execució que la galeria es llegeixi com a continuació del terra.

## Galeries amb paviment visible

La revisió va mostrar que la unió booleana del contorn de sala i el corredor podia deixar el paviment de les galeries sense textura. Ara es dibuixa primer el terra complet de la sala explorada i cada galeria es pinta com una franja triangulada separada, coplanària i amb UV del món perquè la textura continuï a través de la boca. Verificació: Godot 4.6.2 importa i executa la captura OpenGL reports/sortida_isometrica.png. La galeria hi apareix pintada. Bateria de llavors: 51/51 aprovada; git diff --check net.

## Boques de galeria proporcionades

La captura de la sala 05 amb sis sortides va revelar franges massa amples i llargues. L'amplada de cada galeria ara es calcula en coordenades del món, igual que la boca i la màscara transitable; el tram local visible és curt, s'estreny gradualment i acaba fonent-se amb la zona fosca. El centre passa exactament per la posició de la sortida i segueix l'inici de la corba procedural. El paviment es dibuixa per triangles consecutius per evitar polígons invàlids a les corbes. Verificació: importació Godot 4.6.2 sense errors, bateria de 51 llavors aprovada, captura OpenGL de la sala 05 amb sis sortides a reports/galeries_sala_05.png i captura actualitzada a reports/sortida_isometrica.png. Limitació: la captura visual no substitueix una prova manual de moviment amb el jugador.

## Sortida caminant per la galeria

En exploració de sala, un clic dret sobre una galeria visible dona una ordre de moviment explícita cap a la sala connectada. La ruta passa per la boca i pel tram local dibuixat; l'explorador es veu avançar-hi. En superar el final del tram local la vista canvia al mapa general, centrada en la seva posició, i l'ordre de moviment continua. Una ruta sense ordre de galeria no travessa la paret. Les boques ara es calculen on la corba real del corredor creua el contorn de la sala, perquè el terra dibuixat i la màscara transitable coincideixin. La versió del generador puja a p0b-3; les llavors de disposició continuen utilitzant p0b-2 per conservar la xarxa ja coneguda. Verificació: Godot 4.6.2 carrega sense errors, 51/51 llavors aprovades i prova de transició per la sortida inicial i les sis sortides de la sala 05; captura OpenGL de la sala actualitzada. Limitació: la transició s'ha comprovat amb simulació de moviment i captura; falta una sessió manual de clics al joc.

## Inspecció automàtica en arribar a una sala

Quan una ordre de moviment porta l'explorador des del mapa o per una galeria fins a una altra sala, en travessar el contorn s'activa l'exploració isomètrica, la càmera centra la sala i aplica el zoom d'inspecció. La ruta dins la sala continua fins al punt d'arribada. Verificació: la prova de moviment simula la sortida de la vista d'inspecció, el pas pel mapa i l'entrada a la sala connectada; comprova que el mode d'inspecció s'activa allà. També passen les sis sortides de la sala 05 i el total de 51 llavors.

## Inspecció progressiva de sales desconegudes

En arribar a una sala nova, s'obre la vista isomètrica però no es dibuixa tota la cambra. Només apareix el paviment a l'abast de visió de l'explorador, amb boira sobre la resta; el radi de revelació és més curt dins sales encara no escanejades i s'actualitza a mesura que es mou. Les cel·les visibles reutilitzen la mateixa textura del paviment escanejat amb UV del món, i els detalls només es pinten dins la zona revelada. La signatura cyan de detecció no es dibuixa a sobre del jugador quan ja ha entrat. El contorn complet i les sortides no es marquen descoberts fins a utilitzar l'escàner. Verificació: la prova de trajecte comprova que la sala continua fora de `explored_caves` i que només se'n revela una part en arribar; bateria de 51 llavors aprovada. Captura: reports/mode_mirar_sala.png.
