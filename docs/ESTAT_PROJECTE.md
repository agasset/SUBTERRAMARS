# Estat de traspàs

Al mapa, passar el cursor sobre una sala visitada mostra l’escaneig i les tasques de la sala. La sala rep una estrella quan s’ha escanejat, s’han recorregut totes les galeries que hi connecten i s’han completat l’anàlisi, l’observació o l’extracció presents. Una prova headless ha comprovat el còmput de tasques pendents i completades.

Les plantes, els animals i les vetes dels estrats nous es reparteixen per la superfície transitable de la sala. El punt de descens també es genera dins la seva sala i es guarda al món per mantenir alineats el dibuix, el clic i l’arribada en pujar. La prova headless ha comprovat posicions transitables i repetibles en 12 llavors i el trajecte entre −1 i −2.

Els estrats nous apliquen perfils de geometria per bioma, amb proporcions de sala, amplada i curvatura de galeria i connexions opcionals pròpies. Les paletes de terra i roca també varien. Els estrats desats conserven la geometria. Les files amb taller permeten caminar fins a la sala d’entrada, també quan s’arriba des de baix. «Enquadra el mapa» està disponible en vista isomètrica. Una prova amb Godot i OpenGL ha comprovat la connectivitat i els centres transitables en 56 generacions, el retorn a peu al taller del −4 i l’enquadrament dels contorns isomètrics.

El menú «Partida» permet eliminar el perfil seleccionat o la partida local amb confirmació. S’eliminen el desament, la còpia de reserva i els fitxers temporals del perfil. Una prova amb Godot i OpenGL en dades aïllades ha comprovat la cancel·lació, l’eliminació del perfil actiu i de la partida local, i la conservació d’un altre perfil.

La generació de flora i fauna tria només tipus propis del bioma. Les característiques individuals continuen variant per llavor. Una prova headless ha comprovat la selecció als 20 estrats. Els estrats ja desats conserven els organismes que s’hi havien generat.

El primer escaneig d’una espècie al perfil obre una fitxa amb el nom i una captura ampliada. Si el subjecte queda fora de l’enquadrament es mostra la seva il·lustració procedural. Una prova amb Godot i OpenGL ha comprovat la captura en el primer escaneig i que no es repeteix en tornar a escanejar la mateixa espècie.

La base de trets d’organismes genera receptes i noms per a flora i fauna. La fauna incorpora protecció, antenes, cua i moviment, i la flora combina forma de creixement, tiges, fulles, color, mida, textura, terminacions i luminescència. Les receptes es desen amb el nivell i el catàleg conserva les receptes de versions anteriors. Una prova amb Godot i OpenGL ha verificat la generació per llavor i el renderitzat de les targetes de flora i fauna.

La fauna nova es genera combinant un tipus de base amb 1–4 potes, sis colors, pèl opcional, cinc mides i quatre patrons. La recepta versionada identifica cada variant al desament i al catàleg. Una prova amb Godot i OpenGL ha comprovat variants en dotze llavors, repetició de llavor i targetes renderitzades al catàleg.

Els nivells generats amb la revisió biològica 2 combinen flora i fauna pròpies de la zona i visitants d’altres zones. Cada organisme té un 60% de probabilitat de ser del grup local, i flora i fauna poden compartir sala. L’espècie, la sala i el punt dins la sala es determinen per llavor i els nivells desats conserven les assignacions anteriors. Una prova amb Godot i OpenGL ha verificat el mostreig de les vuit zones, dotze llavors diferents, sales compartides, repetició de llavor i restauració de desament.

En morir es tanca l’expedició i la següent comença amb una llavor nova. El perfil conserva les fites, l’historial i el catàleg. Les caixes de recuperació s’han retirat i els desaments antics que les contenen es poden continuar carregant.

«Partida → Historial d’expedicions» mostra les expedicions del perfil, el rècord de profunditat, les morts i les dates de les millores, modificadors comprats i fites. El catàleg conserva flora, fauna i fotografies entre expedicions. Les troballes històriques no puntuen en una expedició nova. En carregar un desament anterior es recuperen les espècies i les fotos que encara hi consten. Una prova amb Godot i OpenGL en un perfil aïllat ha comprovat una millora de botes, una fita, una mort, la represa des de disc i la continuïtat del catàleg i de les fotos.

Les fites −4, −7, −10, −13, −16 i −19 desbloquegen, respectivament, una balisa, una bateria de casc, un ús de caixa d’eines, una reserva d’oxigen, una farmaciola i un ús d’escala. Les recompenses s’acumulen i s’apliquen en iniciar una nova expedició. El selector de profunditat mostra les estrelles i el botó «Fites» explica cada recompensa i l’estat. Una prova amb Godot i OpenGL ha comprovat les estrelles, la restauració de l’estat desat i l’equip inicial després de morir.

La navegació permet generar fins al nivell −20. El −19 i el −20 generen 40 sales per llavor i reserven la sala 40, la més llunyana de l’entrada en línia recta, per a la baixada o la investigació final. Els nivells intermedis reutilitzen el generador i els continguts provisionals existents. Una prova headless ha verificat 50 llavors amb 40 sales, connectivitat i centres transitables, i ha provat el descens −19 → −20 i l’activació i captura de desament del final. Queda pendent la comprovació visual i una expedició completa a peu.

La sala d’entrada del primer nivell de cada bioma i la del −19 tenen accés al taller complet des d’«Equip i millores». El taller reutilitza les compres, reparacions, fabricació, millores i modificadors de la superfície i manté els costos. Obrir-lo no recarrega les reserves. Una prova amb Godot i OpenGL ha comprovat una compra real al −1 i ha validat les regles d’accés de les fites posteriors amb una profunditat simulada. Els nivells del −4 en endavant encara no són jugables.

