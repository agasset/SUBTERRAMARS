extends SceneTree
const Harness=preload("res://scripts/organism_preview.gd")
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var game=Harness.PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game._new_world(134027)
	game.surface_mode=false
	game.analysis_mode=false
	game.selected_cave=-1
	game.current_cave_id=-1
	game.suit_integrity=1.0
	game.repair_kit_uses_spent=0
	assert(game._can_use_repair_kit())
	game._apply_field_repair(game.FieldRepair.SUIT)
	assert(game.suit_integrity>1 and game.repair_kit_uses_spent==1)
	game.analysis_mode=true
	game.selected_cave=-1
	assert(not game._can_use_repair_kit())
	game.repair_kit_uses_spent=0
	assert(game._can_use_repair_kit())
	game.suit_tier=3
	game.equipped_boots=2
	game.supply_tiers["oxygen_tank"]=2
	game.owned_modifiers["boots_ice"]=true
	game.equipped_modifiers["botes"]="boots_ice"
	game.defence_state.weapon_tier=2
	game.materials_in_pack=7
	game.quartz_in_pack=2
	game.magnetite_in_pack=1
	var old_seed: int=game.seed_value
	var old_history: int=game.expedition_history.size()
	game._end_expedition("PROVA DE FRACÀS")
	assert(game.world.get("recovery_caches_v1",[]).is_empty())
	assert(game.materials_in_pack==0 and game.quartz_in_pack==0 and game.magnetite_in_pack==0)
	assert(game.death_dialog.dialog_text.contains("món nou"))
	game._restart_after_death()
	assert(game.seed_value!=old_seed and game.surface_mode)
	assert(game.expedition_history.size()==old_history+1)
	assert(game.suit_tier==3 and game.equipped_boots==2)
	assert(game.supply_tiers.oxygen_tank==2 and game.defence_state.weapon_tier==2)
	assert(game.equipped_modifiers.botes=="boots_ice")
	assert(game.world.get("recovery_caches_v1",[]).is_empty() and game.inactive_levels.is_empty())
	assert(game.suit_integrity==100 and game.health==100)
	print("DEATH_NEW_WORLD_OK seed_changed=true no_recovery=true upgrades_preserved=true repair_map_and_gallery=true")
	game.queue_free()
	await process_frame
	await process_frame
	quit()
