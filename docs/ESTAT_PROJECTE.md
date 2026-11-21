# Estat de traspàs

Fons exterior corregit segons la revisió d’Albert: el paisatge amb horitzó i cel no compartia la perspectiva dels mòduls. Ara `terreny_marcia_isometric.png` mostra només terreny marcià en projecció isomètrica ortogràfica, amb escala uniforme, roques baixes als marges i espai central pla. Substituïda només la textura de fons del renderer exterior; mòduls, ascensor, player i estat de partida es mantenen. Asset generat amb ImageGen integrada, referència de perspectiva dels mòduls i prompt registrat a `docs/PROMPTS_BASE_EXTERIOR.md`. Primera proposta conservada com a històrica.

Importació headless i renderitzat OpenGL sense errors; captures a 1440×900, 1920×1080 i 1024×768 regenerades, composició integrada de 1440×900 inspeccionada. Proves automatitzades d’estat immutable, àrea de clic de l’ascensor i descens/retorn al mateix món superades. Pendent revisió artística d’Albert en partida.

Base exterior renovada amb el pixel art actual: paisatge marcià de capvespre amb cingles, muntanyes i terreny detallat; sprites independents d’hàbitat, control amb antena/parabòlica, plaques solars i equip de servei; paviment metàl·lic amb pols, fanals i llums d’aproximació. El paisatge és decoració passiva sense edificis ni elements jugables incrustats. `scripts/surface_base_art.gd` separa la composició del món i col·loca petites roques segons la llavor, amb recursos carregats una vegada. L’ascensor i el player es mantenen independents i arran de terra. Escala adaptada a l’espai de pantalla disponible; el centre d’accés es conserva i l’àrea de clic comparteix l’escala del dibuix. No canvia el món subterrani, la navegació, les reserves ni els desaments. Assets i prompts d’ImageGen integrada a `docs/PROMPTS_BASE_EXTERIOR.md`.

Verificat en Godot 4.7.2: importació headless sense errors; captures OpenGL a 1440×900, 1920×1080 i 1024×768 generades i inspeccionades (`reports/base_exterior_*.png`). Estat del món, posició i descoberta intactes durant el renderitzat. Prova funcional automatitzada amb clic simulat sobre l’ascensor i retorn a superfície superada, mantenint llavor, coves i galeries. No s’ha executat revisió interactiva manual ni en pantalla ultrapanoràmica. Següent pas: revisió artística amb Albert de la composició exterior i de la mida relativa dels mòduls.

Corregida la connexió de fauna pixel art: el filtre només admetia escarabats bàsics/fèrrics i deixava els isòpodes i altres famílies en dibuix geomètric. Ara les deu famílies utilitzen el renderer modular, amb resolució compartida de receptes v2, receptes v1 i identificadors antics de família. Les receptes v2 conserven exactament els trets, el nombre de potes i les regles de moviment; no es canvien IDs ni jaciments/posicions. Els identificadors sense recepta reben només una aparença de compatibilitat. Les famílies comparteixen l’atlas modular inicial, encara sense atlas específics d’isòpode per bioma.

La descoberta captura ara un fotograma net abans d’obrir la fitxa: percentatge d’escaneig i cercles de senyal ocults, simulació suspesa durant aquest fotograma. També s’oculta el percentatge a les fotografies ordinàries. Verificació Godot/OpenGL: deu famílies de fauna admeses en versions antigues/v1/v2, equivalència exacta dels trets v2, deu famílies de flora i quatre direccions superats; captura del diàleg «Isòpode de pissarra» inspeccionada sense el 99% (`reports/isopode_descoberta_pixel_art.png`). Sense errors de renderitzat. Pendent escaneig interactiu en la partida d’Albert.

Explorador i ascensor integrats en pixel art. `explorador_pixel_art.png`: quatre orientacions escollides segons `explorer_facing`, pose de repòs i un pas de moviment alternat a 7 fps mentre camina; vestit blanc/gris, visor cian i motxilla segons la referència d’Albert. Punt d’ancoratge als peus, ombra baixa i anell cian; fotografia amb pose fixa. També substitueix el marcador geomètric de superfície. `ascensor_pixel_art.png`: plataforma metàl·lica baixa amb reixa, barana posterior, llums cian/ambre i accents taronja; substitueix el dibuix provisional tant a superfície com als accessos construïts subterranis, mantenint centre i àrea d’interacció. Forats encara sense ascensor conserven la representació de pou. Assets generats amb ImageGen integrada; prompts a `docs/PROMPTS_PLAYER_ASCENSOR.md`.

Godot 4.7.2: importació headless i renderitzats OpenGL sense errors. Captura de sala d’entrada amb explorador sobre la plataforma inspeccionada; mostra de les quatre orientacions/poses a `reports/player_ascensor_pixel_art.png`. Proves existents de 59 roques, rutes/persistència i 3.066 punts de mineral superades; vuit perfils renderitzats. Limitacions: moviment inicial de dues poses, no cicle complet de caminar; pendent expedició interactiva i comprovació de pujada/baixada amb l’art nou.

Corregits els buits sobrants de paret al costat de les boques: abans s’eliminava un interval d’amplada lògica/2 + 5, tot i que el paviment visible utilitza una franja més estreta i afuada. Ara el contorn de paret es retalla amb el polígon exacte del paviment representat, tant per al tram curt d’una sortida com per a una galeria completa. El cache distingeix aquests estats i el pas actiu; no es modifica geometria lògica ni navegació. Prova headless d’amplada exacta, obertura en cantonada i contorn tancat superada. Captures OpenGL d’una sala procedural amb sis sortides, abans/després de completar les galeries, inspeccionades (`parets_boca_stub.png`, `parets_boca_galeria.png`). Regressió de 59 roques, 3.066 punts de mineral i vuit perfils superada. Rendiment amb cache: 4,49 ms local i 8,24 ms estrat enquadrat a la mateixa prova; invalidació i estat de món intactes comprovats. Pendent revisar aquesta mateixa sala del desament d’Albert en partida interactiva.

Optimització del renderitzat en estrats molt descoberts: les parets de galeria es retallaven contra totes les sales i es reconstruïen a cada fotograma, fins i tot fora de pantalla. Ara els retalls, parets, formacions, paviment de galeries i llums s’agrupen en geometria 2D reutilitzable en coordenades del món; les galeries fora de pantalla es descarten abans de preparar-les. Textures, UV, boques, escala i regles de descoberta/il·luminació es conserven. Cache temporal separat dels desaments, amb límits i invalidació per canvi de món o nivell. Les línies fines del relleu escalen amb el món en allunyar-se, sense forçar gruix mínim d’un píxel.

Mesurat en Godot 4.7.2/OpenGL, RTX 3060, 1440×900, llavor 134027, 12 fotogrames després d’escalfament: vista local amb totes les sales descobertes de 170,12 a 3,51 ms de CPU de dibuix; estrat complet isomètric de 224,99 a 7,19 ms, crides de dibuix de 22.396 a 1.136. No són FPS totals de partida. Prova de món/descoberta/posició intactes i invalidació de caches superada; regressió de 59 roques i 3.066 punts de mineral superada; vuit perfils renderitzats sense errors. Captura de sala+galeria inspeccionada. Informe i reproducció a `reports/RENDIMENT_RENDERITZAT.md`. Limitacions: construcció inicial puntual del cache (fins a 269 ms en enquadrar tot l’estrat fred de prova); no s’ha mesurat la generació inicial de textures dels altres biomes ni jugat una expedició interactiva llarga. Següent pas: revisar fluïdesa amb el desament avançat d’Albert.

Plantes i animals ampliats 2,2 vegades a la sala isomètrica, conservant la mida relativa determinada pels trets de cada espècie i l’ancoratge a terra. Escala compartida entre dibuix i àrees de selecció; enquadrament de fotos i descobertes ampliat segons el volum del subjecte per no retallar-lo. Mapa i icones conserven l’escala anterior. Captura de zoom d’entrada inspeccionada amb la nova mida; Godot/OpenGL supera les comprovacions de dades i deu famílies de flora. Dos fitxers de captures intermitges no s’han pogut sobreescriure en aquesta passada; les captures de zoom d’entrada, enquadrament i descoberta sí que s’han generat. Pendent revisar interactivament els clics i les fotos.

Corregida la connexió de flora pixel art: el filtre anterior només admetia `falguera` i deixava coralls/molses amb el dibuix geomètric antic. Ara totes les receptes procedurals de flora utilitzen les peces noves, amb els seus trets intactes. Els deu identificadors de família antics sense recepta tenen una recepta només visual de compatibilitat, sense modificar identitats ni desaments. Sala, icones, retrat i selecció comparteixen la mateixa resolució de recepta. Prova OpenGL de les deu famílies amb IDs procedurals i antics superada, estabilitat de dades comprovada i captura del diàleg «Flora nova · Corall de basalt» inspeccionada (`reports/corall_descoberta_pixel_art.png`). La primera passada va trobar dos errors temporals d’escriptura de captures; repetida la prova per verificar el resultat. Les famílies comparteixen l’atlas modular inicial, no tenen encara atlas artístics específics per bioma. Pendent revisió interactiva d’escaneig.

Primera prova executable de flora/fauna modular pixel art a Coves oxidades. `scripts/organism_pixel_art.gd` munta sprites transparents segons les receptes existents, sense regenerar espècies ni moure els seus llocs: falguera amb 1–5 tiges, tres fulles, textures de tija, borrons/flors/espores, color/mida/llum; escarabat (també família fèrrica) amb 1–4 potes, color/mida, patrons, cuirassa/espines/pèl, antenes i cua. Fulles amb petits desplaçaments discrets i dues poses de flor/càpsula; potes amb quatre poses alternades, aturades durant les pauses. Direcció escollida entre quatre dibuixos segons el desplaçament real, inclosa la tornada. La patrulla i la navegació continuen essent les anteriors. Fotografies i icones de catàleg utilitzen una pose fixa. Àrees de selecció ampliades al volum dels organismes. Les altres famílies conserven el dibuix anterior; no representa l’acabat final dels altres biomes.

Assets generats amb ImageGen integrada: `flora_peces_netes.png`, `fauna_cossos_orientats.png`, `fauna_apendixs.png`; fonts i prompts a `docs/PROMPTS_ORGANISMES.md`. Verificat en Godot 4.7.2: importació headless, renderitzat OpenGL de dues variants per organisme i quatre instants, estabilitat de dades/identitats durant el dibuix i selecció de quatre direccions. Captures de mostra, sala, zoom d’entrada i enquadrament a `reports/organismes_*.png`; mostra ampliada i captura de sala inspeccionades. Regressió: 59 roques amb rutes/persistència i 3.066 punts de clic de minerals superats; vuit perfils renderitzats sense errors. Limitacions: animació modular inicial (no cicle complet de cos), vistes posteriors de cuirasses/espines encara necessiten poliment artístic; no s’ha executat expedició interactiva ni validat encara el clic/escaneig manual de les noves siluetes. Següent pas: revisar aquesta prova amb Albert abans d’ampliar famílies i biomes.

Àrea de clic dels jaciments corregida: comparteix el rectangle exacte del sprite i consulta l’alfa de la cel·la del mineral, incloent tota la roca visible, en lloc del petit radi al peu. Els marges transparents no capturen clics; descoberta, extracció i abast d’eina mantenen les regles existents. Imatge alfa carregada una sola vegada en memòria. Prova executada amb Godot/OpenGL: 3.066 punts opacs acceptats entre els tres minerals i zooms 0,8/3,5/8; punts fora del rectangle rebutjats. Renderitzats sense errors i proves existents superades. Pendent clic manual en partida.

Balisa desplegada amb sprite propi pixel art isomètric: suport de tres peus, metall fosc, accents taronja i emissor cian. Asset transparent `assets/sprites/balisa_desplegada.png`, generat amb ImageGen integrada (prompt a `docs/PROMPT_BALISA.md`). Substitueix el marcador provisional de balisa a la sala, amb ancoratge a terra i nearest; conserva la icona del mapa, l’abast, el desament i les regles de desplegament/recuperació. Captura OpenGL en una sala fora de l’entrada inspeccionada (`reports/balisa_desplegada_preview.png`); importació headless i renderitzat de vuit perfils sense errors. Proves existents de navegació/persistència superades. Pendent desplegar i recuperar interactivament.

Jaciments actius amb lluïssor suau pulsant del color del mineral i tres reflexos petits en creu pixel art, desfasats per sala. Es conserva íntegre el sprite de roca; el halo queda arran de terra. Efecte condicionat a la descoberta i al mineral pendent: la roca esgotada no brilla. Les fotografies ometen els reflexos animats. Godot/OpenGL ha renderitzat els tres minerals i els vuit perfils sense errors; captura de quars inspeccionada. Proves existents de navegació i persistència superades. Pendent valorar el ritme de l’animació en partida interactiva.

Correcció artística: eliminades les vetes fetes amb rectangles de dibuix. Nou atlas transparent `assets/sprites/jaciments_minerals.png`, generat amb ImageGen integrat a partir de les roques existents: ferro, quars, magnetita i roca esgotada, amb mineral dibuixat dins les esquerdes i perspectiva isomètrica. Ancoratge a terra, escala comuna i filtratge nearest; conserva jaciments i recompenses. Els fanals tornen a ser exactament quatre: es trien quatre vèrtexs maximitzant la distància mínima entre parelles (empat per suma de distàncies), 5 unitats cap endins, amb resultat en memòria cau. Substitueix la decisió anterior d’un fanal per vèrtex. Importació headless i renderitzat OpenGL dels vuit perfils sense errors; captures dels tres minerals generades, captura de quars inspeccionada amb quatre fanals separats. Proves existents de 59 roques superades. Pendent extracció interactiva. Prompt de l’asset a `docs/PROMPT_JACIMENTS.md`.

