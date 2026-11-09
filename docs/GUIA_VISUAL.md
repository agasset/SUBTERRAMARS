# Guia visual per al prototip

## Decisió aprovada més recent — revisió visual 1.4

El joc té dues vistes 2D: mapa general superior per llegir la xarxa i vista isomètrica local per explorar una sala. Entrar o obrir una sala amaga el mapa general i mostra l’escena local amb terra, parets i eines d’exploració. Tornar al mapa recupera la mateixa xarxa i estat. No és 3D ni un nivell artesanal: la vista isomètrica projecta les dades procedurals de la sala.

## Què s’ha de veure

| Vista | Contingut |
| --- | --- |
| Mapa general | Contorns orgànics, connexions conegudes, estats, posicions petites i accessos detectats |
| Sala isomètrica | Terra i parets de la sala, obstacles, explorador, robot i organismes observables a partir de les dades generades |
| Fitxa lateral | Imatge ampliada de l’espècie, nom, descripció i registre |

Les coves són formes irregulars, amb cambres amples i petites i galeries sinuoses. Evitar sales rectangulars de la mateixa mida. Els sprites han de continuar petits: veure molt territori i tenir consciència de posició és més important que veure animacions grans.

## Estil

Pixel art 2D, fons gairebé negre, contorns i estats llegibles, accents cian o equivalents. Paleta limitada i text net. Els colors exactes són provisionals; contrast i consistència tenen prioritat. UI futurista fosca amb panells laterals i barra inferior d’icones.

Capes del mapa: geometria desconeguda oculta, contorn detectat, interior revelat, unitats, connexions i marcadors. Capes de sala: paviment revelat, parets, obstacles, unitats, organismes observats i marcadors confirmats. Les dues vistes consulten el mateix estat. Canviar de vista o zoom canvia la representació, no el coneixement ni la posició. Una sala detectada no ha de mostrar-ne tots els objectes.

La mida dels panells i la lletra no disminueix amb la càmera. Usa filtratge de veí més proper quan hi hagi textures pixel art. Es pot començar amb dibuix 2D i icones provisionals; no cal fabricar un atlas final abans de provar el mapa.

## Referències de conversa

Aquestes imatges no estan incloses com PNG locals. Els enllaços permeten a Albert recuperar-les; Codex no ha de suposar accés als seus bytes ni quedar bloquejat si no pot obrir-les.

- [Mapa de cuevas marcianas neón](https://chatgpt.com/library?file_id=libfile_c736054bbe28819198cb23b216c2e9ff&account_id=personal): contorns de cova orgànics, referència principal.
- [Mapa holográfico de Project Mars](https://chatgpt.com/library?file_id=libfile_b68aa11b685c819190aff5cac03521cf&account_id=personal): sales de mides variables i estructura general.
- [Mapa d’Exploració de Mart](https://chatgpt.com/library?file_id=libfile_f1397eac2cb4819196e138487982b7f1&account_id=personal): reducció del detall a posicions i connexions.

Les referències defineixen composició i ambient; no s’han d’utilitzar com un fons estàtic sobre el qual fingir moviment sense geometria jugable. La sala isomètrica es dibuixa des de geometria i contingut procedural.

## Prova visual mínima

A escala general, cal llegir ràpidament on som i on podem anar. En obrir una sala, la geometria i les unitats han de coincidir amb el mapa després de la projecció isomètrica. Clics de moviment han d’invertir la projecció i seguir la màscara transitable. Les àrees ocultes continuen ocultes. Canviar de vista no mou el personatge. Els panells no tapen permanentment l’àrea seleccionada.

## Referències visuals prioritàries aprovades

Aquestes dues imatges prevalen sobre els estudis previs pel que fa a composició i estil:

| Referència | Aplicació |
| --- | --- |
| [Mapa de Cuevas de Marte.png](https://chatgpt.com/library?file_id=libfile_89513cabf5b08191895459fb85dfb397&account_id=personal) | Mapa general de coves orgàniques, panells laterals, oxigen/bateria i eines inferiors |
| [Interfaz científica de Subterra: Marte.png](https://chatgpt.com/library?file_id=libfile_b52c57ce96288191b5d11b40f04029fa&account_id=personal) | Ambient de la cova, explorador, robot, flora/fauna, escaneig i HUD cian/taronja |
| [Mapa de Cuevas de Marte.png](referencies_visuals/Mapa%20de%20Cuevas%20de%20Marte.png) | Referència directa aportada per Albert per a la vista general |
| [Sala isomètrica Subterra.png](referencies_visuals/Sala%20isometrica%20Subterra.png) | Referència directa aportada per Albert per a l’exploració de sala |

La segona referència mostra explícitament l’exploració isomètrica de la sala i preval sobre les guies visuals antigues. La distribució concreta de coves, obstacles i organismes sempre es genera; la referència no es copia com a escenari.

Les dues referències directes aportades per Albert s’inclouen al repositori sota `docs/referencies_visuals/`. Es conserven com a material de disseny i no s’empaqueten com a recursos de joc.

Identitat gràfica: [Logo pixel art de Subterra: Marte.png](https://chatgpt.com/library?file_id=libfile_bb3dca2dd7388191838ab34490cce884&account_id=personal). Referència de marca, no atlas de sprites.

## Estructura de profunditat confirmada — versió 1.3

20 nivells totals. Biomes: 1–3, 4–6, 7–9, 10–12, 13–15 i 16–18. Els nivells 19 i 20 tenen identitat estructural especial reconeixible, amb coves, espècies i investigacions procedurals. Noms i trets concrets provisionals. Vegeu la secció 24 del mestre. Conservar les garanties de navegació, objectius assolibles i persistència. P0A continua amb un nivell; els tres nivells de prova no substitueixen la campanya de 20.
