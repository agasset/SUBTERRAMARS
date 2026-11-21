extends SceneTree
const Harness = preload("res://scripts/organism_preview.gd")
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	root.size = Vector2i(1440,900)
	root.content_scale_size = root.size
	var game = Harness.PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game.game_audio.call("set_enabled",false)
	var count := 0
	for seed in [134027,42,91,701]:
		game.call("_new_world",seed)
		game.surface_mode = false
		for depth in [1,4,7,10,13,16,19]:
			game.call("_change_underground_level",depth,-1)
			game.rewards_dialog.hide()
			game.call("_ensure_solid_room_rocks")
			assert(game.world.get("base_solid_v1",false))
			var cave: Dictionary = game.world.caves[game.world.entry]
			assert(game.call("_base_mask_reaches_exits",game.world.walkable_mask,cave))
			for cell in game.world.base_solid_cells_v1:
				var point := (Vector2(cell)+Vector2.ONE*0.5)*float(game.world.cell_size)
				assert(not game.call("_segment_is_walkable",point,point,true))
			var snapshot := var_to_bytes(game.world)
			game.call("_ensure_solid_room_rocks")
			assert(snapshot == var_to_bytes(game.world))
			count += 1
	game.call("_change_underground_level",1,-1)
	game.rewards_dialog.hide()
	var cave: Dictionary = game.world.caves[game.world.entry]
	game.explored_caves[cave.id] = true
	game.selected_cave = cave.id
	game.current_cave_id = cave.id
	game.call("_ensure_solid_room_rocks")
	game.zoom_level = 5.0
	game.call("_focus_cave",cave.id,5.0)
	game.call("_update_view_mode_ui")
	game.queue_redraw()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var lighting = game.get_node_or_null("CaveLighting")
	for child in game.get_children():
		if child.get_script() == preload("res://scripts/cave_lighting.gd"): lighting = child
	assert(lighting != null)
	var fog: Image = lighting.mask.get_image()
	for corner in cave.contour:
		var cell := Vector2i(((Vector2(cave.position)+corner)/game.world.cell_size).floor())
		assert(fog.get_pixel(cell.x,cell.y).r > 0.99)
	assert(root.get_texture().get_image().save_png("res://reports/sala_escanejada_sense_boira.png") == OK)
	print("BASE_SOLID_AND_SCANNED_FOG_OK bases=%d boundary_samples=%d exits=reachable migration=stable" % [count,cave.contour.size()])
	quit()