Vetes integrades sobre una roca pixel art isomètrica de l’atlas existent, substituint el jaciment poligonal provisional. Tres minerals confirmats per Albert: ferro, quars i magnetita, amb vetes esglaonades de colors diferenciats. Només els jaciments reals mostren veta i desapareix en extreure-la; la roca continua al lloc. La variant decorativa amb cristalls queda exclosa de les roques ordinàries per evitar falsos jaciments. Es mantenen posicions, interacció, recompenses i descoberta. Godot 4.7.2: vuit perfils renderitzats sense errors i proves de navegació/persistència existents superades; captura d’entrada inspeccionada. Pendent inspecció interactiva de quars i magnetita i extracció.

Fanals de sala situats a cada cantonada del contorn procedural, amb el peu 5 unitats cap a l’interior perquè reposi al paviment. Substitueix els quatre fanals anteriors desplaçats cap al centre i s’aplica a tots els biomes amb les mateixes regles d’il·luminació. Godot 4.7.2: renderitzats els vuit perfils sense errors; captura de la sala d’entrada inspeccionada amb els fanals al perímetre. Proves existents de navegació i persistència de les 59 roques superades. Pendent revisió interactiva durant l’exploració.

Desactivades totes les fitxes flotants de sala en vista isomètrica. Passar el cursor per una sala visible actualitza la fitxa lateral; en sortir-ne torna a la sala seleccionada. Al mapa es manté la fitxa flotant. Llums de galeria desplaçades 4,5 unitats cap a l’eix (limitat a la meitat de la semiamplada) perquè la carcassa quedi dins del paviment, mantenint l’orientació local. Captura sala+galeria inspeccionada amb llums interiors; renderitzats vuit perfils sense errors i proves de les 59 roques superades. Pendent prova interactiva del cursor.

La informació detallada de sala s’ha mogut del centre superior a una fitxa lateral dreta sota «Opcions»: capçalera amb número de sala, percentatge destacat, barra de progrés i llista d’escaneig, galeries, troballes i accessos. La columna incorpora la fitxa en el càlcul d’escala per evitar la barra d’equip; s’oculta a la superfície, al mapa i quan es travessa una galeria. La zona superior recupera l’espai de càmera anterior. Captura OpenGL inspeccionada amb la fitxa a la posició sol·licitada, renderitzats vuit perfils sense errors en Godot 4.7.2 i comprovacions de les 59 roques superades. Pendent revisió interactiva en resolucions més petites i sales amb totes les categories.

Les llums planes de les galeries s’orienten segons la tangent local de cada tram. La planta del llum gira en coordenades lògiques abans de projectar-la en isomètric, de manera que segueix la corba i l’aplanament del terra. Captura OpenGL sala+galeria regenerada i inspeccionada; Godot 4.7.2 sense errors i proves de navegació/persistència de les 59 roques superades. Pendent revisió interactiva en galeries amb altres orientacions.

Distribució de roques revisada (`rock_spacing_version=2`): mostreig de tota la caixa del contorn, menys agrupacions i separació mínima proporcional al radi, incloent obstacles previs. Reserva central més àmplia. Els desaments antics recuperen les cel·les ocupades pels registres de decoració v1 abans de redistribuir una vegada; es mantenen les exclusions de jugador i ruta activa. Resum superior isomètric ampliat amb tasques, escaneig, galeries, troballes i accessos, compartint les mateixes dades que la fitxa de cursor. S’organitza en tres files; la fitxa flotant de la sala activa s’oculta per no duplicar-les. No mostra tasques desconegudes en sales sense escanejar.

Llums pixel art integrades a tots els biomes: fanals industrials a les sales (`fanals.png`) i llums planes arran de terra a les galeries (`llum_galeria.png`), sense pals. Els quatre fanals es reparteixen prop dels marges, inclosa l’entrada, i conserven la il·luminació i les regles de descoberta existents. Verificació Godot 4.7.2/OpenGL: migració de roques estable, 59 bloquejos/rutes alternatives i persistència comprovats; renderitzats els vuit perfils sense errors i inspeccionada captura de sales i galeria amb les dues classes de llum i resum superior. Pendent expedició interactiva i revisió en diverses resolucions.

Corregit l’ancoratge de formacions: estalagmites exactament al terra projectat (`foot`), també a les parets davanteres; estalactites a la vora superior de la cara. Retirat el desplaçament interior del 12% que les separava dels extrems. Captura OpenGL oxidada inspeccionada, renderitzats els vuit perfils sense errors i proves de les 81 roques sòlides superades. Pendent revisió interactiva.

Retirats els sprites de pedres col·locats damunt el coronament: semblaven objectes solts sobre la paret. Les formacions penjants i de peu ara s’endinsen un 12% dins la cara de roca. Eliminat el contorn de color de sales en vista isomètrica, inclòs el ressaltat en passar-hi el cursor; el mapa superior conserva els contorns. Captura OpenGL regenerada i inspeccionada sense pedres al coronament ni marc cian; renderitzats els vuit perfils sense errors i comprovacions de les 81 roques sòlides superades. Pendent comprovació interactiva.

Estalactites i estalagmites a les cares de paret de sales i galeries, amb atlas pixel art de quatre variants penjants i quatre de terra (`formacions_gruta.png`). Color interpolat entre roca mitjana i clara del bioma actual, mida limitada per l’alçada de la cara i distribució estable segons coordenades/llavor. S’ancoren al coronament o al peu de la paret, fora de les boques ja retallades i sense modificar terra transitable. Importació i captures OpenGL dels vuit perfils amb Godot 4.7.2 sense errors; inspeccionada la sala oxidada. Les comprovacions de les 81 roques sòlides continuen passant. Pendent revisió visual en moviment i de la resta de perfils.

Primera passada de parets amb volum orgànic segons la referència: perfil d’alçada irregular continu i estable per coordenades/llavor, cares de roca amb recessos foscos, coronament amb gruix, fragments pixel art i ombra de contacte. El mateix renderer segueix sales i galeries, amb 17 unitats orientatives al fons i 7 al davant i variacions locals; conserva els colors del bioma i les boques obertes. No altera màscares ni navegació. Captures OpenGL de sala i sala+galeria inspeccionades després de suavitzar una primera vora massa dentada; renderitzats vuit perfils sense errors en Godot 4.7.2. Les 81 comprovacions de col·lisió, ruta alternativa i persistència continuen passant. Acabat encara provisional respecte de la referència; pendent revisió en moviment, boira i diversos angles de galeria.

Decisió visual: completar una sala només en canvia el color al mapa superior. La vista isomètrica conserva el material i el contorn del bioma, sense tint verd de completada; es mantenen els indicadors de progrés i l’estrella.

Corregida la visibilitat de parets: cares texturades de 10 unitats al darrere i 5 al davant, amb coronament i contrast segons bioma. Les galeries ara dibuixen també cares de roca (abans només línies); els segments es retallen contra els contorns de les sales per mantenir les boques obertes, i els trams parcials conserven el degradat. Captura OpenGL `reports/parets_sala_galeria.png` inspeccionada amb dues sales connectades: textura i relleu visibles als dos tipus de paret. Godot 4.7.2 sense errors; les 81 comprovacions de bloqueig, desviament i serialització de roques tornen a passar. Pendent revisió interactiva amb moviment i boira parcial.

Roques sòlides i parets de gruta: s’han incorporat vuit siluetes pixel art addicionals (`roques_variants.png`), tenyides segons la paleta de cada bioma i combinades amb l’atlas de roques pròpies. Les roques decoratives anteriors es reemplacen per registres `world.solid_room_rocks_v1`, materialitzats una vegada i persistits amb el món, que bloquegen cel·les de la màscara real. Només s’ocupen cel·les amb anell obert de vuit veïnes, mantenint substitució de rutes al voltant; es reserven accessos, troballes, base, jugador i trajecte actiu en migrar un desament. Els obstacles ja existents també es representen amb variants pixel art. Parets amb textura `paret_gruta.png` tenyida per bioma, alçada de 3 unitats projectades i menys alçada al davant; les obertures de les galeries es conserven.

Verificació amb Godot 4.7.2/OpenGL: 81 roques bloquegen segments, les 81 tenen ruta alternativa transitable d’un costat a l’altre i la serialització conserva registres i màscara. Captures dels vuit perfils completades sense errors; inspeccionades visualment Coves oxidades i Galeries glacials (mateixa geometria de prova, canvi de perfil visual). No s’ha fet expedició interactiva ni bateria multillavor d’aquesta migració. Següent pas: revisar lectura i col·lisions durant moviment real i validar els altres perfils visualment.

La decoració de sales ara utilitza sprites pixel art isomètrics aprovats, sense plaques metàl·liques (`assets/sprites/roques_biomes.png`, atlas 4×2 amb vuit perfils). Inclou agrupacions de roca, grava i fragments minerals; distribució i escala variades per llavor, sense rotacions que trenquin la perspectiva. Substitueix les formes geomètriques provisionals afegides abans. Ancoratge al 78% de cada cel·la, separació entre agrupacions, marges al contorn i reserves per a accessos, base i troballes. Captura OpenGL de Coves oxidades regenerada i inspeccionada amb Godot 4.7.2 sense errors. Pendent inspeccionar visualment els set perfils restants i la lectura en moviment.

Decoració procedural comuna a tots els biomes: pedres petites amb relleu, fissures angulars i variants minerals (fragments cristal·lins/glacials, crostes minerals als biomes verd i violeta, vetes càlides geotèrmiques). Quantitat proporcional al radi, intents acotats i distribució estable per llavor/sala. Respecta contorn, descoberta, accessos, petjada de base i posicions de troballes. Són detalls visuals sense col·lisió ni recompenses. Godot 4.7.2 OpenGL ha generat una captura de Coves oxidades sense errors, inspeccionada; pendent inspecció artística dels altres biomes i expedició interactiva.

Les galeries de Coves oxidades comparteixen ara la textura pixel art de les sales, amb el mateix període de 32 unitats i UV ancorades al món. Es conserva el degradat de visibilitat dels trams parcials. Importació/editor headless amb Godot 4.7.2 completada sense errors (sortida 0); pendent inspecció visual d’una galeria en partida.

Base de Coves oxidades integrada arran del terra: nova variant `assets/sprites/base_coves_oxidades_arran_terra.png` sense plataforma de roca ni vora vertical de diorama. Ancoratge del sprite ajustat al contacte del suport frontal (88% de l’alçada del PNG). L’original es conserva. Importació i captura OpenGL amb Godot 4.7.2 completades sense errors; captura inspeccionada amb edifici recolzat directament al paviment, sense plataforma ni halo blanc. Pendent revisió interactiva en la partida d’Albert.

Reajustada l’escala del paviment oxidat: cada mosaic ocupa 32 unitats del món (abans 96), amb pedres tres vegades més petites per acostar-les a les del peu de la base. La mida de repetició és constant en totes les sales i amb qualsevol zoom. Captura OpenGL de Godot 4.7.2 regenerada i inspeccionada a `reports/terra_pixelart_preview.png`, sense errors; pendent validació artística d’Albert en la partida.

Terra pixel art integrat a les sales de Coves oxidades (1–3), amb un període fix de 96 unitats del món per mosaic. Corregida la causa de les franges: el mode de repetició del CanvasItem es restaurava abans de renderitzar les ordres de dibuix; ara queda activat des de `_ready`. Eliminats els detalls plans de roca superposats en aquest bioma. Les galeries mantenen el seu material. Captura real OpenGL amb Godot 4.7.2 inspeccionada a `reports/terra_pixelart_preview.png`: la roca cobreix la sala sense franges ni estirament. El visor `scripts/floor_preview.gd` genera la captura sense carregar ni escriure perfils. No s’ha fet una expedició interactiva; queda revisar la repetició del mosaic en més sales i ajustar-ne el contrast si cal.

La col·locació de bases també cerca escales menors en sales de desaments antics i comprova que el rectangle projectat del sprite no tapi l’ascensor. Abans es podia retornar una petjada buida i ocultar la base. Inici headless de quatre fotogrames amb Godot 4.7.2 completat amb sortida 0 i sense errors; pendent confirmar visualment la partida afectada.

Corregit l’error de parseig a `_biome_base_footprint`: els factors dels bucles són `float` i l’ancoratge és `Vector2` explícit. Verificat amb Godot 4.7.2 esperant la finalització real del procés: importació/editor headless i inici de l’escena durant quatre fotogrames, tots dos amb sortida 0 i sense errors. Les comprovacions anteriors que només mostraven la capçalera de Godot no acreditaven el parseig complet. La inspecció visual continua pendent.

La textura generada de roca oxidada es descarta: a escala de partida produïa blocs grans i no encaixava amb el terra. El nivell 1 torna al material procedural de soroll i detalls de roca existent. Pendent dissenyar un material pixel art amb escala comprovada en joc.

