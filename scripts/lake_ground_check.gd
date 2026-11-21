extends SceneTree
const Harness = preload("res://scripts/organism_preview.gd")
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	root.size=Vector2i(1440,900)
	var game=Harness.PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game.game_audio.set_enabled(false)
	game._new_world(134027)
	game.surface_mode=false
	var count := 0
	for depth in [1,4,7,10,13,16,19,20]:
		game._change_underground_level(depth,-1)
		for node in game.get_children():
			if node is Window: node.hide()
		game._ensure_solid_room_rocks()
		var before := var_to_bytes(game.world)
		var best: int = -1
		for cave in game.world.caves:
			for pool in game._room_surface_details(cave):
				assert(pool.thin_end.distance_to(pool.wall_anchor)<0.01)
				assert(absf(pool.ground_u.dot(pool.ground_v))<0.01)
				assert(pool.ground_u.cross(pool.ground_v)>0)
				for point in pool.shape:
					assert(game._distance_to_cave_boundary(point,cave)<0.01 or Geometry2D.is_point_in_polygon(point-cave.position,cave.contour))
				count+=1
				if best<0: best=cave.id
		assert(best>=0)
		assert(before==var_to_bytes(game.world))
		game.selected_cave=best
		game.current_cave_id=best
		game.unit_position=game.world.caves[best].position
		game.explored_caves[best]=true
		game._focus_cave(best,4.5)
		game._update_view_mode_ui()
		game.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://reports/llac_integrat_%02d.png" % depth)
	print("LAKE_GROUND_OK profiles=8 pools=%d anchored=true handedness=true world_unchanged=true" % count)
	game.game_audio.music_player.stop()
	game.queue_free()
	await process_frame
	await process_frame
	quit()
