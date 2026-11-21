extends SceneTree

class PreviewGame extends "res://scripts/main.gd":
	func _ready() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		_build_ui()
		_layout_panels()
	func _save_active_profile() -> bool:
		return true

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game := PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game.call("_new_world", 134027)
	game.surface_mode = true
	game.current_level = 0
	game.call("_update_view_mode_ui")
	var unchanged := var_to_bytes([game.world, game.unit_position, game.revealed_mask, game.inactive_levels])
	for size in [Vector2i(1440, 900), Vector2i(1920, 1080), Vector2i(1024, 768)]:
		root.size = size
		root.content_scale_size = size
		game.call("_layout_panels")
		game.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png("res://reports/panells_pixel_art_%dx%d.png" % [size.x, size.y]) == OK)
		root.get_texture().get_image().get_region(Rect2i(0, int(game.equipment_bar.position.y), size.x, size.y - int(game.equipment_bar.position.y))).save_png("res://reports/equip_pixel_art_%dx%d.png" % [size.x, size.y])
		var resources := game.equipment_bar.get_child(0).get_child(0) as Control
		var resources_rect := Rect2i(resources.get_global_rect())
		assert(root.get_texture().get_image().get_region(resources_rect).save_png("res://reports/recursos_hud_%dx%d.png" % [size.x, size.y]) == OK)
		var center: Vector2 = game.call("_surface_hatch_center")
		var extent: Vector2 = game.call("_surface_elevator_extent")
		var outline: PackedVector2Array = game.call("_elevator_outline", center, extent)
		assert(Geometry2D.is_point_in_polygon(center, outline))
		assert(not Geometry2D.is_point_in_polygon(center + Vector2(extent.x * 1.2, 0), outline))
		assert(unchanged == var_to_bytes([game.world, game.unit_position, game.revealed_mask, game.inactive_levels]))
		print("SURFACE_RENDER_STATE_AND_ELEVATOR_HIT_OK %dx%d" % [size.x, size.y])
	var geometry := var_to_bytes([game.world.seed, game.world.caves, game.world.corridors])
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = game.call("_surface_hatch_center")
	game.call("_input", click)
	assert(not game.surface_mode and game.current_level == 1)
	assert(geometry == var_to_bytes([game.world.seed, game.world.caves, game.world.corridors]))
	game.call("_enter_surface_base")
	assert(game.surface_mode)
	assert(geometry == var_to_bytes([game.world.seed, game.world.caves, game.world.corridors]))
	print("SURFACE_ELEVATOR_CLICK_AND_RETURN_SAME_WORLD_OK")
	quit()

