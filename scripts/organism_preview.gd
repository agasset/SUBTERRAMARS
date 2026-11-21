extends SceneTree

class SpecimenSheet extends Node2D:
	const Pixel = preload("res://scripts/organism_pixel_art.gd")
	const Traits = preload("res://scripts/organism_traits.gd")
	var plants: Array = []
	var animals: Array = []
	var colors: Array = []
	var clock := 0.0
	func _draw() -> void:
		draw_rect(Rect2(0, 0, 1200, 720), Color("091117"))
		draw_string(ThemeDB.fallback_font, Vector2(28, 36), "COVES OXIDADES · PROVA DE FLORA I FAUNA PIXEL ART", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("53e2ef"))
		for variant in range(2):
			var plant := Traits.decode(plants[variant], Traits.PLANT)
			var center := Vector2(300 + variant * 600, 220)
			Pixel.draw_plant(self, center, 4.5, plant, clock, variant)
			draw_string(ThemeDB.fallback_font, center + Vector2(-210, 40), "Variant %d · %d tiges · %s" % [variant + 1, int(plant.stems) + 1, Traits.PLANT.tip[int(plant.tip)]], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("cadde2"))
			var animal := Traits.decode(animals[variant], Traits.ANIMAL)
			animal.legs += 1
			animal.fur = animal.fur == 1
			for facing in range(4):
				var point := Vector2(150 + facing * 300, 420 + variant * 210)
				Pixel.draw_animal(self, point, 5.5, animal, [Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1), Vector2(1, -1)][facing], clock, true, colors)
				draw_string(ThemeDB.fallback_font, point + Vector2(-110, 50), "V%d · %d potes · direcció %d" % [variant + 1, animal.legs, facing + 1], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("cadde2"))

