extends SceneTree
const Harness=preload("res://scripts/organism_preview.gd")
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	root.size=Vector2i(1440,900)
	var game=Harness.PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game._new_world(134027)
	game._change_underground_level(1,-1)
	game.surface_mode=false
	game.analysis_mode=true
	game._ensure_solid_room_rocks()
	var enemy: Dictionary=game.world.predators_v1.values()[0]
	var room: int=enemy.cave_id
	game.selected_cave=room
	game.current_cave_id=room
	game.selected_fauna=room
	game.selected_flora=-1
	game.explored_caves[room]=true
	game.unit_position=enemy.position+Vector2(32,0)
	game._focus_cave(room,4.5)
	game._update_view_mode_ui()
	game.defence_system.tick(game,0.0)
	assert(game.action_notice_label.text.contains("FAUNA HOSTIL"))
	var discovery := var_to_bytes([game.revealed_mask,game.analyzed_fauna,game.seen_fauna])
	var hint: Dictionary=game.defence_system.radar_hint(game)
	assert(not hint.is_empty() and hint.band==1)
	assert(discovery==var_to_bytes([game.revealed_mask,game.analyzed_fauna,game.seen_fauna]))
	assert(not game._can_collect_flora_sample())
	game.action_notice_label.hide()
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://reports/radar_hostil.png")
	game.unit_position=enemy.position+Vector2(24,0)
	enemy.windup=0.01
	enemy.stun=0.0
	game.defence_state.shield=40.0
	game.defence_system.tick(game,0.02)
	assert(game.defence_system.attack_left>0 and game.defence_system.hit_left>0)
	assert(game.defence_system.hit_shield>0 and game.defence_system.hit_health==0)
	game.defence_system.attack_left=0.18
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://reports/atac_impacte_escut.png")
	game.defence_state.shield=0.0
	game.defence_system.damage(game,6.0)
	assert(game.defence_system.hit_health==6 and game.defence_system.hit_shield==0)
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://reports/atac_impacte_vida.png")
	enemy.hp=0.0
	assert(game.defence_system.radar_hint(game).is_empty())
	assert(game._can_collect_flora_sample())
	var points: int=game._research_points()
	game.selected_fauna=-1
	game._select_flora(game.defence_system.sprite_rect(game,enemy.position).get_center())
	assert(game.fauna_samples.has(room) and not game.fauna_samples[room])
	assert(game._research_points()==points+1)
	game._collect_flora_sample()
	assert(game.fauna_samples.size()==1 and game._research_points()==points+1)
	var saved: Dictionary=game._capture_saved_game()
	assert(saved.level.fauna_samples.has(room))
	print("PREDATOR_SAMPLE_RADAR_OK warning=true radar_no_discovery=true corpse_sample_once=true saved=true")
	game.queue_free()
	await process_frame
	await process_frame
	quit()