«Enquadra el mapa» centra les sales, les galeries i les sortides al rectangle lliure entre les estadístiques, la navegació i els panells laterals. La llegenda ocupa la primera posició de la columna dreta. La caixa d’eines només avisa per l’estat del vestit, les botes, l’eina de mineria i l’escàner biològic si encara té usos. Una prova automatitzada amb Godot i OpenGL ha comprovat els contorns projectats, la posició de la llegenda i els avisos de la caixa.

El mapa i la vista isomètrica mostren el nom i la profunditat sobre les estadístiques del nivell. Just a sota hi apareixen el número de sala, el percentatge d’escaneig i les icones de les troballes visibles. La llegenda queda fixa a la dreta. Una prova automatitzada amb Godot i OpenGL ha comprovat l’ordre vertical del HUD, el percentatge de la sala inicial i la visibilitat de la llegenda en totes dues vistes.

Les ones de cobertura triguen 12,8 segons a arribar al límit del senyal a totes dues vistes. Les botes es desgasten a la meitat del ritme anterior per distància. La llum del casc canvia automàticament quan l’explorador passa entre zones il·luminades i fosques. Godot en mode headless ha comprovat l’encesa, l’estalvi de càrrega i que el canvi automàtic no gasta recanvis. Queda pendent la comprovació visual en partida.

El selector de profunditat mostra els nivells 0 a −20 amb separadors cada tres nivells subterranis, el percentatge per nivell visitat i el desglossament de cinc categories en passar-hi el cursor. Les destinacions jugables es poden seleccionar per encadenar els trajectes a peu pels accessos coneguts. La comprovació prèvia estima oxigen i desgast, avisa de despreniments i bloqueja descensos sense escala. Els nivells −4 a −20 hi figuren com a pendents. Godot amb OpenGL ha comprovat la navegació del −3 a la superfície i el retorn al −3, els percentatges del selector i l’avís d’oxigen.

El menú Partida permet crear perfils locals amb un desament per perfil, desar manualment i carregar. El primer perfil adopta l’expedició que hi ha en pantalla. Els perfils següents comencen una partida independent. Es desa automàticament cada tres segons de joc, amb perfil o amb la partida local, i també als canvis de nivell, al retorn a la base, en morir i quan es tanca la finestra. En obrir el joc es reprèn l’última partida activa. Abans de carregar un perfil es desa la partida activa, també si es tria el mateix perfil. Una prova headless amb fitxers aïllats ha comprovat el desament periòdic, la represa, la recàrrega del perfil actiu i la persistència de la mort. Es materialitza el món sencer i es conserva una còpia de la versió anterior. Les textures del terra es tornen a dibuixar i les fotografies es desen en PNG. Godot amb OpenGL ha verificat dos perfils independents, la càrrega des d’una instància nova, la fotografia, l’estat d’equip i minerals, el retorn al nivell superior i la còpia de reserva. Els perfils són locals i es trien des del menú en iniciar el joc.

Els modificadors es compren, activen i desactiven dins de la fitxa de la peça a Millores d’equipament. Cada peça admet un mòdul actiu. Godot ha verificat que desactivar i reactivar un mòdul comprat no torna a cobrar-ne el cost.

Ferro, quars i magnetita es recullen i es mostren per separat. Les millores enumeren el ferro i els punts exigits, i en nivells de fita hi afegeixen quars o magnetita. La caixa d’eines és a Equip, comença amb un ús i en guanya un per nivell. El taller reposa un ús per dos de ferro. Una prova amb Godot i OpenGL ha comprovat el bloqueig sense el mineral, el descompte de les receptes i la reparació i reposició d’un ús.

La pestanya Modificadors del taller permet comprar i equipar soles, aïllaments, capçals de mineria i un filtre espectral. Cada peça admet un modificador actiu i canviar a un mòdul que ja s’ha comprat és gratuït a la base. Algunes sales del −2 i del −3 tenen aigua, gel o calor amb efectes sobre el moviment o el desgast. Les vetes especials de quars i magnetita i les espècies fèrriques requereixen el modificador corresponent. Godot amb OpenGL ha verificat els costos, el canvi de soles, el filtre fèrric i l’extracció de quars.

El topall de l’equip i els subministraments és el nivell 20. L’escala plegable és una sola peça amb un ús inicial i un ús addicional per millora. El requadre mostra els usos gastats i la capacitat total. Reparar-la a la base costa dos materials i recupera tots els usos. Per obrir el segon accés cal reparar l’escala o millorar-la.

El taller permet millorar els onze tipus d’equip i subministraments fins al nivell 10. Cada subministrament té botons separats per reposar o millorar. Materials i punts d’investigació comparteixen el saldo visible del taller, i la columna d’investigació s’ha integrat a les fitxes. Cada nivell de balisa suma 50 unitats d’abast. Godot amb OpenGL ha verificat les onze progressions, el topall, la despesa de tots dos recursos i la finestra amb la barra inferior visible. Els costos i increments són valors de prova.

Les millores d’equipament requereixen materials i punts d’investigació. El dipòsit, les reserves, el llum del casc, les balises, les farmacioles, les caixes d’eines i les escales tenen un segon nivell funcional. Godot ha verificat el bloqueig sense punts, el descompte dels dos saldos i els efectes del dipòsit i la farmaciola millorats.