class PreviewGame extends "res://scripts/main.gd":
	func _ready() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		_build_ui()
		game_audio.settings_enabled=false
		game_audio.music_player.stream_paused=true
		_layout_panels()
	func _save_active_profile() -> bool:
		return true

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var game := PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game.call("_new_world", 134027)
	game.surface_mode = false
	game.current_level = 1
	game.analysis_mode = true
	var room: int = game.fauna_sites.keys()[0]
	game.selected_cave = room
	game.current_cave_id = room
	game.explored_caves[room] = true
	game.seen_fauna[room] = true
	game.unit_position = game.world.caves[room].position
	game.call("_ensure_solid_room_rocks")
	if not game.flora_sites.has(room):
		var rng := RandomNumberGenerator.new()
		rng.seed = 42
		game.flora_sites[room] = game.call("_sample_room_site", game.world.caves[room], rng,
			8.0, game.call("_room_site_reservations", room))
	var plants := ["falguera~2~0~2~1~1~1~1~1~1", "falguera~2~1~4~0~3~2~2~2~2"]
	var animals := ["escarabat~2~3~0~0~2~1~1~1~1~1", "escarabat~2~1~1~1~3~3~2~2~2~2"]
	game.call("_update_view_mode_ui")
	game.call("_focus_cave", room, 5.0)
	for variant in range(2):
		game.flora_species_by_room[room] = plants[variant]
		game.fauna_species_by_room[room] = animals[variant]
		assert(game.OrganismPixelArt.supports_plant(plants[variant]))
		assert(game.OrganismPixelArt.supports_animal(animals[variant]))
		var state := var_to_bytes([game.world, game.flora_sites, game.fauna_sites,
			game.flora_species_by_room, game.fauna_species_by_room, game.fauna_patrol_ends])
		for frame in range(4):
			game.fauna_time = frame * 0.27
			var original_position: Vector2 = game.call("_fauna_position", room)
			game.queue_redraw()
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://reports/organismes_variant_%d_frame_%d.png" % [variant + 1, frame])
			assert(original_position == game.call("_fauna_position", room))
			assert(state == var_to_bytes([game.world, game.flora_sites, game.fauna_sites,
				game.flora_species_by_room, game.fauna_species_by_room, game.fauna_patrol_ends]))
		print("ORGANISM_VARIANT_RENDERED_AND_DATA_STABLE %d" % variant)
	for facing in [Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1), Vector2(1, -1)]:
		assert(game.OrganismPixelArt.facing_index(facing) == [Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1), Vector2(1, -1)].find(facing))
	print("ORGANISM_FOUR_DIRECTIONS_OK")
	# Exercise every current family and its legacy ID through the real discovery UI.
	var snapshot := var_to_bytes([game.flora_sites, game.flora_species_by_room, game.world])
	var original_species: String = game.flora_species_by_room[room]
	for family in game.FLORA_SPECIES:
		var id := str(family) + "~2~2~1~2~5~1~1~1~1"
		assert(game.OrganismPixelArt.supports_plant(id))
		assert(game.OrganismPixelArt.supports_plant(family))
		assert(game.OrganismPixelArt.plant_recipe(id) == game.OrganismTraits.decode(id, game.OrganismTraits.PLANT))
		game.flora_species_by_room[room] = id
		game.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		if family == "coral":
			await game.call("_show_new_discovery", id, false, game.flora_sites[room])
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://reports/corall_descoberta_pixel_art.png")
			game.discovery_dialog.hide()
	game.flora_species_by_room[room] = original_species
	assert(snapshot == var_to_bytes([game.flora_sites, game.flora_species_by_room, game.world]))
	print("ALL_FLORA_FAMILIES_PIXEL_ART_OK families=%d legacy_and_procedural=true" % game.FLORA_SPECIES.size())
	var original_animal: String = game.fauna_species_by_room[room]
	for family in game.FAUNA_SPECIES:
		var id := str(family) + "~2~1~1~0~2~2~2~2~1~1"
		assert(game.OrganismPixelArt.supports_animal(id))
		assert(game.OrganismPixelArt.supports_animal(family))
		assert(game.OrganismPixelArt.supports_animal(str(family) + "~1~3~1~0~2~2"))
		var raw: Dictionary = game.OrganismTraits.decode(id, game.OrganismTraits.ANIMAL)
		raw.legs += 1
		raw.fur = raw.fur == 1
		assert(game.call("_fauna_variant", id) == raw)
		game.fauna_species_by_room[room] = id
		game.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		if family == "isopode":
			game.bio_scan_room = room
			game.bio_scan_fauna = true
			game.bio_scan_elapsed = 0.99 * game.call("_bio_scan_duration", game.bio_scanner_tier)
			game.queue_redraw()
			await process_frame
			await RenderingServer.frame_post_draw
			await game.call("_show_new_discovery", id, true, game.call("_fauna_position", room))
			await process_frame
			await RenderingServer.frame_post_draw
			assert(game.discovery_photo.texture != null)
			assert(not game.discovery_capture_pending and not game.taking_field_photo)
			root.get_texture().get_image().save_png("res://reports/isopode_descoberta_pixel_art.png")
			game.bio_scan_room = -1
			game.discovery_dialog.hide()
	game.fauna_species_by_room[room] = original_animal
	print("ALL_FAUNA_FAMILIES_PIXEL_ART_OK families=%d versions=bare_v1_v2 clean_discovery=true" % game.FAUNA_SPECIES.size())
	game.call("_focus_cave", room, game.call("_analysis_zoom_for_cave", room))
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://reports/organismes_zoom_entrada.png")
	game.call("_fit_discovered_map")
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://reports/organismes_enquadra.png")
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1200, 720)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var sheet := SpecimenSheet.new()
	sheet.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sheet.plants = plants
	sheet.animals = animals
	sheet.colors = game.FAUNA_VARIANT_COLORS
	viewport.add_child(sheet)
	for frame in range(4):
		sheet.clock = frame * 0.19
		sheet.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		viewport.get_texture().get_image().save_png("res://reports/organismes_mostra_%d.png" % frame)
	quit()
