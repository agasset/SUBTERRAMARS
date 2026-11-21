extends SceneTree
const Harness = preload("res://scripts/organism_preview.gd")
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	root.size = Vector2i(1440,900)
	var game = Harness.PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game.game_audio.set_enabled(false)
	game._new_world(134027)
	game.surface_mode = false
	var total := 0
	for depth in [1,4,7,10,13,16,19,20]:
		game._change_underground_level(depth,-1)
		for node in game.get_children():
			if node is Window: node.hide()
		game._ensure_solid_room_rocks()
		var kinds := [0,0,0,0]
		var best: int = game.world.entry
		for item in game.world.ambience_v1:
			kinds[item.kind] += 1
			if item.kind == 1: best = item.cave_id
			for cell in item.blocked_cells:
				assert(game.world.walkable_mask[cell.y*game.world.grid_size.x+cell.x] == 0)
			if item.cave_id == game.descent_access or item.cave_id == game.world.entry:
				assert(item.position.distance_to(game._level_access_position(item.cave_id)) >= 42.0)
		for count in kinds: assert(count > 0)
		for cave in game.world.caves: assert(game._base_mask_reaches_exits(game.world.walkable_mask,cave))
		var before := var_to_bytes(game.world)
		game._ensure_solid_room_rocks()
		assert(before == var_to_bytes(game.world))
		game.selected_cave = best
		game.current_cave_id = best
		game.unit_position = game.world.caves[best].position
		game.explored_caves[best] = true
		game.flashlight_on = true
		game.flashlight_charge = 100
		game.fauna_time = 2.0
		game._focus_cave(best,4.5)
		game._update_view_mode_ui()
		game.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png("res://reports/ambient_bioma_%02d.png" % depth) == OK)
		if depth == 4:
			for node in game.get_children():
				if node.get_script() != preload("res://scripts/cave_lighting.gd"): continue
				assert(int(node.material.get_shader_parameter("blocker_count")) > 0)
				node.set_process(false)
				var lit_image: Image = root.get_texture().get_image()
				node.material.set_shader_parameter("blocker_count",0)
				await process_frame
				await RenderingServer.frame_post_draw
				var unblocked: Image = root.get_texture().get_image()
				var difference := 0.0
				for y in range(220,650,4):
					for x in range(300,1150,4):
						var a := lit_image.get_pixel(x,y)
						var b := unblocked.get_pixel(x,y)
						difference += absf(a.r-b.r)+absf(a.g-b.g)+absf(a.b-b.b)
				assert(difference > 0.5)
				node.set_process(true)
				print("AMBIENCE_SHADOW_PIXEL_DIFFERENCE_OK delta=%.2f" % difference)
		assert(before == var_to_bytes(game.world))
		total += game.world.ambience_v1.size()
		print("AMBIENCE_BIOME_OK depth=%d counts=%s exits=reachable" % [depth,kinds])
		if depth == 1:
			game.selected_cave = game.descent_access
			game.current_cave_id = game.descent_access
			game.explored_caves[game.descent_access] = true
			game._focus_cave(game.descent_access,5.0)
			game.queue_redraw()
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://reports/entrada_descens_pixel_art.png")
			var shaft: Rect2 = game._descent_shaft_rect(game.descent_access)
			var art: Image = game.DESCENT_SHAFT_SPRITE.get_image()
			var hits := 0
			var rail_hits := 0
			var outline: PackedVector2Array = game._elevator_outline(game._world_to_screen(game._level_access_position(game.descent_access)),game._underground_elevator_extent())
			for y in range(0,art.get_height(),64):
				for x in range(0,art.get_width(),64):
					if art.get_pixel(x,y).a<0.5: continue
					var point := shaft.position+Vector2(float(x)/art.get_width(),float(y)/art.get_height())*shaft.size
					assert(game._descent_shaft_hit(point,game.descent_access))
					hits+=1
					if not Geometry2D.is_point_in_polygon(point,outline): rail_hits+=1
			assert(hits>12 and rail_hits>0)
			assert(not game._descent_shaft_hit(shaft.position,game.descent_access))
			print("DESCENT_SHAFT_ALPHA_HIT_OK samples=%d outside_old_outline=%d" % [hits,rail_hits])
	print("AMBIENCE_ALL_8_PROFILES_OK total=%d placement=stable navigation=connected render=unchanged" % total)
	quit()
