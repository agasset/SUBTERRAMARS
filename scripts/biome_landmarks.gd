extends RefCounted
static var atlas: Texture2D
const NAMES := ["Arc de corall fèrric","Geoda en ventall","Cascada de gel","Bolet de les espores","Fumarola basàltica","Membrana bioluminescent","Anells erosionats","Prisma magnètic"]

static func ensure(game) -> void:
	if game.world.has("unique_landmark_v1"): return
	for item in game.world.get("ambience_v1",[]):
		if item.kind!=1 or item.cave_id in [game.world.entry,game.descent_access]: continue
		item.landmark=true
		game.world["unique_landmark_v1"]=item.duplicate(true)
		return
	for rock in game.world.get("solid_room_rocks_v1",[]):
		if rock.cave_id in [game.world.entry,game.descent_access] or rock.get("visual_radius",0)<10: continue
		rock.landmark=true
		game.world["unique_landmark_v1"]={"position":rock.position,"cave_id":rock.cave_id,"landmark":true}
		return
	game.world["unique_landmark_v1"]={}

static func draw(game,item: Dictionary) -> void:
	if atlas==null: atlas=load("res://assets/sprites/singularitats_biomes.png")
	var profile := [1,4,7,10,13,16,19,20].find(game._biome_at_depth(game.current_level))
	var cell := Vector2(atlas.get_size())/Vector2(4,2)
	var source := Rect2(Vector2(profile%4,floori(float(profile)/4))*cell,cell)
	var size: Vector2 = Vector2(38,38*cell.y/cell.x)*game.zoom_level
	game.draw_texture_rect_region(atlas,Rect2((game._world_to_screen(item.position)-size*Vector2(0.5,0.90)).round(),size),source)
