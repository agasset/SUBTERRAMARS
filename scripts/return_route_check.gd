extends SceneTree
const Harness=preload("res://scripts/organism_preview.gd")
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var game=Harness.PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game._new_world(134027)
	game.surface_mode=false
	game.revealed_mask.fill(1)
	for cave in game.world.caves: game.explored_caves[cave.id]=true
	for corridor in game.world.corridors: game.completed_gallery_traces[corridor.id]=true
	var before := var_to_bytes(game.world)
	var checked := 0
	for corridor in game.world.corridors:
		var start: Vector2 = corridor.points[1]
		var finish: Vector2 = corridor.points[-2]
		var path: Array[Vector2] = game._find_path(start,finish,{},true,-1,true)
		if path.is_empty(): continue
		var last := start
		for point in path:
			assert(game._segment_is_walkable(last,point))
			assert(game._is_known_room_route_point(point,true))
			last=point
		checked+=1
		if checked==10: break
	assert(checked>0 and before==var_to_bytes(game.world))
	var sample_gallery: Dictionary=game.world.corridors[0]
	var old_traces: Dictionary=game.walked_gallery_spans.duplicate(true)
	var full: PackedVector2Array=sample_gallery.points
	game.walked_gallery_spans[sample_gallery.id]=[full,full,full.slice(1),full]
	var spans: Array[PackedVector2Array]=game._drawn_gallery_spans(sample_gallery)
	assert(spans.size()==1 and spans[0]==full)
	game.walked_gallery_spans=old_traces
	assert(before==var_to_bytes(game.world))
	assert(game._upgrade_mineral(3)=="quars" and game._upgrade_mineral(6)=="magnetita")
	var room: int = game.world.entry
	var closed := 0
	for exit_info in game._visible_exits_for_cave(room):
		if not game._is_gallery_exit_accessible(game._corridor_by_id(exit_info.corridor_id),room): closed+=1
	if closed>0: assert(("Galeries tancades · %d" % closed) in game._room_detail_lines(room))
	else: assert(not "Galeries tancades · 0" in game._room_detail_lines(room))
	var graph_routes := 0
	for corridor in game.world.corridors:
		var from: Vector2=game.world.caves[corridor.a].position
		var to: Vector2=game.world.caves[corridor.b].position
		var route: Array[Vector2]=game._find_path(from,to,{},true,-1,true)
		if route.is_empty(): continue
		var last:=from
		for point in route:
			assert(game._segment_is_walkable(last,point))
			last=point
		graph_routes+=1
		if graph_routes==10: break
	assert(graph_routes>0)
	print("GRAPH_GALLERY_ROUTE_OK routes=%d" % graph_routes)
	print("RETURN_ROUTE_OK routes=%d every_step_known_and_walkable=true world_geometry_unchanged=true" % checked)
	game.queue_free()
	await process_frame
	await process_frame
	quit()
