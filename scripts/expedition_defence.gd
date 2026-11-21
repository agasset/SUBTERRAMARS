extends RefCounted

const FAMILIES := {1:"depredador_oxidat",4:"depredador_cristalli",7:"depredador_glacial",10:"depredador_jardi",13:"depredador_termic",16:"depredador_abissal",19:"depredador_llindar",20:"depredador_nucli"}
const ROWS := {1:0,4:1,7:2,10:3,13:0,16:3,19:1,20:3}
var atlas: Texture2D
var nav_signature := 0
var grids: Dictionary = {}
var paths: Dictionary = {}
var path_clocks: Dictionary = {}
var safe_edges: Dictionary = {}
var beam_left := 0.0
var beam_from := Vector2.ZERO
var beam_to := Vector2.ZERO
var hit_left := 0.0
var attack_left := 0.0
var attack_room := -1
var attack_from := Vector2.ZERO
var attack_to := Vector2.ZERO
var hit_shield := 0.0
var hit_health := 0.0
var combat_warning_left := 0.0
var combat_alarm_left := 0.0
var warned_room := ""
var weapon_label: Label
var shield_label: Label
var weapon_offer: Label
var shield_offer: Label
var weapon_upgrade: Button
var shield_upgrade: Button
var shield_inventory_toggle: Button
var inventory_bars: Array[ProgressBar] = []

func reset() -> void:
	warned_room=""
	nav_signature=0
	grids.clear(); paths.clear(); path_clocks.clear(); safe_edges.clear()
	beam_left=0.0
	hit_left=0.0
	attack_left=0.0
	attack_room=-1
	combat_warning_left=0.0
	combat_alarm_left=0.0

static func defaults() -> Dictionary:
	return {"weapon_tier":0,"shield_tier":0,"energy":100.0,"shield":40.0,"enabled":true,"cooldown":0.0,"recharge_delay":0.0}

static func restored(saved: Dictionary) -> Dictionary:
	var result := defaults()
	result.merge(saved,true)
	result.weapon_tier=clampi(int(result.weapon_tier),0,5)
	result.shield_tier=clampi(int(result.shield_tier),0,5)
	result.energy=clampf(float(result.energy),0,100)
	result.shield=clampf(float(result.shield),0,40+20*result.shield_tier)
	return result

static func stats(depth: int) -> Dictionary:
	return {"hp":26.0+4.0*depth,"damage":4.0+1.15*depth,"speed":18.0+1.6*depth,"cooldown":1.8-0.025*depth,"windup":0.9-0.015*depth,"awareness":65.0+depth*2.0}

func ensure(game) -> void:
	if game.world.has("predators_v1"): return
	var predators := {}
	var fallback := {}
	var biome: int = game._biome_at_depth(game.current_level)
	for room in game.fauna_sites:
		if room in [game.world.entry,game.descent_access,game.current_cave_id] or game.seen_fauna.has(room) or game.analyzed_fauna.has(room): continue
		var route: PackedVector2Array = game._fauna_safe_patrol(room)
		if route.size()<2 or route[0].distance_to(route[-1])<30: continue
		var point := route[0]
		if not game._fauna_ground_is_clear(point,room): continue
		var entry := {"position":point,"home":point,"cave_id":room,"hp":stats(game.current_level).hp,"facing":Vector2(1,1),"cooldown":1.0,"windup":0.0,"stun":0.0,"alert":false,"biome":biome}
		if fallback.is_empty(): fallback=entry
		if posmod(hash([game.world.seed,room,"predators_v1"]),2 if game.current_level>=13 else 4)!=0: continue
		predators[room]=entry
	if predators.is_empty() and not fallback.is_empty(): predators[fallback.cave_id]=fallback
	for room in predators:
		game.fauna_species_by_room[room]=FAMILIES[biome]
	game.world["predators_v1"]=predators
	game.fauna_safe_paths.clear()

func predator(game, room: int) -> Dictionary:
	return game.world.get("predators_v1",{}).get(room,{})

