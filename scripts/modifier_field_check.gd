extends SceneTree
const Harness = preload("res://scripts/organism_preview.gd")
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	root.size = Vector2i(1440, 900)
	var game = Harness.PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game.game_audio.set_enabled(false)
	game._new_world(134027)
	game.surface_mode = false
	game.analysis_mode = true
	var room: int = game.world.entry
	var other: int = 0 if room != 0 else 1
	game.selected_cave = other
	game.current_cave_id = other
	game.unit_position = game.world.caves[other].position
	game.explored_caves[other] = true
	assert(not game._can_use_workshop())
	var before := var_to_bytes([game.world, game.unit_position, game.materials_in_pack])
	for id: String in game.EQUIPMENT_MODIFIERS:
		game.owned_modifiers[id] = true
		game._apply_equipment_modifier(id)
		var slot: String = game.EQUIPMENT_MODIFIERS[id][0]
		assert(game.equipped_modifiers.get(slot) == id)
		assert(not game.modifier_buttons[id].disabled)
		game._apply_equipment_modifier(id)
		assert(not game.equipped_modifiers.has(slot))
	assert(before == var_to_bytes([game.world, game.unit_position, game.materials_in_pack]))
	game.fauna_sites[other] = game.unit_position
	game.fauna_species_by_room[other] = "escarabat_ferric"
	game.fauna_patrol_ends[other] = game.unit_position
	game.analyzed_fauna.erase(other)
	game._apply_equipment_modifier("scanner_ferric")
	assert(game._fauna_is_visible())
	game.selected_fauna = other
	game.selected_flora = -1
	game._interact_with_flora()
	assert(game.bio_scan_room == other)
	assert(game.inventory_details[1].text.contains("ACTIU"))
	game._apply_equipment_modifier("scanner_ferric")
	game._update_bio_scan(0.1)
	assert(game.bio_scan_room == -1)
	game._apply_equipment_modifier("scanner_ferric")
	game._open_inventory(false)
	await process_frame
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://reports/modificadors_inventari.png")
	print("FIELD_MODIFIERS_OK toggles=%d fauna_scan=started inactive_filter=blocked inventory=active world=unchanged" % (game.EQUIPMENT_MODIFIERS.size()*2))
	quit()