El catàleg d’equip i millores s’obre en una finestra ampla. La graella de l’esquerra agrupa les operacions amb materials i el panell dret mostra les millores amb punts de recerca. Cada apartat indica el seu saldo. Una captura de Godot amb OpenGL ha verificat la disposició a 1440 × 900.

## Coves oxidades (nivells −1 a −3)

Els botons de Navegació porten l’explorador pels camins coneguts fins a l’accés superior o inferior. El botó de baixada apareix quan s’ha descobert l’accés, i el primer descens continua requerint una escala. Una prova headless ha verificat el recorregut amb els botons del −1 al −3 i de tornada a la superfície.

El primer bioma és jugable fins al −3. L’escala plegable i els seus usos es mostren a la barra d’equip. Cada accés nou consumeix un ús i els trajectes posteriors fan servir ascensors. Si només hi ha una veta en una sala veïna dins la cobertura inicial, s’hi afegeix una veta a la sala d’entrada del −1. El retorn conserva la generació i l’estat de cada nivell. Godot amb OpenGL ha verificat el bloqueig del segon accés amb l’escala esgotada i el descens després d’augmentar-ne la capacitat.

La llavor determina la distribució de flora i fauna i les espècies de cada sala, amb la molsa fèrrica i l’escarabat fèrric afegits al bioma. Godot ha verificat 50 llavors, 50 combinacions biològiques diferents al −3, els accessos en els dos sentits, el cost en escales i la disponibilitat de material inicial. La prova automatitzada situa l’explorador als accessos. Queda pendent una expedició completa a peu.

L’oxigen esgotat sense reserves resta vuit punts de vida per segon. Les botes trencades resten vida segons la distància caminada. Una prova headless ha verificat el desgast en moviment, l’ús automàtic de la reserva i la mort per falta d’oxigen quan la vida arriba a zero.

La pols d’un despreniment s’assenta però les pedres queden al túnel fins que es retiren. Si l’explorador és a dins quan cau la galeria, pot perdre 25 punts de vida i 12 d’integritat del vestit. La casella Vida inclou el botó de farmaciola. Se’n dona una en començar, cada ús cura fins a 35 punts i al taller en costen dos materials. Una prova amb Godot i OpenGL ha verificat la ferida, la cura, les pedres persistents en canviar de nivell, la neteja i la mort al 0% de vida.

Els despreniments apareixen dins del túnel. En vista isomètrica l’explorador s’hi acosta i espera davant de les pedres. Clicar-les gasta cinc punts d’integritat de l’eina de mineria i permet reprendre el trajecte. L’espera també acaba quan expira l’incident al cap de dotze segons.

Les ordres directes d’entrada a una galeria poden activar un despreniment aleatori de quatre segons. La pols marca les boques revelades i la primera exposició resta 12 punts d’integritat del vestit. L’incident expira automàticament. Godot en mode headless ha verificat el desgast únic i l’expiració. La comprovació visual de la pols queda pendent.

Els materials que l’explorador porta quan mor queden en una caixa al lloc de l’incident. Mentre hi hagi caixes pendents, el reinici torna a generar el nivell amb la mateixa llavor i reinicia l’equip i l’exploració. Godot en mode headless ha verificat que la caixa es conserva després del reinici i es recull una sola vegada. Les caixes es mantenen durant la sessió actual.

La base de superfície té un nou dibuix 2D amb relleu marcià, mòduls amb volum, plaques solars en perspectiva i una plataforma il·luminada al voltant de l’ascensor. Verificat amb captura de Godot i clic directe a l’ascensor per iniciar el descens.

El clic dret en una altra sala visitada, des de la vista isomètrica, ordena un recorregut per galeries completades. Les sales intermèdies pendents d’explorar encara provoquen una aturada. Godot amb OpenGL ha verificat el retorn a la sala anterior amb un clic dret i la llum del casc apagada.

La vista isomètrica conserva les sales visitades, amb el terra descobert de cadascuna, i els trams de galeria recorreguts del nivell actual. La prova de trànsit amb Godot i OpenGL continua passant amb el dibuix del nivell ampliat.

El trajecte isomètric dibuixa la galeria i el terra revelat de les dues sales amb la mateixa projecció. La càmera segueix l’explorador i manté el zoom quan arriba per la boca de la galeria. S’ha retirat el tall a negre entre vistes. Una prova amb Godot i OpenGL ha verificat el clic de sortida, el trànsit en vista isomètrica i l’arribada a la boca amb el mateix zoom.

Les icones de la sala isomètrica apareixen sota el percentatge. Les galeries recorregudes de punta a punta tenen llums i es poden tornar a travessar amb el casc apagat si hi ha senyal. Una prova amb Godot i OpenGL ha verificat que un tram desconegut queda bloquejat en foscor i que el mateix tram esdevé transitable quan la galeria consta com a recorreguda.

El primer accés al nivell −2 es mostra com un forat i requereix una escala plegable. La partida comença amb una escala i se’n poden comprar al taller per dos materials. El primer descens gasta l’escala i els trajectes posteriors fan servir l’ascensor. Godot en mode headless ha verificat la compra, el bloqueig sense escala, el primer descens, la pujada i el segon descens. La prova visual queda pendent.

L’equip inicial permet escanejar flora i fauna. Les sales es completen explorant-les i es revelen del tot al 90%. Els accessos inicials de nivell es continuen revelant en arribar-hi. L’escaneig territorial manual queda reservat com a possible millora futura. Godot ha carregat el canvi en mode headless.

## Fi de partida

