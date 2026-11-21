extends Node2D
# Draw after lighting/fog and before the HUD. No discovery or navigation changes.
func _process(_delta: float) -> void:
	queue_redraw()
func _draw() -> void:
	var game = get_parent()
	if game.surface_mode or not game.analysis_mode or game.world.is_empty(): return
	game._draw_signal_ranges(self)
	game._draw_beacon_waves(game._world_to_screen(game.world.caves[game.world.entry].position), game._beacon_range() * game.zoom_level, game.ISO_VERTICAL_RATIO, game.LEVEL_EXIT_BEACON_COLOR, self)
	for room in game.deployed_beacons:
		game._draw_beacon_waves(game._world_to_screen(game.world.caves[room].position), game._beacon_range() * game.zoom_level, game.ISO_VERTICAL_RATIO, Color("abbeff"), self)
