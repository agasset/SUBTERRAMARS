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
	game.analysis_mode = true
	game.current_level = 1
	game.call("_ensure_solid_room_rocks")
	var before := var_to_bytes(game.world)
	game.call("_ensure_solid_room_rocks")
	assert(before == var_to_bytes(game.world))
	var wide := 0
	var chosen: Dictionary = {}
	game.dev_mode = true
	for rock in game.world.solid_room_rocks_v1:
		assert(rock.blocked_cells.size() >= 1)
		for cell in rock.blocked_cells:
			assert(game.world.walkable_mask[cell.y * game.world.grid_size.x + cell.x] == 0)
		if rock.blocked_cells.size() == 3:
			wide += 1
			var left: Vector2 = rock.position - Vector2(20, 0)
			var right: Vector2 = rock.position + Vector2(20, 0)
			assert(not game.call("_segment_is_walkable", left, right, true))
			assert(not game.call("_find_path", left, right).is_empty())
			if chosen.is_empty(): chosen = rock
	assert(wide > 0)
	assert(game.call("_depth_order_less", {"point": Vector2(0, -8), "order": 4}, {"point": Vector2.ZERO, "order": 1}))
	assert(not game.call("_depth_order_less", {"point": Vector2(0, 8), "order": 4}, {"point": Vector2.ZERO, "order": 1}))
	var room: int = chosen.cave_id
	game.explored_caves[room] = true
	game.selected_cave = room
	game.current_cave_id = room
	game.call("_update_view_mode_ui")
	for side in [-1, 1]:
		game.unit_position = chosen.position + Vector2(0, side * 8)
		game.zoom_level = 7.0
		game.call("_focus_world_position", chosen.position, 7.0)
		game.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png("res://reports/oclusio_roca_%d.png" % side) == OK)
	print("DEPTH_AND_ROCK_FOOTPRINTS_OK wide=%d migration=stable detours=ok" % wide)
	quit()