La versió actual aplica la decisió posterior de reiniciar de zero quan mor l’explorador. L’oxigen esgotat sense reserves, el vestit o les botes al 0% i l’esgotament de les bateries fora de la sala d’entrada activen l’avís de fi de partida. L’avís mostra la causa i atura la simulació. En confirmar-lo es genera un món amb una llavor nova i es torna a la superfície amb l’equip inicial.

Godot 4.7.2 en mode headless ha verificat les quatre causes, el missatge corresponent i el reinici amb llavor nova i inventari inicial. Queda pendent la comprovació visual en partida.

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

En escanejar una cova, també es pinten les cel·les inicials revelades dins les sales veïnes connectades, a continuació del tram de galeria. El marc de càmera prioritza la cova actual i la sala veïna més propera perquè el jugador pugui percebre la continuïtat. No es dibuixa el contorn de la sala inexplorada i el seu centre continua ocult. Verificació: bateria de 50 llavors aprovada; cada sortida escanejada revela el punt d'arribada però no el centre de la sala. Captura OpenGL regenerada a
eports/prototip_screenshot.png.


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

## Vores automàtiques i terra estable en exploració

La signatura cian de detecció ja no es dibuixa en la vista isomètrica de sala. El contorn s'hi mostra automàticament quan s'ha revelat almenys el 75% de les cel·les transitables; en arribar al 90%, es completa el descobriment: es revelen les cel·les restants, parets i totes les sortides i la sala queda registrada com explorada. Les sales veïnes no es descobreixen senceres. La textura del paviment manté UV ancorades a coordenades del món i els afloraments es generen amb una seqüència fixa independent de la boira: descobrir noves cel·les només els fa visibles, no els recol·loca. Verificació: Godot 4.6.2 ha carregat el projecte i `seed_validation.gd` comprova el completament de sala i totes les sortides amb 51/51 llavors; `git diff --check` net. No s'ha fet revisió visual interactiva.

## Base inicial a la superfície

Cada món nou comença a la base marciana del nivell 0, amb un accés circular visible i clicable cap al nivell 1. El botó «BAIXA AL NIVELL 1» activa el mateix descens; en baixar, l'explorador apareix a la cova d'entrada procedural existent, s'escaneja per presentar-ne les sortides i continua la mateixa partida. El fons, els mòduls de base, els panells solars i el forat són geometria provisional 2D, amb detalls de terreny estables per llavor. Verificació: bateria `seed_validation.gd` 51/51, amb comprovació de l'estat inicial de nivell 0 i clic al forat; captura OpenGL inspeccionada a `reports/base_superficie.png` i `reports/descens_nivell_1.png`. Limitació d'aquesta fita: no implementa gestió completa d'expedicions ni la campanya de 20 nivells.

## Retorn de les coves a la base

Des del nivell 1, el botó «TORNA A LA BASE» es manté a la interfície i només s'activa dins la sala d'entrada, on la vista isomètrica marca la pujada. En tornar, el nivell 0 recupera la base de la partida; en baixar de nou es conserva llavor, xarxa, sales explorades, sortides i cel·les revelades. Verificació: `seed_validation.gd` aprovat 51/51, incloent-hi accés clicable, pujada, conservació d'estat i nou descens; `git diff --check` net. Captura OpenGL inspeccionada a `reports/retorn_base_cova.png`; no s'ha fet una sessió manual de moviment fins a l'entrada.

## Ordres de mapa i galeries més corbes

Una ordre de moviment des del mapa ara conserva l'identificador de la sala clicada. En passar per sales intermèdies, encara que ja estiguin escanejades, l'explorador continua pel recorregut i només canvia al mode d'inspecció en arribar a la destinació indicada. Una ordre sobre una galeria des de la vista d'inspecció també conserva com a destinació la sala connectada. Les galeries procedurals tenen més desviació lateral i més punts de mostreig, mantenint la mateixa corba com a origen de la màscara transitable; la versió del generador passa a `p0b-4` i la versió de disposició de les coves es conserva. Verificació: Godot 4.7.2 headless ha executat `seed_validation.gd` amb 51/51 llavors, incloent-hi el pas per una sala intermèdia escanejada sense obrir-ne la inspecció, i `git diff --check` net. Limitació: no s'ha revisat visualment una execució interactiva de les noves galeries.

## Moviment sobre la línia central de les galeries

La ruta de graella continua trobant un camí transitable, però ara en els trams que coincideixen amb una galeria se substitueixen les cel·les en ziga-zaga per punts projectats sobre la mateixa corba `corridor.points` que es dibuixa al mapa. Cada segment de la ruta ajustada es comprova contra la màscara transitable i les cel·les revelades; si no és segur o visible, aquell tram conserva la ruta original. La prova de navegació ara valida segments continus sobre la màscara i comprova que el jugador comparteix punts amb la línia central generada. Verificació: Godot 4.7.2 headless, 51/51 llavors aprovades, prova de seguiment de la galeria aprovada i `git diff --check` net. Limitació: encara cal comprovar visualment en una partida que la velocitat i l'animació del jugador es llegeixin bé.


## Primera troballa de flora

Una selecció de sales determinada per la llavor conté la falguera de llum, inclosa una sala veïna de l’entrada. A la vista isomètrica apareix quan l’explorador és a prop i ha revelat el terreny. Es pot seleccionar i analitzar amb el botó del panell d’exploració. El catàleg mostra la il·lustració, la descripció i les sales on s’ha analitzat; el mapa marca aquestes troballes. Les dades es mantenen durant la partida actual, també si es torna a la base. Pendent de revisió visual del flux complet.

## Reorganització de la interfície

