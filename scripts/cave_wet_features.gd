extends RefCounted

static func wall_anchor(game, cave: Dictionary, near: Vector2, used: Array = []) -> Dictionary:
	var contour: PackedVector2Array = cave.contour
	var area := 0.0
	for i in range(contour.size()): area += contour[i].cross(contour[(i+1)%contour.size()])
	var best := {}
	var distance := INF
	for i in range(contour.size()):
		var a: Vector2 = cave.position+contour[i]
		var b: Vector2 = cave.position+contour[(i+1)%contour.size()]
		var axis := (b-a).normalized()
		var inward := Vector2(-axis.y,axis.x)*(1.0 if area>=0 else -1.0)
		if inward.y<0.65: continue # Avoid flattening a hanging formation against a cutaway side wall.
		for ratio in [0.25,0.5,0.75]:
			var anchor := a.lerp(b,ratio)
			var foot := anchor+inward*7.0
			if not game._point_inside_cave_id(foot,cave.id) or game._decoration_near_fixture(foot,cave): continue
			var clear := true
			for point: Vector2 in used:
				if foot.distance_to(point)<26: clear=false
			if not clear: continue
			var score := anchor.distance_squared_to(near)
			if score>=distance: continue
			distance=score
			var phase := float(posmod(int(game.world.seed),997))
			var noise := 0.5+sin(anchor.x*0.12+anchor.y*0.08+phase)*0.28+sin(anchor.x*0.31-anchor.y*0.18)*0.12
			best={"anchor":anchor,"inward":inward,"foot":foot,"height":17.0*inward.y*(0.72+noise*0.56)}
	return best

static func migrate_drips(game) -> void:
	if game.world.has("wet_walls_v3"): return
	var used: Array = []
	for item in game.world.get("ambience_v1",[]):
		if item.kind!=3: continue
		var wall := wall_anchor(game,game.world.caves[item.cave_id],item.position,used)
		if wall.is_empty():
			item.kind=0
			continue
		for cell in item.get("blocked_cells",[]):
			game.world.walkable_mask[cell.y*game.world.grid_size.x+cell.x]=1
		item.blocked_cells=[] # The ceiling formation and its shallow puddle are traversable below.
		item.position=wall.foot
		item.wall_anchor=wall.anchor
		item.wall_height=wall.height
		used.append(item.position)
	game.world["wet_walls_v3"]=true
	game.fauna_safe_paths.clear()

static func pools(game, cave: Dictionary) -> Array:
	var result: Array = []
	var rng := RandomNumberGenerator.new()
	rng.seed=hash([game.world.seed,cave.id,"wall_pools_v2"])
	var room := PackedVector2Array()
	for point in cave.contour: room.append(cave.position+point)
	var used: Array = []
	for attempt in range(24):
		if result.size()>=(2 if float(cave.radius)>110 else 1): break
		var near: Vector2 = cave.position+cave.contour[rng.randi_range(0,cave.contour.size()-1)]
		var wall := wall_anchor(game,cave,near,used)
		if wall.is_empty(): continue
		var length := rng.randf_range(52,68)
		var width := rng.randf_range(64,82)
		var inward: Vector2 = wall.inward
		var tangent := Vector2(inward.y,-inward.x)
		# An overhead decal follows the ground basis, never a standing billboard.
		# Its short stream ends at the back edge; keep image handedness intact.
		var u := tangent*width
		var v := inward*length
		var origin: Vector2 = wall.anchor-u*0.5-v*0.08
		var center := origin+u*0.5+v*0.55
		if game._decoration_near_fixture(center,cave): continue
		var clear := true
		for other in result:
			if center.distance_to(other.position)<68: clear=false
		if not clear: continue
		var quad := PackedVector2Array([origin,origin+u,origin+u+v,origin+v])
		# Keep the shoreline clear of existing solid decorations and the base.
		for rock in game.world.get("solid_room_rocks_v1",[]):
			if rock.cave_id==cave.id and _near_patch(rock.position,quad,maxf(22.0,float(rock.get("visual_radius",rock.radius))*1.8)): clear=false
		for obstacle in game.world.get("obstacles",[]):
			if _near_patch(obstacle.position,quad,float(obstacle.radius)*1.8+10.0): clear=false
		for item in game.world.get("ambience_v1",[]):
			if item.cave_id==cave.id and item.kind!=3 and _near_patch(item.position,quad,14.0): clear=false
		if cave.id==game.world.entry and game.world.has("base_solid_footprint_v1"):
			if not Geometry2D.intersect_polygons(quad,game.world.base_solid_footprint_v1).is_empty(): clear=false
		if not clear: continue
		var pieces := Geometry2D.intersect_polygons(quad,room)
		var transform := Transform2D(u,v,origin).affine_inverse()
		for shape in pieces:
			if shape.size()<3 or not Geometry2D.is_point_in_polygon(center,shape): continue
			for sites in [game.flora_sites,game.fauna_sites,game.material_sites]:
				if sites.has(cave.id) and _near_patch(sites[cave.id],shape,28.0): clear=false
			if not clear: continue
			if (cave.id==game.world.entry or cave.id==game.descent_access) and Geometry2D.is_point_in_polygon(game._level_access_position(cave.id),shape): continue
			var uvs := PackedVector2Array()
			for point in shape: uvs.append(transform*point)
			result.append({"position":center,"shape":shape,"local_uvs":uvs,"wall_anchor":wall.anchor,"thin_end":origin+u*0.5+v*0.08,"ground_u":u,"ground_v":v})
			used.append(wall.foot)
			break
	return result

static func _near_patch(point: Vector2, polygon: PackedVector2Array, margin: float) -> bool:
	if Geometry2D.is_point_in_polygon(point,polygon): return true
	for i in range(polygon.size()):
		if point.distance_to(Geometry2D.get_closest_point_to_segment(point,polygon[i],polygon[(i+1)%polygon.size()]))<margin: return true
	return false

static func draw_drip(game, item: Dictionary, texture: Texture2D, profile: int) -> void:
	if not item.has("wall_anchor"): return
	var factor := Vector2(texture.get_size())/Vector2(1536,1024)
	var source := Rect2(Vector2((profile%4)*384,730)*factor,Vector2(384,175)*factor)
	var height: float = minf(36.0*175.0/384.0,float(item.wall_height)*0.90)*game.zoom_level
	var width: float = height*384.0/175.0
	var top: Vector2 = game._world_to_screen(item.wall_anchor)-Vector2(0,float(item.wall_height)*game.zoom_level)
	game.draw_texture_rect_region(texture,Rect2((top-Vector2(width*0.5,0)).round(),Vector2(width,height)),source)
	var foot: Vector2 = game._world_to_screen(item.position)
	var pool_size: Vector2 = Vector2(44,8)*game.zoom_level
	source=Rect2(Vector2((profile%4)*384,945)*factor,Vector2(384,79)*factor)
	game.draw_texture_rect_region(texture,Rect2((foot-pool_size*Vector2(0.5,0.65)).round(),pool_size),source)
	var phase := fposmod(game.fauna_time*0.65+item.position.x,1.0)
	var drop := (top+Vector2(0,height*0.78)).lerp(foot,phase)
	game.draw_rect(Rect2(drop.round(),Vector2(0.5,1.0)*game.zoom_level),Color("9ce3f1"))
