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
	game.current_level = 1
	game.analysis_mode = true
	game.call("_ensure_solid_room_rocks")
	var samples := 0
	for room in game.fauna_sites:
		var route: PackedVector2Array = game.call("_fauna_safe_patrol", room)
		assert(not route.is_empty())
		for frame in range(400):
			game.fauna_time = frame * 0.23
			assert(game.call("_fauna_ground_is_clear", game.call("_fauna_position", room), room))
			samples += 1
	# Force one ore to overlap a normal rock, then run the bounded repair.
	var rock: Dictionary = game.world.solid_room_rocks_v1[0]
	var room: int = rock.cave_id
	game.material_sites[room] = rock.position
	game.explored_caves[room] = true
	game.world.erase("material_clearance_v1")
	game.call("_ensure_material_clearance")
	assert(game.call("_material_position_is_clear", game.material_sites[room], room))
	var sites_before := var_to_bytes(game.material_sites)
	game.call("_ensure_material_clearance")
	assert(sites_before == var_to_bytes(game.material_sites))
	# The oxygen reserve remains usable, but does not pulse at high charge.
	game.oxygen_cartridges = 1
	game.oxygen_seconds = game.call("_oxygen_capacity") * 0.91
	game.call("_update_equipment_display")
	game.call("_update_equipment_action_pulses")
	assert(not game.pulsing_equipment_actions.has(game.oxygen_reserve_card_button))
	game.oxygen_seconds = game.call("_oxygen_capacity") * 0.1
	game.call("_update_equipment_display")
	game.call("_update_equipment_action_pulses")
	assert(game.pulsing_equipment_actions.has(game.oxygen_reserve_card_button))
	game.selected_cave = room
	game.current_cave_id = room
	game.unit_position = game.world.caves[room].position
	game.call("_update_view_mode_ui")
	game.call("_focus_cave", room, 5.0)
	var corridor: Dictionary = game.world.corridors[0]
	game.rockfall_corridor_id = corridor.id
	game.rockfall_position = corridor.points[int(corridor.points.size() / 2)]
	game.rockfall_remaining = 10.0
	game.completed_gallery_traces[corridor.id] = true
	game.selected_cave = corridor.a
	game.explored_caves[corridor.a] = true
	game.call("_focus_world_position", game.rockfall_position, 5.0)
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png("res://reports/despreniment_pixel_art.png") == OK)
	print("FAUNA_COLLISION_MINERAL_CLEARANCE_OXYGEN_OK samples=%d" % samples)
	quit()
