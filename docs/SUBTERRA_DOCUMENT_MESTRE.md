# SUBTERRA: MARS

## Document mestre de disseny

**Versió 1.4 · 9 de novembre de 2026 · Projecte d’Albert**

Nom confirmat per Albert: **SUBTERRA: MARS**. Projecte originat com PROJECT NESS dins del context Ness Operation i reconvertit en exploració de coves marcianes.

Aquest document conserva els sis blocs històrics del qüestionari i defineix el disseny vigent amb les revisions posteriors. La revisió visual 1.4 aprovada per Albert el 9 de novembre de 2026 estableix un mapa general superior i una vista d’exploració isomètrica 2D de cada sala. Les dues representacions utilitzen el mateix món procedural i estat de partida; la vista isomètrica no és 3D ni una sala fixa.

L’objectiu és explorar les profunditats de Mart, descobrir flora i fauna procedurals, millorar l’equip i arribar al fons per completar una investigació. El món de cada partida és diferent i es conserva entre les seves expedicions. El joc manté gestió lleugera i no incorpora simulació ecològica complexa.

## 1 Com llegir aquest document

**Confirmat** identifica respostes d’Albert als sis blocs i aclariments posteriors visibles en la conversa. La revisió 1.1 va prioritzar temporalment investigar sobre el mapa ampliat; la revisió visual 1.4 posterior aprovada per Albert torna a establir una vista isomètrica per a l’exploració local de sales. Les files històriques del qüestionari es conserven i no anul·len aquesta decisió posterior. **Regla operativa** resol com encaixen les decisions perquè el joc sigui implementable. **Provisional** és un valor de treball per provar, no una elecció definitiva d’Albert. **Pendent** es reserva a allò encara no resolt.

Les espècies i les coves són ficció. Profunditats, colors i formes no es presenten com a cartografia o biologia marciana documentades. No es fixa cap llindar científic de quilòmetres per garantir vida.

Aquest lliurament és documentació. No acredita que existeixin codi, assets finals, prototip o proves de Godot. Les imatges aprovades són referències de direcció visual, no sprites ni interfícies ja implementades.

## 2 Identitat i límits

Joc individual roguelite d’exploració i descobriment, amb preparació senzilla i progressió permanent. La guia heretada de 60% exploració i 40% gestió és orientativa; no obliga a omplir menús ni a dedicar-hi temps artificialment.

El jugador controla un explorador i robots, consulta una xarxa de coves esquemàtica des de dalt i entra a les sales per explorar-les amb una projecció isomètrica 2D. La curiositat, les rutes, els recursos i les espècies rares sostenen la tensió.

Sense combat com a sistema central, sense indústria, agricultura, relacions socials detallades, política, cadenes alimentàries ni supervivència amb desenes de necessitats. No es requereixen primera persona, tercera persona 3D ni un planeta obert.

## 3 Registre complet de decisions

### Bloc 1 Estructura de joc

| ID | Pregunta | Decisió consolidada |
| --- | --- | --- |
| B1.2 | Durada d’una expedició | 30–60 minuts orientatius amb desament, segons l’aclariment posterior; la partida completa pot durar diverses hores |
| B1.2 | Control de l’exploració | Combinació de moviment i ordres; revisió 1.2: investigació al mapa ampliat |
| B1.3 | Final d’expedició | Es torna a la base; els aclariments posteriors mantenen el món durant la partida. Un accés permet baixar sense obligació immediata |
| B1.4 | Descobrir flora i fauna | Combinant exploració i escàners |
| B1.5 | Persistència entre partides | Millores d’equip i catàleg d’espècies |
| B1.6 | Fracàs | Es pot recuperar material en una expedició posterior |
| B1.7 | Augment de dificultat | Combinació equilibrada; els blocs 3 i 5 concreten profunditat, recursos, obstacles i millores |

L’opció inicial de mapa nou després de cada expedició queda substituïda per la distinció entre expedició i partida, consolidada als blocs següents. La resposta B1.7 no especificava a què es referien exactament «tots dos»; aquí no s’inventa un sistema addicional.

### Bloc 2 Coves i exploració

| ID | Pregunta | Decisió |
| --- | --- | --- |
| B2.1 | Mida dels nivells | 20–40 coves per nivell |
| B2.2 | Descobriment del mapa | L’escàner revela coves properes |
| B2.3 | Perspectiva d’investigació | Resposta original: isomètrica. Substituïda en 1.2 per vista superior del mateix mapa amb zoom |
| B2.4 | Control de l’explorador | Clic per moure i interactuar |
| B2.5 | Accessos inferiors | Diverses sortides possibles |
| B2.6 | Varietat de mides | Coves petites, mitjanes i grans |
| B2.7 | Distribució biològica | Aleatòria segons profunditat |
| B2.8 | Zones no explorades | Connexions parcials i zones desconegudes |

### Bloc 3 Explorador equip i progressió

