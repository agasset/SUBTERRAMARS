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
	game.surface_mode=true
	game.materials_in_pack=100
	for i in range(8): game.flora_samples[i]=false
	for id in ["weapon_focus","weapon_efficiency","shield_hardening","shield_recovery"]:
		game._apply_equipment_modifier(id)
		assert(game.owned_modifiers.has(id))
		assert(game.modifier_buttons.has(id))
	assert(game.materials_in_pack==88)
	game.surface_mode=false
	game.analysis_mode=true
	var enemy: Dictionary=game.world.predators_v1.values()[0]
	var room: int=enemy.cave_id
	game.selected_cave=room
	game.current_cave_id=room
	game.explored_caves[room]=true
	game.unit_position=enemy.position+Vector2(24,0)
	game.equipped_modifiers["arma"]="weapon_focus"
	enemy.hp=100.0
	game.defence_state.energy=100.0
	assert(game.defence_system.fire(game))
	assert(game.defence_state.energy==85 and is_equal_approx(float(enemy.hp),77.5))
	game.equipped_modifiers["arma"]="weapon_efficiency"
	game.defence_state.cooldown=0.0
	assert(game.defence_system.fire(game))
	assert(game.defence_state.energy==76 and is_equal_approx(float(enemy.hp),59.5))
	game.equipped_modifiers["escut"]="shield_hardening"
	game.defence_state.shield=40.0
	game.health=100.0
	game.defence_system.damage(game,10)
	assert(game.defence_state.shield==32 and game.health==100)
	game.equipped_modifiers["escut"]="shield_recovery"
	game.defence_system.damage(game,1)
	assert(game.defence_state.recharge_delay==4)
	enemy.hp=0
	game.defence_state.recharge_delay=0
	game.defence_state.shield=20.0
	game.defence_system.tick(game,0.1)
	assert(is_equal_approx(float(game.defence_state.shield),20.9))
	var saved: Dictionary=game._capture_saved_game()
	assert(saved.equipped_modifiers.arma=="weapon_efficiency" and saved.owned_modifiers.has("shield_recovery"))
	if DisplayServer.get_name()!="headless":
		root.size=Vector2i(1440,900)
		game.surface_mode=true
		game._open_inventory(true)
		await process_frame
		await process_frame
		var node: Node=game.defence_system.shield_offer
		while node!=null and not node is ScrollContainer: node=node.get_parent()
		if node is ScrollContainer: node.scroll_vertical=100000
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://reports/modificadors_defensa_taller.png")
	print("COMBAT_MODIFIERS_OK purchased=4 energy_damage=true shielding_regeneration=true saved=true")
	game.queue_free()
	await process_frame
	await process_frame
	quit()
