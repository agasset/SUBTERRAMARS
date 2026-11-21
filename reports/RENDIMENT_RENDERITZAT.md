# Rendiment del renderitzat — 20 de novembre de 2026

Godot 4.7.2, OpenGL Compatibility, NVIDIA RTX 3060, finestra 1440 × 900. Llavor 134027, Coves oxidades. Prova amb simulació aturada i desament desactivat; mitjana de 12 dibuixos després de 3 fotogrames d’escalfament. Es mesura el temps de CPU de `_draw()`, no els FPS totals ni el cost de simulació, autodesament o GPU.

| Situació | Abans, ms de CPU | Després, ms de CPU | Crides de dibuix abans → després |
| --- | ---: | ---: | ---: |
| Només sala d’entrada | 1,01 | 0,59 | 577 → 479 |
| Totes les sales descobertes, vista local | 170,12 | 3,51 | 13.511 → 519 |
| Tot l’estrat enquadrat en isomètric | 224,99 | 7,19 | 22.396 → 1.136 |
| Mapa superior amb tot descobert | No mesurat abans | 4,96 | No mesurat abans → 842 |

El terra de les sales ja reutilitzava les textures. El cost principal era el retallat de cada segment de paret de galeria contra totes les sales a cada dibuix, la reconstrucció dels relleus i milers de crides per a superfícies i llums. S’han introduït geometria 2D agrupada i memòria cau, així com descart de galeries fora de pantalla. Es mantenen els materials, UV ancorades al món, obertures, quatre fanals i orientació dels llums de galeria.

Els caches són temporals, acotats per a galeries/grups i es descarten quan canvia la identitat del món o el nivell. Els trams coneguts, les sortides i l’estat d’il·luminació continuen decidint què es dibuixa a cada fotograma. Zoom i desplaçament reutilitzen geometria en coordenades del món.

## Verificació

- `scripts/render_benchmark.gd`: casos anteriors, invariància de món, màscara revelada, descobertes i posició; invalidació en canviar de nivell i substituir el món, superats.
- `scripts/floor_preview.gd`: 59 roques amb bloquejos, rutes alternatives i persistència; 3.066 punts de clic sobre els tres minerals; vuit perfils de bioma renderitzats, superats.
- Captura `parets_sala_galeria.png` inspeccionada: terra, parets, boques, formacions i llums presents. Captura de tot l’estrat a `rendiment_estrat_complet.png`.

La primera construcció de tota la geometria encara té un cost puntual: 21 ms en passar de l’entrada a la vista local amb tot descobert, i 269 ms la primera vegada que s’enquadra tot l’estrat d’aquesta prova. Els temps estables de la taula s’obtenen després de construir el cache. Els altres biomes mantenen la generació inicial de textures procedurals per sala; aquesta prova no en mesura el cost inicial. Pendent expedició interactiva llarga amb un desament avançat d’Albert.

Reproducció: executar Godot amb `--path C:/projectes/SubterraMars --script res://scripts/render_benchmark.gd`.