| ID | Pregunta | Decisió |
| --- | --- | --- |
| B3.1 | Unitats controlables | Un explorador i robots |
| B3.2 | Acció dins de la cova | Exploració lliure amb clics |
| B3.3 | Eines inicials | Escàner i càmera |
| B3.4 | Recursos d’expedició | Oxigen i bateria |
| B3.5 | Millores permanents | Mitjançant descobertes científiques |
| B3.6 | Robots | Control directe amb clics |
| B3.7 | Material perdut | Queda a la cova per recuperar-lo |
| B3.8 | Tornada a la base | Preparació manual senzilla |
| B3.9 | Evolució de dificultat | Millores que permeten arribar més profund |

### Bloc 4 Flora fauna i descobertes

| ID | Pregunta | Decisió |
| --- | --- | --- |
| B4.1 | Varietat | Espècies generades proceduralment |
| B4.2 | Aparença de flora | Barreja de formes familiars i alienígenes |
| B4.3 | Comportament de fauna | Animals que es mouen per la cova |
| B4.4 | Confirmació de descoberta | Escaneig de l’organisme |
| B4.5 | Distribució de raresa | Espècies més rares amb més profunditat |
| B4.6 | Recompensa | Punts de recerca per millores |
| B4.7 | Espècies conegudes | Noves observacions amplien la fitxa |
| B4.8 | Consulta | Catàleg amb imatge i descripció |
| B4.9 | Descobriments especials | Algunes espècies molt rares |

La generació procedural d’espècies substitueix explícitament el catàleg fix de la versió 0.4. Les peces visuals poden ser dibuixades a mà; la seva combinació, identitat i distribució es generen.

### Bloc 5 Partides i profunditat

| ID | Pregunta | Decisió |
| --- | --- | --- |
| B5.1 | Nombre total de nivells | 20 nivells confirmats en 1.3; sis biomes de tres nivells fins al 18 i dos nivells especials |
| B5.2 | Canvi d’entorn | Variacions visuals i ambientals aleatòries |
| B5.3 | Avançar | Trobar un accés i preparar equip |
| B5.4 | Tornar a nivells anteriors | Sí, sempre que hi hagi ruta |
| B5.5 | Objectiu final | Arribar al fons i completar una investigació |
| B5.6 | En completar la partida | Nova partida amb coves i espècies noves |
| B5.7 | Dificultat entre partides | Equilibrada segons profunditat |
| B5.8 | Motivació per repetir | Descobrir noves espècies |
| B5.9 | Desament | Automàtic freqüent |

### Bloc 6 Interfície i representació

| ID | Pregunta | Decisió |
| --- | --- | --- |
| B6.1 | Mapa principal | Pantalla completa amb panells laterals |
| B6.2 | Canvi a investigació | Clicant una cova al mapa, s’hi centra i amplia el zoom sense canviar de perspectiva |
| B6.3 | Detall d’investigació | Pixel art molt petit i vista llunyana, ara en vista superior contínua |
| B6.4 | Càmera | Roda per zoom i arrossegament |
| B6.5 | Informació durant exploració | Oxigen, bateria i eines |
| B6.6 | Estats de coves | Colors segons exploració |
| B6.7 | Flora i fauna detectades | Marcadors al mapa després d’escanejar |
| B6.8 | Eines | Barra inferior amb icones |
| B6.9 | Interfície | Futurista fosca segons els dissenys aprovats |

Les respostes dels sis blocs es conserven com a registre històric. La revisió visual 1.4 actualitza la representació activa d’exploració de sala sense reescriure les respostes originals.

## 4 Vocabulari de persistència

| Concepte | Què representa | Quan canvia |
| --- | --- | --- |
| Perfil | Progrés permanent, millores i catàleg | Entre partides i durant descobertes confirmades |
| Partida | Una xarxa completa de coves i espècies | Només en començar un món nou |
| Nivell | Estrat de profunditat amb 20–40 coves | Es visita i revisita dins del mateix món |
| Expedició | Sortida de la base al món actual | Acaba en retornar o fracassar |
| Sessió | Temps real jugant | Es pot interrompre amb desament |

Una expedició de 30–60 minuts no és un temporitzador obligatori. Es pot desar abans i continuar més tard. La partida completa suma diverses expedicions. Tornar a la base no regenera coves, accessos, espècies ni material pendent.

## 5 Bucle jugable

Preparar equip → escanejar i triar ruta → entrar en coves → moure i observar → escanejar organismes → valorar autonomia → continuar, baixar o tornar → gastar recerca en millores.

Exemple: l’explorador detecta dues cambres properes al mapa. Entra en una cova gran i hi identifica flora. Descobreix un accés inferior, però decideix continuar al mateix nivell per ampliar una fitxa i aconseguir punts per millorar la bateria. Torna a la base, prepara el següent descens i retroba la mateixa xarxa.

El generador pot produir carrerons sense sortida i branques opcionals, però aquestes han de contenir informació, descobertes o decisions que justifiquin investigar-les. Cap nivell exigeix explorar totes les sales abans de baixar.

## 6 Mapa superior i exploració isomètrica de sala — revisió 1.4

