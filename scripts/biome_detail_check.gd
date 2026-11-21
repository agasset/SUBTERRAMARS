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
	var moving_animals := 0
	for room in game.fauna_sites:
		var first: Vector2 = game.call("_fauna_position", room)
		var moved := false
		for i in range(160):
			game.fauna_time = i * 0.35
			var point: Vector2 = game.call("_fauna_position", room)
			assert(game.call("_fauna_ground_is_clear", point, room))
			if point.distance_to(first) > 2.0: moved = true
		if moved: moving_animals += 1
	assert(moving_animals == game.fauna_sites.size())
	var cave: Dictionary = game.world.caves[game.world.entry]
	game.explored_caves[cave.id] = true
	game.selected_cave = cave.id
	game.current_cave_id = cave.id
	game.unit_position = game.call("_level_access_position", cave.id)
	game.call("_update_view_mode_ui")
	var footprint: PackedVector2Array = game.call("_biome_base_footprint", cave)
	var anchor := Vector2.ZERO
	for point in footprint: anchor += point
	anchor /= 4.0
	var before: Vector2 = game.unit_position
	assert(game.call("_try_click_biome_base", game.call("_world_to_screen", anchor) - Vector2(0, game.zoom_level * 12)))
	assert(game.inventory_window.visible and game.inventory_tabs.current_tab == 1)
	assert(game.unit_position == before)
	game.inventory_window.hide()
	var corners: PackedVector2Array = game.call("_room_lantern_corners", cave.contour)
	for corner in corners:
		var point: Vector2 = game.call("_room_lamp_anchor", cave, corner)
		assert(game.call("_distance_to_cave_boundary", point, cave) >= 10.0)
	var rear := corners[0]
	for corner in corners:
		if corner.y < rear.y: rear = corner
	var lamp: Vector2 = game.call("_room_lamp_anchor", cave, rear)
	game.zoom_level = 8.0
	game.call("_focus_world_position", lamp, 8.0)
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png("res://reports/fanal_cristalli_revisat.png") == OK)
	print("BIOME_FIXTURES_BASE_CLICK_AND_FAUNA_OK moving=%d lamps=4 workshop_tab=1 no_teleport=true" % moving_animals)
	quit()