func _grid(game, room: int) -> AStarGrid2D:
	if grids.has(room): return grids[room]
	var cave: Dictionary = game.world.caves[room]
	var bounds := Rect2(cave.position+cave.contour[0],Vector2.ZERO)
	for point in cave.contour: bounds=bounds.expand(cave.position+point)
	var low := Vector2i((bounds.position/float(game.world.cell_size)).floor()).max(Vector2i.ZERO)
	var high := Vector2i((bounds.end/float(game.world.cell_size)).ceil()).min(Vector2i(game.world.grid_size)-Vector2i.ONE)
	var grid := AStarGrid2D.new()
	grid.region=Rect2i(low,high-low+Vector2i.ONE)
	grid.cell_size=Vector2.ONE*float(game.world.cell_size)
	grid.offset=grid.cell_size*0.5
	grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.update()
	for y in range(low.y,high.y+1):
		for x in range(low.x,high.x+1):
			var cell := Vector2i(x,y)
			grid.set_point_solid(cell,not game._fauna_ground_is_clear(grid.get_point_position(cell),room))
	grids[room]=grid
	return grid

func _nearest(grid: AStarGrid2D, point: Vector2) -> Vector2i:
	var cell := Vector2i((point/grid.cell_size).floor())
	var best := Vector2i(-1,-1)
	var distance := INF
	for y in range(-2,3):
		for x in range(-2,3):
			var candidate := cell+Vector2i(x,y)
			if not grid.region.has_point(candidate) or grid.is_point_solid(candidate): continue
			var score := point.distance_squared_to(grid.get_point_position(candidate))
			if score<distance: best=candidate; distance=score
	return best

func _route(game, grid: AStarGrid2D, from: Vector2i, to: Vector2i, room: int) -> PackedVector2Array:
	var queue: Array[Vector2i] = [from]
	var parents := {from:from}
	var cursor := 0
	var best := from
	while cursor<queue.size() and cursor<4096:
		var cell := queue[cursor]
		cursor+=1
		if cell.distance_squared_to(to)<best.distance_squared_to(to): best=cell
		if cell==to: break
		for direction in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var next: Vector2i = cell+direction
			if not grid.region.has_point(next) or grid.is_point_solid(next) or parents.has(next): continue
			var key := hash([room,cell,next])
			if not safe_edges.has(key):
				var clear := true
				for ratio in [0.25,0.5,0.75]:
					if not game._fauna_ground_is_clear(grid.get_point_position(cell).lerp(grid.get_point_position(next),ratio),room): clear=false
				safe_edges[key]=clear
				safe_edges[hash([room,next,cell])]=clear
			if not safe_edges[key]: continue
			parents[next]=cell
			queue.append(next)
	var result := PackedVector2Array()
	var cell := best
	while true:
		result.append(grid.get_point_position(cell))
		if parents[cell]==cell: break
		cell=parents[cell]
	result.reverse()
	return result

func _move(game, enemy: Dictionary, delta: float, speed: float) -> void:
	var room: int = enemy.cave_id
	path_clocks[room]=float(path_clocks.get(room,0.0))-delta
	if float(path_clocks[room])<=0:
		path_clocks[room]=0.8
		var grid := _grid(game,room)
		var from := _nearest(grid,enemy.position)
		var to := _nearest(grid,game.unit_position)
		paths[room]=_route(game,grid,from,to,room) if from.x>=0 and to.x>=0 else PackedVector2Array()
	var path: PackedVector2Array = paths.get(room,PackedVector2Array())
	while not path.is_empty() and enemy.position.distance_to(path[0])<1.0: path.remove_at(0)
	paths[room]=path
	if path.is_empty(): return
	var next: Vector2 = Vector2(enemy.position).move_toward(path[0],speed*delta)
	if next.distance_to(game.unit_position)<22: return
	for ratio in [0.25,0.5,0.75,1.0]:
		if not game._fauna_ground_is_clear(Vector2(enemy.position).lerp(next,ratio),room): return
	enemy.facing=Vector2(enemy.position).direction_to(next)
	enemy.position=next