La sala d’entrada del nivell 1 usa com a prova el sprite de la base de Coves oxidades, amb filtre de veí més proper. La petjada de col·locació ara cobreix la mida mundial del sprite i reserva un marge mínim a l’ascensor. Els generadors de les primeres sales dels biomes (nivells 1, 4, 7, 10, 13, 16 i 19) imposen un radi mínim a l’entrada perquè hi càpiga la base. La versió del generador ha pujat a p0b-5. Asset: `assets/sprites/base_coves_oxidades.png`. Pendent verificar diverses llavors i inspecció visual interactiva.

La base de bioma manté una silueta reutilitzable amb carcassa fosca facetada, porta emmarcada, finestra de servei, antena i llums en blocs nítids. Els accents i els panells varien segons el perfil de profunditat. La petjada continua dins del contorn procedural i deixa més separació respecte de l’accés a l’ascensor; tots els punts es projecten amb la transformació de la sala. Godot 4.7.2 ha carregat el projecte en mode editor headless i ha iniciat l’escena en mode headless sense errors. Queda pendent la inspecció visual interactiva de les sales d’entrada −1 i −4 i dels dos zooms: la finestra de Codex ha tapat la partida activa durant aquesta sessió.

Els mòduls de les bases de bioma comparteixen la projecció 2D del terra. La planta es col·loca dins el contorn de la sala i les portes, finestres i llums segueixen les cares del mòdul. Una prova amb Godot i OpenGL ha comprovat la planta dins la sala del −4 i l’accés a Equip i millores.

Les bases de bioma tenen un mòdul construït a la sala d’entrada i una icona d’edifici. La fitxa i la navegació mostren «Base – nom del bioma». Una prova amb Godot i OpenGL ha comprovat el renderitzat de la sala d’entrada del −4, el nom al diàleg i l’accés a Equip i millores.

La vista isomètrica realça la sala ocupada i comparteix amb el mapa la fitxa de sala en passar-hi el cursor. Les sales completes tenen una estrella i terra verdós. Els resums marquen pujada, baixada i taller, i Opcions permet desactivar les ones sense ocultar els cercles de cobertura. Una prova amb Godot i OpenGL ha comprovat la detecció de la sala en totes dues vistes i la restauració de la preferència d’ones.

Els trajectes automàtics cap a tallers, base i accessos utilitzen galeries completades. Els trams parcials es dibuixen sobre l’eix de la galeria procedural, inclosos els traços de desaments anteriors. S’ha comprovat la projecció d’un traç esglaonat i el retorn al taller del −4 amb Godot.

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

## Clic sobre les roques amb veta — 20/11/2026

El jaciment accepta el clic dins la silueta exterior de la roca, incloses les esquerdes entre lloses. La silueta es calcula una vegada per mineral i queda en memòria; els marges transparents de l’atles continuen exclosos. El jaciment té prioritat sobre l’ascensor quan se superposen les àrees de clic. Si falta il·luminació per extreure, es mostra un avís explícit. Es conserven els requisits de capçal, estat d’extracció i descoberta; les roques decoratives no es converteixen en jaciments.

Verificació: `scripts/mineral_click_check.gd`, Godot 4.7.2 headless, 27 punts interiors entre els tres minerals i tres zooms, rebuig del marge transparent i clic simulat sobre una veta superposada a l’ascensor. Prova superada. No s’ha fet una inspecció visual interactiva de la partida de la captura; pendent confirmar-hi el cas concret.

## Panells amb acabat pixel art — 20/11/2026

Primera passada integrada del marc visual del HUD: panells laterals, fila d’equip, targetes d’inventari/taller i botons compartits amb vores rectes, bisell metàl·lic, reblons de píxel i accents cian/taronja. Indicadors sense extrems arrodonits. Càmera i tub de mostra amb glifs dibuixats en graella de píxels. Es conserva la tipografia llegible i la distribució adaptable; les altres icones d’equip encara mantenen el dibuix anterior i les finestres natives no tenen una pell completa pròpia.

Verificat: execució Godot 4.7.2 amb OpenGL i captures reals a 1440×900, 1920×1080 i 1024×768 (`scripts/ui_preview.gd`), sense errors. Inspecció de les captures del conjunt i de la fila d’equip. La prova comprova també que dibuixar no canvia el món i que el clic de l’ascensor i el retorn conserven la geometria. No és una partida manual; queda pendent completar les altres icones i estats de totes les finestres segons aquesta mateixa direcció.

### Revisió del HUD a partir de la referència de menús

Es conserva l’organització actual dels menús. La pell compartida passa a fons negre blavós, marcs amb cantonades realment retallades en esglaons, línies cian i accents taronja i ornaments petits inspirats en la referència aportada. Botons d’acció foscos amb text clar i ressalt taronja en passar-hi el ratolí o prémer. El fons dels botons es dibuixa en un Control darrere del text i ignora el ratolí. No s’han afegit les pestanyes ni la distribució de la imatge de referència.

Verificat amb `scripts/ui_preview.gd`: renderitzat OpenGL a tres resolucions sense errors, inspecció de captura a 1440×900 i comprovació automatitzada de conservació del món i accés de l’ascensor. No és una prova manual completa de tots els menús. Les finestres natives i algunes icones continuen pendents d’una passada específica.

### Retorn al format anterior dels panells — 20/11/2026

Per petició d’Albert es retiren les dues passades de format pixel art del HUD. Es recuperen els fons, vores arrodonides, botons, indicadors i icones de càmera/mostra anteriors. Es conserven la distribució i totes les altres millores del joc, inclosa la correcció del clic als jaciments. Les dues entrades anteriors sobre la pell pixel art queden com a historial d’una proposta descartada.

Verificat amb Godot/OpenGL i `scripts/ui_preview.gd` a tres resolucions, sense errors; inspeccionada la captura de la fila d’equip restaurada. No s’ha fet una partida manual.

### Il·lustracions de les targetes de recursos — 20/11/2026

Només les quatre targetes de RECURSOS incorporen il·lustració: ferro, quars i magnetita reutilitzen les roques amb veta de l’atles del joc, amb filtratge nearest; punts de recerca utilitza un exemplar de flora pixel art com a símbol de recerca. Es manté el marc anterior, els títols, els comptadors i la resta del HUD. Les il·lustracions són estàtiques i decoratives, no consulten ni revelen espècies de la partida. S’aprofita l’espai del peu buit sense augmentar l’alçada de la barra.

Verificat amb renderitzat Godot/OpenGL a 1440×900, 1920×1080 i 1024×768 sense errors i inspecció de la captura de la barra. La prova conserva dades del món i funcionament de l’accés. No és una partida manual.

### Recursos ampliats i microscopi de recerca — 20/11/2026

Les roques de les tres targetes de minerals ocupen ara l’amplada disponible i fins a 52 píxels lògics d’alçada. L’enquadrament ignora els píxels d’alfa gairebé invisible dels marges de l’atles; es calcula una sola vegada per mineral. Les il·lustracions disposen de 56 píxels lògics sense ampliar l’alçada de la barra. Els punts de recerca substitueixen la planta per un microscopi isomètric pixel art transparent, amb metall fosc i accents cian/taronja. Recurs: `assets/sprites/microscopi_recerca.png`; prompt i eina integrada documentats a `docs/PROMPT_ICONA_LABORATORI.md`.

Verificat: importació headless sense errors i renderitzat OpenGL a tres resolucions amb `scripts/ui_preview.gd`, sense errors; inspecció de la captura de la barra d’equip final. No s’ha fet una partida manual. No es modifica cap saldo, geometria ni mecànica.

### Marcs d’inventari segons la referència de botons — 20/11/2026

A petició d’Albert, les targetes de la barra inferior i les targetes compartides d’inventari/taller tenen ara marc metàl·lic amb cantonades retallades en passos de dos píxels, diversos nivells de bisell clar/fosc i fons gairebé negre. Els tres grups de la barra tenen un marc exterior amb accent coure/taronja. Els estats d’acció en curs i del llum del casc utilitzen el ressalt taronja. Es mantenen ordre, textos, comptadors, indicadors, il·lustracions i mida de les targetes; no s’han copiat les dreceres ni la distribució de la referència. Els marcs són dibuix 2D sense antialiàsing i no capturen el ratolí.

Verificat amb `scripts/ui_preview.gd`: renderitzat OpenGL a tres resolucions, sense errors, i inspecció de la captura de la barra inferior. Es conserva la comprovació del món i l’accés de l’ascensor. Pendent prova manual dels estats actius en partida.

### Flora i fauna lligades al zoom del món — 20/11/2026

L’escala dels organismes isomètrics és ara lineal amb `zoom_level`, conservant la mida acordada al zoom 3,5 i eliminant el límit superior heretat de l’escala dels marcadors. Plantes i animals s’amplien i s’allunyen proporcionalment al terreny. Les àrees de clic i l’enquadrament de les fotos ja comparteixen aquesta funció i segueixen la nova mida. Els elements del HUD conserven l’escala pròpia.

Verificat amb `scripts/organism_zoom_check.gd`, Godot/OpenGL: sis zooms de 0,28 a 8, escala i rectangles de clic proporcionals, dades i posicions del món invariants; captures a 1,75, 3,5 i 7, inspeccionada la de 7. No s’ha fet una partida manual.

### Microscopi llegible a mida de HUD — 20/11/2026

Substituïda la il·lustració detallada del microscopi per una versió pixel art simplificada, de silueta clara: braç platejat, ocular curt, un objectiu, platina cian i peu ample. Recurs actiu `assets/sprites/microscopi_recerca_llegible.png`; es conserva l’original. Mateix enquadrament, filtratge nearest i dimensions de targeta. Prompt de l’edició amb image_gen integrat registrat a `docs/PROMPT_ICONA_LABORATORI.md`.

Verificat: importació headless sense errors; renderitzat OpenGL del HUD a 1440×900, 1920×1080 i 1024×768 amb `scripts/ui_preview.gd`, sense errors. Inspeccionats retalls a mida real del grup de recursos a 1920 i 1024 (`reports/recursos_hud_*.png`). La lectura del símbol millora sense ampliar el panell. No s’ha fet una partida manual.

### Registre de sala i correcció de l’escalat del microscopi — 20/11/2026

L’estat de la sala inferior dret adopta la composició de registre de la referència: fons gairebé negre, marc retallat, títol REGISTRE D’EXPEDICIÓ, separador cian i files amb marca verda per a les tasques fetes o indicador buit per a les altres entrades. Es mantenen sala, percentatge, progrés i tota la informació anterior. Les files només es reconstrueixen quan en canvia el contingut.

Es recupera `microscopi_recerca.png`, el disseny original que Albert vol conservar. La versió simplificada deixa d’utilitzar-se. La integració redueix l’original una sola vegada a 52 píxels lògics d’alçada amb Lanczos i conserva aquesta textura en memòria: evita seleccionar directament píxels dispersos de l’original gran en cada dibuix. El HUD conserva mida i posició.

Verificat: Godot/OpenGL sense errors, captures del HUD a tres resolucions i captura de sala amb `organism_zoom_check.gd`; inspeccionats `reports/registre_sala.png` i `reports/recursos_hud_1920x1080.png`. No és una partida manual ni una inspecció de totes les combinacions de tasques.

### Unió de parets a les galeries completes — 20/11/2026

Corregit un cas de retall ambigu: la ruta completa acabava exactament al contorn de la sala i el polígon d’obertura podia conservar un tram de paret al mig del pas. El retall s’estén ara 10 unitats dins de les dues sales, sense modificar la ruta, el terra ni la navegació. Una galeria dibuixada completa obre també la boca de destinació encara que el marcador de sortida d’aquella sala no estigui registrat. L’estat de descoberta no es modifica.

Verificat amb `wall_openings_check.gd`: obertura exacta, cantonada, paret tancada i nou cas de galeria que acaba al límit de la sala. Proves superades. `wall_openings_preview.gd` renderitza una sala amb sis connexions en estat parcial i complet, sense errors i amb el món invariant; inspeccionada la captura completa. No s’ha reproduït la llavor ni la posició exactes de la captura d’Albert ni s’ha fet una partida manual.

### Segona revisió del clic als jaciments — 20/11/2026

La detecció del clic deixa de limitar-se a `selected_cave`: recorre les mateixes sales elegibles per al dibuix, en ordre invers de pintat, i comprova la silueta del jaciment visible. Una veta d’una altra sala respon amb un avís d’entrar-hi abans d’extreure, sense moviment ni descoberta. Si l’explorador ja és a la sala correcta però n’hi havia una altra seleccionada, selecciona la seva sala mantenint l’ancoratge visual de la càmera i inicia l’acció habitual. El clic sobre la veta es comprova abans del senyal de despreniment; si s’està retirant pedra, informa que cal acabar l’acció. Extracció i escaneig en curs deixen de rebutjar el clic silenciosament. Es conserven els requisits de llum, eina i capçal i la silueta completa del jaciment.

Verificat amb `scripts/mineral_click_check.gd`, Godot 4.7.2 headless: 27 punts de tres minerals a tres zooms, prioritat sobre l’ascensor, sala seleccionada diferent, veta veïna amb resposta sense moviment i extracció real de ferro iniciada; avisos d’extracció/escaneig en curs i quars sense capçal comprovats. Sense errors. No s’ha reproduït el jaciment concret de la partida d’Albert ni s’ha fet una prova visual interactiva.

### Panell esquerre amb format de registre — 20/11/2026

