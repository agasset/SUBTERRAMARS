extends Node2D
var mask: ImageTexture
var signature := 0
var reveal_elapsed := 2.0
var reveal_origin := Vector2.ZERO
var reveal_radius := 1.0
var reveal_level := -1
var reveal_seed := 0
var previous_mask: ImageTexture
const MASK_PADDING := 8
func begin_room_reveal(cave: Dictionary) -> void:
	if mask==null: return
	var game=get_parent()
	previous_mask=ImageTexture.create_from_image(mask.get_image())
	reveal_origin=game.unit_position
	reveal_radius=1.0
	for point in cave.contour: reveal_radius=maxf(reveal_radius,reveal_origin.distance_to(cave.position+point)+80.0)
	reveal_elapsed=0.0
	reveal_level=game.current_level
	reveal_seed=game.world.seed
func _ready() -> void:
	material = ShaderMaterial.new()
	material.shader = preload("res://shaders/cave_lighting.gdshader")
func _process(_delta: float) -> void:
	reveal_elapsed=minf(2.0,reveal_elapsed+_delta)
	queue_redraw()
func _draw() -> void:
	var game = get_parent()
	if game.surface_mode or not game.analysis_mode or game.world.is_empty(): return
	var key := hash([game.world.seed, game.current_level, game.revealed_mask, game.explored_caves])
	if mask == null or key != signature:
		signature = key
		var padded: Vector2i = game.world.grid_size+Vector2i.ONE*MASK_PADDING*2
		var bytes := PackedByteArray()
		bytes.resize(padded.x*padded.y)
		for y in range(game.world.grid_size.y):
			for x in range(game.world.grid_size.x):
				bytes[(y+MASK_PADDING)*padded.x+x+MASK_PADDING]=255 if game.revealed_mask[y*game.world.grid_size.x+x]!=0 else 0
		for cave in game.world.caves:
			if not game.explored_caves.has(cave.id): continue
			var bounds := Rect2(cave.position + cave.contour[0], Vector2.ZERO)
			for corner in cave.contour: bounds = bounds.expand(cave.position + corner)
			bounds = bounds.grow(70.0)
			var expanded := Geometry2D.offset_polygon(cave.contour, 20.0)
			var low := Vector2i((bounds.position / game.world.cell_size).floor()).max(-Vector2i.ONE*MASK_PADDING)
			var high := Vector2i((bounds.end / game.world.cell_size).ceil()).min(Vector2i(game.world.grid_size)+Vector2i.ONE*(MASK_PADDING-1))
			for y in range(low.y, high.y + 1):
				for x in range(low.x, high.x + 1):
					var point := (Vector2(x, y) + Vector2.ONE * 0.5) * float(game.world.cell_size) - Vector2(cave.position)
					# Include the already-known wall extrusion above a scanned floor.
					for polygon in expanded:
						if Geometry2D.is_point_in_polygon(point, polygon) or Geometry2D.is_point_in_polygon(point + Vector2(0, 40), polygon):
							bytes[(y+MASK_PADDING)*padded.x+x+MASK_PADDING] = 255
							break
		var image := Image.create_from_data(padded.x,padded.y,false,Image.FORMAT_R8,bytes)
		if mask != null and mask.get_size() == Vector2(image.get_size()): mask.update(image)
		else: mask = ImageTexture.create_from_image(image)
	var shader := material as ShaderMaterial
	var active: bool = reveal_elapsed<2.0 and reveal_level==game.current_level and reveal_seed==int(game.world.seed)
	shader.set_shader_parameter("reveal_progress",reveal_elapsed/2.0 if active else 1.0)
	shader.set_shader_parameter("previous_revealed",previous_mask if previous_mask!=null else mask)
	shader.set_shader_parameter("reveal_origin",reveal_origin)
	shader.set_shader_parameter("reveal_radius",reveal_radius)
	shader.set_shader_parameter("revealed", mask)
	shader.set_shader_parameter("screen_origin", game.call("_world_to_screen", Vector2.ZERO))
	shader.set_shader_parameter("zoom", game.zoom_level)
	shader.set_shader_parameter("grid_size", Vector2(game.world.grid_size)+Vector2.ONE*MASK_PADDING*2)
	shader.set_shader_parameter("mask_offset",Vector2.ONE*MASK_PADDING*float(game.world.cell_size))
	shader.set_shader_parameter("cell_size", game.world.cell_size)
	shader.set_shader_parameter("helmet", game.call("_world_to_screen", game.unit_position) - Vector2(0, 12.0 * game.zoom_level))
	shader.set_shader_parameter("facing", Vector2(game.explorer_facing.x, game.explorer_facing.y * 0.5))
	shader.set_shader_parameter("beam_on", game.flashlight_on and game.flashlight_charge > 0.0)
	shader.set_shader_parameter("beam_radius", game.call("_flashlight_radius") * game.zoom_level)
	var enemy: Dictionary=game.defence_system.predator(game,game._cave_at_position(game.unit_position))
	var hostile_visible: bool=not enemy.is_empty() and float(enemy.hp)>0 and bool(enemy.alert)
	shader.set_shader_parameter("hostile_on",hostile_visible)
	if hostile_visible:
		shader.set_shader_parameter("hostile",game._world_to_screen(enemy.position)-Vector2(0,7)*game.zoom_level)
	var blockers := PackedVector3Array()
	for detail in game.world.get("ambience_v1", []):
		if detail.kind != 1 or blockers.size() >= 8: continue
		if not game.explored_caves.has(detail.cave_id) and not game._is_revealed(detail.position): continue
		var point: Vector2 = game._world_to_screen(detail.position)
		if get_viewport_rect().grow(100).has_point(point):
			blockers.append(Vector3(point.x,point.y,9.0*game.zoom_level))
	shader.set_shader_parameter("blocker_count",blockers.size())
	blockers.resize(8)
	shader.set_shader_parameter("blockers",blockers)
	var positions := PackedVector2Array()
	var radii := PackedFloat32Array()
	var colors := PackedColorArray()
	var view := get_viewport_rect().grow(150)
	var profile: int = [1,4,7,10,13,16,19,20].find(game._biome_at_depth(game.current_level))
	var crystal_colors := [Color("ffb35b"),Color("78e9ff"),Color("a4eaff"),Color("a0e357"),Color("ff7847"),Color("73efce"),Color("ffe196"),Color("a9f5ff")]
	for detail in game.world.get("ambience_v1", []):
		if detail.kind != 0 or positions.size() >= 8: continue
		if not game.explored_caves.has(detail.cave_id) and not game._is_revealed(detail.position): continue
		var point: Vector2 = game._world_to_screen(detail.position)
		if not view.has_point(point): continue
		positions.append(point)
		radii.append(14.0*game.zoom_level)
		colors.append(crystal_colors[maxi(0,profile)])
	for cave in game.world.caves:
		if not game.call("_room_is_fully_lit", cave.id): continue
		for corner in game.call("_room_lantern_corners", cave.contour):
			var point: Vector2 = game.call("_world_to_screen", game.call("_room_lamp_anchor", cave, corner))
			if view.has_point(point) and positions.size() < 32:
				positions.append(point)
				radii.append(38.0 * game.zoom_level)
				colors.append(Color("ffba70"))
		for pool in game.call("_room_surface_details", cave):
			var point: Vector2 = game.call("_world_to_screen", pool.position)
			if view.has_point(point) and positions.size() < 32:
				positions.append(point)
				radii.append(22.0 * game.zoom_level)
				colors.append(Color("55d4df"))
	for corridor in game.world.corridors:
		if not game.completed_gallery_traces.has(corridor.id): continue
		for i in range(0, corridor.points.size(), 12):
			var point: Vector2 = game.call("_world_to_screen", corridor.points[i])
			if view.has_point(point) and positions.size() < 32:
				positions.append(point)
				radii.append(24.0 * game.zoom_level)
				colors.append(Color("ffba70"))
	# Pad fixed-size shader arrays without introducing phantom lights.
	var count := positions.size()
	positions.resize(32); radii.resize(32); colors.resize(32)
	shader.set_shader_parameter("light_count", count)
	shader.set_shader_parameter("lamps", positions)
	shader.set_shader_parameter("radii", radii)
	shader.set_shader_parameter("inks", colors)
	draw_rect(get_viewport_rect(), Color.WHITE)