El mapa general manté la vista superior esquemàtica de la xarxa. En seleccionar o entrar a una sala, la interfície passa a una vista local d’exploració isomètrica 2D, com a les referències visuals aportades per Albert. En tornar al mapa es recupera la xarxa. És un canvi de representació del mateix nivell, no un món separat: geometria, posicions, màscara transitable, obstacles, revelació, unitats i sortides conserven identitat i estat.

La projecció isomètrica és 2D i no implica una simulació 3D. Dades procedurals descriuen la sala; el renderer les projecta i hi dibuixa terra, parets, obstacles, explorador, robots i, quan s’implementin, organismes i recursos. No usar una imatge de referència com a fons jugable ni una escena artesanal diferent per cada sala.

### Escala general

Coves de contorns orgànics, túnels, posicions d’unitats i colors d’exploració. El mapa és fosc, esquemàtic i no mostra tot el contingut de les sales. Pantalla completa amb panells laterals, selector de profunditat i barra inferior d’eines.

### Vista d’exploració de sala

La sala es presenta amb un terra isomètric ampli, relleu de parets i detalls pixel art. Explorador i robot s’ubiquen amb les mateixes coordenades lògiques que al mapa. Flora, fauna i recursos procedurals apareixen només quan les regles de revelació i observació ho permeten; després de l’escaneig queden registrats i poden tenir marcador.

L’escàner revela progressivament l’interior. Desconegut continua fosc encara que acostem el zoom. El zoom no és un instrument: només canvia la mida de la representació, no l’abast ni la informació disponible.

Clic sobre sòl transitable per moure i clic sobre organisme per usar l’eina activa. La selecció d’una espècie obre una fitxa lateral amb imatge ampliada. Aquesta és la manera d’apreciar els dissenys sense fer enormes els organismes al món.

Clicar una sala la selecciona o n’obre la vista local; no hi teletransporta la unitat. Moure l’explorador continua requerint una ordre i una ruta vàlida. Una vista remota només pot mostrar el fragment ja conegut i no habilita l’escàner a distància.

Canviar entre mapa i sala no recarrega recursos, no reinicia fauna ni modifica posicions o coneixement. Els llindars de zoom són paràmetres de presentació, no portes de progressió.

**Regla operativa inicial:** el mapa consultiu i els menús estratègics poden pausar; els moviments ordenats avancen el temps. La pausa és una proposta de prova i no depèn d’acostar o allunyar el zoom.

## 7 Escàner i informació desconeguda

Cal separar dues funcions de la mateixa eina:

- **Exploració del mapa:** revela cavitats properes i connexions parcials segons un abast de joc. Pot suggerir una sala que encara no podem visitar. No implica veure’n l’interior ni conèixer-hi les espècies.
- **Escaneig biològic:** confirma un organisme quan la unitat té abast i visibilitat suficients dins de la cova. Després apareix el marcador corresponent.

Això substitueix l’antiga prohibició absoluta de detectar cap cova a través de roca. És una abstracció jugable de l’escàner, no una especificació científica real de LiDAR.

Estats operatius suggerits: desconeguda, detectada, visitada i explorada. «Explorada» significa que la cobertura espacial prevista s’ha revisat; no garanteix que hi haguem trobat totes les espècies rares. Els colors es complementen amb símbols per no dependre només de la paleta.

Els marcadors de fauna indiquen l’última observació i no rastregen màgicament animals fora de cobertura. Les marques de flora poden conservar la posició coneguda mentre l’organisme continuï allí.

## 8 Generació procedural de coves

Cada partida crea una llavor i una xarxa finita de nivells. La partida completa té 20 nivells. Els nivells 1–18 formen sis biomes de tres nivells; els nivells 19 i 20 tenen regles especials de generació. El generador separa topologia, forma de coves, distribució d’obstacles, espècies i aparença ambiental.

Procediment proposat:

1. Crear l’entrada, la ruta principal i els accessos entre nivells.
2. Distribuir entre 20 i 40 cavitats per nivell, amb categories de mida.
3. Donar siluetes irregulars als contorns i connectar-les amb galeries.
4. Afegir bifurcacions, circuits alternatius i carrerons sense sortida.
5. Col·locar obstacles i requisits d’equip sense bloquejos circulars.
6. Situar flora, fauna i objectius segons profunditat i espai transitable.
7. Validar i corregir o repetir amb intents acotats.

La forma pot generar-se amb màscares de cel·les i convertir-se en contorns; la tecnologia concreta queda a criteri d’implementació. Les escales general i propera del mapa provenen de les mateixes dades transitables, amb nivells de detall diferents.

### Garanties de jugabilitat

Connexió principal cap al fons, diverses sortides inferiors possibles, accessos reversibles quan estan preparats i absència de coves obligatòries desconnectades. Les galeries poden tenir límits segons l’equip; almenys una ruta de progressió és viable amb millores assolibles abans de necessitar-les.

La garantia estructural no evita fracassar per esgotar recursos. Evita perdre perquè el generador ha creat un món impossible.

Les millores obligatòries no es financen amb una espècie rara que pot no aparèixer. El generador garanteix prou descobertes comunes accessibles per assolir els requisits mínims. Les reserves, costos i camins de retorn es validen amb l’equip mínim previst, amb marge provisional de seguretat.

