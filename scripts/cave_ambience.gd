extends RefCounted
static var atlases: Array[Texture2D] = []
static var floor_meshes: Dictionary = {}
const MeshBuilder = preload("res://scripts/cave_wall_mesh.gd")

static func draw_gallery_relief(game, edges: Dictionary, fade: bool) -> void:
	# Fading exit stubs retain their existing alpha profile.
	if fade: return
	var contour: PackedVector2Array = edges.left.duplicate()
	var right: PackedVector2Array = edges.right.duplicate()
	right.reverse()
	contour.append_array(right)
	var origin: Vector2 = contour[0]
	for i in range(contour.size()): contour[i] -= origin
	draw_floor_relief(game,{"id":hash([edges.left,edges.right]),"position":origin,"contour":contour,"radius":35.0,"relief_margin":3.0,"relief_size":0.45},Color.WHITE)

static func draw_floor_relief(game, cave: Dictionary, tint: Color) -> void:
	var key := hash([game.world.seed,game.current_level,cave.id])
	var texture: Texture2D = game._get_cave_room_floor_texture(cave.id)
	if not floor_meshes.has(key):
		var top := MeshBuilder._builder()
		var sides := MeshBuilder._builder()
		var rng := RandomNumberGenerator.new()
		rng.seed = hash([game.world.seed,cave.id,"floor_relief_v1"])
		var palette: Array = game.BIOME_ROCK[game._biome_at_depth(game.current_level)]
		var bounds := Rect2(cave.contour[0],Vector2.ZERO)
		for corner in cave.contour: bounds = bounds.expand(corner)
		for attempt in range(clampi(int(cave.radius),25,90)):
			var center: Vector2 = cave.position + Vector2(rng.randf_range(bounds.position.x,bounds.end.x),rng.randf_range(bounds.position.y,bounds.end.y))
			if not Geometry2D.is_point_in_polygon(center-cave.position,cave.contour) or game._distance_to_cave_boundary(center,cave)<float(cave.get("relief_margin",14.0)): continue
			if game._decoration_near_fixture(center,cave): continue
			var height := rng.randf_range(0.35,1.2)
			var radius := Vector2(rng.randf_range(4.0,10.0),rng.randf_range(3.0,7.0))
			radius *= float(cave.get("relief_size",1.0))
			var points := PackedVector2Array()
			var clear := true
			var corners := rng.randi_range(5,9)
			var rotation := rng.randf_range(0,TAU)
			for i in range(corners):
				var angle := rotation + float(i)*TAU/float(corners)
				var point := center + Vector2(cos(angle),sin(angle))*radius*rng.randf_range(0.78,1.15)
				if not Geometry2D.is_point_in_polygon(point-cave.position,cave.contour): clear = false
				points.append(point)
			if not clear: continue
			var ink := Color.WHITE * rng.randf_range(0.90,1.10)
			ink.a = 1.0
			var pivot: Vector2 = game._render_project_delta(center-cave.position)-Vector2(0,height)
			for i in range(points.size()):
				var a := points[i]
				var b := points[(i+1)%points.size()]
				var ground_a: Vector2 = game._render_project_delta(a-cave.position)
				var ground_b: Vector2 = game._render_project_delta(b-cave.position)
				var lift := Vector2(0,height)
				MeshBuilder._triangle(top,PackedVector2Array([pivot,ground_a-lift,ground_b-lift]),PackedColorArray([ink]),PackedVector2Array([game._floor_material_uv(center,texture),game._floor_material_uv(a,texture),game._floor_material_uv(b,texture)]))
				MeshBuilder._quad(sides,PackedVector2Array([ground_a,ground_b,ground_b-lift,ground_a-lift]),PackedColorArray([Color(palette[0]).darkened(0.1),Color(palette[0]).darkened(0.1),Color(palette[1]),Color(palette[1])]))
		if floor_meshes.size()>=512: floor_meshes.clear()
		floor_meshes[key] = [MeshBuilder._mesh(sides),MeshBuilder._mesh(top)]
	var meshes: Array = floor_meshes[key]
	var transform: Transform2D = game._render_mesh_transform(cave.position)
	for i in range(2):
		if meshes[i].get_surface_count()>0: game.draw_mesh(meshes[i],null if i==0 else texture,transform,tint)

