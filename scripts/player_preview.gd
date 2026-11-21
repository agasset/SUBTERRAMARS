extends SceneTree

class SpriteSheet extends "res://scripts/main.gd":
	func _ready() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		set_process(false)
	func _draw() -> void:
		draw_rect(Rect2(0, 0, 1200, 620), Color("091117"))
		draw_string(ThemeDB.fallback_font, Vector2(30, 40), "EXPLORADOR · QUATRE ORIENTACIONS", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, CYAN)
		draw_string(ThemeDB.fallback_font, Vector2(740, 40), "ASCENSOR PIXEL ART", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, CYAN)
		var directions := [Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1), Vector2(1, -1)]
		for column in range(4):
			_draw_explorer_sprite(Vector2(100 + column * 155, 230), 2.2, directions[column], false)
			fauna_time = 0.16
			_draw_explorer_sprite(Vector2(100 + column * 155, 460), 2.2, directions[column], true)
		draw_string(ThemeDB.fallback_font, Vector2(30, 270), "Repòs", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("cadde2"))
		draw_string(ThemeDB.fallback_font, Vector2(30, 500), "Pas de moviment", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("cadde2"))
		_draw_elevator_platform(Vector2(900, 370), Vector2(135, 72))
		_draw_explorer_sprite(Vector2(900, 370), 2.2, Vector2(1, 1), false)

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	root.size = Vector2i(1200, 620)
	root.content_scale_size = Vector2i(1200, 620)
	var sheet := SpriteSheet.new()
	root.add_child(sheet)
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png("res://reports/player_ascensor_pixel_art.png") == OK)
	print("PLAYER_FOUR_DIRECTIONS_AND_ELEVATOR_RENDERED")
	quit()