Si fallen els intents de generació, s’utilitza una disposició segura de reserva. No hi ha bucles infinits. La mateixa llavor amb versions iguals reprodueix el món inicial; actualitzar el joc no ha de regenerar silenciosament una partida guardada.

## 9 Profunditat i entorns

Els primers trams introdueixen controls i investigació; la descoberta biològica es concentra en profunditat. La versió de prova pot comprimir aquesta progressió per comprovar el bucle ràpidament.

Cada nivell varia visualment i ambientalment: roca, tonalitats, formacions, pols, gel o efectes estilitzats. Els paràmetres aleatoris es mantenen dins d’un rang de dificultat associat a la profunditat. La variació no justifica un salt arbitrari impossible entre dos nivells consecutius.

Trobar un accés no força a baixar. Es mostra l’equip requerit i el jugador pot continuar investigant el nivell actual. Diferents accessos poden comunicar cambres diferents del nivell inferior; tots pertanyen al mateix món persistent.

La dificultat d’una partida nova no escala automàticament amb el nombre de victòries. Les millores permanents fan més còmode el recorregut inicial i permeten assolir més profunditat; la generació respecta la dificultat prevista per cota.

## 10 Flora i fauna procedurals

Les espècies es generen combinant components visuals i atributs compatibles. La flora barreja formes familiars i alienígenes. La fauna té silueta, mida, paleta i moviment local; no necessita alimentació, reproducció, genètica ni simulació de poblacions.

La varietat ha de ser visible a la mida real dels sprites. Un canvi imperceptible de color no justifica per si sol una espècie «nova». Els components s’agrupen en famílies compatibles amb animacions i dimensions per evitar combinacions trencades.

Una espècie guarda recepta visual, nom generat, tipus, descripció basada en atributs, raresa i rang de profunditat. La descripció no atribueix conductes que el joc no simula. La imatge del catàleg deriva de la mateixa recepta que el sprite observat.

Més profunditat augmenta les oportunitats de trobar espècies rares. No totes les coves contenen vida, però la distribució de cada món garanteix flora i fauna descobribles. Les espècies molt rares són incentius opcionals; la investigació final no depèn de trobar un resultat de probabilitat ínfima.

### Identitat entre partides

Regla operativa proposada: cada espècie té un identificador estable derivat de la recepta normalitzada i la versió del generador d’espècies. Si una recepta ja catalogada reapareix, es reconeix; una recepta nova genera una nova entrada. No es promet que totes les combinacions siguin exclusives per sempre.

Cada món nou prioritza varietat respecte dels anteriors sense exigir un catàleg finit complet. Els antics registres guarden la recepta i la versió per poder seguir representant-se després d’una actualització.

## 11 Descoberta catàleg i recerca

L’escàner confirma la descoberta. La càmera és una eina complementària per documentar imatges i observacions; no substitueix el requisit d’escaneig decidit al Bloc 4.

Catàleg persistent amb imatge, nom, flora o fauna, descripció, raresa, primer descobriment i observacions. Pot filtrar-se per tipus i consultar-se des de la base o un panell. La recompensa principal és obtenir punts de recerca per millorar l’equip.

Una espècie nova concedeix una recompensa única. Les observacions addicionals poden ampliar la fitxa fins a unes fites limitades. No es concedeix recerca il·limitada per repetir escanejos del mateix individu.

**Regla operativa inicial:** un escaneig complet escriu immediatament el descobriment i els punts al perfil mitjançant una transacció identificada. Això manté el progrés científic després d’un fracàs; la pèrdua afecta material d’expedició. Aquesta regla encara no és una resposta explícita del qüestionari i s’ha de validar en prova.

## 12 Explorador robots i ordres

Un explorador és la unitat humana principal. Porta escàner i càmera i es mou per clics. Els robots també es controlen per clics i poden investigar accessos compatibles amb les seves dimensions o equipament.

Per al prototip es proposa un únic robot. El seu nombre màxim final queda obert. Canviar d’unitat conserva la posició de totes dues. No és una forma de transportar instantàniament persones o material.

L’explorador consumeix oxigen durant el temps actiu d’expedició i bateria en eines i equip. Proposta inicial: el robot té bateria pròpia i no consumeix oxigen. Mentre el robot actua, l’explorador continua existint i consumint segons les regles del rellotge.

Les ordres de mapa permeten viatjar per camins coneguts. Un robot no revela automàticament tot un nivell desconegut. La delegació avançada queda per després de provar el control directe.

## 13 Recursos base i millores

Oxigen i bateria són els dos límits principals. La interfície mostra estat, acció d’eina i avisos. La previsió de retorn utilitza una ruta coneguda real, no una línia recta fins a la base.

Preparació manual senzilla: seleccionar eines i robot, comprovar reserves, escollir objectiu i sortir. Reomplir no exigeix comprar cada peça o gestionar proveïdors. No s’introdueix una moneda logística addicional com a requisit del primer prototip: els punts de recerca són la progressió principal.