func tick(game, delta: float) -> void:
	game.defence_state.enabled=true
	if game.inventory_window.visible:
		refresh_ui(game)
		return
	delta=minf(delta,0.1)
	beam_left=maxf(0,beam_left-delta)
	hit_left=maxf(0,hit_left-delta)
	attack_left=maxf(0,attack_left-delta)
	combat_warning_left=maxf(0,combat_warning_left-delta)
	combat_alarm_left=maxf(0,combat_alarm_left-delta)
	var state: Dictionary = game.defence_state
	state.cooldown=maxf(0,float(state.cooldown)-delta)
	state.recharge_delay=maxf(0,float(state.recharge_delay)-delta)
	if game.surface_mode:
		state.energy=100.0
		state.shield=40.0+20.0*int(state.shield_tier)
		refresh_ui(game)
		return
	var room: int = game._cave_at_position(game.unit_position)
	var enemy := predator(game,room)
	var room_key := str([game.world.seed,game.current_level,room])
	if room_key!=warned_room:
		warned_room=room_key
		if not enemy.is_empty() and float(enemy.hp)>0:
			game._action_notice("FAUNA HOSTIL A LA SALA · Consulta el radar. F: arma · Escut automàtic")
			game.game_audio.play("alarm")
	var threat := false
	if not enemy.is_empty() and float(enemy.hp)>0 and not game.inventory_window.visible:
		var signature := hash([game.world.seed,game.current_level,game.world.walkable_mask])
		if signature!=nav_signature:
			nav_signature=signature; grids.clear(); paths.clear(); path_clocks.clear(); safe_edges.clear()
		var config := stats(game.current_level)
		var distance: float = game.unit_position.distance_to(enemy.position)
		threat=distance<float(config.awareness)
		if threat and not enemy.alert:
			game.status_label.text="DEPREDADOR A PROP · F: POLS · ESCUT AUTOMÀTIC"
			game.game_audio.play("predator")
		enemy.alert=threat
		if float(enemy.windup)>0 or (threat and distance<=35.0):
			combat_warning_left=2.5
		if combat_warning_left>0 and combat_alarm_left<=0:
			game.game_audio.play("alarm")
			combat_alarm_left=1.0
		enemy.cooldown=maxf(0,float(enemy.cooldown)-delta)
		enemy.stun=maxf(0,float(enemy.stun)-delta)
		if threat and float(enemy.stun)<=0:
			if float(enemy.windup)>0:
				enemy.windup=maxf(0,float(enemy.windup)-delta)
				if distance>31: enemy.windup=0.0
				elif float(enemy.windup)<=0:
					if game._segment_is_walkable(enemy.position,game.unit_position,true):
						attack_room=room
						attack_from=enemy.position
						attack_to=game.unit_position
						attack_left=0.35
						damage(game,float(config.damage))
					enemy.cooldown=config.cooldown
			elif distance<=25 and float(enemy.cooldown)<=0:
				enemy.windup=config.windup
			elif distance>25:
				_move(game,enemy,delta,float(config.speed))
	if not threat:
		state.energy=minf(100,float(state.energy)+delta*7.0)
		if float(state.recharge_delay)<=0: state.shield=minf(40+20*int(state.shield_tier),float(state.shield)+delta*(9.0 if game.equipped_modifiers.get("escut","")=="shield_recovery" else 6.0))
	refresh_ui(game)

func damage(game, amount: float) -> void:
	var state: Dictionary = game.defence_state
	if float(state.shield)>0 and game.equipped_modifiers.get("escut","")=="shield_hardening": amount*=0.8
	var absorbed := minf(amount,float(state.shield)) if bool(state.enabled) else 0.0
	state.shield=float(state.shield)-absorbed
	state.recharge_delay=4.0 if game.equipped_modifiers.get("escut","")=="shield_recovery" else 6.0
	game.health=maxf(0,game.health-(amount-absorbed))
	hit_shield=absorbed
	hit_health=amount-absorbed
	hit_left=1.0
	combat_warning_left=2.5
	game._cancel_bio_scan()
	game.mining_cave=-1
	game.mining_remaining=0.0
	game.game_audio.play("alarm" if hit_health>0 else "shield")
	game.status_label.text="ATAC DE DEPREDADOR · ESCUT −%d · VIDA −%d · F PER DEFENSAR-TE" % [ceili(hit_shield),ceili(hit_health)]
	game._update_health_display()
	if game.health<=0: game._end_expedition("ATAC D’UN DEPREDADOR")

