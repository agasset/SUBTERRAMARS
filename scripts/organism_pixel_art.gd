extends RefCounted

# Rendering only: recipes, sites, movement and discovery remain owned by the game.
const PLANT = preload("res://assets/sprites/flora_peces_netes.png")
const BODY = preload("res://assets/sprites/fauna_cossos_orientats.png")
const LIMBS = preload("res://assets/sprites/fauna_apendixs.png")
const Traits = preload("res://scripts/organism_traits.gd")

static func supports_plant(id: String) -> bool:
	return not plant_recipe(id).is_empty()

static func plant_recipe(id: String) -> Dictionary:
	var recipe := Traits.decode(id, Traits.PLANT)
	if not recipe.is_empty():
		return recipe
	# Older saves and UI family icons have no encoded recipe. Keep their IDs intact.
	var families := {
		"falguera": [0, 2, 1, 0, 1, 1, 0, 1],
		"coral": [2, 3, 2, 2, 1, 1, 1, 1],
		"molsa_ferrica": [3, 4, 0, 3, 0, 2, 2, 0],
		"coral_prismatic": [2, 3, 2, 1, 1, 1, 1, 2],
		"molsa_glacial": [3, 4, 0, 1, 0, 2, 2, 1],
		"falguera_jardi": [0, 3, 1, 0, 2, 1, 0, 1],
		"coral_termic": [2, 3, 2, 4, 1, 1, 1, 2],
		"molsa_abissal": [3, 4, 0, 2, 0, 2, 2, 2],
		"coral_llindar": [2, 3, 2, 3, 1, 1, 1, 2],
		"falguera_nucli": [0, 3, 1, 5, 2, 1, 0, 2],
	}
	if not families.has(id):
		return {}
	for i in range(Traits.PLANT.size()):
		recipe[Traits.PLANT.keys()[i]] = families[id][i]
	return recipe

static func supports_animal(id: String) -> bool:
	return not animal_recipe(id).is_empty()

static func animal_recipe(id: String) -> Dictionary:
	var recipe := Traits.decode(id, Traits.ANIMAL)
	if not recipe.is_empty():
		recipe.legs += 1
		recipe.fur = recipe.fur == 1
		return recipe
	var fields := id.split("~")
	if fields.size() == 7 and fields[1] == "1":
		return {"legs": clampi(fields[2].to_int(), 1, 4), "color": clampi(fields[3].to_int(), 0, 5),
			"fur": fields[4] == "1", "size": clampi(fields[5].to_int(), 0, 4),
			"pattern": clampi(fields[6].to_int(), 0, 3)}
	var families := {"escarabat": 0, "isopode": 3, "escarabat_ferric": 1,
		"isopode_cristalli": 4, "isopode_glacial": 3, "escarabat_jardi": 2,
		"escarabat_termic": 1, "isopode_abissal": 4, "escarabat_llindar": 0, "isopode_nucli": 5}
	if not families.has(id):
		return {}
	return {"legs": 4, "color": families[id], "fur": false, "size": 2,
		"pattern": 0, "armor": 1 if id.begins_with("isopode") else 0,
		"antennae": 1, "tail": 0}

static func plant_hit_rect(base: Vector2, scale: float, recipe: Dictionary) -> Rect2:
	var height := (13.0 + int(recipe.size) * 5.0) * 1.12 * 0.67 + 9.0
	return Rect2(base - Vector2(16, height) * scale, Vector2(32, height + 5) * scale)

static func animal_hit_rect(base: Vector2, scale: float, recipe: Dictionary) -> Rect2:
	var unit := scale * (0.78 + 0.11 * int(recipe.size))
	return Rect2(base - Vector2(18, 28) * unit, Vector2(36, 44) * unit)

static func _piece(canvas: CanvasItem, texture: Texture2D, grid: Vector2, index: int,
		point: Vector2, extent: float, tint: Color, anchor: Vector2 = Vector2(0.5, 0.85),
		flip_x: bool = false, flip_y: bool = false) -> void:
	var cell := Vector2(texture.get_size()) / grid
	var source := Rect2(Vector2(index % int(grid.x), floori(float(index) / grid.x)) * cell, cell)
	var size := Vector2(extent, extent * cell.y / cell.x)
	var rect := Rect2((-size * anchor).round(), size)
	canvas.draw_set_transform(point.round(), 0.0, Vector2(-1 if flip_x else 1, -1 if flip_y else 1))
	canvas.draw_texture_rect_region(texture, rect, source, tint, false, true)
	canvas.draw_set_transform(Vector2.ZERO)