Millores proposades: capacitat d’oxigen, autonomia de bateria, abast de l’escàner, eines d’accés i robot. Valors i costos són balanceig pendent. Les millores no creen galeries noves en un món ja generat; permeten superar obstacles existents.

Retornar a la base conserva el món. Les rutes llargues ja conegudes poden simplificar-se amb ordres de viatge i acceleració segura quan s’hagi validat el ritme. Els punts de suport profunds són una proposta futura per mantenir sortides de 30–60 minuts; no es consideren confirmats ni es construeix una xarxa industrial.

## 14 Fracàs i recuperació

El material perdut queda localitzat a la cova del món actual. Una nova expedició dins de la mateixa partida pot recuperar-lo si hi arriba. La pila de material té identificador persistent, contingut i posició.

Proposta de recuperació inicial: el fracàs retorna l’explorador a la base, manté millores i catàleg i deixa eines opcionals o càrrega recuperable al lloc de l’incident. L’equip bàsic de reemplaçament permet iniciar una sortida de recuperació. Els desbloquejos permanents no desapareixen.

Aquesta regla evita perdre l’escàner imprescindible i quedar sense possibilitat de progressar. El detall de penalitzacions i si es perd un robot són valors de prova pendents. No s’ha confirmat mort permanent del protagonista.

Començar un món nou no trasllada les piles de material de l’anterior. Abans d’abandonar una partida activa, la interfície informa que el material pendent d’aquell món no es podrà recuperar des del nou. Un fracàs d’expedició no inicia automàticament un món nou.

## 15 Objectiu final i següent partida

Una partida s’acaba amb dues condicions: arribar al fons i completar una investigació. El nivell màxim és el 20. Les investigacions dels nivells 19 i 20 es generen proceduralment dins de les regles de cada zona especial; els tipus concrets d’objectiu continuen pendents de desenvolupament.

Proposta de prova: registrar un petit conjunt de descobertes específiques presents de manera garantida al nivell final. És una tasca simple d’observació i escaneig, no una aventura de laboratori ni una prova de sort amb una espècie excepcional.

Després s’ofereix el resum de profunditat, espècies i recerca, i l’inici d’un món nou. Catàleg i millores es mantenen. No es genera un altre món sense una acció explícita del jugador.

## 16 Direcció visual i interfície

Mapa científic abstracte i exploració isomètrica són dues representacions del mateix món 2D procedural. El mapa mostra xarxa i estat de sales; la sala mostra en perspectiva isomètrica les parts revelades i els elements que hi ha segons les dades generades.

Paleta fosca futurista amb accents cian i taronja, parets rocoses irregulars i panells de bon contrast. Pixel art 2D amb siluetes llegibles. La vista isomètrica utilitza terra, parets i objectes generats o compostos per regles reutilitzables; no és una càmera 3D. La fitxa lateral mostra l’organisme ampliat quan es vol apreciar-ne el detall.

La roda controla el zoom i l’arrossegament mou el mapa. El zoom s’ancora preferiblement al cursor, amb escales que preservin llegibilitat. La interfície manté la mida de text independent del món. Una icona d’unitat pot conservar una mida mínima de selecció encara que el seu sprite sigui petit.

Referències aprovades identificades en la conversa:

| Referència | Paper |
| --- | --- |
| Mapa de cuevas marcianas neón.png | Contorns orgànics i mapa esquemàtic |
| Mapa holográfico de Project Mars.png | Mides variables de sales i panells |
| Mapa d’Exploració de Mart.png | Posicions i connexions amb informació reduïda |

Les imatges són referències, no sprites finals. Els PNG no formen part d’aquest paquet; docs/GUIA_VISUAL.md descriu la direcció i en dona els enllaços de consulta. El prototip pot començar amb formes i sprites provisionals propis.

Barra inferior d’eines amb icones i eina activa; laterals amb unitat, reserves i cova; llegenda d’estats i selector de profunditat. Els clics sobre panells no arriben al món. Arrossegar no dona ordres en deixar anar.

Textos en català, símbols a més de color, etiquetes d’eines i avisos visuals a més de so. Mida de sprites, resolució interna i llindars de zoom es proven amb el primer mapa. L’aparença de cartografia no ha d’ocultar les accions disponibles.

## 17 Model de dades i desament

Cal separar perfil permanent i partida activa, però guardar-los de manera coherent.

| Dada | Abast | Camps principals |
| --- | --- | --- |
| Perfil | Entre partides | Versió, millores, punts, catàleg i transaccions de recompensa |
| Partida | Món actual | Identificador, llavor, versions de generadors i objectiu final |
| Nivell | Partida | Coves, contorns, galeries, accessos, variació ambiental |
| Cova | Partida | Identificador, màscara transitable, estat de descoberta i connexions |
| Unitat | Partida | Cova, posició local, equip, reserves i ordre activa |
| Espècie | Permanent i món | Identitat, recepta visual, descripció i observacions |
| Individu | Partida | Espècie, posició, estat i moviment |
| Material perdut | Partida | Identificador, contingut, cova i posició |