func fire(game) -> bool:
	if game.surface_mode or game.taking_field_photo or game.inventory_window.visible or game.discovery_dialog.visible or game.death_dialog.visible: return false
	var state: Dictionary = game.defence_state
	var modifier: String=game.equipped_modifiers.get("arma","")
	var energy_cost := 9.0 if modifier=="weapon_efficiency" else (15.0 if modifier=="weapon_focus" else 12.0)
	if float(state.cooldown)>0: return false
	if float(state.energy)<energy_cost:
		game._action_notice("ARMA SENSE ENERGIA · Allunya’t del depredador per recarregar-la.")
		return false
	var room: int = game._cave_at_position(game.unit_position)
	var enemy := predator(game,room)
	var target_known: bool = not enemy.is_empty() and (game._fauna_is_visible_in_room(room) or (bool(enemy.alert) and game.unit_position.distance_to(enemy.position)<=31))
	if enemy.is_empty() or float(enemy.hp)<=0 or not target_known:
		game._action_notice("CAP DEPREDADOR VISIBLE A L’ABAST")
		return false
	if game.unit_position.distance_to(enemy.position)>70+8*int(state.weapon_tier) or not game._segment_is_walkable(game.unit_position,enemy.position,true):
		game._action_notice("DEPREDADOR FORA D’ABAST O COBERT PER LA ROCA")
		return false
	state.energy=float(state.energy)-energy_cost
	state.cooldown=0.45
	game._cancel_bio_scan()
	game.mining_cave=-1
	game.mining_remaining=0.0
	enemy.hp=maxf(0,float(enemy.hp)-(18+7*int(state.weapon_tier))*(1.25 if modifier=="weapon_focus" else 1.0))
	enemy.stun=0.55
	enemy.windup=0.0
	beam_from=game.unit_position
	beam_to=enemy.position
	beam_left=0.15
	game.explorer_facing=game.unit_position.direction_to(enemy.position)
	game.game_audio.play("weapon")
	game.status_label.text="DEPREDADOR ABATUT · ES POT OBSERVAR I RECOLLIR UNA MOSTRA" if float(enemy.hp)<=0 else "POLS D’ENERGIA · DEPREDADOR ATURDIT"
	refresh_ui(game)
	game._save_active_profile()
	return true

func toggle_shield(game) -> void:
	game.defence_state.enabled=true
	refresh_ui(game)
	game._save_active_profile()

func drop_pack(game) -> void:
	if game.materials_in_pack+game.quartz_in_pack+game.magnetite_in_pack<=0: return
	if not game.world.has("recovery_caches_v1"): game.world["recovery_caches_v1"]=[]
	game.world.recovery_caches_v1.append({"position":game.unit_position,"iron":game.materials_in_pack,"quartz":game.quartz_in_pack,"magnetite":game.magnetite_in_pack,"recovered":false})

func draw_cache(game, canvas: CanvasItem, item: Dictionary) -> void:
	var source := Rect2(830,560,550,425)
	var size: Vector2 = Vector2(12,12*425.0/550.0)*game.zoom_level
	var anchor: Vector2 = game._world_to_screen(item.position)
	canvas.draw_texture_rect_region(game.surface_base_art.MODULES,Rect2(anchor-size*Vector2(0.5,0.9),size),source)
	canvas.draw_string(ThemeDB.fallback_font,anchor+Vector2(-45,14),"RECUPERA",HORIZONTAL_ALIGNMENT_CENTER,90,12,Color("ffc778"))

