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
	game.show_signal_rings = true
	game.show_beacon_waves = true
	game.fauna_time = 2.0
	game.surface_mode = false
	game.analysis_mode = true
	game.current_level = 1
	game.call("_ensure_solid_room_rocks")
	var room: int = game.world.entry
	game.selected_cave = room
	game.current_cave_id = room
	game.unit_position = game.world.caves[room].position
	game.explored_caves[room] = true
	game.explorer_facing = Vector2.RIGHT
	game.flashlight_charge = 100
	game.zoom_level = 5.0
	game.call("_focus_cave", room, 5.0)
	game.call("_update_view_mode_ui")
	var before := var_to_bytes([game.world,game.revealed_mask,game.unit_position,game.material_sites])
	var pools: Array = game.call("_room_surface_details", game.world.caves[room])
	assert(not pools.is_empty())
	assert(pools == game.call("_room_surface_details", game.world.caves[room]))
	for enabled in [false, true]:
		game.flashlight_on = enabled
		game.queue_redraw()
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png("res://reports/llum_dinamica_%s.png" % enabled) == OK)
		assert(before == var_to_bytes([game.world,game.revealed_mask,game.unit_position,game.material_sites]))
	game.explored_caves.erase(room)
	game.revealed_mask.fill(0)
	game.call("_reveal_around", game.unit_position, 3)
	var fog_state: PackedByteArray = game.revealed_mask.duplicate()
	game.queue_redraw()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png("res://reports/boira_descoberta.png") == OK)
	assert(fog_state == game.revealed_mask)
	print("LIGHTING_FOG_POOLS_LEGEND_RENDER_OK pools=%d world_and_discovery=unchanged" % pools.size())
	quit()
