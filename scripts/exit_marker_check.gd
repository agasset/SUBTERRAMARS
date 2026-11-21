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
	game.analysis_mode=true
	game._ensure_solid_room_rocks()
	game.revealed_mask.fill(1)
	for cave in game.world.caves: game.explored_caves[cave.id]=true
	for corridor in game.world.corridors:
		game.discovered_exits[game._exit_key(corridor.a,corridor.id)]=true
		game.discovered_exits[game._exit_key(corridor.b,corridor.id)]=true
	var count := 0
	var routes := 0
	var before := var_to_bytes(game.world)
	for cave in game.world.caves:
		game.selected_cave=cave.id
		game.current_cave_id=cave.id
		game.zoom_level=3.5
		for exit_info in game._visible_exits_for_cave(cave.id):
			game.unit_position=game._arrival_point(cave.id,exit_info.corridor_id)
			var marker: Vector2=exit_info.position+exit_info.direction*8.0
			var order: Dictionary=game._resolve_order_target(marker)
			assert(not order.is_empty() and order.corridor_id==exit_info.corridor_id)
			var path: Array[Vector2]=game._path_for_order(order)
			if not path.is_empty():
				var last: Vector2=game.unit_position
				for point in path:
					assert(game._segment_is_walkable(last,point))
					last=point
				routes+=1
			count+=1
	assert(count>0 and routes==count)
	assert(before==var_to_bytes(game.world))
	var clicked := false
	for cave in game.world.caves:
		if clicked: break
		game.selected_cave=cave.id
		game.current_cave_id=cave.id
		game._focus_cave(cave.id,3.5)
		game._update_view_mode_ui()
		for exit_info in game._visible_exits_for_cave(cave.id):
			var corridor: Dictionary=game._corridor_by_id(exit_info.corridor_id)
			if not game._is_gallery_exit_accessible(corridor,cave.id): continue
			var point: Vector2=game._world_to_screen(exit_info.position+exit_info.direction*8.0)
			if game._over_ui(point) or not game._view_rect().has_point(point): continue
			game.unit_position=game._arrival_point(cave.id,corridor.id)
			var click := InputEventMouseButton.new()
			click.button_index=MOUSE_BUTTON_LEFT
			click.pressed=true
			click.position=point
			game._input(click)
			assert(game.moving and game.inspection_corridor_id==corridor.id)
			clicked=true
			break
	assert(clicked)
	print("EXIT_MARKER_OK markers=%d routes=%d exact_corridor=true world_unchanged=true" % [count,routes])
	game.queue_free()
	await process_frame
	await process_frame
	quit()
