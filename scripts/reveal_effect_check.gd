extends SceneTree
const Harness=preload("res://scripts/organism_preview.gd")
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	root.size=Vector2i(1440,900)
	var game=Harness.PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game._new_world(134027)
	game.surface_mode=false
	game.analysis_mode=true
	game.current_level=1
	var room: int = 0
	var top := INF
	for cave in game.world.caves:
		for point in cave.contour:
			if cave.position.y+point.y<top:
				top=cave.position.y+point.y
				room=cave.id
	game.selected_cave=room
	game.current_cave_id=room
	game.unit_position=game.world.caves[room].position
	game.explored_caves.clear()
	game.revealed_mask.fill(0)
	game.flashlight_on=false
	game._focus_cave(room,4.5)
	game._update_view_mode_ui()
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	var light
	for node in game.get_children():
		if node.get_script()==preload("res://scripts/cave_lighting.gd"): light=node
	assert(light!=null and light.mask!=null)
	assert(light.mask.get_width()==game.world.grid_size.x+16)
	assert(light.mask.get_height()==game.world.grid_size.y+16)
	light.set_process(false)
	light.begin_room_reveal(game.world.caves[room])
	game._reveal_entire_room(game.world.caves[room])
	game._scan_current_cave()
	var state := var_to_bytes([game.world,game.explored_caves,game.revealed_mask])
	var images: Array[Image]=[]
	for elapsed in [0.0,0.9,2.0]:
		light.reveal_elapsed=elapsed
		light.queue_redraw()
		game.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		var capture: Image=root.get_texture().get_image()
		images.append(capture)
		capture.save_png("res://reports/obertura_sala_%02d.png" % roundi(elapsed*10))
	assert(images[0].get_data()!=images[1].get_data() and images[1].get_data()!=images[2].get_data())
	assert(state==var_to_bytes([game.world,game.explored_caves,game.revealed_mask]))
	assert(is_equal_approx(float(light.material.get_shader_parameter("reveal_progress")),1.0))
	print("REVEAL_EFFECT_OK duration=2s stages=3 world_and_discovery_unchanged=true")
	game.queue_free()
	await process_frame
	await process_frame
	quit()