func recover_click(game, point: Vector2) -> bool:
	for item in game.world.get("recovery_caches_v1",[]):
		if item.recovered or not game._is_revealed(item.position): continue
		var anchor: Vector2 = game._world_to_screen(item.position)
		var size: Vector2 = Vector2.ONE*maxf(12,game.zoom_level*8)
		if not Rect2(anchor-size,size*2).has_point(point): continue
		if game.unit_position.distance_to(item.position)>24:
			game._action_notice("ACOSTA’T ALS MATERIALS PER RECUPERAR-LOS")
			return true
		item.recovered=true
		game.materials_in_pack+=int(item.iron)
		game.quartz_in_pack+=int(item.quartz)
		game.magnetite_in_pack+=int(item.magnetite)
		game.status_label.text="MATERIALS RECUPERATS"
		game._update_equipment_display()
		game._save_active_profile()
		return true
	return false

func sprite_rect(game, point: Vector2) -> Rect2:
	var size: Vector2 = Vector2(24,16)*game.zoom_level
	return Rect2(game._world_to_screen(point)-size*Vector2(0.5,0.95),size)

func draw_creature(game, enemy: Dictionary) -> void:
	if atlas==null: atlas=load("res://assets/sprites/depredadors_isometrics.png")
	var cell := Vector2(atlas.get_size())/Vector2(4,4)
	var column: int = game.OrganismPixelArt.facing_index(Vector2(enemy.facing.x,enemy.facing.y*0.5))
	var source := Rect2(Vector2(column,ROWS[int(enemy.biome)])*cell,cell)
	var tint := Color.WHITE if float(enemy.hp)>0 else Color(0.55,0.65,0.70,0.80)
	var visual: Vector2=enemy.position
	if not game.taking_field_photo:
		if attack_left>0 and int(enemy.cave_id)==attack_room:
			visual=attack_from.lerp(attack_to,minf(0.45,9.0/maxf(1.0,attack_from.distance_to(attack_to)))*sin((1.0-attack_left/0.35)*PI))
		elif float(enemy.windup)>0:
			visual-=Vector2(enemy.facing).normalized()*2.0*(1.0-float(enemy.windup)/float(stats(game.current_level).windup))
	game.draw_texture_rect_region(atlas,sprite_rect(game,visual),source,tint)
	if float(enemy.hp)<=0 and not game.taking_field_photo and not game.fauna_samples.has(enemy.cave_id):
		var anchor: Vector2=game._world_to_screen(enemy.position)-Vector2(0,18)*game.zoom_level
		var caption := "RECULL RESTES"
		var font_size := 13
		var width := ThemeDB.fallback_font.get_string_size(caption,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
		game.draw_rect(Rect2(anchor-Vector2(width*0.5+5,15),Vector2(width+10,21)),Color("0b2228"))
		game.draw_string(ThemeDB.fallback_font,anchor-Vector2(width*0.5,0),caption,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color("a9f7db"))
	if game.taking_field_photo or float(enemy.hp)<=0: return
	var anchor: Vector2 = game._world_to_screen(enemy.position)-Vector2(0,15)*game.zoom_level
	var width: float = 16*game.zoom_level
	game.draw_rect(Rect2(anchor-Vector2(width*0.5,0),Vector2(width,1.1*game.zoom_level)),Color("2a121a"))
	game.draw_rect(Rect2(anchor-Vector2(width*0.5,0),Vector2(width*float(enemy.hp)/float(stats(game.current_level).hp),1.1*game.zoom_level)),Color("fa705c"))
	if float(enemy.windup)>0:
		game.draw_string(ThemeDB.fallback_font,anchor-Vector2(10,4)*game.zoom_level,"ATACA!",HORIZONTAL_ALIGNMENT_LEFT,-1,maxi(12,int(3*game.zoom_level)),Color("ff8f65"))

func draw_badge(canvas: CanvasItem, center: Vector2, species: String, scale: float) -> void:
	if atlas==null: atlas=load("res://assets/sprites/depredadors_isometrics.png")
	var biome: int = FAMILIES.find_key(species)
	var cell := Vector2(atlas.get_size())/Vector2(4,4)
	var size := Vector2(24,16)*scale
	canvas.draw_texture_rect_region(atlas,Rect2(center-size*Vector2(0.5,0.7),size),Rect2(Vector2(0,ROWS.get(biome,0))*cell,cell))

func draw_fx(game, canvas: CanvasItem) -> void:
	if game.surface_mode or game.taking_field_photo: return
	draw_radar(game,canvas)
	if combat_warning_left>0:
		var enemy := predator(game,game._cave_at_position(game.unit_position))
		if not enemy.is_empty() and float(enemy.hp)>0:
			var view: Rect2=game._view_rect()
			var width: float=minf(480.0,view.size.x-24.0)
			var rect := Rect2(Vector2(view.get_center().x-width*0.5,210),Vector2(width,64))
			canvas.draw_rect(rect,Color("2d1118"))
			canvas.draw_rect(rect,Color(1.0,0.28,0.18,0.65+0.35*sin(game.fauna_time*9)),false,3.0)
			canvas.draw_string(ThemeDB.fallback_font,rect.position+Vector2(6,27),"T’ESTAN ATACANT!",HORIZONTAL_ALIGNMENT_CENTER,width-12,22,Color("fff0d5"))
			canvas.draw_string(ThemeDB.fallback_font,rect.position+Vector2(6,49),"F: DEFENSA’T · ALLUNYA’T DEL DEPREDADOR",HORIZONTAL_ALIGNMENT_CENTER,width-12,12,Color("ffbd8b"))
			var player: Vector2=game._world_to_screen(game.unit_position)-Vector2(0,20)
			var direction: Vector2=player.direction_to(game._world_to_screen(enemy.position)-Vector2(0,20))
			var tip := player+direction*52.0
			canvas.draw_line(player+direction*25,tip,Color("ff7053"),3.0,false)
			canvas.draw_colored_polygon(PackedVector2Array([tip+direction*8,tip-direction*5+direction.orthogonal()*7,tip-direction*5-direction.orthogonal()*7]),Color("ffb16d"))
	if hit_left>0:
		var scale: float=clampf(game.zoom_level if game.analysis_mode else 1.0,1.0,5.0)
		var point: Vector2=game._world_to_screen(game.unit_position)-Vector2(0,9)*scale
		var color := Color("71f0ff") if hit_health<=0 else Color("ff6d58")
		if hit_left>0.65:
			for i in range(7):
				var direction := Vector2.from_angle(float(i)*TAU/7.0)
				var spark: Vector2=(point+direction*(1.0-hit_left)*50.0*scale).round()
				canvas.draw_rect(Rect2(spark,Vector2(1,2)*scale),color)
			canvas.draw_line((point-Vector2(4,5)*scale).round(),(point+Vector2(4,5)*scale).round(),color,2.0*scale,false)
		var caption := "ESCUT −%d" % ceili(hit_shield)
		if hit_health>0: caption="VIDA −%d" % ceili(hit_health)+(" · ESCUT −%d" % ceili(hit_shield) if hit_shield>0 else "")
		var font_size := roundi(13.0*clampf(scale/3.0,1.0,1.4))
		var width := ThemeDB.fallback_font.get_string_size(caption,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
		var label_pos := point-Vector2(width*0.5,18*scale+(1-hit_left)*18)
		canvas.draw_rect(Rect2(label_pos-Vector2(5,font_size),Vector2(width+10,font_size+6)),Color("0b141b"))
		canvas.draw_string(ThemeDB.fallback_font,label_pos,caption,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,color)
	if not game.analysis_mode:
		for item in game.world.get("recovery_caches_v1",[]):
			if not item.recovered and game._is_revealed(item.position): draw_cache(game,canvas,item)
		return
	if beam_left>0:
		var start: Vector2 = game._world_to_screen(beam_from)-Vector2(0,12)*game.zoom_level
		var finish: Vector2 = game._world_to_screen(beam_to)-Vector2(0,4)*game.zoom_level
		canvas.draw_line(start.round(),finish.round(),Color("80f1ff"),maxf(1,game.zoom_level*0.5),false)
		canvas.draw_rect(Rect2(finish-Vector2.ONE*game.zoom_level,Vector2.ONE*game.zoom_level*2),Color("fff6cc"))

func attach_footer(game, parent: Control, slot: int) -> void:
	if slot==20: return
	var button: Button = game._button("F · POLS",Vector2.ZERO,Vector2.ZERO,true)
	button.add_theme_font_size_override("font_size",11)
	button.icon=load("res://assets/ui/icona_arma.svg" if slot==19 else "res://assets/ui/icona_escut.svg")
	button.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	button.tooltip_text="Dispara al depredador visible de la sala [F]" if slot==19 else "Activa o desactiva l’escut personal [G]"
	button.pressed.connect(func() -> void: fire(game) if slot==19 else toggle_shield(game))
	parent.add_child(button)

func build_ui(game, inventory: Control, upgrades: Control) -> void:
	weapon_label=game._add_inventory_slot(inventory,"Projector de polsos")
	weapon_label.tooltip_text="F o Ctrl+clic sobre el depredador. Recarrega fora de perill."
	shield_label=game._add_inventory_slot(inventory,"Escut personal")
	for label in [weapon_label,shield_label]:
		label.get_parent().get_parent().custom_minimum_size.y=150
		for maximum in [6.0,100.0]:
			var bar: ProgressBar=game._new_resource_meter(maximum,Color("72deee") if maximum==6 else Color("b7d787"))
			bar.custom_minimum_size=Vector2(0,12)
			label.get_parent().add_child(bar)
			inventory_bars.append(bar)
	shield_label.tooltip_text="Escut automàtic: absorbeix dany i es regenera fora de perill."
	shield_inventory_toggle=game._button("",Vector2.ZERO,Vector2.ZERO,true)
	shield_inventory_toggle.add_theme_font_size_override("font_size",11)
	shield_inventory_toggle.pressed.connect(func() -> void: toggle_shield(game))
	shield_label.get_parent().add_child(shield_inventory_toggle)
	shield_inventory_toggle.hide()
	weapon_upgrade=game._button("",Vector2.ZERO,Vector2.ZERO)
	weapon_upgrade.pressed.connect(func() -> void: upgrade(game,false))
	weapon_offer=game._add_workshop_offer(upgrades,"Projector de polsos","",weapon_upgrade)
	shield_upgrade=game._button("",Vector2.ZERO,Vector2.ZERO)
	shield_upgrade.pressed.connect(func() -> void: upgrade(game,true))
	shield_offer=game._add_workshop_offer(upgrades,"Escut personal","",shield_upgrade)
	game._add_equipment_modifiers(weapon_offer,"arma")
	game._add_equipment_modifiers(shield_offer,"escut")
	game._add_modifier_menu(weapon_label.get_parent(),"arma")
	game._add_modifier_menu(shield_label.get_parent(),"escut")
	refresh_ui(game)

func upgrade(game, shield: bool) -> bool:
	var key := "shield_tier" if shield else "weapon_tier"
	var tier: int = game.defence_state[key]
	var iron := (3 if shield else 4)+tier*2
	if tier>=5 or not game._can_upgrade_equipment(iron,1): return false
	game.materials_in_pack-=iron
	game.equipment_research_spent+=1
	game.defence_state[key]=tier+1
	if shield: game.defence_state.shield=40+20*(tier+1)
	else: game.defence_state.energy=100.0
	game._record_expedition_milestone(("Escut" if shield else "Projector de polsos")+" · nivell %d" % (tier+2))
	game._update_research_panel()
	game._save_active_profile()
	return true

func refresh_ui(game) -> void:
	var state: Dictionary = game.defence_state
	state.enabled=true
	if game.inventory_strip_values.size()>20 and is_instance_valid(game.inventory_strip_values[19]):
		game.inventory_strip_values[19].text="Nv. %d · %d%%" % [int(state.weapon_tier)+1,roundi(state.energy)]
		game.inventory_strip_values[20].text="%s · %d%%" % ["ACTIU" if state.enabled else "INACTIU",roundi(100*float(state.shield)/(40+20*int(state.shield_tier)))]
		game.inventory_strip_meters[19].value=float(state.energy)
		game.inventory_strip_meters[20].value=100*float(state.shield)/(40+20*int(state.shield_tier))
	if not is_instance_valid(weapon_label): return
	if inventory_bars.size()==4:
		inventory_bars[0].value=int(state.weapon_tier)+1
		inventory_bars[1].value=state.energy
		inventory_bars[2].value=int(state.shield_tier)+1
		inventory_bars[3].value=100*float(state.shield)/(40+20*int(state.shield_tier))
	weapon_label.text="Nv. %d · %d%%\nF · POLS" % [int(state.weapon_tier)+1,roundi(state.energy)]
	shield_label.text="Nv. %d · %s\n%d%%" % [int(state.shield_tier)+1,"ACTIU" if state.enabled else "INACTIU",roundi(100*float(state.shield)/(40+20*int(state.shield_tier)))]
	shield_inventory_toggle.text="DESACTIVA" if state.enabled else "ACTIVA"
	for shield in [false,true]:
		var tier: int = state.shield_tier if shield else state.weapon_tier
		var iron := (3 if shield else 4)+tier*2
		var button := shield_upgrade if shield else weapon_upgrade
		button.text="MÀXIM" if tier>=5 else "MILLORA · %d FERRO + 1 PUNT" % iron
		button.disabled=tier>=5 or not game._can_upgrade_equipment(iron,1)
		var label := shield_offer if shield else weapon_offer
		label.text="Nv. %d · %d punts de protecció" % [tier+1,40+20*tier] if shield else "Nv. %d · %d dany · %d u d’abast" % [tier+1,18+7*tier,70+8*tier]

func radar_hint(game) -> Dictionary:
	if game.surface_mode or game.world.is_empty(): return {}
	var room: int = game._cave_at_position(game.unit_position)
	var enemy := predator(game,room)
	if enemy.is_empty() or float(enemy.hp)<=0: return {}
	var offset: Vector2 = enemy.position-game.unit_position
	# Deliberately quantized: hints, without revealing map cells or identity.
	var direction := roundi(offset.angle()/(TAU/8.0))
	var band := 1 if offset.length()<45.0 else (2 if offset.length()<95.0 else 3)
	return {"direction":direction,"band":band}

func draw_radar(game, canvas: CanvasItem) -> void:
	var hint := radar_hint(game)
	if hint.is_empty(): return
	var view: Rect2 = game._view_rect()
	var center := Vector2(view.position.x+78.0,view.end.y-245.0)
	var panel := Rect2(center-Vector2(62,72),Vector2(124,148))
	canvas.draw_rect(panel,Color("061318"))
	canvas.draw_rect(panel,Color("3b7d88"),false,2.0)
	canvas.draw_string(ThemeDB.fallback_font,center+Vector2(-47,-52),"RADAR HOSTIL",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("ffb77a"))
	for radius in [14.0,28.0,42.0]: canvas.draw_arc(center,radius,0,TAU,40,Color("24545d"),1.0,true)
	canvas.draw_line(center-Vector2(42,0),center+Vector2(42,0),Color("24545d"))
	canvas.draw_line(center-Vector2(0,42),center+Vector2(0,42),Color("24545d"))
	var sweep := Vector2.from_angle(game.fauna_time*1.6)
	canvas.draw_line(center,center+sweep*42.0,Color("4cd5d5"),1.0,true)
	canvas.draw_rect(Rect2(center-Vector2(2,2),Vector2(4,4)),Color("9cffff"))
	var bearing := Vector2.from_angle(float(hint.direction)*TAU/8.0)
	bearing.y*=0.5 if game.analysis_mode else 1.0
	bearing=bearing.normalized()
	var echo := center+bearing*(float(hint.band)*12.0)
	var blink: float = 0.6+0.4*sin(game.fauna_time*5.0)
	canvas.draw_rect(Rect2(echo-Vector2(4,4),Vector2(8,8)),Color(1.0,0.3,0.18,blink))
	var text: String = ["","MOLT A PROP","A PROP","LLUNY"][int(hint.band)]
	canvas.draw_string(ThemeDB.fallback_font,center+Vector2(-48,62),text,HORIZONTAL_ALIGNMENT_CENTER,96,11,Color("ffb77a"))