El panell principal esquerre comparteix el dibuix del registre inferior dret: fons negre blavós, contorn retallat gris cian, títol clar i separador cian. La funció del marc és compartida per mantenir coherència. Es conserva la informació, el selector de profunditat amb desplaçament, els botons i la distribució. El títol s’ajusta a l’espai anterior al botó Partida.

Verificat amb `scripts/ui_preview.gd`: renderitzat Godot/OpenGL a tres resolucions sense errors i inspecció del conjunt a 1024×768. Prova automatitzada de món invariant i ascensor superada. No s’ha fet una partida manual.

### Text net als dos panells laterals — 20/11/2026

El HUD deixa d’heretar el filtratge nearest del món: `ui_root` utilitza filtratge lineal i una còpia de la font integrada amb renderitzat MSDF, que manté els contorns del text quan els panells s’escalen. S’aplica al panell esquerre, als de la dreta, al registre i a la resta de Controls del HUD. Les il·lustracions de recursos mantenen el seu filtratge nearest explícit i el món pixel art no canvia. Es conserven contingut i distribució.

Verificat amb Godot/OpenGL: captures a tres resolucions (`ui_preview.gd`) i registre en sala (`organism_zoom_check.gd`), sense errors. Inspeccionat el conjunt a 1440×900. No s’ha fet una partida manual a la resolució exacta de la captura d’Albert.

### Format compartit per a llegenda, inventari i finestres — 20/11/2026

S’estén el marc del registre als panells compartits de la interfície, inclosa la llegenda, amb el recurs de nou pedaços `assets/ui/marc_registre.svg`: fons negre blavós, cantonades retallades i accents cian. El nou `scripts/interface_theme.gd` aplica la mateixa família visual i la font MSDF a les 13 finestres i menús emergents creats pel joc: inventari/taller, catàleg, partida/perfils, historial, opcions, fites, descobertes i confirmacions, entre d’altres. Pestanyes, camps i botons natius tenen paleta coherent. Les funcions i dades es conserven.

Corregida també la mida inicial de l’inventari: es recalcula després que les etiquetes amb salt de línia disposin de l’amplada definitiva; així no creix fora de pantalla durant la primera obertura.

Verificat amb Godot/OpenGL: `ui_preview.gd` a tres resolucions sense errors; `interface_theme_preview.gd` comprova tema i font de 13 finestres, captura inventari, taller, catàleg, opcions i confirmació i verifica que el món no canvia. Inspeccionats inventari, taller i confirmació. La prova és automatitzada, no una partida manual ni una inspecció exhaustiva de totes les finestres.

### Profunditat dels objectes i petjada física de les roques — 20/11/2026

La vista isomètrica deixa de pintar sempre el jugador al final. Parets de sala, roques, obstacles, jaciments, flora, fauna, fanals i mòduls s’ordenen pel punt de contacte amb el terra (coordenada Y del món). Això permet que una roca o un fanal situats davant ocultin les parts corresponents del jugador o d’un organisme. El terra continua en una capa separada; els fanals de sala es dibuixen individualment dins l’ordre de profunditat i conserven els halos agrupats. Els trams de paret mantenen geometria en memòria, amb límit de 4096 grups.

Les roques decoratives tenien una amplada visual superior a l’única cel·la que bloquejaven. Una migració idempotent, sense canviar-ne la posició, amplia la petjada a tres cel·les horitzontals quan hi ha un anell transitable que garanteix un desviament, evitant l’explorador i el camí actiu. Si l’ampliació no és segura, el dibuix s’ajusta a la petjada existent. Les cel·les bloquejades es guarden amb la roca i les dues vistes continuen compartint la màscara. No es canvien espècies, recompenses ni identitats. No s’ha afegit col·lisió a flora/fauna.

Verificat amb Godot/OpenGL: `depth_sort_preview.gd` comprova ordre davant/darrere, migració estable, 53 roques ampliades amb desviaments assolibles i captures amb el jugador darrere/davant d’una roca. Inspeccionada la captura amb el jugador ocult per la roca. `floor_preview.gd` verifica 59 obstacles, persistència i desviaments, 3066 punts clicables dels minerals i renderitzat dels altres set perfils de bioma. Aquesta bateria ha detectat un marge de píxel fora de l’embolcall de clic dels jaciments: s’han inclòs les quatre cantonades dels píxels extrems i la prova passa. `organism_zoom_check.gd` passa sense canviar el món amb el zoom. Benchmark: dibuix CPU mitjà 5,45 ms en vista local amb tot conegut i 13,58 ms amb tot enquadrat, 12 fotogrames de prova, no equival a FPS totals. No s’ha reproduït la partida exacta de les captures ni s’ha fet una prova manual. L’ordenació de parets llargues es fa per tram; no hi ha intersecció geomètrica per píxel entre sprites i parets.

### Despreniments pixel art, fauna i jaciments separats — 20/11/2026

Els despreniments de galeria reutilitzen els sprites de roca del bioma, amb tres peces variades i pols en petits píxels. Es conserven el bloqueig, el temps i el clic de retirada anteriors. Al mapa segueixen com a marcador petit.

La fauna substitueix la interpolació recta de la patrulla per un recorregut AStarGrid2D dins la sala, sobre la màscara compartida i amb marge de set unitats per al cos. Evita obstacles i jaciments. La ruta es calcula una vegada i queda en memòria fora de les dades desades; conserva espècie, identitat, velocitat i pauses. Si no hi ha connexió segura, es queda al punt segur inicial. No es modifica la màscara de navegació ni l’estat de descoberta per fer la patrulla.

Els jaciments amb espai insuficient respecte a roques, parets o organismes busquen una ubicació propera lliure mitjançant un màxim de 128 candidats dins la mateixa sala. La correcció es desa a `material_sites`, conserva mineral, identitat de sala i estat d’extracció i no s’executa durant una extracció activa. Si la sala no és completa, no trasllada una veta ja revelada a terreny desconegut. Si no troba lloc, conserva la posició anterior.

La pulsació del botó de reserva d’oxigen només s’activa al 10% o menys, en lloc de destacar qualsevol reserva utilitzable. L’ús manual continua disponible amb càrrega més alta.

Verificat amb `fauna_collision_check.gd`, Godot/OpenGL: 800 posicions temporals de fauna sense col·lisió, reparació d’un solapament de jaciment forçat i estabilitat de la correcció, absència de pulsació al 91% i presència al 10%, captura real del despreniment pixel art inspeccionada. `mineral_click_check.gd` també passa. Sense errors. No s’ha reproduït la partida exacta de les captures ni s’ha fet una prova manual.

### Cavernes cristal·lines amb el mateix sistema d’acabat — 20/11/2026

El bioma dels estrats 4–6 utilitza ara una textura de paviment pixel art pròpia, violeta i mineral, a les sales i galeries. Comparteix el període de 32 unitats del paviment oxidat, les coordenades UV mundials i la projecció, sense estirar-la per sala. La base d’entrada del −4 substitueix el polígon provisional per una variant pixel art del mòdul aprovat, amb carcassa fosca, accents ametista, finestra cian i el mateix ancoratge a terra. Parets, fanals, explorador, organismes, navegació i descoberta continuen utilitzant els sistemes compartits. Es corregeix també el subtítol del panell esquerre que estava fixat a «Coves oxidades».

L’escala no té integritat ni desgast reparable: el botó existent es reanomena «Reposa usos» i l’avís diu «Usos de l’escala reposats». Es manté el consum d’usos en habilitar accessos i la reposició a taller; no s’ha fet l’escala il·limitada ni s’han canviat costos.

Verificat amb Godot 4.7.2: importació headless sense errors i `crystalline_preview.gd` amb generació real dels estrats 4, 5 i 6, captures OpenGL i comprovació que dibuixar no canvia geometria, llocs ni descoberta. Verificats material, període UV, petjada de la base, nom del bioma i text de l’escala. Inspeccionades les captures del −4 i d’enquadrament. No s’ha fet una partida manual ni s’ha revisat tota la campanya. Els biomes posteriors encara tenen paviment procedural provisional i les seves bases pendents d’aquesta passada artística. Prompts i recursos a `docs/PROMPTS_CAVERNES_CRISTALLINES.md`.

### Acabat pixel art a tots els biomes i zones finals — 20/11/2026

Completada la passada de paviment i mòdul de base als perfils 7, 10, 13, 16 i 19: glaç i roca blava, basalt amb molsa, fractures fosques amb brases, roca abissal violeta i mineral bronze del Llindar. El Nucli té paviment propi de roca teal amb vetes turquesa; conserva la seva estructura final sense crear-hi cap taller o base addicional. Les bases mantenen porta, finestra, antena, perspectiva i mida visual coherent amb el mòdul oxidat/cristal·lí.

S’integren dos atles nous de 3×2 cel·les: `assets/textures/terres_biomes_atlas.png` i `assets/sprites/bases_biomes_atlas.png`. Cada material de terra s’extreu una sola vegada a una textura independent i es comparteix entre totes les sales i galeries del perfil. Tots els paviments mantenen període UV de 32 unitats, amb filtratge nearest i coordenades mundials. Els mòduls utilitzen regions d’atles amb mida i punt de contacte ajustats; no s’altera la petjada lògica ni la navegació. Parets, llums, organismes, col·lisions, eines i descoberta continuen utilitzant el codi compartit.

La prova de campanya ha detectat i corregit un error preexistent de cobertura: les projeccions de dues boques sobre una ruta sinuosa podien quedar en ordre invers i produir un `slice` invàlid. Ara s’ordenen les projeccions abans de comprovar els trams, incloent-hi el cas d’un mateix segment.

Verificat amb `scripts/all_biomes_preview.gd`, Godot/OpenGL: generació real dels 20 estrats, vuit materials de bioma compartits, període UV, mòdul i petjada de cada entrada amb base, absència de taller nou al Nucli i dades del món invariants durant el renderitzat. Captures d’entrada i enquadrament dels vuit perfils; resum renderitzat `reports/biomes_pixel_art_resum.png` inspeccionat. Segona execució completa sense errors. No s’ha fet una partida manual a cadascun dels 20 estrats ni una inspecció de totes les sales possibles. Prompts i recursos documentats a `docs/PROMPTS_BIOMES_RESTANTS.md`. La nota anterior sobre paviments i bases pendents dels biomes posteriors queda superada per aquesta fita.

### Escaneig en panell, despreniments i retorn a la base del bioma — 20/11/2026

Retirat el cercle violeta darrere de la icona de fauna del resum de sala. També desapareix el cercle central dels despreniments. La pila passa de tres a nou roques pixel art i durant els primers cinc segons hi ha quatre fragments petits en caiguda; es conserven els avisos de perill a les boques i les mecàniques de retirada.

L’escaneig actiu de flora/fauna es mostra amb un panell fosc retallat, títol ESCANEJANT..., barra cian i percentatge, a mida de lectura fixa respecte al zoom. La mineria reutilitza el mateix format amb EXTRAENT... i accent ambre. Els organismes ja analitzats deixen de tenir el 100% flotant permanent. La captura de descoberta continua ocultant els indicadors.

Nou botó «Base del bioma» a la barra de navegació subterrània. Utilitza el flux existent de ruta coneguda i confirmació per tornar al taller inicial del bioma actual; al Nucli la base de retorn és la del Llindar, sense crear cap taller al nivell final. No teletransporta ni revela rutes, i es desactiva durant accions incompatibles. Es manté l’opció de pujar un estrat.

Verificat amb Godot/OpenGL: `scan_base_ui_preview.gd` comprova destinació als 20 estrats, confirmació de ruta a la base cristal·lina sense moure l’explorador i captura de la barra d’escaneig inspeccionada. `fauna_collision_check.gd` passa amb 800 posicions, verificacions de jaciments/oxigen i captura del despreniment nou. Sense errors. No s’ha fet una partida manual ni s’ha recorregut automàticament una ruta entre tots els biomes.

### Fanals, identitat de roca, patrulles i clic de base — 20/11/2026

Els quatre fanals continuen separats als extrems de la sala però ara busquen un punt interior amb almenys deu unitats de marge respecte al contorn. Les parets es divideixen en trams curts per ordenar-ne correctament l’oclusió a l’escala local: un tram diagonal llarg ja no tapa el cap d’un fanal situat dins la sala. Els trams consecutius sense objectes intercalats es dibuixen agrupats i l’enquadrament llunyà utilitza menys subdivisions.

Fora del bioma oxidat, la majoria de variants de roca reutilitzen el recurs específic del bioma (cristalls, gel, molsa, geotermia, etc.) i les variants neutres tenen tint més marcat. Les parets de galeria passen pel mateix ordre de profunditat i il·luminació que les de sala; la clau de memòria cau de les parets incorpora el perfil del bioma.

La patrulla de fauna explora les connexions realment transitables, comprovant el marge del cos a tot el segment, i tria un destí alternatiu assolible si el previst queda bloquejat. Ja no es descarta tota la ruta per un segment invàlid. Si el component transitable només conté un punt, continua aturada per seguretat.

Clicar el cos del mòdul de base obre la pestanya «Equip i millores» quan l’explorador és a la sala del taller. Des d’una altra sala mostra un avís de tornar-hi; no teletransporta ni obre un taller desconegut.