static func draw_plant(canvas: CanvasItem, base: Vector2, scale: float,
		recipe: Dictionary, clock: float, identity: int = 0, ghost: bool = false) -> void:
	var tint := Color(0.72,0.9,0.96,0.55) if ghost else Color(Traits.PLANT_COLORS[int(recipe.color)])
	var count := int(recipe.stems) + 1
	var height := (13.0 + int(recipe.size) * 5.0) * scale
	var phase := clock * 1.3 + float(identity % 31)
	# Fixed roots and stalks; leaf/tip poses change in discrete frames, never stretch.
	_piece(canvas, PLANT, Vector2(4, 3), 0, base, 13 * scale, tint.darkened(0.45))
	for i in range(count):
		var spread := 0.0 if count == 1 else float(i) / float(count - 1) * 2.0 - 1.0
		var root := base + Vector2(spread * 7, absf(spread) * -1.5) * scale
		var stalk_height := height * (1.0 - absf(spread) * 0.15)
		match int(recipe.form):
			1: root.x += spread * 3 * scale; stalk_height *= 0.75
			2: stalk_height *= 1.12
			3: stalk_height *= 0.6
		var stem_index := 1 if int(recipe.texture) == 0 else (8 if int(recipe.texture) == 1 else 9)
		_piece(canvas, PLANT, Vector2(4, 3), stem_index, root, stalk_height, tint.darkened(0.3))
		var top := root - Vector2(0, stalk_height * 0.67)
		var frame := int(floor(clock * 3 + i + identity % 7)) % 4
		var flutter := Vector2(0, -1 if frame == 1 else 0) * maxf(1, roundf(scale * 0.4))
		var leaf_index: int = [2, 3, 4][int(recipe.leaf)]
		for side in [-1, 1]:
			var leaf := root.lerp(top, 0.48 if side < 0 else 0.7) + flutter
			_piece(canvas, PLANT, Vector2(4, 3), leaf_index, leaf, 11 * scale, tint,
				Vector2(0.62, 0.88), side > 0)
		var tip_index: int = [5, 6, 7][int(recipe.tip)]
		if frame >= 2 and int(recipe.tip) > 0:
			tip_index = 10 if int(recipe.tip) == 1 else 11
		if int(recipe.glow) > 0 and not ghost:
			var glow := Color(tint, (0.04 + 0.02 * sin(phase + i)) * int(recipe.glow))
			canvas.draw_circle(top, (3 + int(recipe.glow)) * scale, glow)
		_piece(canvas, PLANT, Vector2(4, 3), tip_index, top, 9 * scale,
			tint.lerp(Color.WHITE, 0.12 * int(recipe.glow)))

static func facing_index(direction: Vector2) -> int:
	if direction.y >= 0:
		return 0 if direction.x >= 0 else 1
	return 3 if direction.x >= 0 else 2

static func draw_animal(canvas: CanvasItem, base: Vector2, scale: float, recipe: Dictionary,
		direction: Vector2, clock: float, walking: bool, colors: Array) -> void:
	var tint := Color(colors[int(recipe.color)])
	var unit := scale * (0.78 + 0.11 * int(recipe.size))
	var facing := facing_index(direction)
	var axis := Vector2(0.85 if facing in [0, 3] else -0.85, 0.5 if facing < 2 else -0.5)
	var across := Vector2(-axis.y, axis.x * 0.5)
	var gait := int(floor(clock * (5.0 + int(recipe.get("movement", 0)) * 2))) % 4 if walking else 0
	var tail := int(recipe.get("tail", 0))
	if tail > 0:
		_piece(canvas, LIMBS, Vector2(4, 4), 5 + tail, base - axis * 6 * unit,
			11 * unit, tint.darkened(0.15), Vector2(0.65, 0.3), facing in [1, 2], facing >= 2)
	# Alternating foot poses, one visible limb per procedural leg.
	for leg in range(int(recipe.legs)):
		var side := -1 if leg % 2 == 0 else 1
		var offset := axis * (-2.5 if leg < 2 else 2.5) + across * side * 3
		var pose := (gait + (2 if leg % 2 == 0 else 0)) % 4
		_piece(canvas, LIMBS, Vector2(4, 4), pose + (12 if side < 0 else 0),
			base + offset * unit, 12 * unit, tint.darkened(0.12), Vector2(0.7 if side < 0 else 0.3, 0.25))
	var armor := int(recipe.get("armor", 0))
	var row := 3 if recipe.fur and armor == 0 else armor
	_piece(canvas, BODY, Vector2(4, 4), row * 4 + facing,
		base, 24 * unit, tint, Vector2(0.5, 0.72))
	if recipe.fur and armor > 0:
		for side in [-1, 1]:
			_piece(canvas, LIMBS, Vector2(4, 4), 11, base + across * side * 5 * unit,
			8 * unit, tint, Vector2(0.5, 0.75), side < 0)
	var pattern := int(recipe.pattern)
	if pattern > 0:
		_piece(canvas, LIMBS, Vector2(4, 4), 7 + pattern, base - Vector2(0, 3) * unit,
			12 * unit, tint.lightened(0.5), Vector2(0.5, 0.6), facing in [1, 3])
	var antennae := int(recipe.get("antennae", 0))
	if antennae > 0:
		for side in [-1, 1]:
			var head: Vector2 = base + (axis * 6 + across * side * 1.5) * unit - Vector2(0, 2) * unit
			_piece(canvas, LIMBS, Vector2(4, 4), 3 + antennae, head,
				(8 + antennae * 2) * unit, tint.lightened(0.12), Vector2(0.35, 0.75), facing in [1, 2])