Guardar disposició generada i receptes, no només la llavor. Així les actualitzacions no reconstrueixen un món diferent. Els generadors de mapa, espècies i comportament utilitzen aleatorietat separada per evitar que moure un animal alteri futures sales.

Desament automàtic freqüent, amb punts d’esdeveniment: canvi de cova o nivell, descoberta confirmada, compra de millora, retorn i fracàs. Interval periòdic proposat: 60 segons, a validar. Sortir desa també si és possible; no es pressuposa que sempre hi haurà una sortida neta.

Escritures atòmiques amb còpia de seguretat i versions. Carregar no reomple reserves, no elimina material perdut i no torna a concedir punts. Les transaccions de descoberta eviten duplicitats entre perfil i partida si el programa s’interromp durant l’escriptura.

## 18 Arquitectura proposada per a Godot

Godot 4 amb GDScript i renderització 2D. Les decisions concretes de versió s’adapten a l’entorn existent; no cal documentar característiques d’una versió no comprovada.

Mòduls de responsabilitat: dades de perfil i partida, generació de món, generació d’espècies, navegació, mapa unificat amb capes segons zoom, eines, interfície i persistència. No es necessita un autoload per cada mòdul.

La simulació guarda coordenades lògiques 2D, màscares i identitats estables. Un renderer superior presenta la xarxa i un renderer isomètric 2D projecta la sala; tots dos llegeixen i actualitzen el mateix estat. La conversió pantalla/món de la vista isomètrica ha de ser inversa i compatible amb selecció, moviment, escàner i col·lisions. La navegació local i el viatge entre coves són problemes diferents però comparteixen connexions vàlides.

Només les zones properes al focus de la càmera necessiten detalls visuals. Les altres conserven dades i estats amb actualització simplificada. Canviar de zoom no regenera coves ni fauna. Les capes de sòl, obstacles, unitats i marcadors tenen ordre de dibuix explícit.

Aquesta arquitectura és una proposta d’implementació. No hi ha cap afirmació de rendiment mesurat ni d’equivalència entre 40 coves de dades i 40 escenes obertes.

## 19 Pla del primer prototip

**Objectiu:** comprovar mapa superior → viatge → exploració de sala isomètrica → escaneig → catàleg → retorn → millora.

| Fita | Contingut | Resultat visible |
| --- | --- | --- |
| P0A Mapa | Un nivell de 20 coves orgàniques, llavor, connexions, zoom, arrossegament i escàner de proximitat | Xarxa diferent i explorable sense bloquejos |
| P0B Investigació | Interior de sala isomètric 2D amb clic per moure, obstacles i revelació local | Entrar a una sala canvia de representació, no de món; coordenades, ruta i boira de guerra es conserven |
| P0C Descobertes | Flora i fauna amb receptes procedurals, moviment simple, escaneig i catàleg | Descobrir i reconèixer una espècie |
| P0D Sortida | Oxigen, bateria, un robot, base, punts i una millora | Primera expedició completa |
| P0E Roguelite | Fracàs, material recuperable, perfil persistent i món nou | Perdre material sense perdre el llegat |
| P0F Profunditat | Tres nivells configurables de prova, diversos accessos i investigació final simple | Partida curta completa de validació |

Les 20 coves inicials i tres nivells de prova són valors de desenvolupament. El rang de coves per nivell continua sent 20–40 i la partida completa té 20 nivells. Els tres nivells de prova són un recorregut abreujat de desenvolupament, no el final de la campanya. Per provar controls es poden usar subescenes mínimes, sense substituir el mapa procedural del prototip integrat.

La persistència bàsica s’introdueix aviat i s’amplia a cada fita; no s’ajorna fins a l’última. Primeres espècies: components limitats, almenys una família de flora i una de fauna amb diverses combinacions visibles. No calen centenars d’assets finals.

## 20 Verificació

| Àrea | Criteri d’acceptació |
| --- | --- |
| Reproducció | Mateixa llavor i versions donen les mateixes dades inicials |
| Varietat | Una mostra de llavors produeix xarxes i espècies visiblement diferents |
| Topologia | Entrada, rutes inferiors i retorn són viables amb equip assolible |
| Geometria | Les connexions del graf corresponen a passos transitables |
| Informació | Escàner de mapa revela proximitat; organismes requereixen escaneig local |
| Controls | Clic, arrossegament i panells no generen accions involuntàries |
| Escales de zoom | Ampliar o allunyar conserva unitats, consum i estat; no revela dades ocultes |
| Catàleg | Reconeix una espècie i no duplica la recompensa inicial |
| Progrés | Cap millora obligatòria exigeix un descobriment bloquejat per ella mateixa |
| Fracàs | Material queda al món i una sortida posterior el recupera una sola vegada |
| Persistència | Càrrega conserva perfil, món, reserves i piles de material |
| Final | L’objectiu garantit és resoluble i dona pas a un nou món conservant perfil |

Bateria inicial proposada de 50 llavors per a connectivitat i requisits; ampliar només si els resultats mostren problemes. Les proves de graf no substitueixen proves visuals i de navegació real. L’autodesament també s’ha de provar amb interrupció i recuperació de còpia.