# Persistent deterministic placements; rendering never changes navigation.
static func ensure(game) -> void:
	if game.world.has("ambience_v1"):
		preload("res://scripts/cave_wet_features.gd").migrate_drips(game)
		preload("res://scripts/biome_landmarks.gd").ensure(game)
		return
	var details: Array = []
	var mask: PackedByteArray = game.world.walkable_mask.duplicate()
	var grid: Vector2i = game.world.grid_size
	var step: float = game.world.cell_size
	for cave in game.world.caves:
		var rng := RandomNumberGenerator.new()
		rng.seed = hash([game.world.seed, cave.id, "biome_ambience_v1"])
		var bounds := Rect2(cave.position + cave.contour[0], Vector2.ZERO)
		for corner in cave.contour: bounds = bounds.expand(cave.position + corner)
		var placed: Array = []
		var target := clampi(int(cave.radius / 12.0), 4, 10)
		for attempt in range(384):
			if placed.size() >= target: break
			var cell := Vector2i(Vector2(rng.randf_range(bounds.position.x,bounds.end.x),rng.randf_range(bounds.position.y,bounds.end.y)) / step)
			var point := (Vector2(cell) + Vector2.ONE * 0.5) * step
			var kind := attempt % 4
			var radius := 2 if kind == 1 else 1
			if not game._point_inside_cave_id(point,cave.id) or game._distance_to_cave_boundary(point,cave) < 22: continue
			if point.distance_to(game.unit_position) < 30 or game._decoration_near_fixture(point,cave): continue
			if (cave.id == game.descent_access or cave.id == game.world.entry) and point.distance_to(game._level_access_position(cave.id)) < 42: continue
			var clear := true
			# A complete open ring around the blocked footprint guarantees a detour.
			for y in range(-radius,radius+1):
				for x in range(-radius,radius+1):
					var c := cell + Vector2i(x,y)
					if c.x < 0 or c.y < 0 or c.x >= grid.x or c.y >= grid.y or mask[c.y*grid.x+c.x] == 0: clear = false
			for sites in [game.flora_sites,game.fauna_sites,game.material_sites]:
				if sites.has(cave.id) and point.distance_to(sites[cave.id]) < 28: clear = false
			for rock in game.world.get("solid_room_rocks_v1",[]):
				if point.distance_to(rock.position) < (28 if kind == 1 else 22): clear = false
			for other in placed:
				if point.distance_to(other.position) < (32 if kind == 1 or other.kind == 1 else 24): clear = false
			for pool in game._room_surface_details(cave):
				if point.distance_to(pool.position) < 26: clear = false
			if not clear: continue
			var blocked: Array[Vector2i] = [cell]
			if kind == 1: blocked.append_array([cell+Vector2i.LEFT,cell+Vector2i.RIGHT])
			for c in blocked: mask[c.y*grid.x+c.x] = 0
			var item := {"position":point,"kind":kind,"cave_id":cave.id,"variant":rng.randi_range(0,2),"blocked_cells":blocked}
			placed.append(item)
			details.append(item)
	game.world.walkable_mask = mask
	game.world["ambience_v1"] = details
	game.fauna_safe_paths.clear()
	preload("res://scripts/cave_wet_features.gd").migrate_drips(game)
	preload("res://scripts/biome_landmarks.gd").ensure(game)

static func draw(game, detail: Dictionary, force_hole: bool = false) -> void:
	if detail.get("landmark",false):
		preload("res://scripts/biome_landmarks.gd").draw(game,detail)
		return
	var profile := [1,4,7,10,13,16,19,20].find(game._biome_at_depth(game.current_level))
	if atlases.is_empty():
		atlases.assign([load("res://assets/sprites/ambient_coves_1.png"),load("res://assets/sprites/ambient_coves_2.png")])
	var texture: Texture2D = atlases[0 if profile < 4 else 1]
	var kind: int = 2 if force_hole else detail.kind
	if kind==3:
		preload("res://scripts/cave_wet_features.gd").draw_drip(game,detail,texture,profile)
		return
	# The tall pillars need more vertical canvas than crystals and pit rims.
	var starts := [0.0,180.0,510.0,730.0]
	var ends := [180.0,510.0,730.0,1024.0]
	var factor := Vector2(texture.get_size()) / Vector2(1536,1024)
	var source := Rect2(Vector2((profile % 4)*384,starts[kind])*factor,Vector2(384,ends[kind]-starts[kind])*factor)
	var widths := [17.0,30.0,24.0,17.0]
	var width: float = widths[kind] * (1.0 + 0.10 * int(detail.get("variant",0)))
	var size: Vector2 = Vector2(width,width * source.size.y / source.size.x) * game.zoom_level
	var contact := Vector2(0.5,0.55 if kind == 2 else 0.92)
	var rect := Rect2((game._world_to_screen(detail.position) - size * contact).round(),size)
	game.draw_texture_rect_region(texture,rect,source,Color.WHITE,false,true)
	if kind == 0:
		var pulse := 0.5 + 0.5*sin(game.fauna_time*1.8 + detail.position.x)
		var light: Color = [Color("ffc271"),Color("8bedf4"),Color("b2eeff"),Color("b8ee6f"),Color("ff9858"),Color("89f4cf"),Color("ffe5a3"),Color("b0f4ff")][profile]
		light.a = 0.3 + pulse*0.4
		var spark: Vector2 = game._world_to_screen(detail.position) - Vector2(0,3.5)*game.zoom_level
		game.draw_line(spark-Vector2(1.3,0)*game.zoom_level,spark+Vector2(1.3,0)*game.zoom_level,light,1,false)
		game.draw_line(spark-Vector2(0,1.3)*game.zoom_level,spark+Vector2(0,1.3)*game.zoom_level,light,1,false)
	if kind == 3:
		var phase := fposmod(game.fauna_time*0.6 + detail.position.x,1.0)
		var drop: Vector2 = game._world_to_screen(detail.position) - Vector2(0,8.0*(1-phase))*game.zoom_level
		game.draw_rect(Rect2(drop.round(),Vector2(0.4,0.7)*game.zoom_level),Color("8ac9dc"))
