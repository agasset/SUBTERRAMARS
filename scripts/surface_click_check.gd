extends SceneTree
const Harness = preload("res://scripts/surface_preview.gd")
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	root.size = Vector2i(1440,900)
	root.content_scale_size = root.size
	var game = Harness.PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game.call("_new_world",134027)
	game.surface_mode = true
	game.current_level = 0
	game.game_audio.call("set_enabled",false)
	game.call("_update_view_mode_ui")
	await process_frame
	var unchanged := var_to_bytes([game.world,game.unit_position,game.revealed_mask])
	var clicks := 0
	for size in [Vector2i(1440,900),Vector2i(1920,1080),Vector2i(1024,768)]:
		root.size = size
		root.content_scale_size = size
		game.call("_layout_panels")
		await process_frame
		var scale: float = game.call("_surface_art_scale")
		var hatch: Vector2 = game.call("_surface_hatch_center")
		for module in game.SurfaceBaseArt.MODULE_ENTRIES:
			var feet: Vector2 = game.surface_base_art.call("_point",module.point,hatch,scale)
			var extent := Vector2(module.width,module.width * module.source.size.y / module.source.size.x) * scale
			var target := Vector2.ZERO
			var found := false
			for y in range(3,9):
				for x in range(2,9):
					var sample: Vector2 = (feet - extent * Vector2(0.5,0.96)).round() + extent * Vector2(x/10.0,y/10.0)
					if not game.call("_over_ui",sample) and game.surface_base_art.module_action_at(sample,hatch,scale) == module.action:
						target = sample
						found = true
						break
				if found: break
			assert(found)
			var click := InputEventMouseButton.new()
			click.pressed = true
			click.button_index = MOUSE_BUTTON_LEFT
			click.position = target
			game.call("_input",click)
			if module.action == "catalog":
				assert(game.flora_catalog.visible)
				game.flora_catalog.hide()
			else:
				assert(game.inventory_window.visible)
				assert(game.inventory_tabs.current_tab == (0 if module.action == "inventory" else 1))
				game.inventory_window.hide()
			clicks += 1
		assert(unchanged == var_to_bytes([game.world,game.unit_position,game.revealed_mask]))
		assert(game.surface_base_art.module_action_at(Vector2(5,5),hatch,scale).is_empty())
	print("SURFACE_MODULE_CLICKS_OK clicks=%d resolutions=3 world=unchanged" % clicks)
	quit()