Verificat: `biome_detail_check.gd`, Godot/OpenGL, set animals del nivell cristal·lí mostrant desplaçament i sense travessar obstacles durant 160 mostres per animal; quatre ancoratges de fanal interiors; clic de base que obre la pestanya 1 sense moure l’explorador. Captura del fanal posterior inspeccionada, amb el cap visible davant la paret. `all_biomes_preview.gd` torna a passar els 20 estrats sense errors; `wall_openings_check.gd` i `fauna_collision_check.gd` també passen. Benchmark final: dibuix CPU aproximat de 4,54 ms en vista local amb tot conegut i 22,66 ms amb tot enquadrat, 12 fotogrames; no són FPS totals. No s’ha fet una partida manual ni s’ha reproduït la llavor exacta de les captures d’Albert.

### Basses, feix del casc, llum comuna i boira de descoberta — 20/11/2026

Afegides depressions poc profundes amb basses i esquerdes en pixel art per als vuit perfils. La col·locació és determinista per llavor i sala, dins el contorn i separada de roques i elements principals, amb intents acotats i cache de representació. Són detalls visuals transitables: no afegeixen llacs profunds, dany ni obstacles nous. Comparteixen la projecció del terra i no alteren dades ni rutes. Recurs i prompts a `docs/PROMPTS_BASSES_BIOMES.md`.

Nova capa 2D d’il·luminació compartida, posterior als objectes i anterior al HUD (`scripts/cave_lighting.gd`, `shaders/cave_lighting.gdshader`). El casc emet un feix cian que segueix la direcció, amb origen a l’alçada del casc i atenuació de distància. Fanals, galeries completes i basses aporten llum local, amb un màxim de 32 fonts visibles i fluctuació subtil. El terra ja no es construeix per cel·les revelades: es dibuixa el material continu i una boira en pantalla consulta una textura de la descoberta existent, amb transició suavitzada i moviment lent. Les sales escanejades inclouen l’extrusió coneguda de les parets a la màscara visual. El personatge conegut no queda retallat pel límit de boira del seu casc.

Corregida la llegenda: els renderitzadors modulars de flora i fauna reiniciaven una transformació comuna i desplaçaven les icones següents. Ara cada fila utilitza coordenades absolutes i restableix la transformació. La flora, fauna, mineral i rastres tornen a correspondre als seus textos.

Verificat: importació headless i `environment_preview.gd` amb renderitzat OpenGL, captures amb feix encès/apagat i boira parcial; dues basses estables a la sala de prova; geometria, posicions, jaciments i descoberta invariants durant el dibuix. Inspeccionades les captures de llum i boira i la llegenda. `all_biomes_preview.gd` ha recorregut de nou els 20 estrats amb els efectes actius sense errors. No s’ha fet una partida manual ni una mesura de FPS/GPU de la nova capa. L’efecte no projecta ombres físiques de cada roca; és il·luminació 2D amb boira de descoberta, i es mantenen les comprovacions lògiques de visibilitat i ús de les eines.

### Avisos de requisits, organismes fantasma, sons i llegibilitat de la boira — 20/11/2026

Els clics rebutjats sobre jaciments mostren un avís central temporal i llegible. El quars indica eina de mineria Nv. 1 + Capçal de precisió; la magnetita, Nv. 1 + Capçal reforçat, amb la indicació de comprar/activar a Equip i millores. Aquests són els requisits reals vigents: pujar de nivell per si sol no substitueix el modificador, i no s’han afegit bloquejos de nivell inventats. Les denegacions d’escaneig indiquen aturar-se, acabar l’acció, reparar l’escàner amb el seu nivell actual o il·luminar/entrar a la sala segons el cas. El missatge llarg queda a l’avís i a la informació emergent, amb resum curt al panell esquerre per evitar solapaments.

Les espècies bloquejades pel filtre fèrric mostren una silueta genèrica tènue només a una posició revelada o dins una sala escanejada. Clicar-la explica Escàner Nv. 1 + Filtre espectral fèrric. No revela el nom, no registra l’espècie ni inicia l’escaneig; en activar el filtre, es recuperen dibuix i interacció habituals.

Nou servei `scripts/game_audio.gd`: nou timbres sintètics propis en PCM per clics, denegació, escaneig, eines/mineria/neteja, finalització, alarma, foto, serveis i llum. Volum moderat, sis veus màximes i límit de freqüència; les alarmes de vida, oxigen i bateria no es repeteixen més sovint que cada sis segons. Opcions inclou «Sons del joc» i silenciar atura les veus actives. L’opció de so és de sessió; encara no es desa al perfil. No s’hi afegeix música.

Després de la captura d’Albert, es corregeix la nova capa de boira: utilitzava coordenades físiques de pantalla per a una màscara definida en coordenades lògiques, cosa que podia desplaçar-la amb finestres escalades/HiDPI. El shader passa ara les coordenades del mateix canvas a la fragmentació. La llum ambiental puja de 0,46 a 0,72 per mantenir el terreny conegut llegible. Es conserva l’ocultació del terreny desconegut i no es modifica la màscara de descoberta.

Verificat amb Godot/OpenGL: `feedback_audio_preview.gd` en finestra 1920×1080 amb canvas 1440×900, avisos de quars i filtre, registre biològic invariant, escaneig habilitat després d’activar el filtre, nou fluxos PCM vàlids i silenci de totes les veus; captura inspeccionada amb la sala visible. `environment_preview.gd` torna a passar llum/boira sense canviar el món ni la descoberta. `mineral_click_check.gd` passa els clics i les denegacions amb els avisos nous. No s’ha fet una partida manual de la llavor exacta d’Albert ni una escolta manual per ajustar la mescla sonora.

### Icones genèriques a la llegenda — 20/11/2026

La flora i fauna de la llegenda deixen de mostrar exemplars d’espècies. S’utilitzen símbols genèrics de fulles verdes i petjada ambre, dibuixats en graella de píxels a `assets/ui/icona_flora_generica.svg` i `assets/ui/icona_fauna_generica.svg`. Textos i alineació es mantenen. Importació i renderitzat automatitzat de la interfície en Godot sense errors; no s’ha fet una partida manual.

### Edificis interactius a la base exterior — 20/11/2026

Clicar l’hàbitat obre Inventari; Control obre el catàleg biològic; el mòdul Taller i els panells d’Energia obren Equip i millores. L’ascensor conserva prioritat i l’acció de baixar. La detecció comparteix les mateixes regions, escala i ancoratge que el dibuix i descarta píxels transparents, respectant l’ordre dels edificis superposats. Afegida l’etiqueta Taller al mòdul de serveis. No mou el personatge ni modifica el món.

Verificat amb `surface_click_check.gd`, Godot/OpenGL: dotze clics simulats en quatre mòduls a tres resolucions, finestra/pestanya correctes, rebuig del fons i món invariant. Corregida una connexió duplicada de redimensionat en obrir l’inventari diverses vegades dins el mateix fotograma. Segona execució sense errors. No s’ha fet una partida manual.

### Bases sòlides i retirada completa de la boira en sales escanejades — 20/11/2026

Els mòduls de base subterranis bloquegen ara les cel·les de la seva petjada, amb un petit marge. La petjada desada és la mateixa que determina la mida i ancoratge del dibuix. El mapa, la navegació isomètrica i la fauna comparteixen el bloqueig. Abans d’activar-lo es comprova per cerca acotada a la graella que l’accés i totes les sortides de la sala continuen connectats; si cal, s’ajusta la mida del mòdul. La migració és idempotent i queda al món desat. Si una partida antiga té l’explorador dins del mòdul, s’espera que en surti per activar la col·lisió: no es teletransporta ni es mou per un canvi de zoom. A la superfície no s’ha afegit moviment nou del personatge.

La boira visual de les sales escanejades incorpora ara un marge exterior de vint unitats a més de l’extrusió de les parets. Així el filtratge de la màscara no deixa una vora negra sobre el terra o el mur que ja es coneixen. No es canvia la descoberta real ni es treu la boira de les altres sales.

Verificat amb `base_collision_fog_check.gd`, Godot/OpenGL: 28 bases (quatre llavors, set profunditats amb taller), cel·les interiors intransitables, sortides accessibles i migració estable. També comprova que tots els vèrtexs del contorn de la sala escanejada tenen màscara visual plena. Captura `reports/sala_escanejada_sense_boira.png` inspeccionada amb terra i parets complets. `all_biomes_preview.gd` passa els 20 estrats. Sense errors; no s’ha fet una partida manual de la llavor exacta d’Albert.

### Modificadors accessibles en expedició i cartells proporcionals — 20/11/2026

Els modificadors adquirits es poden activar i desactivar des de qualsevol lloc; només la compra requereix taller. Selector a la peça corresponent del HUD i de l’inventari amb estat actiu/inactiu, opcions marcades i nom del modificador actiu al detall. Es manté un únic modificador per peça i es desa el canvi. Activar el filtre actualitza immediatament la detecció de fauna il·luminada, també sense haver-la marcat abans com a vista; desactivar-lo durant un escaneig que el necessita cancel·la l’acció amb avís. El filtre no substitueix la llum ni repara l’escàner.

Els cartells Extraient/Escanejant escalen amb el zoom entre 65% i 135%, incloent marc, text, barra i separació de l’objecte; el mínim preserva lectura i el màxim evita cartells excessius.

Verificat en Godot/OpenGL amb scripts/modifier_field_check.gd: setze commutacions dels vuit modificadors fora del taller, cap cost ni canvi del món/posició, escaneig de fauna fèrrica iniciat amb filtre i cancel·lat sense filtre, estat actiu a inventari. Captura reports/modificadors_inventari.png inspeccionada. Sense errors. No s’ha fet una partida manual ni s’ha reproduït l’exemplar exacte d’Albert; cal contrastar els cartells amb el seu zoom habitual.

### Radis de balises sobre la boira — 20/11/2026

En vista isomètrica els contorns de cobertura i les ones de les balises es dibuixen ara en una capa posterior a la boira/il·luminació i anterior al HUD. Respecten les opcions de visualització i s’amaguen durant les fotografies. El mapa conserva la seva representació. Eliminat el farciment translúcid del radi per no tenyir la boira. No es modifica descoberta ni navegació.

Verificat amb environment_preview.gd en Godot/OpenGL, sense errors: món i descoberta invariants, captura reports/boira_descoberta.png inspeccionada amb radis visibles sobre zones fosques. Sense partida manual.

### Correcció de parets en entrants i laterals de les coves — 20/11/2026

L’orientació de cada tram de paret es calcula segons la normal exterior del contorn, respectant els dos sentits de recorregut del polígon. Ja no depèn de si el tram és per sobre o per sota del centre de la sala: aquest criteri aixecava aletes altes en entrants que havien de ser vores baixes. L’alçada posterior es redueix gradualment segons la inclinació lateral, evitant làmines altes als costats gairebé verticals. Es conserva la geometria lògica, descoberta, col·lisions i amplada de les obertures.

Verificat: wall_openings_check.gd comprova amplada exacta, cantonades, sortides tancades i boca de galeria completa, més entrant còncau en ambdós sentits. all_biomes_preview.gd passa els 20 estrats amb món invariant. Inspeccionada captura reports/bioma_complet_01.png. Sense errors; no s’ha reproduït la sala exacta de la captura d’Albert. Les terminacions verticals de les boques de galeria continuen existint i es poden refinar separadament.

### Separació entre explorador i fauna; fotografia neta — 20/11/2026

La fauna atura el seu avanç si s’apropa a menys de 22 unitats de l’explorador; pausa individual de patrulla, desada per estrat, sense modificar el rellotge de la resta d’animals. L’explorador espera si el següent pas travessa aquest espai, mantenint la possibilitat d’allunyar-se quan una partida antiga ja els té superposats. No es teletransporten unitats. Durant la captura fotogràfica s’omet l’explorador del dibuix perquè no tapi l’exemplar a la descoberta o al catàleg.

Verificat amb fauna_separation_check.gd en Godot/OpenGL: pas d’aproximació bloquejat, retirada permesa, 120 passos de fauna sense acostar-se dins del marge i captura de descoberta amb posicions inicialment superposades. Inspeccionada reports/fauna_descoberta_sense_explorador.png: animal visible sense explorador al damunt. biome_detail_check.gd continua passant amb set animals mòbils. Sense errors ni partida manual; els clics que intenten travessar un animal esperen que s’aparti i es pot ordenar passar pel costat.

### El feix del casc dissipa la boira visual sobre les parets — 20/11/2026

El shader de boira utilitza ara també la intensitat del feix per obrir la màscara visual, amb transició suau. Afecta totes les superfícies renderitzades sota el feix, inclosa la part elevada de les parets que no correspon a una cel·la de terra revelada. No incorpora oclusió del feix per parets. En apartar la llum, les zones no descobertes continuen subjectes a la boira; la descoberta persistent i les condicions de flora/fauna segueixen independents.

Verificat amb environment_preview.gd en Godot/OpenGL sense errors, invariància del món i màscara de descoberta. Captura reports/boira_descoberta.png inspeccionada: el feix obre la boira més enllà de la zona de terra prèviament descoberta. No s’ha fet una partida manual a la paret exacta d’Albert.

### Ambientació per bioma, entrada de descens i relleu de parets i terra — 20/11/2026

Integrats 32 sprites nous en dos atlas transparents: cristalls lluminosos, estalagmites grans, forats cecs i goteres/formacions amb líquid, amb vuit combinacions de materials corresponents als sis biomes i les dues zones finals. Prompts i regions reals a docs/PROMPTS_AMBIENT_COVES.md. Espurnes i gotes animades, llum local dels cristalls i ordenació per profunditat. Els cristalls ambientals no substitueixen els tres minerals extraïbles.