- Totes les fitxes inferiors reserven una franja de la mateixa alçada per a les icones, amb els valors a sobre. Verificats a Godot l’alineació i el clic dels recanvis.

- Les icones d’acció romanen visibles a les fitxes d’equip i s’atenuen quan l’acció no és disponible. Els botons de recanvi mostren una icona i la quantitat. Verificat a Godot que la mostra de fauna continua bloquejada i els recanvis es poden activar quan correspon.

- Les fitxes inferiors són més altes i integren els controls d’equip. Dipòsit d’oxigen i Llum del casc inclouen els recanvis. Les accions de fotografia i mostra són dins d’Escàner biològic, i les icones de mineria i balisa són a les fitxes corresponents. Verificada la disposició a Godot.

- En seleccionar una troballa, les icones de fotografia i mostra apareixen sobre la fitxa Escàner biològic. La fauna només mostra la càmera i les accions es desbloquegen en completar l’escaneig. Verificat a Godot el posicionament i la selecció de flora i fauna.

- La fitxa de balises és a Equip i permet col·locar o recuperar una balisa a la sala on és l’explorador. Verificat a Godot des de la vista de sala i el mapa, inclòs el bloqueig de les balises que ja s’han fet servir.

- Els avisos de consum i desgast s’activen en arribar al 10% d’oxigen, càrrega del casc, vestit, botes, eina de mineria o escàner. Indiquen l’acció disponible. Les fitxes de reserves d’oxigen i de bateries del casc permeten utilitzar un recanvi amb un clic. Verificat a Godot el llindar i la reposició manual.

- El progrés del nivell es mostra en sis fitxes a la fila superior, amb percentatges i barres horitzontals segmentades. La mateixa fila és visible al mapa i a la sala. Disposició comprovada amb captures de Godot.

- La vista isomètrica té un botó per centrar la càmera en l’explorador. El canvi entre sala i túnel es produeix amb l’escena completament fosca durant 120 ms. Verificats a Godot el centrat i l’enfosquiment total als dos canvis de càmera.

- Quan augmenta un recompte, la fitxa corresponent de la fila inferior s’il·lumina amb un +N breu. Si hi ha dos guanys seguits mentre l’avís és visible, s’hi mostra la suma. Verificat a Godot amb minerals, punts de recerca i mostres.

- La vista isomètrica s’enfosqueix gradualment a les dues boques de la galeria i recupera la claror en entrar a la sala. Verificat a Godot que el feix i l’explorador es veuen durant la transició.

- Si falta llum per entrar en una galeria o explorar terreny desconegut, apareix un avís al punt del clic i es ressalta la fitxa de la llum del casc. El missatge indica si cal encendre-la, canviar la bateria o si no queda cap recanvi.

- Travessar una galeria requereix llum del casc. Des de la sala, la càmera segueix l’explorador en vista isomètrica pel túnel i enfoca l’arribada just dins de la sala, per la boca de la galeria. Verificat amb clic a la galeria, apagada i represa de la llum, i comprovació del punt d’arribada.

- La fitxa de l’eina activa s’il·lumina de baix a dalt segons el progrés de l’extracció o l’escaneig biològic. El ressalt es manté un instant en completar l’acció. Verificat a Godot el progrés intermedi, la finalització i la cancel·lació.

- La fitxa Llum del casc de la fila inferior funciona com a interruptor i es ressalta en ambre quan és encesa. Verificat amb clics sobre la fitxa a Godot.

- Els indicadors duplicats del panell esquerre passen a consultar-se a la fila inferior, visible també a la base. El catàleg d’equip i millores utilitza la mateixa graella del taller i es pot consultar durant l’expedició. Les compres i millores s’activen a la base.

- Cada espècie de flora analitzada o fauna observada, primera fotografia per espècie i mostra recollida donen un punt de recerca al moment. El saldo es mostra a Recursos i només es pot gastar en millores al taller. Verificat a Godot el saldo abans de tornar a la base i el descompte en aplicar una millora al taller.

- Els apartats de la fila inferior i dels panells de la dreta tenen marcs independents i espai entre blocs. Revisat amb captures del mapa i de la sala a Godot.

- Amb la llum del casc apagada o esgotada, el moviment queda restringit al terreny revelat i les sales il·luminades. Verificat a Godot el bloqueig d’una destinació fosca i l’aturada quan la bateria s’esgota en moviment.

- La fila inferior inclou l’oxigen del dipòsit a Equip i mostra barres verticals d’oxigen, integritat del vestit, càrrega del casc i estat de l’eina de mineria. Verificat a Godot amb els quatre valors parcialment consumits.

- Les fitxes de la fila inferior del mapa i la sala es reparteixen en Recursos, Equip i Recerca. Disposició comprovada amb una captura del mapa a Godot.

- Els botons del panell dret s’agrupen per funció. A la sala hi ha Navegació, Astronauta i Recerca i recursos. Al mapa hi ha Navegació, Recerca i Mapa. Verificat a Godot el canvi de vista i l’ús de l’ascensor amb la disposició nova.

- La interfície indica la profunditat com a nivell 0 a superfície i nivells -1, -2 sota terra. Els ascensors tenen una icona pròpia amb fletxa de pujada o baixada a la sala, al mapa i a la llegenda. Verificat a Godot el recorregut entre els tres nivells disponibles.

- Al mapa, clicar el marcador de l’explorador quan és dins d’una sala o clicar el fragment visible d’una sala visitada obre la inspecció, encara que la sala estigui pendent d’escanejar. Verificat a Godot el clic sobre l’explorador en una sala fosca i el bloqueig d’una sala encara no visitada.

