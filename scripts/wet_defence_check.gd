extends SceneTree
const Harness = preload("res://scripts/organism_preview.gd")
const Defence = preload("res://scripts/expedition_defence.gd")
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	root.size=Vector2i(1440,900)
	var game=Harness.PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game.game_audio.set_enabled(false)
	game._new_world(134027)
	game.surface_mode=false
	var pools := 0
	var drips := 0
	var predators := 0
	for depth in [1,4,7,10,13,16,19,20]:
		game._change_underground_level(depth,-1)
		for node in game.get_children():
			if node is Window: node.hide()
		game._ensure_solid_room_rocks()
		assert(not game.world.unique_landmark_v1.is_empty())
		var unchanged := var_to_bytes(game.world)
		game._ensure_solid_room_rocks()
		assert(unchanged==var_to_bytes(game.world))
		for cave in game.world.caves:
			for pool in game._room_surface_details(cave):
				assert(pool.thin_end.distance_to(pool.wall_anchor)<0.01)
				assert(game._distance_to_cave_boundary(pool.wall_anchor,cave)<0.01)
				pools+=1
			assert(game._base_mask_reaches_exits(game.world.walkable_mask,cave))
		for item in game.world.ambience_v1:
			if item.kind!=3: continue
			assert(item.has("wall_anchor") and item.blocked_cells.is_empty())
			assert(game._distance_to_cave_boundary(item.wall_anchor,game.world.caves[item.cave_id])<0.01)
			drips+=1
		for enemy in game.world.predators_v1.values():
			assert(enemy.cave_id not in [game.world.entry,game.descent_access])
			assert(game._fauna_ground_is_clear(enemy.position,enemy.cave_id))
			predators+=1
		var feature: Dictionary = game.world.unique_landmark_v1
		game.selected_cave=feature.cave_id
		game.current_cave_id=feature.cave_id
		game.unit_position=game.world.caves[feature.cave_id].position
		game.explored_caves[feature.cave_id]=true
		game._focus_cave(feature.cave_id,4.5)
		game._update_view_mode_ui()
		game.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://reports/singularitat_bioma_%02d.png" % depth)
	assert(pools>0 and drips>0 and predators>0)
	for depth in range(2,21):
		assert(Defence.stats(depth).damage>Defence.stats(depth-1).damage)
		assert(Defence.stats(depth).hp>Defence.stats(depth-1).hp)
	game._change_underground_level(1,-1)
	game._ensure_solid_room_rocks()
	var enemy: Dictionary = game.world.predators_v1.values()[0]
	var room: int = enemy.cave_id
	game.selected_cave=room
	game.current_cave_id=room
	game.explored_caves[room]=true
	game.seen_fauna[room]=true
	var route: PackedVector2Array = game._fauna_safe_patrol(room)
	game.unit_position=route[-1]
	var origin: Vector2 = enemy.position
	for frame in range(30):
		game.defence_system.tick(game,0.1)
		assert(game._fauna_ground_is_clear(enemy.position,room))
	assert(origin.distance_to(enemy.position)>1.0)
	var found := false
	for angle in range(16):
		var point: Vector2 = enemy.position+Vector2.from_angle(float(angle)*TAU/16.0)*24.0
		if game._fauna_ground_is_clear(point,room) and game._segment_is_walkable(enemy.position,point,true):
			game.unit_position=point
			found=true
			break
	assert(found)
	game.health=100
	game.defence_state=Defence.defaults()
	enemy.cooldown=0.0
	enemy.windup=0.0
	game.defence_system.tick(game,0.1)
	assert(enemy.windup>0 and game.health==100 and game.defence_state.shield==40)
	for i in range(10): game.defence_system.tick(game,0.1)
	assert(game.defence_state.shield<40 and game.health==100)
	var shield_before: float = game.defence_state.shield
	var toggle := InputEventKey.new()
	toggle.keycode=KEY_G
	toggle.pressed=true
	game._input(toggle)
	game.defence_system.damage(game,8)
	assert(game.health==100 and game.defence_state.shield==shield_before-8)
	game.defence_system.toggle_shield(game)
	game._focus_cave(room,5.0)
	game._update_view_mode_ui()
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://reports/depredador_escut_encontre.png")
	var energy: float = game.defence_state.energy
	var shot := InputEventKey.new()
	shot.keycode=KEY_F
	shot.pressed=true
	game._input(shot)
	assert(game.defence_state.energy==energy-12 and enemy.stun>0)
	assert(not game.defence_system.fire(game))
	game.defence_state.cooldown=0.0
	var cell := Vector2i(((Vector2(enemy.position)+game.unit_position)*0.5/float(game.world.cell_size)).floor())
	var index: int = cell.y*game.world.grid_size.x+cell.x
	var old: int = game.world.walkable_mask[index]
	game.world.walkable_mask[index]=0
	energy=game.defence_state.energy
	assert(not game.defence_system.fire(game) and game.defence_state.energy==energy)
	game.world.walkable_mask[index]=old
	var click := InputEventMouseButton.new()
	click.button_index=MOUSE_BUTTON_LEFT
	click.pressed=true
	click.ctrl_pressed=true
	click.position=game.defence_system.sprite_rect(game,enemy.position).get_center()
	game._input(click)
	assert(game.defence_state.energy==energy-12)
	while enemy.hp>0:
		game.defence_state.cooldown=0.0
		assert(game.defence_system.fire(game))
	var dead := var_to_bytes(enemy)
	game._ensure_solid_room_rocks()
	assert(dead==var_to_bytes(enemy))
	game.materials_in_pack=100
	for id in game.flora_sites: game.flora_samples[id]=true
	game.surface_mode=true
	assert(game.defence_system.upgrade(game,false))
	assert(game.defence_system.upgrade(game,true))
	game.surface_mode=false
	var saved: Dictionary = game._capture_saved_game()
	game._new_world(42)
	game._restore_saved_game(saved)
	assert(game.defence_state.weapon_tier==1 and game.defence_state.shield_tier==1)
	assert(game.world.predators_v1[room].hp==0)
	game._open_inventory(false)
	await process_frame
	var parent: Node = game.defence_system.shield_label
	while not parent is ScrollContainer: parent=parent.get_parent()
	parent.scroll_vertical=10000
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://reports/arma_escut_inventari.png")
	var enabled: bool = game.defence_state.enabled
	game.defence_system.shield_inventory_toggle.pressed.emit()
	assert(bool(game.defence_state.enabled)==enabled and enabled)
	assert(not game.defence_system.shield_inventory_toggle.visible)
	assert(game.action_notice_label.size.y<150)
	root.size=Vector2i(1024,640)
	root.content_scale_size=root.size
	game._layout_panels()
	game._resize_inventory_tab(0)
	await process_frame
	await process_frame
	assert(game.inventory_window.position.y+game.inventory_window.size.y<=game.equipment_bar.position.y+2)
	print("WET_LANDMARK_DEFENCE_OK profiles=8 pools=%d wall_drips=%d predators=%d exits=connected windup=visible shield=absorbs weapon=occluded cooldown=checked save=stable" % [pools,drips,predators])
	quit()