Col·locació per llavor, desada a world.ambience_v1, amb intents acotats, espai entre peces i exclusió de fauna/flora/minerals, roques i basses. Reserva de 42 unitats al voltant dels accessos encara que no estiguin descoberts. Les peces bloquegen cel·les de la mateixa màscara usada per jugador i fauna; s’exigeix un anell obert per permetre el desviament. El nombre és orientatiu i es redueix si no hi ha lloc segur. Els forats ambientals no creen connexions ni descensos. La boca del descens abans de posar-hi l’ascensor deixa de ser un polígon pla i utilitza roca pixel art del seu bioma; conserva l’ancoratge i la interacció del mateix accés.

Estalagmites grans amb atenuació suau del feix del casc i de les llums locals. Límit de vuit formacions visibles com a oclusors i 32 fonts de llum; aproximació 2D amb penombra, sense simulació física volumètrica. Parets amb carena irregular i ressalts intermedis facetats, colors derivats de la paleta del bioma, sense moure el perímetre transitable. Terra amb petits ressalts irregulars de la mateixa textura i escala, ombra lateral i altura visual baixa. També aplicat a galeries completes; els extrems amb esvaïment conserven el seu perfil. Malles de paret i terra en memòria cau; cap regeneració per zoom.

Verificat en Godot/OpenGL amb ambience_preview.gd: 818 peces en vuit estrats representatius, quatre categories presents a cada perfil, cel·les bloquejades, separació dels accessos, totes les sortides connectades, generació idempotent i món invariant durant el renderitzat. Comparació d’ombres activades/desactivades amb diferència de píxels comprovada (33,57 acumulat sobre mostreig). Inspeccionades captures ambient_bioma_04.png, ambient_bioma_13.png i entrada_descens_pixel_art.png. all_biomes_preview.gd passa els 20 estrats; biome_detail_check.gd manté set animals mòbils i quatre fanals. Sense errors.

render_benchmark.gd, dotze mostres després de preparar la memòria cau: CPU del dibuix principal 5,46 ms en vista local amb totes les sales descobertes i 19,85 ms enquadrant el conjunt. Primera preparació de la vista completa: 461,53 ms. Són costos de dibuix CPU, no FPS ni una mesura aïllada de la GPU amb ombres. No s’ha fet una partida manual. Següent pas: ajustar densitat, mides i intensitat de penombra amb les observacions d’Albert durant la partida.

### Noms dels biomes ocults fins a descobrir-los al perfil — 20/11/2026

Els títols de grups de profunditat, les capçaleres de sala/estrat i els noms de les bases i els seus textos emergents passen per _profile_biome_name. Mostren «Bioma per descobrir» fins que deepest_reached del perfil arriba al primer estrat del bioma; els estrats 19 i 20 es desbloquegen separadament. Arribar al bioma el revela, tornar a superfície o començar una nova expedició del mateix perfil conserva els noms coneguts, i un perfil nou torna a tenir-los tots ocults. Es reutilitza el progrés persistent del perfil. En carregar, els nivells en memòria sense cap sala visitada ja no incrementen per si sols la profunditat assolida.

Verificat amb biome_names_check.gd en Godot/OpenGL: perfil nou sense noms, descoberta als estrats 1 i 4, textos emergents sense noms futurs, conservació en nova expedició i desament/restauració, i aïllament després de netejar el progrés d’un perfil. Captura reports/biomes_noms_ocults.png inspeccionada. Sense errors ni partida manual.

### Ordre variable dels biomes i requisits per superar-los — 20/11/2026

Implementada una primera versió de les regles de campanya a scripts/campaign_rules.gd. Les noves partides mantenen Coves oxidades als estrats 1–3, barregen per llavor els quatre biomes centrals en blocs de tres als estrats 4–15 i mantenen Abisme biològic als 16–18, El Llindar al 19 i El Nucli al 20. campaign_biome_order es desa explícitament; no es recalcula en carregar. Els desaments anteriors sense aquest camp conserven l’ordre clàssic i el món existent. Ordres corruptes es rebutgen a la validació del desament.

La identitat del bioma, i no la posició antiga, determina geometria, terra, parets, base, ambientació, llums, flora, fauna i trets ambientals de gel/aigua/calor. Els costos, pressió i recompenses per profunditat segueixen l’estrat físic. La base de retorn correspon al primer estrat del bloc actual, no al número d’identitat del bioma. Descoberta dels noms per identificador de bioma a discovered_biomes del perfil: es conserva entre expedicions i no es transfereix a perfils nous. Migració dels noms de desaments antics segons el seu progrés i ordre clàssic.

Requisits inicials per sortir del bioma, només a les fronteres 3, 6, 9, 12, 15, 18 i 19; són decisions de detall d’aquesta primera implementació, pendents d’equilibri jugant:

- Coves oxidades: escàner Nv. 2 operatiu.
- Cavernes cristal·lines: capçal de precisió actiu, eina operativa.
- Galeries glacials: grampons actius, botes operatives.
- Jardins subterranis: sola de drenatge activa, botes operatives.
- Fractures geotèrmiques: sola tèrmica amb botes operatives O aïllament tèrmic amb vestit operatiu.
- Abisme biològic: nou filtre de bioluminescència actiu, escàner operatiu.
- El Llindar: escàner Nv. 3 operatiu.

El requisit s’indica al registre de la base/accés; el botó bloquejat conserva la possibilitat de clicar per llegir l’avís exacte. El modificador ha d’estar actiu, no només adquirit. Una peça avariada no compleix el requisit. Es comprova abans de gastar l’escala i en trajectes automàtics; els retorns cap amunt no es bloquegen. L’escala conserva els seus usos i cost de reposició. No s’exigeix cap espècie rara ni mineral que necessiti el mateix desbloqueig: els modificadors costen ferro i recerca bàsica, i els nivells d’escàner 2 i 3 tampoc no exigeixen quars/magnetita. Cost mínim inicial dels set requisits: 20 ferro i 7 punts, excloent consumibles, reparacions i millores opcionals.

Verificat amb campaign_rules_check.gd en Godot/OpenGL: 50 llavors d’ordre reproduïble (21 permutacions observades), extrems fixos, 20 estrats generats amb espècies del bioma correcte, set fronteres amb rebuig sense cost i descens efectiu amb ús d’escala quan es compleix l’equip, rebuig de peces avariades i alternatives de protecció tèrmica. Per cada estrat de la campanya mostrejada hi ha prou ferro amb eina bàsica per un modificador + reposició d’escala + reparació, i almenys tres espècies detectables sense filtre. Desament/restauració i món antic invariant comprovats. Informe reports/campanya_ordre_requisits.json. biome_names_check.gd passa amb ordre variable i perfils separats; modifier_field_check.gd passa les 18 commutacions dels nou modificadors. all_biomes_preview.gd passa els 20 estrats i vuit materials amb l’ordre variable. Captura reports/requisit_descens_glacial.png revisada. Sense errors.

Limitació: aquesta és una comprovació de recursos disponibles i dependències, no una simulació de supervivència, despeses arbitràries ni una partida completa. Falta contrastar manualment l’economia, els retorns per reposar l’escala i el ritme dels requisits. Les partides antigues mantenen l’ordre; per veure’n un de nou cal iniciar una partida nova.

### Goteres i llacs a paret, singularitats i primera defensa — 20/11/2026

Per petició explícita posterior d’Albert, el projecte incorpora fauna capaç d’atacar, arma i escut. Actualitzada l’excepció a AGENTS.md: preval sobre l’exclusió anterior de combat. L’exploració científica continua com a objectiu; no s’han afegit cadenes alimentàries ni ecologia simulada.

Goteres ampliades: es compon la formació penjant i la bassa per separat, amb proporció preservada, gota animada i ancoratge a la carena real d’un tram posterior de paret. S’eviten laterals retallats que deformaven la peça. Migració wet_walls_v3: les antigues goteres interiors passen a paret, s’obren les seves velles cel·les i la bassa superficial no bloqueja el pas. Si no hi ha una paret apta, la peça queda com a petit cristall visible, sense obstacles invisibles. Llacs ampliats amb quadrilàter de 62–88 per 48–66 unitats abans de projectar/retallar; el rierol prim de la textura s’orienta cap al mur. Es retallen al contorn de la sala i s’eviten accessos i punts biològics/minerals. Continuen essent basses ambientals superficials transitables. Corregida la invalidació de render_surface_details abans de consultar-lo en un altre món/estrat.

Vuit singularitats ambientals exclusives del perfil: arc de corall fèrric, geoda en ventall, cascada de gel, bolet d’espores, fumarola basàltica, membrana bioluminescent, anells erosionats i prisma magnètic. Una per estrat quan hi ha una petjada apta, reaprofita un obstacle ja validat sense canviar la geometria del graf. Sprite gran, ordre de profunditat i veí més proper. Recursos i prompts a PROMPTS_SINGULARITATS_DEPREDADORS.md.

Depredadors: quatre siluetes amb quatre direccions, vuit variants locals registrables com a fauna. Es col·loquen per llavor en algunes sales amb fauna encara no observada, sense substituir observacions ja fetes. Entrades, bases i sales d’accés inferior queden excloses. S’exigeix una patrulla segura amb amplitud suficient abans d’assignar agressivitat. L’estat es desa a world.predators_v1: posició, salut, orientació, alerta, preparació, atordiment i temporització. No reapareixen en carregar ni en tornar a la sala si ja estan immobilitzats. La navegació usa nodes i arestes que caben a la mateixa màscara real transitable que les roques i el jugador. La cerca és acotada i amb memòria cau; l’activitat es limita a la sala ocupada. Canviar de zoom o vista no modifica la posició ni la salut.

Letalitat inicial per estrat físic, independentment de l’ordre dels biomes: salut 26+4×profunditat, dany 4+1,15×profunditat, velocitat 18+1,6×profunditat; avís/preparació abans d’atacar, atac cancel·lable allunyant-se i comprovat contra obstacles. Són valors provisionals d’equilibri. Els animals immobilitzats continuen observables i fotografiables. No es donen recursos o recerca per disparar-los; la ciència manté la seva recompensa explícita.

Equip: projector de polsos i escut personal amb icones, càrrega i accions al HUD, fitxes d’inventari i millores al taller. F dispara a l’amenaça local coneguda; Ctrl+clic sobre el depredador també dispara. G i el botó d’inventari commuten l’escut. Pols inicial: 18 dany, 12 energia, 0,45 s entre trets, abast 70 unitats; augmenten dany i abast amb nivell. Escut inicial de 40 punts, absorció abans de vida, desactivable; +20 capacitat per nivell. Sis nivells inicials. Energia i escut es regeneren fora de perill; l’escut espera sis segons després d’un impacte. Estat d’equip separat a defence_state, compatible amb desaments antics que reben equip bàsic. L’inventari pausa la simulació, té desplaçament vertical i permet commutar l’escut. Nous sons procedurals per arma, impacte d’escut i alerta de depredador, respectant el silenciament existent. Corregida l’alçada inicial dels avisos perquè l’ajust de línies no generi un panell buit gegant.

Integració del fracàs: detectat que el camí antic esborrava materials i canviava de llavor, contrari al contracte vigent. Ara deixa un paquet recuperable a world.recovery_caches_v1, buida la càrrega perduda i retorna a superfície amb el mateix món, descobertes i millores, equip revisat i reserves bàsiques. El paquet s’assenyala en mapa/isomètric i es recull a prop amb clic, una sola vegada. El retorn d’emergència desa l’estrat del fracàs i recupera l’estat del primer estrat; iniciar expressament una partida nova continua essent una acció separada. Compatibilitat de fauna_pause com a camp opcional dels desaments antics.

Verificació real en Godot/OpenGL, sense errors:

- wet_defence_check.gd: vuit perfils, 218 basses amb punta a paret, 238 goteres ancorades, 11 depredadors de mostra, singularitat a cada estrat provat i accessos connectats. Persecució segura, avís abans del dany, absorció/desactivació d’escut, tecles F/G, Ctrl+clic, tret bloquejat per roca sense consum, temps entre trets, immobilització persistent, millores pagades, desament/restauració i botó d’escut d’inventari. Ajust de finestra a 1024×640.
- defence_recovery_check.gd: derrota, desament mentre és activa, restauració, retorn al mateix món, millores preservades, materials 7 ferro/2 quars/1 magnetita recuperables i recollida idempotent. Topologia del món conservada i camp antic opcional validat.
- all_biomes_preview.gd passa els 20 estrats amb món invariant durant el renderitzat. campaign_rules_check.gd continua passant 50 ordres, 20 estrats i set fronteres.
- Inspeccionades captures singularitat_bioma_01.png, singularitat_bioma_10.png, depredador_escut_encontre.png i arma_escut_inventari.png.
- render_benchmark.gd: dotze mostres amb memòria cau, CPU del dibuix 5,37 ms en vista local amb tot descobert i 22,92 ms enquadrant-ho tot. Primera preparació completa 531,61 ms. No són FPS ni una mesura de la GPU o de tota la IA.

Limitacions i següent pas: no s’ha fet partida manual ni audició manual dels sons. Cal equilibrar letalitat, energia, millores i recuperació amb joc real. L’arma és un projector d’energia, sense munició física ni botí de combat; l’escut protegeix d’atacs, no de manca d’oxigen. La fauna hostil es desperta en la sala ocupada i no persegueix l’explorador entre sales. Els llacs són ambientals; no impliquen natació ni caigudes. Les ombres continuen essent aproximacions 2D.

