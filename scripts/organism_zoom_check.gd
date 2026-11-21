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
	game.analysis_mode = true
	var room: int = game.fauna_sites.keys()[0]
	game.selected_cave = room
	game.current_cave_id = room
	game.explored_caves[room] = true
	game.seen_fauna[room] = true
	game.unit_position = game.world.caves[room].position
	game.call("_ensure_solid_room_rocks")
	game.flora_sites[room] = game.unit_position + Vector2(12, 0)
	game.flora_species_by_room[room] = "falguera"
	var plant: Dictionary = game.OrganismPixelArt.plant_recipe("falguera")
	var animal: Dictionary = game.call("_fauna_variant", game.fauna_species_by_room[room])
	var before := var_to_bytes([game.world, game.unit_position, game.flora_sites, game.fauna_sites, game.revealed_mask])
	game.call("_update_view_mode_ui")
	for zoom in [0.28, 0.8, 1.75, 3.5, 7.0, 8.0]:
		game.zoom_level = zoom
		game.call("_focus_cave", room, zoom)
		var factor: float = game.call("_isometric_organism_scale")
		assert(is_equal_approx(factor / zoom, game.ISOMETRIC_ORGANISM_SIZE / 3.5))
		var flora: Rect2 = game.OrganismPixelArt.plant_hit_rect(Vector2.ZERO, factor * 1.4, plant)
		var fauna: Rect2 = game.OrganismPixelArt.animal_hit_rect(Vector2.ZERO, factor, animal)
		var base_flora: Rect2 = game.OrganismPixelArt.plant_hit_rect(Vector2.ZERO, 1.4, plant)
		var base_fauna: Rect2 = game.OrganismPixelArt.animal_hit_rect(Vector2.ZERO, 1.0, animal)
		assert(flora.size.is_equal_approx(base_flora.size * factor))
		assert(fauna.size.is_equal_approx(base_fauna.size * factor))
		game.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		assert(before == var_to_bytes([game.world, game.unit_position, game.flora_sites, game.fauna_sites, game.revealed_mask]))
		if zoom in [1.75, 3.5, 7.0]:
			assert(root.get_texture().get_image().save_png("res://reports/organismes_escala_%.2f.png" % zoom) == OK)
		if zoom == 7.0:
			assert(root.get_texture().get_image().get_region(Rect2i(game.room_details_panel.get_global_rect())).save_png("res://reports/registre_sala.png") == OK)
	print("ORGANISM_WORLD_ZOOM_OK zooms=6 draw_and_hit_bounds=linear world=unchanged")
	quit()
