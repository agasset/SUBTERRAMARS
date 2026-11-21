extends SceneTree
const Harness = preload("res://scripts/ui_preview.gd")
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	root.size = Vector2i(1440, 900)
	root.content_scale_size = root.size
	var game = Harness.PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game.call("_new_world", 134027)
	game.surface_mode = true
	game.call("_update_view_mode_ui")
	await process_frame
	game.call("_layout_panels")
	var unchanged := var_to_bytes([game.world, game.unit_position, game.materials_in_pack])
	var count := 0
	for node in game.get_children():
		if node is Window:
			assert(node.theme != null and node.theme.default_font != null)
			assert(node.theme.get_stylebox("embedded_border", "Window") is StyleBoxTexture)
			count += 1
	for screen in ["inventari", "millores", "cataleg", "opcions", "confirmacio"]:
		var window: Window
		match screen:
			"inventari":
				game.call("_open_inventory", false)
				window = game.inventory_window
			"millores":
				game.call("_open_inventory", true)
				window = game.inventory_window
			"cataleg":
				game.call("_open_flora_catalog")
				window = game.flora_catalog
			"opcions":
				window = game.map_options_window
				window.popup_centered(Vector2i(550, 500))
			"confirmacio":
				window = game.restart_run_dialog
				window.popup_centered(Vector2i(520, 200))
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png("res://reports/finestra_%s.png" % screen) == OK)
		print(screen, " size=", window.size, " position=", window.position)
		window.hide()
		assert(unchanged == var_to_bytes([game.world, game.unit_position, game.materials_in_pack]))
	print("SHARED_WINDOW_THEME_OK windows=%d captures=5 world=unchanged" % count)
	quit()