- El botó Mapa centra la càmera en l’explorador i el segueix fins que acaba el desplaçament en curs. El zoom manual, el desplaçament de càmera i l’enquadrament del mapa cancel·len aquest seguiment.

- El panell esquerre mostra barres d’oxigen, integritat del vestit i càrrega de la llanterna. El text de la llanterna canvia a taronja amb un 20% de càrrega o menys. Les piles de recanvi tenen una fitxa pròpia a la fila inferior de l’inventari.

- Amb la llum del casc apagada o esgotada, caminar per una sala en penombra no descobreix terreny ni sortides noves. La bateria dura provisionalment 180 segons d’ús i la partida comença amb un recanvi. L’inventari indica la càrrega i els recanvis. Verificat a Godot l’esgotament i el canvi de bateria.

- L’escàner manual requereix llum. A les sales en penombra, la mineria, l’anàlisi de flora, l’observació de fauna i la càmera exigeixen que la troballa estigui dins el feix i a la vista. Amb la sala il·luminada, les eines es poden fer servir des de dins de la sala sense límit de distància. Verificat a Godot el bloqueig a les fosques, l’orientació del feix, l’aturada de l’extracció en apagar la llanterna i l’extracció a distància en una sala il·luminada.

- Els accessos ara es representen com a plataformes d’ascensor metàl·liques amb baranes. El clic utilitza el contorn de la plataforma. Verificat a Godot el descens directe des de la superfície i les transicions subterrànies mitjançant el botó de la sala.

- Les nou fitxes de l’inventari es mostren en una sola fila inferior al mapa i a la sala. Els valors es comparteixen amb la graella i les accions d’equip es troben al panell de la sala. Verificat el renderitzat de la fila a Godot.

- Els accessos indiquen la direcció i el destí amb fletxes i etiquetes. A la superfície, clicar l’ascensor baixa directament al nivell 1. Sota terra, un clic inicia l’aproximació si cal i activa la pujada o baixada corresponent en arribar. Verificat a Godot el descens i les dues pujades fins a la superfície.

- Les balises de les sales d’entrada es dibuixen al centre de l’ascensor. En vista de sala, l’ona creix fins al punt més llunyà del contorn. Al mapa, el senyal de base i de les balises instal·lades fa servir el radi efectiu de cobertura.

- La pujada de cada sala d’entrada es marca des de l’arribada amb una balisa ambre. En escanejar la sala de baixada, l’ascensor mostra quatre llums fixes i una etiqueta de destí, sense balisa automàtica. Verificat a Godot que es pot baixar i tornar a pujar.

- Les balises instal·lades emeten llum blau violaci i dues ones animades que s’expandeixen i s’esvaeixen a la vista isomètrica i al mapa. Verificat el renderitzat de totes dues vistes a Godot.

- La projecció de sala manté l’orientació del mapa general i comprimeix l’eix vertical per conservar la sensació de profunditat. Verificat a Godot que 58 boques de galeria mantenen la posició relativa horitzontal i vertical i que la projecció inversa recupera les coordenades del clic.

- El Catàleg de l’expedició presenta una graella de dues columnes amb una fitxa per espècie registrada. Cada fitxa inclou fotografia o icona, estat, descripció i ubicacions. Verificat a Godot amb el catàleg buit i amb quatre registres de prova.

- La pestanya Taller i compres mostra sis opcions en una graella amb efectes, preus i accions. Disposició comprovada amb una captura OpenGL de Godot a la base.

- La pestanya Inventari mostra una graella de tres columnes amb quantitats, estat de l’equip i recerca pendent. Disposició comprovada amb una captura OpenGL de Godot a la base.

- El panell esquerre agrupa oxigen, vestit, senyal, recursos i profunditat. Inventari i catàleg es poden obrir des de les vistes principals.
- El mapa concentra el progrés i les accions en un panell curt. La llegenda agrupa el significat dels marcadors. A Opcions es poden ocultar els cercles de cobertura i les icones biològiques, i accedir als controls de desenvolupament i de llavor.
- La vista isomètrica manté el percentatge de sala a dalt i mostra les accions disponibles segons les troballes i l’equip. El taller agrupa millores de recerca, fabricació i eines de mineria.
- Verificat amb l’arrencada headless de Godot 4.7.2 i captures OpenGL del mapa, la sala isomètrica, la llegenda i el taller. Queda pendent comprovar la llegibilitat amb una partida avançada i diverses mides de finestra.

## Inventari, taller i equip per a la pressió

- L’escàner biològic mostra el progrés sobre la flora o fauna. En completar-se, habilita la fotografia de totes dues i la recollida de mostres de flora. El model estàndard triga 6 s i perd 8 punts d’estat. El model avançat triga 3 s i en perd 4. La millora costa 3 materials i la reparació al taller en costa 1. La caixa d’eines també el pot reparar al camp. Verificats a Godot el progrés, el desgast i les accions disponibles després de l’escaneig.

- La caixa d’eines costa 2 materials al taller. Cada caixa recupera fins a 30 punts d’estat del vestit, les botes o l’eina de mineria durant la inspecció d’una sala. Verificat a Godot el cost, el menú de selecció i el consum només en reparar.

- Les botes perden un punt percentual d’integritat cada 80 unitats recorregudes. El desgast redueix gradualment la velocitat fins a un 30% i el taller pot reparar les botes per 1 material. Verificat a Godot el desgast per distància i la reparació.

- Mentre s’extreu una veta, les ordres de moviment, el retorn a la base i els ascensors queden bloquejats. Verificat a Godot que es recupera el moviment en completar l’extracció.

