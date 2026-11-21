extends RefCounted

# Passive exterior dressing. The elevator/player and all world state stay in main.
const LANDSCAPE = preload("res://assets/textures/terreny_marcia_isometric.png")
const MODULES = preload("res://assets/sprites/base_exterior_moduls.png")
const DECK = preload("res://assets/textures/paviment_base_exterior.png")
const ROCKS = preload("res://assets/sprites/roques_variants.png")
const LANTERN = preload("res://assets/sprites/fanals.png")
const FLOOR_LIGHT = preload("res://assets/sprites/llum_galeria.png")

var decoration_seed := -1
var rocks: Array[Dictionary] = []
var module_hit_image: Image
const MODULE_ENTRIES := [
	{"source": Rect2(810,5,650,530), "point": Vector2(70,-280), "width":235.0, "action":"catalog"},
	{"source": Rect2(70,65,650,465), "point": Vector2(-160,-180), "width":230.0, "action":"inventory"},
	{"source": Rect2(65,580,650,400), "point": Vector2(265,-140), "width":175.0, "action":"workshop"},
	{"source": Rect2(830,560,550,425), "point": Vector2(-230,60), "width":115.0, "action":"workshop"},
]

func module_action_at(point: Vector2, hatch: Vector2, scale: float) -> String:
	if module_hit_image == null: module_hit_image = MODULES.get_image()
	for i in range(MODULE_ENTRIES.size() - 1, -1, -1):
		var module: Dictionary = MODULE_ENTRIES[i]
		var source: Rect2 = module.source
		var size := Vector2(module.width, module.width * source.size.y / source.size.x) * scale
		var area := Rect2((_point(module.point,hatch,scale) - size * Vector2(0.5,0.96)).round(),size)
		if not area.has_point(point): continue
		var uv := (point-area.position)/area.size
		var pixel := Vector2i(source.position + uv * source.size)
		if module_hit_image.get_pixelv(pixel).a >= 0.2: return module.action
	return ""

func _point(local: Vector2, origin: Vector2, scale: float) -> Vector2:
	return origin + Vector2(local.x, local.y * 0.5) * scale

func _sprite(canvas: CanvasItem, texture: Texture2D, source: Rect2,
		feet: Vector2, width: float, anchor: Vector2 = Vector2(0.5, 0.96), tint: Color = Color.WHITE) -> void:
	var size := Vector2(width, width * source.size.y / source.size.x)
	canvas.draw_texture_rect_region(texture, Rect2((feet - size * anchor).round(), size), source, tint, false, true)

func _prepare_rocks(seed_value: int) -> void:
	if decoration_seed == seed_value:
		return
	decoration_seed = seed_value
	rocks.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([seed_value, "surface_pixel_art_rocks_v1"])
	for i in range(28):
		var point := Vector2(rng.randf_range(-550, 550), rng.randf_range(-300, 490))
		if Rect2(-385, -505, 770, 740).has_point(point):
			continue
		rocks.append({"point": point, "width": rng.randf_range(25, 55), "variant": rng.randi_range(0, 6)})

func _floor_light(canvas: CanvasItem, position: Vector2, origin: Vector2, scale: float) -> void:
	var source := Rect2(360, 785, 535, 340)
	var texture_size := Vector2(FLOOR_LIGHT.get_size())
	var points := PackedVector2Array()
	for corner in [Vector2(-5, -5), Vector2(5, -5), Vector2(5, 5), Vector2(-5, 5)]:
		points.append(_point(position + corner, origin, scale))
	var uv := PackedVector2Array([source.position / texture_size,
		Vector2(source.end.x, source.position.y) / texture_size, source.end / texture_size,
		Vector2(source.position.x, source.end.y) / texture_size])
	canvas.draw_polygon(points, PackedColorArray([Color.WHITE]), uv, FLOOR_LIGHT)

func draw(canvas: CanvasItem, viewport_size: Vector2, hatch: Vector2, scale: float, seed_value: int) -> void:
	var image_size := Vector2(LANDSCAPE.get_size())
	var cover := maxf(viewport_size.x / image_size.x, viewport_size.y / image_size.y)
	var backdrop_size := image_size * cover
	canvas.draw_texture_rect(LANDSCAPE, Rect2((viewport_size - backdrop_size) * 0.5, backdrop_size), false)
	_prepare_rocks(seed_value)
	var cell := Vector2(ROCKS.get_size()) / Vector2(4, 2)
	for rock in rocks:
		var variant: int = rock.variant
		var source := Rect2(Vector2(variant % 4, floori(float(variant) / 4)) * cell, cell)
		_sprite(canvas, ROCKS, source, _point(rock.point, hatch, scale), float(rock.width) * scale,
			Vector2(0.5, 0.9), Color("ad7056"))
	# A flat service apron, projected with the same ground transform as its lights.
	var local_pad := PackedVector2Array([Vector2(-350, -170), Vector2(-260, -430),
		Vector2(120, -470), Vector2(365, -210), Vector2(340, 70),
		Vector2(150, 185), Vector2(-170, 185), Vector2(-350, 50)])
	var pad := PackedVector2Array()
	var uv := PackedVector2Array()
	for point in local_pad:
		pad.append(_point(point, hatch, scale))
		uv.append(point / 160.0)
	var edge := pad.duplicate()
	for i in range(edge.size()):
		edge[i] += Vector2(0, 2.0 * scale)
	canvas.draw_colored_polygon(edge, Color("211b20"))
	canvas.draw_polygon(pad, PackedColorArray([Color("c5aaa0")]), uv, DECK)
	# Small recessed approach lights guide the eye to the real elevator.
	for step in range(4):
		for side in [-1, 1]:
			_floor_light(canvas, Vector2(side * 24, -40 - step * 40), hatch, scale)
	# Back-to-front order is based on each module's ground contact.
	for module in MODULE_ENTRIES:
		_sprite(canvas, MODULES, module.source, _point(module.point, hatch, scale), module.width * scale)
	for lamp in [Vector2(-310, -110), Vector2(330, -90), Vector2(-170, 160), Vector2(170, 155)]:
		var feet := _point(lamp, hatch, scale)
		canvas.draw_colored_polygon(_ellipse(feet, Vector2(18, 7) * scale), Color(1.0, 0.65, 0.32, 0.08))
		_sprite(canvas, LANTERN, Rect2(310, 35, 275, 790), feet, 12 * scale, Vector2(0.5, 0.98))
	for item in [[Vector2(-160, -150), "HÀBITAT"], [Vector2(70, -250), "CONTROL"], [Vector2(265, -110), "ENERGIA"], [Vector2(-230,90), "TALLER"]]:
		var position := _point(item[0], hatch, scale)
		var text_scale := clampf(scale, 0.85, 1.8)
		canvas.draw_string_outline(ThemeDB.fallback_font, position + Vector2(-40, 6) * text_scale,
			item[1], HORIZONTAL_ALIGNMENT_CENTER, 80 * text_scale, roundi(10 * text_scale), 3, Color("10151a"))
		canvas.draw_string(ThemeDB.fallback_font, position + Vector2(-40, 6) * text_scale,
			item[1], HORIZONTAL_ALIGNMENT_CENTER, 80 * text_scale, roundi(10 * text_scale), Color("b7c8c9"))

func _ellipse(center: Vector2, extent: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(20):
		points.append(center + Vector2.from_angle(TAU * float(i) / 20) * extent)
	return points
