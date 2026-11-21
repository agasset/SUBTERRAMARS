extends SceneTree

class BenchGame extends "res://scripts/main.gd":
	var samples: Array[float] = []
	var sections: Dictionary = {}
	var measure := false
	func _ready() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		_build_ui()
		_layout_panels()
	func _save_active_profile() -> bool:
		return true
	func _draw() -> void:
		var start := Time.get_ticks_usec()
		super._draw()
		if measure:
			samples.append(float(Time.get_ticks_usec() - start) / 1000.0)
	func _record(key: String, start: int) -> void:
		if measure:
			sections[key] = float(sections.get(key, 0.0)) + float(Time.get_ticks_usec() - start) / 1000.0
	func _draw_world_textured_corridor(edges: Dictionary, cave_id: int, fade_at_end: bool = true) -> void:
		var start := Time.get_ticks_usec()
		super._draw_world_textured_corridor(edges, cave_id, fade_at_end)
		_record("corridors_ms", start)
	func _draw_cave_wall_face(start: Vector2, finish: Vector2, direction: float, opacity: float = 1.0) -> void:
		var tick := Time.get_ticks_usec()
		super._draw_cave_wall_face(start, finish, direction, opacity)
		_record("walls_ms_including_corridor_walls", tick)
	func _draw_isometric_floor(cave: Dictionary, min_x: int, max_x: int, min_y: int, max_y: int, tint: Color) -> void:
		var tick := Time.get_ticks_usec()
		super._draw_isometric_floor(cave, min_x, max_x, min_y, max_y, tint)
		_record("floors_ms", tick)

	func _draw_gallery_lamps(edges: Dictionary) -> void:
		var tick := Time.get_ticks_usec()
		super._draw_gallery_lamps(edges)
		_record("lamps_ms", tick)

	func _draw_isometric_room_terrain(cave: Dictionary, occupied: bool) -> void:
		var tick := Time.get_ticks_usec()
		super._draw_isometric_room_terrain(cave, occupied)
		_record("room_terrain_ms", tick)

	func _draw_isometric_room_fixtures(cave: Dictionary) -> void:
		var tick := Time.get_ticks_usec()
		super._draw_isometric_room_fixtures(cave)
		_record("fixtures_ms", tick)

	func _draw_isometric_walls(cave: Dictionary) -> void:
		var tick := Time.get_ticks_usec()
		super._draw_isometric_walls(cave)
		_record("room_walls_ms", tick)

	func _draw_isometric_corridors(cave: Dictionary, passage_id: int) -> void:
		var tick := Time.get_ticks_usec()
		super._draw_isometric_corridors(cave, passage_id)
		_record("exit_stubs_ms", tick)

	func _draw_isometric_room_features(cave_id: int) -> void:
		var tick := Time.get_ticks_usec()
		super._draw_isometric_room_features(cave_id)
		_record("features_ms", tick)

	func _draw_room_lamps(cave: Dictionary, at_entry: bool) -> void:
		var tick := Time.get_ticks_usec()
		super._draw_room_lamps(cave, at_entry)
		_record("room_lamps_ms", tick)

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(1440, 900)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var game := BenchGame.new()
	root.add_child(game)
	game.set_process(false)
	game.call("_new_world", 134027)
	game.surface_mode = false
	game.current_level = 1
	game.analysis_mode = true
	game.selected_cave = game.world.entry
	game.current_cave_id = game.world.entry
	game.unit_position = game.world.caves[game.world.entry].position
	game.call("_ensure_solid_room_rocks")
	game.call("_update_view_mode_ui")
	for scenario in ["entry_only", "all_local", "all_fit", "map_all"]:
		if scenario != "entry_only":
			game.revealed_mask.fill(1)
			for cave in game.world.caves:
				game.detected_caves[cave.id] = true
				game.explored_caves[cave.id] = true
			for corridor in game.world.corridors:
				game.completed_gallery_traces[corridor.id] = true
		game.analysis_mode = scenario != "map_all"
		game.call("_focus_cave", game.world.entry, 3.5)
		if scenario in ["all_fit", "map_all"]:
			game.call("_fit_discovered_map")
		var unchanged := var_to_bytes([game.world, game.unit_position, game.revealed_mask,
			game.detected_caves, game.explored_caves, game.completed_gallery_traces])
		game.samples.clear()
		game.measure = true
		for warmup in range(3):
			game.queue_redraw()
			await process_frame
			await RenderingServer.frame_post_draw
		var first_draw := game.samples[0] if not game.samples.is_empty() else 0.0
		game.samples.clear()
		game.sections.clear()
		game.measure = true
		var draw_calls := 0.0
		for frame in range(12):
			game.queue_redraw()
			await process_frame
			await RenderingServer.frame_post_draw
			draw_calls += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		game.measure = false
		var total := 0.0
		for sample in game.samples:
			total += sample
		var count := maxi(1, game.samples.size())
		var report := {"scenario": scenario, "draw_cpu_ms": snappedf(total / count, 0.01),
			"draw_calls": roundi(draw_calls / 12.0), "frames": count, "zoom": game.zoom_level, "first_draw_cpu_ms": snappedf(first_draw, 0.01)}
		for key in game.sections:
			report[key] = snappedf(game.sections[key] / count, 0.01)
		print(JSON.stringify(report))
		assert(unchanged == var_to_bytes([game.world, game.unit_position, game.revealed_mask,
			game.detected_caves, game.explored_caves, game.completed_gallery_traces]))
		if scenario == "all_fit":
			root.get_texture().get_image().save_png("res://reports/rendiment_estrat_complet.png")
	game.current_level = 4
	game.call("_ensure_cave_render_cache")
	assert(game.render_wall_groups.is_empty() and game.render_room_lights.is_empty())
	game.current_level = 1
	game.world = game.world.duplicate(true)
	game.call("_ensure_cave_render_cache")
	assert(game.render_wall_groups.is_empty() and is_same(game.render_cache_world, game.world))
	print("RENDER_CACHE_INVALIDATION_AND_WORLD_STATE_OK")
	quit()
