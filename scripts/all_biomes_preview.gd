extends SceneTree
const Harness = preload("res://scripts/organism_preview.gd")
class Sheet extends Node2D:
	var captures: Array[Texture2D] = []
	var captions: Array[String] = []
	func _draw() -> void:
		draw_rect(Rect2(0, 0, 1760, 640), Color("050e12"))
		for i in range(captures.size()):
			var origin := Vector2((i % 4) * 440, int(i / 4) * 320)
			draw_texture_rect(captures[i], Rect2(origin + Vector2(4, 28), Vector2(432, 280)), false)
			draw_string(ThemeDB.fallback_font, origin + Vector2(12, 21), captions[i], HORIZONTAL_ALIGNMENT_LEFT, 418, 17, Color("a5e8e7"))
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	root.size = Vector2i(1440, 900)
	root.content_scale_size = root.size
	var game = Harness.PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game.call("_new_world", 134027)
	game.surface_mode = false
	await process_frame
	game.call("_layout_panels")
	var sheet := Sheet.new()
	var textures: Dictionary = {}
	var profiles := [1, 4, 7, 10, 13, 16, 19, 20]
	for depth in range(1, 21):
		game.call("_change_underground_level", depth, -1)
		for window in game.get_children():
			if window is Window: window.hide()
		game.call("_ensure_solid_room_rocks")
		var entry: int = game.world.entry
		game.explored_caves[entry] = true
		var profile: int = game._biome_at_depth(depth)
		var floor_texture: Texture2D = game.call("_get_cave_room_floor_texture", entry)
		assert(game.call("_floor_material_uv", Vector2(32, 32), floor_texture) == Vector2.ONE)
		if textures.has(profile): assert(textures[profile] == floor_texture)
		textures[profile] = floor_texture
		if profile in game.OTHER_BIOME_PROFILES:
			assert(floor_texture.get_size() == Vector2(512, 512))
		if depth in profiles and depth < 20:
			assert(game.call("_is_biome_workshop", entry))
			assert(game.call("_biome_module_texture", profile) != null)
			assert(game.call("_biome_base_footprint", game.world.caves[entry]).size() == 4)
		if depth == 20: assert(not game.call("_is_biome_workshop", entry))
		for corridor in game.world.corridors:
			if corridor.a == entry or corridor.b == entry:
				game.completed_gallery_traces[corridor.id] = true
				game.discovered_exits[game.call("_exit_key", entry, corridor.id)] = true
				break
		var unchanged := var_to_bytes([game.world, game.unit_position, game.revealed_mask, game.material_sites])
		game.zoom_level = 3.5
		game.call("_focus_cave", entry, 3.5)
		game.call("_update_view_mode_ui")
		game.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		assert(unchanged == var_to_bytes([game.world, game.unit_position, game.revealed_mask, game.material_sites]))
		if depth in profiles:
			var picture: Image = root.get_texture().get_image()
			assert(picture.save_png("res://reports/bioma_complet_%02d.png" % depth) == OK)
			sheet.captures.append(ImageTexture.create_from_image(picture.get_region(Rect2i(260, 190, 900, 560))))
			sheet.captions.append(game.DEPTH_ZONE_NAMES[profile])
			game.call("_fit_discovered_map")
			game.queue_redraw()
			await process_frame
			await RenderingServer.frame_post_draw
			assert(root.get_texture().get_image().save_png("res://reports/bioma_enquadra_%02d.png" % depth) == OK)
		print("BIOME_DEPTH_OK ", depth)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1760, 640)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	viewport.add_child(sheet)
	await process_frame
	await RenderingServer.frame_post_draw
	assert(viewport.get_texture().get_image().save_png("res://reports/biomes_pixel_art_resum.png") == OK)
	assert(textures.size() == 8)
	print("ALL_20_DEPTHS_PIXEL_ART_OK profiles=8 cached_materials=8 world=unchanged final_structure=preserved")
	quit()
