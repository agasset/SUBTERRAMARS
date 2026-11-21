extends SceneTree
const Harness=preload("res://scripts/organism_preview.gd")
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var game=Harness.PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game._new_world(134027)
	game._change_underground_level(1,-1)
	game.surface_mode=false
	game._ensure_solid_room_rocks()
	game.revealed_mask.fill(1)
	for cave in game.world.caves: game.explored_caves[cave.id]=true
	for corridor in game.world.corridors: game.completed_gallery_traces[corridor.id]=true
	var corridor: Dictionary=game.world.corridors[0]
	game.unit_position=game._arrival_point(corridor.a,corridor.id)
	var target: Vector2=game.unit_position
	var before := var_to_bytes(game.world)
	for iso in [false,true]:
		game.analysis_mode=iso
		game.unit_position=target
		game.place_marker_button.pressed.emit()
		assert(game.navigation_marker.position==target)
		var saved: Dictionary=game._capture_saved_game()
		assert(saved.navigation_marker.position==target and saved.navigation_marker.level==1)
		game.unit_position=game._arrival_point(corridor.b,corridor.id)
		game.return_marker_button.pressed.emit()
		if not game.moving: print("MARKER_ROUTE_DIAGNOSTIC ",game.action_notice_label.text," iso=",iso)
		assert(game.moving and game.move_target==target and game.move_path.back()==target)
		var last: Vector2=game.unit_position
		for point in game.move_path:
			assert(game._segment_is_walkable(last,point))
			last=point
	assert(before==var_to_bytes(game.world))
	var completed: Dictionary=game.completed_gallery_traces.duplicate()
	game.completed_gallery_traces.clear()
	game.walked_gallery_spans.clear()
	game.unit_position=game._arrival_point(corridor.b,corridor.id)
	var stationary: Vector2=game.unit_position
	game._return_to_navigation_marker()
	assert(not game.moving and game.move_path.is_empty() and game.unit_position==stationary)
	game.completed_gallery_traces.assign(completed)
	if DisplayServer.get_name()!="headless":
		root.size=Vector2i(1440,900)
		game.analysis_mode=true
		game.selected_cave=corridor.a
		game.current_cave_id=corridor.a
		game.unit_position=target
		game._focus_cave(corridor.a,3.5)
		game._update_view_mode_ui()
		game.action_notice_label.hide()
		game.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://reports/marcador_retorn.png")
	game._change_underground_level(2,-1)
	game.surface_mode=false
	game.unit_position=game._level_access_position(game.world.entry)
	game.current_cave_id=game.world.entry
	game._return_to_navigation_marker()
	await process_frame
	await process_frame
	assert(game.current_level==1 and game.move_target==target)
	game._new_world(134028)
	assert(game.navigation_marker.is_empty())
	print("NAVIGATION_MARKER_OK map_iso=true saved_exact_position=true routes_walkable=true new_world_clears=true")
	game.queue_free()
	await process_frame
	await process_frame
	quit()
