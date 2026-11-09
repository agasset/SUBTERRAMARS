# SUBTERRA: MARS

## Disseny vigent

Llegeix docs/SUBTERRA_DOCUMENT_MESTRE.md i les actualitzacions visuals posteriors a la versió 1.3, docs/GUIA_VISUAL.md, docs/PLA_IMPLEMENTACIO.md i docs/ESTAT_PROJECTE.md. Formen el traspàs vigent del projecte d’Albert, originat com PROJECT NESS dins Ness Operation. La decisió visual més recent preval sobre paquets 0.x i revisions anteriors.

El joc és 2D pixel art amb dues representacions: mapa general superior i vista isomètrica 2D en entrar/inspeccionar una sala. Totes dues provenen del mateix món procedural, coordenades lògiques, màscares transitables i estat de descoberta; canviar de vista no regenera ni teletransporta res. No crear un món 3D ni escenes fixes com a substitut de dades procedurals.

## Experiència

Explorar coves marcianes per trobar flora i fauna procedurals. Un explorador i robots amb clic per moure i interactuar, escàner i càmera, oxigen i bateria, punts de recerca, millores permanents i catàleg. Món nou en començar partida; tornar a la base conserva el món actual.

20–40 coves orgàniques petites, mitjanes i grans per nivell. Sortides de 30–60 minuts orientatius, amb autodesament. Diversos accessos inferiors, descens opcional, retorn si existeix ruta. 20 nivells confirmats; tres només en proves abreujades.

## Forma de treball

Comunica’t en català. Albert autoritza decisions de detall sense qüestionaris continus. Inspecciona la carpeta i qualsevol instrucció aplicable abans d’editar; preserva canvis existents. Si no hi ha projecte, crea Godot 4 estable amb GDScript i 2D. Si existeix, conserva versió i estructura compatibles. No toquis altres projectes d’Albert.

Implementa per fites executables. Primera sessió: P0A i, si es pot integrar i provar, el mínim P0B. No et limitis a un pla quan puguis crear la primera versió. No intentis fer tot el joc alhora.

Utilitza geometria i recursos provisionals propis. Les imatges de referència defineixen la composició final (mapa superior i sala isomètrica), no són contingut que s'hagi de copiar com a fons. No calen compres, connectors ni generació d’assets externa per començar.

## Regles innegociables

- Zoom i desplaçament no mouen unitats, no revelen dades desconegudes ni recarreguen reserves.
- Clicar una cova centra o selecciona; moure-hi l’explorador requereix ruta i ordre explícita.
- L’escàner territorial pot detectar coves properes, però no revela automàticament la flora i fauna.
- Generació per llavor i versions, amb identitats estables i estat desable. Màscara real transitable coherent amb el graf. Mapa superior i vista isomètrica projecten les mateixes dades.
- Ruta cap al fons i millores obligatòries assolibles sense bloquejos circulars. No exigir una espècie raríssima per progressar.
- Intent de generació acotat i reserva segura si falla.
- Recompenses idempotents. Guardar separadament perfil i partida de manera coherent.
- Fracàs deixa material recuperable al món actual; no genera automàticament un món nou.
- No afegir ecologia completa, cadenes alimentàries, combat, indústria, logística detallada ni necessitats quotidianes.

## Verificació i continuïtat

Executa Godot si està disponible. Distingir importació/headless, proves de dades i prova visual interactiva. No afirmar que funciona visualment només perquè compila. Registra proves realment executades i limitacions.

Actualitza docs/ESTAT_PROJECTE.md després de cada fita amb implementat, verificat, limitacions i següent pas. Preserva les 51 respostes històriques del mestre, però aplica la revisió visual 1.3. No converteixis un valor provisional en una decisió confirmada sense deixar-ne constància.

## Generació procedural i visor

Llegeix també docs/ARQUITECTURA_PROCEDURAL.md. Implementa el visor de llavors amb P0A i una bateria inicial de 50 llavors. Mantén separades dades, representació i simulació. Les referències visuals prioritàries són les dues de SUBTERRA: MARS indicades a GUIA_VISUAL.md.

## Estructura de profunditat confirmada — versió 1.3

20 nivells totals. Biomes: 1–3, 4–6, 7–9, 10–12, 13–15 i 16–18. Els nivells 19 i 20 tenen identitat estructural especial reconeixible, amb coves, espècies i investigacions procedurals. Noms i trets concrets provisionals. Vegeu la secció 24 del mestre. Conservar les garanties de navegació, objectius assolibles i persistència. P0A continua amb un nivell; els tres nivells de prova no substitueixen la campanya de 20.