- Les eines de mineria perden estat mentre extreuen vetes, amb desgast provisional del 8%, 6% i 4% per jaciment segons l’eina. El taller les pot reparar al 100% per 1 material. Verificat a Godot el desgast, l’avaria a mig treball i la reparació.

- Tornar a la superfície conserva l’oxigen, la integritat del vestit i la bateria. Al taller, la recàrrega completa d’oxigen costa 2 materials, la reparació del vestit en costa 1 i una bateria del casc en costa 1. Són preus provisionals. Verificat a Godot el retorn, el bloqueig sense materials i el resultat de les compres.

- Les botes apareixen a l’inventari i es milloren al taller. Velocitats provisionals de 145, 175 i 210 unitats per segon, aplicades des del mateix moviment del mapa i de la sala. Verificades a Godot la compra de les dues millores i la velocitat de les botes impulsades.

- Cada sala d’entrada subterrània té llum ambiental reforçada i quatre llums fixes al voltant de l’accés. Les altres sales guanyen la mateixa il·luminació amb quatre llums repartides pel terra quan queden al 100%. Verificat amb captures OpenGL als nivells 1 i 2 per a les entrades i amb una altra sala abans i després d’escanejar-la.

- El panell dret del mapa i de la vista isomètrica mostra el percentatge de vetes descobertes respecte als jaciments del nivell, inclosos els ja explotats. Verificat el renderitzat amb Godot 4.7.2.

- Els minerals apareixen com una veta sobre una roca, que continua visible després de l’extracció. La durada provisional és de 6 s amb el pic, 4 s amb el trepant i 2 s amb l’extractor. El percentatge de recollida es dibuixa sobre la veta. Verificat a Godot el percentatge a mitja extracció i el lliurament del material.

- En extreure un jaciment, el guany apareix a la fitxa Materials de la fila inferior. Verificat a Godot que l’extracció amb el pic manual suma un material, actualitza la graella i no torna a sumar en repetir l’acció al mateix jaciment.

- La vista isomètrica aplica llum ambiental baixa. La llanterna projecta un feix amb vores suaus orientat segons l’últim moviment de l’explorador. Verificat el renderitzat OpenGL del feix en dues direccions.

Es poden explotar jaciments als dos nivells. El pic manual obté un material per jaciment, el trepant n’obté dos i l’extractor n’obté tres. Les eines es compren al taller de la base i s’equipen automàticament. Amb els materials també es fabriquen balises, reserves portàtils de cinc minuts d’oxigen i un vestit reforçat. La llanterna augmenta en una cel·la el radi de descoberta mentre està encesa. El vestit es desgasta més de pressa al nivell 2, el reforç redueix el desgast un 60% i a la superfície es repara. El vestit esgotat dobla el consum d’oxigen. L’inventari és accessible durant l’expedició i el taller només a la base.

La pujada del nivell 2 es pot activar clicant l’accés a la vista isomètrica o amb el botó de retorn. El retorn automàtic busca un punt accessible dins de la sala d’arribada. Les proves headless han comprovat compres, extracció sense duplicats, reserva d’oxigen, desgast per profunditat, conservació de l’equip i tornada al nivell 1 des d’una sala veïna. Queda pendent revisar la interfície en una partida.

## Accés al segon nivell

Una sala connectada amb l’entrada del nivell 1 conté la baixada. Un cop escanejada, l’accés es marca al mapa i, des de la vista isomètrica, es pot baixar quan l’explorador és a prop. El nivell 2 es genera amb una llavor derivada de la partida i té senyal a l’entrada. La pujada recupera la sala d’accés del nivell 1. Cada nivell conserva el seu estat mentre dura la partida. L’oxigen, les millores, l’inventari de balises i el registre científic es comparteixen entre nivells. El panell esquerre ressalta el nivell actual al diagrama de profunditat. La prova headless ha comprovat la baixada, la pujada, la restauració del mapa i la continuïtat de l’oxigen. Queda pendent la revisió visual.

## Xarxa de balises

Les ordres directes del mapa cap a sales visitades busquen una destinació accessible per les galeries recorregudes. En vista isomètrica es pot caminar cap a terra encara fosc dins de la sala actual. La boira es revela durant el moviment.

El botó «Torna a la base» calcula una ruta per les galeries recorregudes i puja a la superfície quan l’explorador arriba a la sala d’entrada. Si manca una ruta coneguda, el joc ho indica. Godot ha carregat el canvi en mode headless.

Es pot recuperar una balisa des de la sala on s’ha instal·lat fins que el seu senyal sigui necessari per arribar a una sala nova. Recuperar-la retorna una unitat a l’inventari i recalcula la cobertura. Godot ha carregat el canvi en mode headless.

Una galeria nova només es pot travessar si hi ha cobertura contínua entre les dues boques. El marcador de l’entrada indica si es pot passar. Els cercles discontinus marquen l’abast real en línia recta. Les zones de la base i de les balises se sumen.

La sala d’entrada rep el senyal directament de la base i l’explorador porta dues balises de camp. La cobertura es calcula per distància en línia recta des de la base o de qualsevol balisa. Per entrar en una sala nova, l’abast ha d’arribar fins a aquella sala. Les balises es poden col·locar en arribar físicament a una sala, encara que estigui pendent d’escanejar o no tingui cobertura al centre. Es pot tornar per les galeries recorregudes encara que es perdi el senyal. A la base, un punt de recerca augmenta l’abast de 650 a 900 unitats. Els valors són provisionals. Godot ha carregat el canvi en mode headless.

## Reserva d’oxigen

