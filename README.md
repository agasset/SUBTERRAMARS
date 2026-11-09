# SUBTERRA: MARS

Prototip executable en Godot 4.6.2, basat en la revisió visual 1.4 del disseny.

## Estat actual

- Mapa general superior amb 20 coves proceduralment generades, galeries corbes, selecció, escàner, revelació local i moviment per rutes transitables.
- Vista local isomètrica 2D per explorar una sala. Reutilitza la geometria, màscara transitable, coordenades i boira de guerra del mateix món.
- Generador determinista amb obstacles i bateria de validació de 51 llavors.
- Flora, fauna, robots, recursos, desament i progressió encara pendents.

## Com executar

Obre aquesta carpeta a Godot 4.6.2 o posterior i executa `scenes/main.tscn` (F6) o el projecte (F5).

Per validar la generació:

```powershell
godot --headless --path . --script res://scripts/seed_validation.gd
```

Per actualitzar les captures de viewport:

```powershell
godot --path . --script res://scripts/capture_viewport.gd
```

Les captures verificades s'emmagatzemen a `reports/`.

## Documents del projecte

- `AGENTS.md`: instruccions de treball i decisions vigents.
- `docs/SUBTERRA_DOCUMENT_MESTRE.md`: decisions de disseny i revisió 1.4.
- `docs/GUIA_VISUAL.md`: referències del mapa superior i la sala isomètrica.
- `docs/ARQUITECTURA_PROCEDURAL.md`: contractes de generació i dades.
- `docs/PLA_IMPLEMENTACIO.md`: fites executables.
- `docs/ESTAT_PROJECTE.md`: implementat, proves, limitacions i passos següents.
- `docs/referencies_visuals/`: dues imatges aportades per Albert com a referència; no són recursos de joc.