### Escut al costat de la vida i descens diferenciat — 21/11/2026

Per indicació d’Albert, eliminat el contorn angular de l’escut sobre l’explorador i l’anella cian als peus; es conserva l’ombra natural. L’escut continua funcionant i es mostra immediatament a la dreta de Vida al HUD, amb percentatge, estat i botó de commutació. Inventari, millores, absorció i regeneració es mantenen.

Nou sprite exclusiu assets/sprites/acces_descens.png per a l’obertura de baixar abans de disposar de plataforma: revestiment metàl·lic, escala visible, baranes, senyalització taronja i llums de servei. Els forats ambientals continuen naturals i no comparteixen la imatge de l’accés. El punt lògic, requisits d’equip, escala i món desat es conserven. La detecció de clic accepta els píxels opacs de la nova silueta, incloses les baranes, i rebutja els marges transparents. Prompt a PROMPT_ACCES_DESCENS.md.

Verificat en Godot/OpenGL: wet_defence_check.gd passa els vuit perfils, combat, commutació d’escut i desament. Inspeccionada depredador_escut_encontre.png amb l’explorador sense contorn i Vida/Escut adjacents. ambience_preview.gd passa vuit perfils i connectivitat; 167 punts opacs de l’accés acceptats, 20 fora de l’antic contorn, i cantonada transparent rebutjada. Inspeccionada entrada_descens_pixel_art.png amb escala/baranes diferenciades. Sense errors. No s’ha fet partida manual.

### Música de fons amb les pistes d’Albert — 21/11/2026

Copiades sense modificar les cançons aportades Subterranean Pulse.mp3 i Stone Echoes.mp3 a assets/audio/music/subterranean_pulse.mp3 i stone_echoes.mp3. SHA-256 de cada còpia idèntic al fitxer de Descàrregues. El reproductor de música de game_audio.gd alterna les dues pistes quan cadascuna acaba i torna a la primera; no es reinicia en canviar de sala, estrat, vista o partida dins de la sessió. Reproducció des de l’entrada al joc, inclosa la base.

A les opcions: Efectes de so separat de Música de fons i volum de música 0–100%, inicialment 25%. Desactivar música pausa i reprendre-la conserva la posició. Preferències generals a user://audio_settings.cfg, separades del progrés del perfil. Els recursos MP3 tenen bucle individual desactivat perquè el final passi a la pista següent. El visor de proves silencia la música i evita escriure preferències de l’usuari.

Verificat amb music_check.gd: importació MP3, dues durades vàlides (199,2 i 224,3 segons), reproducció, pausa estable, represa, independència dels efectes, volum i persistència. Cerca al final real de les dues pistes: el senyal finished avança a la segona i torna a la primera. Fitxer de configuració de prova separat i eliminat. Execucions headless i OpenGL amb controlador d’àudio Dummy; sense errors ni objectes pendents. Inspeccionada captura reports/opcions_musica.png, amb controls llegibles. No s’ha fet audició manual de la barreja ni una partida manual; següent pas, ajustar el volum amb l’escolta d’Albert si cal.

### Llacs integrats al terra i fauna sense anella — 21/11/2026

Corregida la projecció del llac: la base UV anterior girava i deformava la placa de roca fins a donar aparença de paret. Nou atles basses_biomes_planes.png amb aigua, marge de pedra estret i transparència exterior, creat amb imagegen integrat (prompt a PROMPT_BASSES_PLANES.md). Base ortogonal tangent/interior de sala, sense invertir la imatge; es projecta amb la mateixa transformació que el sòl. Extrem prim fixat a la paret, retall contra contorn i marge respecte de roques, ambientació sòlida i base. Sense canviar màscara, llavor, navegació o descobriment. Les sales sense emplaçament segur ometen el llac en lloc de superposar-lo. Eliminada l'anella violeta del dibuix de fauna del mapa, capçalera i catàleg, fins i tot si una crida antiga la demana.

Verificat: importació headless sense errors; lake_ground_check.gd en OpenGL real amb àudio Dummy comprova 62 basses als vuit perfils, ancoratge, orientació de la base, retall dins la sala i món invariant. Captures reports/llac_integrat_01.png i 04 inspeccionades: llac horitzontal, sense la gran placa de roca anterior i separat de la singularitat. La prova acaba amb un avís de dues instàncies ObjectDB pendents; sense errors de script. No s'ha fet partida manual. Següent pas: valorar integració i mida amb el zoom habitual d'Albert.

### Correcció de text — 21/11/2026

Indicador de mineria corregit de EXTRAENT... a EXTRAIENT... segons indicació d’Albert. Verificat el literal a scripts/main.gd; canvi exclusivament de text, sense executar una nova prova de renderitzat.

### Flora fantasma i registre al mapa — 21/11/2026

La flora que no es pot detectar pel filtre ara es dibuixa amb la recepta pixel art completa, semitransparent (55%), a la mateixa escala de món que la planta normal. Substitueix la composició genèrica de peces poc recognoscible. No revela identitat ni habilita l’anàlisi; el clic manté l’avís de requisit i activar el filtre permet escanejar.

El registre d’expedició de la dreta inferior també apareix a la vista de mapa, amb la mateixa targeta, tasques i percentatge de la sala ocupada. Passar per sobre d’una sala coneguda actualitza el panell com en isomètric. Sense canviar navegació o descoberta.

Verificat feedback_audio_preview.gd en Godot/OpenGL: avís de filtre, registre biològic invariant abans de millorar, escaneig habilitat després del filtre, panell visible al mapa amb identificador correcte. Captures avis_requisits_escala_1920.png (flora semitransparent) i registre_sala_mapa.png inspeccionades. Última execució sense errors ni avisos de sortida. No s’ha fet partida manual.

### Ordre de l’equip — 21/11/2026

Projector de polsos mogut des de l’extrem dret al començament de la fila EQUIP, immediatament després de Vida i Escut. Canvi exclusiu d’ordre dels controls, sense alterar funcionalitat ni identificadors. Verificat l’ordre a la construcció del HUD; sense nova prova de renderitzat.

### Evitar aturades indefinides davant de fauna — 21/11/2026

Detectat que el control de separació amb un animal interrompia el pas sense recalcular ruta, deixant l’explorador esperant indefinidament. Ara intenta un desviament local acotat a 4096 cel·les dins la sala: cada tram valida màscara, boira i separació amb fauna; conserva la resta de la ruta i no modifica el món. Si no existeix pas, atura l’ordre i informa PAS OCUPAT PER FAUNA · TRIA UN ALTRE PUNT. Sortir d’un solapament preexistent continua permès si augmenta la distància; no es teletransporta ni s’obre cap roca.

Verificat fauna_separation_check.gd en Godot/OpenGL: quatre desviaments complets al voltant d’un animal, tots els trams transitables i sense travessar-lo, aproximació bloquejada i escapada permesa; pausa de fauna i fotografia continuen passant. Sense errors de script; avís de dues instàncies ObjectDB pendents en sortir del visor. No s’ha reproduït manualment la llavor exacta de la captura d’Albert ni s’ha fet partida manual. Següent pas: validar en joc els passos estrets entre animal i roca.

### Sortides llegibles, galeries tancades i retorn conservador — 21/11/2026

Marcadors de sortida isomètrics dibuixats després de parets/objectes, amb fons fosc i escala mínima 1,35 (abans baixava amb el zoom), contrast reforçat per a accessible i cadenat vermell per a fora d’abast. Mateixos punts lògics i clics. El registre de sala afegeix Galeries tancades · N calculat amb les mateixes regles d’accessibilitat de les sortides visibles, sense confondre-les amb recorregudes.

Albert informa d’una galeria aparentment nova després del retorn directe. La cerca ja limitava el retorn a sales conegudes i galeries completades, però després substituïa trams per línies centrals i suavitzava. Ara les rutes completed_only conserven les cel·les validades, amb comprovació de cada segment i punt conegut; s’evita aquesta font potencial de dreceres en encreuaments. No hi ha cap creació de corredor al retorn. No s’ha reproduït el cas exacte d’Albert; pendent comprovar-lo amb la seva partida.

Verificació: feedback_audio_preview.gd en OpenGL passa amb els canvis d’interfície. return_route_check.gd headless valida deu rutes: trams transitables i coneguts, geometria del món invariant. Avís de dues instàncies ObjectDB pendents en finalitzar el visor. Les proves no equivalen a una partida manual ni confirmen la causa exacta de la galeria que ha vist Albert.

### Obertura progressiva al 90% — 21/11/2026

Quan l’exploració arriba al 90% i completa automàticament la sala, la capa de boira conserva la màscara visual anterior i dissipa la resta amb una ona radial de dos segons des de l’explorador. Front cian subtil com a efecte d’escaneig. El terra no es materialitza per peces: és una transició de boira. Estat de descoberta i recompensa continuen atòmics/idempotents; l’efecte no altera màscara lògica, coordenades ni navegació. Només s’activa en el llindar automàtic, no en carregar una sala ja escanejada; es desactiva en canviar de món/estrat.

Verificat reveal_effect_check.gd en OpenGL: captures a 0, 0,9 i 2 segons diferents, final progress=1, món i descoberta invariants durant l’animació. Inspeccionada captura intermèdia reports/obertura_sala_09.png. El visor força una boira inicial més gran per comprovar clarament l’efecte; no és una partida manual fins al 90%. Sense errors de shader/script, avís de dues instàncies ObjectDB pendents en sortir del visor. Següent pas: valorar el ritme amb joc real.

### Mostres de depredador, alerta de sala i radar — 21/11/2026

Depredador amb hp=0: permet recollir una mostra única amb el botó de mostres en seleccionar-lo, aturat i a menys de 38 unitats, sense exigir escaneig previ. Pot continuar sent observat/fotografiat. fauna_samples reutilitza inventari, retorn/lliurament, punts i persistència existents; recollida idempotent. Clicar un abatut ja no arrenca automàticament un escaneig que impediria recollir la mostra.

En entrar en una sala amb depredador viu: avís visible FAUNA HOSTIL A LA SALA i so d’alarma. Es repeteix en una entrada nova, no cada fotograma. Radar sobre la vista de món, esquerra inferior: vuit sectors de direcció i tres bandes de proximitat, escombratge i eco vermell. Només detecta l’hostil de la sala ocupada; no revela cel·les, nom ni descobertes biològiques. Desapareix en abatre’l o sortir de la sala. No representa un halo al personatge.

Verificat predator_sample_radar_check.gd en OpenGL amb àudio Dummy: avís, pista radar sense alterar descoberta, mostra rebutjada en viu, acceptada en abatut una sola vegada, +1 punt únic i fauna_samples inclòs al desament de nivell. Inspeccionada reports/radar_hostil.png. Sense errors de script; avís de quatre instàncies ObjectDB pendents en sortir del visor. No s’ha fet audició ni partida manual. Valors de mida/rang i recompensa provisionals d’equilibri.

### Mur complet, resum sense zeros i rutes pel graf — 21/11/2026

Corregida la màscara visual de boira: ara té vuit cel·les de marge per cada costat fora de la graella lògica, i el shader incorpora aquest desplaçament. Permet representar la carena i extrusió conegudes de sales prop del límit del món sense tall horitzontal. No amplia el món transitable ni la descoberta lògica. L’ona de dissipació conserva el mateix format de màscara ampliada.

El registre omet Galeries tancades quan el recompte és zero. Per a trajectes entre sales amb destí en una altra sala i sense galeria explícita, la cerca passa pel graf de connexions: aproximació dins la sala, boca real, seqüència exacta de punts de la galeria existent i entrada a la següent sala. El retorn només admet connexions completades. Si algun tram no és transitable/conegut, rebutja la ruta; no inventa un corredor. Eliminat també l’assignació final unit_position=move_target: l’arribada és l’últim punt validat, sense salt al clic original.

Verificat return_route_check.gd headless: deu rutes locals i deu rutes entre sales, tots els trams transitables; món invariant, recompte de tancades condicionat. Avís de dues instàncies ObjectDB pendents en sortir d’aquest visor. reveal_effect_check.gd en OpenGL: màscara ampliada 16 cel·les en cada dimensió, tres fases de boira vàlides i estat invariant. Última execució gràfica sense errors ni avisos; inspeccionada obertura_sala_20.png amb sala propera al límit superior i mur complet, i sense fila de tancades=0. No s’ha reproduït manualment la partida concreta d’Albert. Següent pas: comprovar retorns llargs i creuaments amb el seu desament.

### Avisos restaurats, primer estrat més suau i arrossegament dret — 21/11/2026

L’actualització d’inventari recalcula immediatament els avisos de reserves/integritat, també amb simulació pausada a l’inventari, i en esborrar un avís redibuixa la targeta correcta de resource_gain_cards. Evita mantenir l’últim fotograma vermell després de recarregar/reparar. El primer estrat aplica modulació del paviment (0,76/0,88/0,94), reduint especialment la intensitat vermella, tant en sales com galeries; conserva la textura, escala i resta de biomes.

Botó dret premut sobre espai buit (fora de sala i galeria) inicia arrossegament de càmera en mapa i isomètric, amb desactivació del centrat automàtic. Alliberar-lo finalitza l’arrossegament encara que el cursor sigui sobre UI. Sobre terreny es conserva l’ordre de moviment/interacció. La classificació d’espai buit no altera geometria ni descoberta.

