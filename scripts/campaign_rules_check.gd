extends SceneTree
const Harness = preload("res://scripts/organism_preview.gd")
const Rules = preload("res://scripts/campaign_rules.gd")
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var orders := {}
	for seed_value in range(50):
		var order := Rules.order_for_seed(seed_value)
		assert(Rules.valid_order(order) and order == Rules.order_for_seed(seed_value))
		orders[str(order)] = true
		for depth in range(1,21):
			var biome := Rules.biome_at_depth(depth,order)
			if depth<=3: assert(biome==1)
			if depth>=16: assert(biome==Rules.biome_at_depth(depth,Rules.CLASSIC_ORDER))
	assert(orders.size()>1)
	root.size = Vector2i(1440,900)
	var game = Harness.PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game.game_audio.set_enabled(false)
	game._clear_profile_progress()
	game._new_world(134027)
	var expected: Array = game.campaign_biome_order.duplicate()
	assert(game.discovered_biomes.is_empty())
	for heading in game.depth_zone_headings.values(): assert(heading.text=="Bioma per descobrir")
	var baseline: Dictionary = game._capture_saved_game()
	game.surface_mode = false
	var checked_gates := 0
	var budgets: Array = []
	for depth in range(1,21):
		game._change_underground_level(depth,-1)
		for node in game.get_children():
			if node is Window: node.hide()
		var biome: int = game._biome_at_depth(depth)
		assert(game.world.biome_profile==biome)
		for id in game.flora_species_by_room.values():
			assert(game.FLORA_SPECIES[str(id).get_slice("~",0)].get("biome",1)==biome)
		for id in game.fauna_species_by_room.values():
			assert(game.FAUNA_SPECIES[str(id).get_slice("~",0)].get("biome",1)==biome)
		var iron := 0
		var basic_biology := {}
		game.equipped_modifiers.clear()
		for room in game.material_sites:
			if game._mineral_type(room)=="ferro": iron+=game._mining_yield(0)
		for sites in [game.flora_species_by_room,game.fauna_species_by_room]:
			for species in sites.values():
				if game._can_detect_species(species): basic_biology[species]=true
		# One modifier, ladder refill and a repair; no rare mineral/filter dependency.
		assert(iron>=game.MODIFIER_MATERIAL_COST+game.FOLDING_LADDER_REPAIR_COST+1)
		assert(basic_biology.size()>=3)
		budgets.append({"depth":depth,"biome":biome,"iron_at_basic_tool":iron,"basic_scanner_species":basic_biology.size(),"gate":Rules.requirement(biome),"boundary":Rules.is_boundary(depth)})
		for start in Rules.STARTS:
			var name: String = game._profile_biome_name(start)
			assert((name!="Bioma per descobrir")==game.discovered_biomes.has(game._biome_at_depth(start)))
		if not Rules.is_boundary(depth): continue
		game.selected_cave = game.descent_access
		game.current_cave_id = game.descent_access
		game.unit_position = game._level_access_position(game.descent_access)
		game.move_target = game.unit_position
		game.explored_caves[game.descent_access] = true
		game.moving = false
		game.bio_scanner_tier = 0
		game.bio_scanner_integrity = 100
		# Each isolated boundary scenario starts with a replenished ladder.
		game.ladder_uses_spent = 0
		assert(not game._can_descend_to_lower_level())
		var uses: int = game.ladder_uses_spent
		game._descend_to_lower_level()
		assert(game.current_level==depth and game.ladder_uses_spent==uses)
		assert(game.action_notice_label.text.contains("Requereix"))
		if biome==7:
			game._ensure_solid_room_rocks()
			game._focus_cave(game.selected_cave,4.5)
			game._update_view_mode_ui()
			game.queue_redraw()
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://reports/requisit_descens_glacial.png")
		match biome:
			1: game.bio_scanner_tier = 1
			4: game.equipped_modifiers["mineria"] = "mining_crystal"
			7: game.equipped_modifiers["botes"] = "boots_ice"
			10: game.equipped_modifiers["botes"] = "boots_water"
			13: game.equipped_modifiers["vestit"] = "suit_hot"
			16: game.equipped_modifiers["escaner"] = "scanner_abyss"
			19: game.bio_scanner_tier = 2
		assert(game._can_descend_to_lower_level())
		var integrity_property: String = "bio_scanner_integrity" if biome in [1,16,19] else ("mining_tool_integrity" if biome==4 else ("suit_integrity" if biome==13 else "boots_integrity"))
		var integrity: float = game.get(integrity_property)
		game.set(integrity_property,0.0)
		assert(not game._can_descend_to_lower_level())
		game.set(integrity_property,integrity)
		if biome==13:
			game.equipped_modifiers.clear()
			game.equipped_modifiers["botes"]="boots_magma"
			assert(game._can_descend_to_lower_level())
		game._descend_to_lower_level()
		assert(game.current_level==depth+1 and game.ladder_uses_spent==uses+1)
		checked_gates+=1
	assert(checked_gates==7)
	var saved: Dictionary = game._capture_saved_game()
	game._clear_profile_progress()
	game._new_world(42)
	game._restore_saved_game(saved)
	assert(game.campaign_biome_order==expected and game.discovered_biomes.size()==8)
	assert(game._valid_saved_game(saved))
	var corrupt := saved.duplicate(true)
	corrupt.campaign_biome_order=[1,4,4,7,10,16,19,20]
	assert(not game._valid_saved_game(corrupt))
	# Legacy saves retain their actual old layout and known names.
	baseline.erase("campaign_biome_order")
	baseline.erase("discovered_biomes")
	baseline.deepest_reached=4
	var original_world := var_to_bytes(baseline.level.world)
	game._restore_saved_game(baseline)
	assert(game.campaign_biome_order==Rules.CLASSIC_ORDER)
	assert(game.discovered_biomes.has(1) and game.discovered_biomes.has(4) and not game.discovered_biomes.has(7))
	assert(original_world==var_to_bytes(game.world))
	var report := FileAccess.open("res://reports/campanya_ordre_requisits.json",FileAccess.WRITE)
	report.store_string(JSON.stringify({"order_seed":134027,"order":expected,"tested_seeds":50,"unique_orders":orders.size(),"levels":budgets,"minimum_gate_equipment_cost":{"iron":20,"research":7},"excludes":["consumables","repairs","optional upgrades"],"legacy_world_unchanged":true},"\t"))
	print("CAMPAIGN_ORDER_AND_GATES_OK seeds=50 permutations=%d levels=20 boundaries=7 economy=basic_resources legacy=unchanged profile=stable" % orders.size())
	quit()
