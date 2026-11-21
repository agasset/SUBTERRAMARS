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
	for depth in [4, 5, 6]:
		game.call("_change_underground_level", depth, -1)
		game.rewards_dialog.hide()
		game.call("_ensure_solid_room_rocks")
		var entry: int = game.world.entry
		game.explored_caves[entry] = true
		assert(game.call("_get_cave_room_floor_texture", entry) == game.CRYSTALLINE_FLOOR_TEXTURE)
		assert(game.call("_floor_material_uv", Vector2(32, 32), game.CRYSTALLINE_FLOOR_TEXTURE) == Vector2.ONE)
		for corridor in game.world.corridors:
			if corridor.a == entry or corridor.b == entry:
				game.completed_gallery_traces[corridor.id] = true
				game.discovered_exits[game.call("_exit_key", entry, corridor.id)] = true
				break
		var before := var_to_bytes([game.world, game.unit_position, game.revealed_mask, game.material_sites])
		game.zoom_level = 3.5
		game.call("_focus_cave", entry, 3.5)
		game.call("_update_view_mode_ui")
		assert(game.mode_heading_label.text.begins_with("Cavernes cristal·lines"))
		assert(game.repair_folding_ladder_button.text.begins_with("REPOSA USOS"))
		game.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png("res://reports/cavernes_cristallines_%d.png" % depth) == OK)
		assert(before == var_to_bytes([game.world, game.unit_position, game.revealed_mask, game.material_sites]))
		if depth == 4:
			assert(game.call("_biome_base_footprint", game.world.caves[entry]).size() == 4)
			game.call("_fit_discovered_map")
			game.queue_redraw()
			await process_frame
			await RenderingServer.frame_post_draw
			assert(root.get_texture().get_image().save_png("res://reports/cavernes_cristallines_enquadra.png") == OK)
	print("CRYSTALLINE_BIOME_REAL_DEPTHS_4_5_6_OK geometry=unchanged floor_period=32 base_and_gallery=rendered")
	quit()
