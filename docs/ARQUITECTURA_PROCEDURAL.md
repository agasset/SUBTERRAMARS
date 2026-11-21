# Arquitectura procedural de SUBTERRA: MARS

Versió 1.3 · Especificació per implementar; encara sense codi de joc.

## Contracte del món

Una partida conserva el mateix món entre expedicions. Canviar de zoom, entrar en una cova, tornar a la base o carregar una partida no regenera contingut. Generar implica construir geometria i dades, després representar-les. No es generen captures de pantalla com a terreny.

## Ordre de generació

1. Normalitzar la llavor introduïda i fixar les versions dels generadors.
2. Crear el graf de 20 coves al prototip; rang de joc 20–40 configurable.
3. Assignar mides, posicions, entrada i accessos. Construir una ruta principal i branques opcionals.
4. Crear màscares orgàniques i galeries amb amplada suficient per a les unitats.
5. Validar connectivitat sobre cel·les transitables amb flood fill; comprovar que cada aresta del graf té un pas físic real.
6. Col·locar obstacles sense tallar rutes obligatòries i reservar punts vàlids d’aparició.
7. Assignar entorns, recursos, receptes d’espècies i individus segons profunditat.
8. Validar progressió quan existeixin costos i equip. Reintentar un nombre configurable i finit de vegades; després usar una disposició segura validada i registrar el motiu.

No exigir gràficament coves separades si la geometria les fusiona: corregir el solapament o reflectir la connexió real en el graf.

## Aleatorietat i versions

Derivar llavors independents per topologia, geometria de cada cova, entorn, espècies i comportament a partir de llavor principal, versió, domini i identificador estable. Usar una derivació especificada i estable, no el hash variable del procés. Evitar un RNG global compartit. La mateixa llavor amb les mateixes versions i paràmetres reprodueix les dades inicials; el moviment posterior no canvia el món per generar.

## Dades mínimes

| Registre | Camps |
| --- | --- |
| WorldData | world_id, seed, generator_versions, config, levels, species |
| LevelData | level_id, depth_index, caves, corridors, entry, exits |
| CaveData | cave_id, bounds, walkable_mask, contour, biome_id, objects |
| SpeciesRecipe | recipe_version, family_id, compatible_parts, palette, scale, traits |
| IndividualState | individual_id, species_id, cave_id, position, behavior_state |
| RunState | units, reserves, discovered_areas, lost_material, objective_state |

L’identificador d’espècie deriva de la recepta canònica i la seva versió. Conservar la recepta completa i resoldre possibles col·lisions comparant-la. No emprar el nom generat com a identitat. Flora i fauna comparteixen famílies anatòmiques compatibles, punts d’ancoratge i animacions vàlides; els paràmetres es limiten per mantenir siluetes llegibles.

## Representació i simulació

Un únic sistema de coordenades lògiques del món alimenta màscara, navegació, contorns, sprites i marcadors. El mapa general utilitza projecció superior; l’exploració local utilitza una projecció isomètrica 2D inversible. Són renderers de les mateixes dades, no dos mons ni nivells fixos. Els clics isomètrics es converteixen a coordenades lògiques abans de consultar màscara, navegació o interaccions. El detall es carrega segons proximitat; les dades no s’eliminen en ocultar-lo. La revelació és independent de la projecció i del zoom. Canviar de vista no teletransporta fauna/unitats ni reinicia reserves.

La geometria de la sala, la màscara transitable i les receptes de contingut defineixen paviment, perímetre de paret, obstacles, recursos i organismes. Una llavor estable ha de reproduir tant el mapa general com la mateixa sala isomètrica. La il·luminació, ombres i decoració poden variar per regla de biome i coordenades deterministes, però no poden alterar connectivitat ni coneixement.

## Desament

Desar llavor, versions, configuració, geometria materialitzada, receptes i estat dinàmic. Conservar també el progrés permanent i els identificadors de transaccions de recompensa. Escriure de manera atòmica amb còpia de seguretat. Una versió incompatible requereix migració explícita o avís clar; mai regeneració silenciosa.

## Visor de llavors de desenvolupament

Incloure entrada de llavor, regenerar, anterior/següent i superposicions de graf, màscara, ruta principal, accessos i punts d’aparició. Només en mode de desenvolupament es pot revelar tot el mapa. Mostrar versió, temps de generació, intents, ús de reserva i errors. El visor no modifica la partida activa sense una acció explícita de nova partida.

Executar una mostra inicial de 50 llavors reproduïbles, amb informe per llavor: quantitat de coves, connectivitat física, aparicions vàlides, hash canònic de les dades i ús de reserva. Repetir cada llavor per comprovar determinisme; excloure temps i identificadors de sessió del hash. Inspeccionar visualment diversos casos, incloses coves petites i grans. Provar deliberadament fallades per verificar el límit d’intents i la reserva.

En P0A els accessos inferiors poden ser punts reservats; les garanties entre nivells i d’economia es validaran a les fites corresponents. No presentar-les com a proves ja superades.

## Estructura de profunditat confirmada — versió 1.3

20 nivells totals. Biomes: 1–3, 4–6, 7–9, 10–12, 13–15 i 16–18. Els nivells 19 i 20 tenen identitat estructural especial reconeixible, amb coves, espècies i investigacions procedurals. Noms i trets concrets provisionals. Vegeu la secció 24 del mestre. Conservar les garanties de navegació, objectius assolibles i persistència. P0A continua amb un nivell; els tres nivells de prova no substitueixen la campanya de 20.

Derivar el perfil dels nivells 1–18 amb floor((level_index - 1) / 3) + 1. Assignar perfils especials explícits als índexs 19 i 20. Validar l’índex 1–20 abans de generar. Guardar biome_id/special_zone_id, structure_profile_version i les investigacions amb el seu progrés; no recalcular-les en carregar. Generar objectius només sobre contingut assolit o garantit i després validar-ne dependències.

## Revisió d’ordre de campanya — 20/11/2026

Per a partides noves, la fórmula antiga biome_at_depth identifica únicament el bloc físic. La partida desa campaign_biome_order = [1, permutació de 4/7/10/13, 16, 19, 20], validat i estable, amb vuit entrades. La representació i selecció d’espècies utilitzen _biome_at_depth amb aquest ordre; la generació rep explícitament el perfil correcte. Un món nou incorpora biome_profile i campaign_order_version. No s’ha canviat la geometria dels desaments existents; la manca d’ordre es tracta com a ordre clàssic.

La descoberta de noms és persistent per identitat a discovered_biomes del perfil, separada del número màxim d’estrat assolit. Els requisits són regles de transició de frontera, no regeneració ni canvis de coordenades. Es comproven abans del consum d’escala. Els retorns no requereixen haver mantingut el modificador actiu. La bateria campaign_rules_check.gd valida reproducció de 50 ordres, identitats als 20 estrats, recursos bàsics, transicions i compatibilitat dels desaments.

## Defensa i recuperació persistents — 20/11/2026

L’estat dels depredadors es desa dins el món, indexat per sala, amb identitat biològica lligada a fauna_species_by_room. La IA canvia posició només durant simulació: nodes i arestes segures segons màscara compartida, amb cerques acotades i sense travessar roques. Renderització, zoom i canvi de vista no creen enemics ni reinicien salut. Equip global a defence_state, camp opcional en versions antigues. Els paquets de materials perduts són world.recovery_caches_v1 amb marca recovered abans de la recompensa; la derrota no crea una llavor nova. Les singularitats reutilitzen petjades d’obstacles; la migració de goteres obre les velles cel·les de decoració del sostre sense canviar el graf ni moure l’explorador.
