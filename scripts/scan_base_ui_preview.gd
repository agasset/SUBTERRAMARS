extends SceneTree
const Harness = preload("res://scripts/organism_preview.gd")
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	root.size = Vector2i(1440, 900)
	root.content_scale_size = root.size
	var game = Harness.PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game.call("_new_world", 134027)
	game.surface_mode = false
	game.call("_change_underground_level", 4, -1)
	game.rewards_dialog.hide()
	game.call("_ensure_solid_room_rocks")
	game.call("_update_view_mode_ui")
	assert(game.biome_base_return_button.visible)
	assert(game.call("_current_biome_base_depth") == 4)
	var before: Vector2 = game.unit_position
	game.biome_base_return_button.pressed.emit()
	assert(game.depth_trip_dialog.visible)
	assert(game.unit_position == before)
	game.depth_trip_dialog.hide()
	for depth in range(1, 21):
		game.current_level = depth
		var target: int = game.call("_current_biome_base_depth")
		assert(target == (19 if depth >= 19 else 1 + int((depth - 1) / 3) * 3))
	game.current_level = 4
	var room: int = game.world.entry
	game.flora_sites[room] = game.unit_position + Vector2(14, 8)
	game.flora_species_by_room[room] = "falguera"
	game.explored_caves[room] = true
	game.bio_scan_room = room
	game.bio_scan_fauna = false
	game.bio_scan_elapsed = game.call("_bio_scan_duration", game.bio_scanner_tier) * 0.78
	game.zoom_level = 5.0
	game.call("_focus_world_position", game.unit_position, 5.0)
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png("res://reports/escaneig_barra_pixel_art.png") == OK)
	print("SCAN_BAR_AND_BIOME_BASE_BUTTON_OK destinations=20 route_confirmation=no_teleport")
	quit()