Validació de joc: una sortida sense espècie rara ha de continuar sent interessant; l’exploració lateral ha d’ajudar a preparar el descens; el zoom ha de permetre interactuar mantenint sprites petits, amb detall a la fitxa lateral. Si els trajectes dominen la sessió, ajustar rutes i ritme abans d’afegir sistemes.

## 21 Pendents i valors provisionals

| Tema | Estat | Tractament |
| --- | --- | --- |
| Nom comercial | Confirmat | SUBTERRA: MARS |
| Total de nivells | Confirmat en 1.3 | 20; tres només en proves abreujades |
| Cotes en metres | Pendent | No fixar 5 o 10 km com a requisit científic |
| Investigació final | Generació procedural confirmada | Tipus concrets pendents; objectius assolibles garantits al nivell 20 |
| Nombre màxim de robots | Pendent | Un al prototip |
| Penalització exacta per fracàs | Provisional | Material recuperable i equip bàsic de reemplaçament |
| Quan consolidar recerca | Provisional | Immediatament en confirmar escaneig |
| Pausa i consum en mapa | Provisional | Pausa consultiva, temps actiu en viatge |
| Costos i capacitats | Pendent de balanceig | Dades externes al codi |
| Reaparició d’espècies entre mons | Regla operativa proposada | Recepta idèntica reconeguda, varietat afavorida |
| Punts de suport profunds | Proposta futura | Avaluar segons temps de retorn |
| Mida de píxel i zoom | Pendent de prova visual | Sprites petits i UI llegible |

No cal reobrir un qüestionari per resoldre cadascun d’aquests detalls. Albert ha autoritzat decisions de treball raonables; s’han de comunicar els canvis que alterin substancialment l’experiència.

## 22 Traspàs a implementació i control de canvis

Aquest document és la font de disseny activa. El paquet Codex 1.3 constitueix la base documental; la revisió 1.4 següent actualitza la presentació de l’exploració de sala. Les dues referències visuals aportades per Albert el 9 de novembre de 2026 prevalen sobre interpretacions visuals anteriors.

Ordre de lectura recomanat per a Codex: identitat i registre de decisions; vista contínua i escàner; generació i persistència; primera fita i verificació. Primer s’inspecciona la carpeta existent i després es crea o adapta el projecte. No s’eliminen canvis d’Albert ni es modifiquen altres jocs.

Els recursos gràfics de referència s’han de posar explícitament a disposició de Codex si s’han d’utilitzar. No es pressuposa que una imatge visible al xat existeixi a la carpeta de desenvolupament.

Les actualitzacions del mestre han de conservar decisions confirmades, registrar excepcions i separar implementat, verificat i només previst. Si una prova obliga a canviar el rang de coves, el sistema de partides o la persistència del catàleg, cal presentar-ne la conseqüència abans de donar-ho per definitiu.

## 23 Arquitectura procedural aprovada

La generació procedural és la base del joc des del primer prototip. Es construeixen dades, geometria i organismes mitjançant regles i peces compatibles; les imatges aprovades no són mapes fixos ni fons de joc.

| Mòdul lògic | Responsabilitat |
| --- | --- |
| WorldGenerator | Graf, llavors derivades, accessos i validació global |
| CaveGenerator | Màscara transitable, contorns, galeries i obstacles |
| BiomeGenerator | Condicions, paletes, minerals i decoració compatible |
| SpeciesGenerator | Receptes de flora/fauna i identitats estables |
| WorldRenderer | Un únic món 2D, càmera i detall segons zoom |
| ExplorationSystem | Ordres, navegació, revelació i escaneig |
| SaveManager | Perfil, món materialitzat i estat dinàmic |

Són responsabilitats, no set autoloads obligatoris. L’especificació tècnica complementària és docs/ARQUITECTURA_PROCEDURAL.md. Primera entrega: P0A i mínim P0B, amb visor de llavors, abans de crear molts assets.

### Registre de versions

| Versió | Data | Canvi |
| --- | --- | --- |
| 0.1–0.2 | 9 de novembre de 2026 | Concepte del llac Ness i simplificació |
| 0.3–0.4 | 9 de novembre de 2026 | Adaptació a coves de Mart i primera proposta procedural |
| 1.0 | 9 de novembre de 2026 | Sis blocs consolidats; roguelite 2D, dues perspectives, espècies procedurals, persistència i pla de prototip |

| 1.1 | 9 de novembre de 2026 | Revisió aprovada: investigació sobre el mateix mapa en vista superior amb zoom; paquet Codex alineat |

| 1.2 | 9 de novembre de 2026 | Nom SUBTERRA: MARS confirmat, dues referències visuals prioritàries i arquitectura procedural amb visor de llavors |
| 1.3 | 9 de novembre de 2026 | 20 nivells; sis biomes de tres nivells i zones 19–20 reconeixibles amb coves, espècies i investigacions procedurals |
| 1.4 | 9 de novembre de 2026 | Revisió visual aprovada: mapa general superior i vista d’exploració isomètrica 2D per sala, basades en el mateix estat i dades procedurals |

