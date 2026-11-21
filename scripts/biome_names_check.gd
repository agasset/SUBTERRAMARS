extends SceneTree
const Harness = preload("res://scripts/organism_preview.gd")
func _initialize() -> void:
	call_deferred("_run")
func _check(game, reached: int) -> void:
	game._refresh_depth_selector()
	if reached==0: assert(game.discovered_biomes.is_empty())
	for biome: int in game.DEPTH_ZONE_NAMES:
		var identity: int = game._biome_at_depth(biome)
		var known: bool = game.discovered_biomes.has(identity)
		var expected: String = game.DEPTH_ZONE_NAMES[identity] if known else "Bioma per descobrir"
		assert(game.depth_zone_headings[biome].text == expected)
		assert(game._profile_biome_name(biome) == expected)
		if not known:
			assert(not game.depth_rows[biome].tooltip_text.contains(game.DEPTH_ZONE_NAMES[identity]))
			assert(not game._biome_base_name(biome).contains(game.DEPTH_ZONE_NAMES[identity]))
func _run() -> void:
	root.size = Vector2i(1440,900)
	var game = Harness.PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game.game_audio.set_enabled(false)
	game._clear_profile_progress()
	game._new_world(134027)
	_check(game,0)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://reports/biomes_noms_ocults.png")
	game.surface_mode = false
	game._change_underground_level(1,-1)
	_check(game,1)
	game._change_underground_level(4,-1)
	_check(game,4)
	var saved: Dictionary = game._capture_saved_game()
	assert(saved.deepest_reached == 4)
	game._new_world(91)
	_check(game,4)
	game._clear_profile_progress()
	game._new_world(91)
	_check(game,0)
	game._restore_saved_game(saved)
	_check(game,4)
	print("BIOME_NAMES_PROFILE_GATED_OK new_profile=hidden arrival=unlocked restart=preserved restore=preserved cross_profile=no_leak")
	quit()