Verificat service_pan_check.gd amb Godot/OpenGL: avís d’oxigen baix, restauració de reserva i vestit elimina avisos; pressió/moviment/alliberament sintètics de botó dret en ambdues vistes mouen la càmera exactament (28,16), sense canviar món, explorador o boira. Inspeccionada reports/oxidat_mes_suau.png. Sense errors de script, avís de dues instàncies ObjectDB pendents en sortir del visor. No s’ha fet partida manual.

### HUD d’equip amb icones i modificadors laterals — 21/11/2026

El mapa ja no dibuixa popup en passar sobre una sala: queda el registre dret existent. Barra EQUIP amb icones pròpies en SVG sobre graella 16×16, nearest, nom al tooltip i conservació de nivell/percentatge/reserves. Recursos nous equip_*.svg, més les icones prèvies d’arma/escut. Modificadors al costat de la icona/títol, també a l’inventari, amb ✓ verd actiu o ○ inactiu i el mateix menú de selecció; eliminats els textos MOD. ACTIU/INACTIU sota les targetes.

Simplificat escut a automàtic sempre disponible mentre tingui càrrega: retirada tecla G i botons visibles de commutació; desaments antics amb enabled=false es normalitzen en actualitzar l’equip. Es conserva l’absorció i regeneració prèvies. El botó ocult de compatibilitat i mètode antic ja no poden desactivar-lo. Motiu de la simplificació: no hi havia cost de manteniment ni avantatge de joc en apagar-lo.

Verificat importació SVG, service_pan_check.gd en OpenGL amb menús dins HBox, estat ✓/○ segons modificador, escut antic desactivat restaurat a actiu i botó de desactivació ocult. Proves prèvies de recàrrega i desplaçament continuen passant. Captura oxidat_mes_suau.png inspeccionada amb les icones. Última execució sense errors ni avisos. Adaptades les expectatives antigues de commutació a wet_defence_check.gd; aquesta bateria completa no s’ha tornat a executar en aquesta fita. No s’ha fet partida manual.

### Unió de rastres i materials avançats — 21/11/2026

Revisats costos: les millores generals demanen ferro/recerca i un mineral addicional periòdic. Amb tier intern 3 (Nv.4→5) quars; tier 6 (Nv.7→8) magnetita; alternança cada tres nivells. Arma i escut encara tenen costos propis només de ferro i recerca. No s’han modificat costos ni equilibri en aquesta fita.

Possible causa visual de galeria aparentment generada en anar/tornar: múltiples rastres solapats del mateix corredor es dibuixaven amb terres i parets independents, a més de la boca provisional. _drawn_gallery_spans ara uneix intervals solapats sobre la línia central existent abans de dibuixar. _draw_isometric_corridors omet la boca provisional quan ja està coberta per un tram recorregut. No afegeix corredor, no crea drecera ni modifica el món desat.

Verificat return_route_check.gd: quatre rastres duplicats/parcials es representen com un únic tram idèntic a la geometria original; deu rutes locals i deu pel graf passen i el món és invariant; requisits quars/magnetita comprovats. Sense errors ni avisos en aquesta execució headless. wall_openings_preview.gd en OpenGL renderitza sis boques abans/després de completar galeries; inspeccionada parets_boca_galeria.png. Avís de dues instàncies ObjectDB pendents en sortir del visor gràfic. No s’ha reproduït la partida exacta de la captura d’Albert; no es dona per confirmada la causa única ni s’ha fet partida manual.

### Inventari ampliat, barres i accessos destacats — 21/11/2026

Inventari ara amb la mateixa mida disponible que Equip i millores, graella de quatre columnes amb desplaçament vertical i targetes de 150 píxels mínims. Cada equip general mostra barra cian de nivell sobre el màxim de 20 i barra verda d’integritat, càrrega o disponibilitat de reserves. Arma/escut inclouen nivell sobre 6 i energia/càrrega. Es conserven percentatges/nivells textuals i modificadors laterals.

Llacs: la separació ara inclou també world.obstacles (abans només solid_room_rocks_v1 i ambience), marges segons visual_radius i marge de 28 per a punts de flora/fauna/mineral. Evita l’obstacle que encara podia quedar damunt de l’aigua. La falta d’emplaçament segur omet el llac.

Accessos: cartell fosc amb vora ambre, fletxa de pujada/baixada també abans d’instal·lar ascensor i mida mínima de lectura en mapa/isomètric. En isomètric es dibuixa després de parets/objectes; no crea un punt de navegació nou.

Verificat service_pan_check.gd: inventari a mida gran, barres de nivell/estat amb valors correctes i proves d’avisos/arrossegament passen. lake_ground_check.gd valida 25 basses segures als vuit perfils, ancoratge i món invariant. Ambdues execucions OpenGL sense errors ni avisos. Inspeccionades inventari_barres_gran.png i oxidat_mes_suau.png. Sense partida manual.

### Icones d’equip detallades — 21/11/2026

Substituïdes les icones esquemàtiques del HUD per sprites detallats de metall, volum isomètric, llums cian i accents taronja: assets/ui/equip_pixel_art_detall.png, atles 4×4 creat amb imagegen integrat. Retall per AtlasTexture amb filter_clip, filtratge nearest i espai de 48×48 abans de l’escala general del HUD. Ordre/identificadors, modificadors laterals i noms al tooltip es conserven. Font original preservada a generated_images; recurs final copiat al repositori. Prompt exacte a docs/PROMPT_ICONES_EQUIP_DETALL.md.

Importació i service_pan_check.gd OpenGL passen; inventari gran, barres, modificadors i desplaçament continuen passant. Inspeccionada oxidat_mes_suau.png amb les tretze icones noves al costat dels recursos. Sense errors de script; dues instàncies ObjectDB pendents al tancament del visor. No s’ha fet partida manual. Les cel·les extra de bateria/mostra/càmera estan disponibles a l’atles, sense canviar els controls petits existents en aquesta fita.

### Noms d’icona i activació de modificadors visibles — 21/11/2026

Les icones TextureRect del HUD ara capturen el ratolí (MOUSE_FILTER_STOP) perquè el tooltip amb el nom sigui accessible; també afegit nom a la targeta. El control lateral de modificadors deixa de ser un símbol petit: botó amb marc cian, fons contrastat i text MOD + / MOD ✓, àrea mínima 48×28 abans d’escala HUD i cursor de mà. Actiu verd. Clicar obre la llista amb checks per activar/desactivar des de qualsevol lloc. Si no hi ha cap modificador comprat, el botó continua visible i obre explicació que cal comprar-ne a Equip i millores, en lloc de quedar desactivat sense una via clara.

Verificat service_pan_check.gd OpenGL: menús habilitats, indicador correcte, senyal id_pressed del popup desactiva i reactiva grampons comprats; inventari/barres i proves prèvies passen. Captura oxidat_mes_suau.png inspeccionada amb MOD al costat de les quatre peces compatibles. Sense errors de script; dues instàncies ObjectDB pendents en sortir del visor. Verificat el filtre de ratolí per codi, sense inspecció manual del tooltip. Intent headless aturat perquè el visor espera frame_post_draw; execució gràfica posterior completada.

### Modificadors laterals al taller — 21/11/2026

A Equip i millores, cada targeta de vestit/mineria/botes/escàner ara divideix l’espai en dues columnes: equipament i millora a l’esquerra, modificadors corresponents a la dreta amb separador vertical. S’han reubicat els controls existents, conservant costos, compra amb activació i commutació sense recompra. La columna general d’equipament rep més proporció horitzontal.

Verificat service_pan_check.gd en OpenGL: compra de sola tèrmica resta tres ferros i un punt, activa; segon clic desactiva i tercer reactiva sense cap segon cobrament. Inspeccionada reports/modificadors_costat_taller.png amb els quatre equips i modificadors laterals. Sense errors de script; dues instàncies ObjectDB pendents en sortir del visor. Sense partida manual.

### Atacs visibles de depredador — 21/11/2026

Preparació d’atac amb retrocés visual curt i ATACA!; en executar el cop, escomesa visual de 0,35 s cap a l’explorador sense canviar coordenades, màscara, col·lisions o abast lògic. Impacte amb tall i espurnes pixelades, cian si absorbit per l’escut i vermell si toca vida. Indicador flotant d’un segon ESCUT −N / VIDA −N, incloent tots dos si el dany és mixt. Missatge d’estat explicita ATAC DE DEPREDADOR amb quantitats. So d’escut o alarma segons dany real a salut. No afegeix halo ni marc permanent al personatge; s’oculta en fotografies.

Verificat predator_sample_radar_check.gd en OpenGL: final real de windup executa atac i activa animació/impacte, dany absorbit separat del dany directe de sis punts, mostres/radar i desament continuen passant. Captures atac_impacte_escut.png i atac_impacte_vida.png generades; inspeccionada la segona amb tall vermell i VIDA −6 visible. Execució sense errors ni avisos. Sense audició o partida manual; següent pas valorar durada/intensitat jugant.

### Revisió confirmada de fracàs — 21/11/2026

Albert confirma explícitament: «Sí: en morir comença un món nou». Substitueix les decisions anteriors de recuperar materials al mateix món. _end_expedition deixa de generar paquet recuperable; es perden ferro/quars/magnetita a sobre. El missatge explica món nou, sense recuperació, i el botó diu COMENÇA UN MÓN NOU. La confirmació genera una llavor diferent i arxiva l’expedició morta una sola vegada, preservant catàleg/perfil i millores permanents (nivells, modificadors comprats/actius, despesa de recerca, arma/escut). Actualitzat AGENTS.md. Els retorns normals a base continuen conservant el món.

Caixa d’eines disponible també des del mapa i galeries, sense exigir sala seleccionada ni vista isomètrica. Pausa de simulació mentre és obert el menú de reparació; avisos si usos esgotats/acció pendent, desament després de reparar. Cadàvers visibles sense filtre de detecció: clicar cos a menys de 38 unitats, aturat i sense acció en curs recull una mostra única directament. Lluny dona instrucció d’acostar-se, i el botó de mostres continua disponible.

Verificat death_new_world_check.gd headless: reparació al mapa/galeria, consum d’un ús, final sense paquet, llavor nova, historial sense duplicar i millores/modificadors preservats. Sense errors/avisos. defence_recovery_check.gd queda com a entrada compatible cap a la nova prova vigent. predator_sample_radar_check.gd en OpenGL comprova clic real de selecció del cos, mostra única/desament i efectes d’atac; sense errors, sis instàncies ObjectDB pendents en sortir del visor. Sense partida manual ni desament real d’Albert modificat per les proves.

### Recuperació manual de l’explorador encallat — 21/11/2026

Afegit DESENCALLA L’EXPLORADOR a Opcions i tecla F8. Cancel·la ordres, mineria/escaneig/neteja en curs i navegació encadenada. Busca un punt ja descobert amb peu lliure, sense fauna, a 10/20/30 unitats i dins la mateixa sala/galeria; valida tot el tram, permetent sortir només d’una cel·la inicial bloquejada antiga. Si no hi ha punt segur, deixa l’explorador on és i reinicia les ordres. No recarrega oxigen, energia, integritat ni modifica màscara/boira/món. A superfície només cancel·la ordres. No actua durant mort o descoberta modal.

Verificat unstuck_check.gd headless amb tecla F8 sintètica en mapa/isomètric: ordres netejades, desplaçament màxim de 30, mateixa sala i peu transitable, món/boira/reserves invariants. service_pan_check.gd en OpenGL continua passant; inspeccionada opcions_desencalla.png amb botó llegible. Sense errors, dos ObjectDB pendents en sortir de cada visor. No s’ha fet partida manual ni es garanteix sortir de qualsevol geometria corrupta: no es travessen obstacles per forçar recuperació.

### Llums centrals de galeria — 21/11/2026

Cada punt de llum de les galeries utilitza ara un únic llum de terra sobre la línia central del pas, en lloc d’una parella als laterals. Conserva espaiat de 35 unitats i orientació segons la tangent abans de projectar. Sense canviar màscara ni estat de descoberta.

Verificat wall_openings_preview.gd en OpenGL, sis boques amb galeries parcials/completes; sense errors ni avisos. Inspeccionada parets_boca_galeria.png amb llums al centre. Sense partida manual.

### Desencalla al final de navegació — 21/11/2026

Afegit botó DESENCALLA · F8 a l’extrem final de la barra de navegació, amb el mateix estil i distribució adaptable. Connecta a la mateixa recuperació local que F8 i Opcions. Disponible en mapa/isomètric subterranis.

Verificat unstuck_check.gd headless: senyal del botó al mapa i tecla F8 en isomètric executen recuperació sense canviar reserves/món. Sense errors de script; quatre ObjectDB pendents en sortir del visor. Sense nova inspecció visual ni partida manual.

### Navegació compacta entre panells — 21/11/2026

Botons de navegació ajustats a l’amplada real del text més 20 píxels, mínim 92, amb separació de 4. La barra es centra i limita a _view_rect (espai entre panells), en lloc d’ocupar tota l’amplada de la finestra i quedar tapada pel panell dret després d’afegir Desencalla.

Verificat service_pan_check.gd OpenGL i inspeccionada oxidat_mes_suau.png: tots els botons, inclòs Desencalla al final, dins l’espai central. Sense errors; dues instàncies ObjectDB pendents en sortir del visor. Sense partida manual.