L’explorador disposa de 30 minuts d’oxigen. El temps sota terra redueix la reserva i el panell comú del mapa i de la vista isomètrica mostra el percentatge. Al 20% apareix l’avís de reserva baixa. Tornar a la base recarrega la reserva. En aquesta versió, esgotar-la activa l’avís de retorn. Queden pendents les conseqüències de l’esgotament i les millores del dipòsit. Godot ha carregat el canvi en mode headless.

## Càmera de camp

Després d’analitzar una planta o d’observar un animal, l’explorador pot fotografiar-lo de prop des de la vista isomètrica. Es desa una captura del joc per espècie i es mostra al catàleg durant la partida. Godot ha carregat la funcionalitat en mode headless. La captura de la imatge queda pendent de comprovació amb renderitzat interactiu.

## Accés a les galeries des de la sala

La navegació per una galeria té en compte l’amplada de la seva màscara de cel·les. Si el punt d’arribada previst no és accessible, l’ordre busca un altre punt revelat i transitable dins de la mateixa sala de destinació. La vista també canvia en arribar a la sala veïna quan la galeria és massa curta per arribar abans al llindar de canvi de càmera.

## Segona espècie de fauna

L’isòpode de pissarra comparteix el flux d’observació de l’escarabat. Té una closca segmentada blavosa, es projecta sobre el terra isomètric i es mou més lentament. La llavor assigna les espècies a les sales amb fauna. El catàleg agrupa les observacions per espècie. Godot ha carregat el canvi en mode headless. Queda pendent la revisió visual.

## Moviment de l’escarabat

L’escarabat fa un recorregut curt d’anada i tornada dins de la sala, amb una pausa a cada extrem. El recorregut es valida contra el contorn i la màscara transitable. La selecció i l’observació fan servir la posició actual. Godot ha carregat el canvi en mode headless. Queda pendent veure el moviment en una partida interactiva.

## Primera troballa de fauna

L’escarabat de cendra apareix en sales determinades per la llavor. Es pot veure de prop a la vista isomètrica, seleccionar i observar per registrar-lo al catàleg. El mapa marca les observacions i el percentatge de fauna ja compta al total del nivell. Aquesta primera versió representa un escarabat quiet. Godot ha carregat el canvi en mode headless i queda pendent la revisió visual.

## Progrés de descoberta del nivell

El panell del mapa mostra el percentatge de sales escanejades, galeries travessades de punta a punta i plantes analitzades. El percentatge total dona el mateix pes a les categories disponibles. La fauna es mostra com a pendent i s’incorporarà al càlcul quan estigui implementada. Godot ha carregat el canvi en mode headless.

## Varietat de flora per llavor

Cada planta pot ser una falguera de llum o un corall de basalt. La llavor determina quines sales tenen flora, la posició i l’espècie. El catàleg agrupa les troballes analitzades per espècie amb descripció i sales. Godot ha carregat el canvi en mode headless. Queda pendent una revisió visual en una partida.

## Rutes cap a sales des del mapa

Una ordre directa cap a una altra sala només pot utilitzar les zones descobertes de les sales visitades i els trams de galeria ja recorreguts. Una galeria nova es pot explorar donant una ordre a la seva boca.

## Punts de recerca i millora d’abast

Cada mostra lliurada val un punt de recerca. A la base es pot gastar un punt una sola vegada per passar de tres a quatre cel·les de radi de descoberta quan l’explorador es mou per una sala sense escanejar. El saldo es calcula a partir de les mostres lliurades i la compra, i el catàleg el mostra. La millora es conserva durant la partida actual. Godot ha carregat la interfície en mode headless. Queda pendent comprovar la compra i la descoberta ampliada en una partida interactiva.

## Recollida i lliurament de mostres

Després d’analitzar una planta, es pot recollir una mostra per sala. El retorn a la base lliura automàticament les mostres transportades i el catàleg mostra els dos recomptes. La prova headless del flux ha comprovat la recollida, que no es duplica, el lliurament i el recompte del catàleg. Queda pendent la revisió visual en una partida.

## Recorregut dins de les sales

Al mapa, la galeria es pinta a mesura que l’explorador hi passa. El registre cobreix també les cel·les transitables de la vora per evitar talls al dibuix. Les ordres des d’una sortida isomètrica suavitzen els esglaons curts del recorregut alternatiu quan el segment directe és transitable i revelat. Godot ha carregat el canvi en mode headless. Queda pendent revisar la continuïtat del traçat en una partida.

El clic al mapa i el botó d’inspecció obren la vista isomètrica només per a sales registrades com a explorades. L’arribada a peu permet explorar una sala nova. Quan s’arriba al llindar del 90% de descoberta, el joc revela la resta i la registra com a escanejada automàticament.

Durant un trajecte, si l’explorador entra en una sala intermèdia que encara no està registrada com a explorada, s’atura i obre la vista isomètrica. Per reprendre el trajecte cal una nova ordre de moviment. Les sales intermèdies completades es poden travessar.

El mapa general i la vista isomètrica comparteixen el mateix ajust de navegació. Dins de la sala s’ometen els esglaons de la graella quan el segment directe passa per terra transitable i revelat. A les galeries es continua seguint la corba central. La bateria de Godot 4.7.2 en mode headless ha superat 51 de 51 llavors. Queda pendent la comprovació visual amb una partida interactiva.
El menú Partida inclou «Reinicia la run» amb confirmació. Inicia una expedició a la superfície amb equip inicial i una llavor nova. Una prova automatitzada amb Godot i OpenGL ha comprovat que cancel·lar conserva l’expedició i que confirmar reinicia la llavor i els materials.
