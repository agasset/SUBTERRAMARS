extends SceneTree

class PreviewGame extends "res://scripts/main.gd":
	func _ready() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		_build_ui()
		_layout_panels()
	func _save_active_profile() -> bool:
		return true

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game := PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game.call("_new_world", 134027)
	game.surface_mode = false
	game.analysis_mode = true
	game.current_level = 1
	var room := 0
	var degree := 0
	for cave in game.world.caves:
		var connections := 0
		for corridor in game.world.corridors:
			connections += int(corridor.a == cave.id or corridor.b == cave.id)
		if connections > degree:
			degree = connections
			room = cave.id
	game.selected_cave = room
	game.current_cave_id = room
	game.unit_position = game.world.caves[room].position
	game.explored_caves[room] = true
	for corridor in game.world.corridors:
		if corridor.a == room or corridor.b == room:
			game.discovered_exits[game.call("_exit_key", room, corridor.id)] = true
	game.call("_ensure_solid_room_rocks")
	game.call("_update_view_mode_ui")
	game.call("_focus_cave", room, 4.0)
	var unchanged := var_to_bytes([game.world, game.unit_position, game.discovered_exits])
	for complete in [false, true]:
		if complete:
			for corridor in game.world.corridors:
				if corridor.a == room or corridor.b == room:
					game.completed_gallery_traces[corridor.id] = true
		game.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		var name := "parets_boca_galeria.png" if complete else "parets_boca_stub.png"
		assert(root.get_texture().get_image().save_png("res://reports/" + name) == OK)
		assert(unchanged == var_to_bytes([game.world, game.unit_position, game.discovered_exits]))
		print("WALL_MOUTHS_RENDERED full_gallery=%s exits=%d" % [complete, degree])
	quit()