## Referències visuals prioritàries aprovades

Aquestes dues imatges prevalen sobre els estudis previs pel que fa a composició i estil:

| Referència | Aplicació |
| --- | --- |
| [Mapa de Cuevas de Marte.png](https://chatgpt.com/library?file_id=libfile_89513cabf5b08191895459fb85dfb397&account_id=personal) | Mapa general de coves orgàniques, panells laterals, oxigen/bateria i eines inferiors |
| [Interfaz científica de Subterra: Marte.png](https://chatgpt.com/library?file_id=libfile_b52c57ce96288191b5d11b40f04029fa&account_id=personal) | Ambient de la cova, explorador, robot, flora/fauna, escaneig i HUD cian/taronja |

Les referències visuals aportades directament per Albert el 9 de novembre de 2026 concreten el format: [Mapa de Cuevas de Marte.png](referencies_visuals/Mapa%20de%20Cuevas%20de%20Marte.png) és la vista general superior i [Sala isomètrica Subterra.png](referencies_visuals/Sala%20isometrica%20Subterra.png) és l’exploració isomètrica de sala. Es conserven al repositori com a referències de composició, no com a fons de joc; la topologia, geometria i contingut continuen generant-se proceduralment.

Identitat gràfica: [Logo pixel art de Subterra: Marte.png](https://chatgpt.com/library?file_id=libfile_bb3dca2dd7388191838ab34490cce884&account_id=personal). Referència de marca, no atlas de sprites.

## 24 Biomes i nivells especials — decisió confirmada 1.3

Cada partida té 20 nivells de profunditat. El bioma canvia cada tres nivells fins al 18; els dos últims nivells són zones especials diferenciades. La seqüència de grups és estable i el contingut de cada món es genera amb la llavor.

| Nivells | Zona | Nom de treball provisional |
| --- | --- | --- |
| 1–3 | Bioma 1 | Coves oxidades |
| 4–6 | Bioma 2 | Cavernes cristal·lines |
| 7–9 | Bioma 3 | Galeries glacials |
| 10–12 | Bioma 4 | Jardins subterranis |
| 13–15 | Bioma 5 | Fractures geotèrmiques |
| 16–18 | Bioma 6 | Abisme biològic |
| 19 | Zona especial 19 | El Llindar |
| 20 | Zona especial 20 i final | El Nucli |

**Confirmat:** repartiment, màxim de 20 nivells i estructura especial reconeixible als nivells 19 i 20 amb coves, espècies i investigacions procedurals. **Provisional:** tots els noms, paletes, trets ambientals i motius estructurals concrets. La progressió introductòria/intermèdia/intensa dins de cada grup continua sent una proposta, no una condició aprovada.

### Identitat especial sense mapa fix

Cada zona especial té un perfil propi de generació: regles de topologia, composició i punts d’interès que permetin reconèixer-la entre partides. El motiu concret de cadascuna es definirà en desenvolupament; no s’aproven encara cambres, ruïnes ni formes específiques. La geometria, les connexions, els obstacles, les espècies i les investigacions varien proceduralment dins d’aquestes restriccions. No reutilitzar un mapa fix disfressat amb decoració aleatòria.

El nivell 19 prepara el tram final i connecta amb el 20. El nivell 20 és el fons i completar-hi la investigació final tanca la partida. Arribar-hi no completa automàticament l’objectiu. No existeix un nivell 21 en la partida completa. El rang de 20–40 coves per nivell es manté també a les zones especials, mentre no s’aprovi una excepció.

### Investigacions procedurals resolubles

Generar els objectius a partir de contingut existent i accessible, o reservar explícitament el contingut necessari abans de validar. Variar objectius i organismes entre partides, però conservar-los dins del mateix món, incloent-hi retorns a la base i càrregues. No dependre d’una espècie excepcional de probabilitat ínfima, de l’aparició casual d’un individu ni d’un equip impossible d’obtenir. La recerca obligatòria i les rutes de retorn han de superar les mateixes garanties de progressió de la resta del joc.

### Dades i acceptació

Guardar per nivell el seu índex 1–20, biome_id o special_zone_id, versió del perfil estructural, llavors derivades, receptes, geometria i investigacions materialitzades amb progrés. Els nivells 19 i 20 no són un setè bioma de tres nivells. La selecció de perfil és determinista; la variació interna prové de llavors separades.

Validar límits 3/4, 6/7, 9/10, 12/13, 15/16, 18/19 i 19/20. Comprovar 20 nivells totals, cap accés inferior al 20, perfils especials diferents, variació entre llavors i reconeixement visual del perfil dins de diverses llavors. Verificar que tots els objectius obligatoris tenen contingut i ruta assolibles i que desar/carregar no els substitueix.

La primera fita continua sent P0A amb un nivell. El prototip abreujat de tres nivells és només una eina de prova. Afegir després una validació de campanya de 20 nivells i dels perfils especials, sense exigir que P0A contingui tot el joc.

