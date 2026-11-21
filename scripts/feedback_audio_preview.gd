extends SceneTree
const Harness = preload("res://scripts/organism_preview.gd")
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	root.size = Vector2i(1920,1080)
	root.content_scale_size = Vector2i(1440,900)
	var game = Harness.PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game.call("_new_world",134027)
	game.surface_mode = false
	game.analysis_mode = true
	game.current_level = 1
	game.call("_ensure_solid_room_rocks")
	var room: int = game.world.entry
	game.selected_cave = room
	game.current_cave_id = room
	game.unit_position = game.world.caves[room].position
	game.explored_caves[room] = true
	game.flashlight_on = true
	game.flashlight_charge = 100
	game.call("_focus_cave",room,5.0)
	game.call("_update_view_mode_ui")
	game.material_sites[room] = game.unit_position + Vector2(22,18)
	game.mineral_types[room] = "quars"
	game.equipped_modifiers.clear()
	game.call("_collect_material")
	assert(game.mining_cave == -1)
	assert(game.action_notice_label.text.contains("Nv. 1") and game.action_notice_label.text.contains("Capçal de precisió"))
	game.flora_sites[room] = game.unit_position + Vector2(15,0)
	game.flora_species_by_room[room] = "molsa_ferrica"
	var register_before := var_to_bytes(game.biological_register)
	game.call("_select_flora", game.call("_world_to_screen",game.flora_sites[room]) - Vector2(0,10))
	assert(game.action_notice_label.text.contains("Filtre espectral fèrric"))
	assert(game.bio_scan_room == -1 and register_before == var_to_bytes(game.biological_register))
	for kind in ["ui","denied","scan","tool","complete","alarm","photo","service","light"]:
		var clip: AudioStreamWAV = game.game_audio.call("_clip",kind)
		assert(clip.mix_rate == 22050 and clip.data.size() > 1000)
	game.game_audio.call("set_enabled",false)
	for voice in game.game_audio.voices: assert(not voice.playing)
	var before := var_to_bytes([game.world,game.unit_position,game.revealed_mask])
	await process_frame
	game.call("_layout_panels")
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png("res://reports/avis_requisits_escala_1920.png") == OK)
	assert(before == var_to_bytes([game.world,game.unit_position,game.revealed_mask]))
	game.equipped_modifiers["escaner"] = "scanner_ferric"
	assert(game.call("_can_detect_species", "molsa_ferrica"))
	game.selected_flora = room
	game.selected_fauna = -1
	game.call("_interact_with_flora")
	assert(game.bio_scan_room == room)
	game.call("_cancel_bio_scan")
	game.analysis_mode=false
	game.call("_update_view_mode_ui")
	game.call("_refresh_room_progress")
	assert(game.room_details_panel.visible)
	assert(game.room_details_status.text.begins_with("SALA %02d" % (room+1)))
	game.action_notice_label.hide()
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://reports/registre_sala_mapa.png")
	print("FEEDBACK_GHOST_AUDIO_AND_SCALED_LIGHTING_OK waveform_types=9 unidentified=preserved world=unchanged")
	quit()
