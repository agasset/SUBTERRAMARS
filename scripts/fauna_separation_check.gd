extends SceneTree
const Harness = preload("res://scripts/organism_preview.gd")
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	root.size = Vector2i(1440,900)
	var game = Harness.PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game.game_audio.set_enabled(false)
	game._new_world(134027)
	game.surface_mode = false
	game.analysis_mode = true
	game.current_level = 1
	game.equipped_modifiers["escaner"] = "scanner_ferric"
	var room: int = game.fauna_sites.keys()[0]
	game.selected_cave = room
	game.current_cave_id = room
	game.explored_caves[room] = true
	game.seen_fauna[room] = true
	game._focus_cave(room,5.0)
	var animal: Vector2 = game._fauna_position(room)
	var checked := false
	for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
		var approach: Vector2 = animal + direction * 24
		if game._cave_at_position(approach) != room: continue
		assert(game._fauna_blocks_player_step(approach,animal))
		game.moving=true
		assert(not game._fauna_blocks_player_step(approach,animal))
		game.moving=false
		assert(not game._fauna_blocks_player_step(animal,approach))
		checked = true
		break
	assert(checked)
	var detours := 0
	for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
		var approach: Vector2 = animal+direction*30
		var goal: Vector2 = animal-direction*35
		if not game._segment_is_walkable(approach,goal,true): continue
		game.unit_position=approach
		game._reveal_entire_room(game.world.caves[room])
		game.move_path.assign([goal])
		var route: Array[Vector2] = game._detour_around_fauna()
		if route.is_empty(): continue
		var last := approach
		for point in route:
			assert(game._segment_is_walkable(last,point))
			assert(not game._fauna_blocks_player_step(last,point))
			last=point
		assert(last.distance_to(goal)<0.01)
		detours+=1
	assert(detours>0)
	print("FAUNA_DETOUR_OK routes=%d solid_and_dynamic_collisions_respected=true" % detours)
	game.unit_position = animal + Vector2(1,0)
	for i in range(120):
		var before: float = game._fauna_position(room).distance_to(game.unit_position)
		game._advance_fauna(0.016)
		var after: float = game._fauna_position(room).distance_to(game.unit_position)
		assert(after >= before - 0.0001 or after >= 22.0)
	game.unit_position = game._fauna_position(room)
	game.analyzed_fauna[room] = true
	game._update_view_mode_ui()
	await game._show_new_discovery(game.fauna_species_by_room[room],true,game._fauna_position(room))
	await process_frame
	await RenderingServer.frame_post_draw
	assert(game.discovery_photo.texture != null)
	root.get_texture().get_image().save_png("res://reports/fauna_descoberta_sense_explorador.png")
	print("FAUNA_SEPARATION_OK approach=blocked escape=allowed fauna=pauses photo=captured_without_player")
	quit()
