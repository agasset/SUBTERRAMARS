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
	call_deferred("_capture")

func _capture() -> void:
	var game = PreviewGame.new()
	# Skip startup/loading and disable simulation: preview cannot write player saves.
	game.set_block_signals(true)
	game.set_process(false)
	game.request_ready()
	root.add_child(game)
	game.set_process(false)
	game.call("_new_world", 134027)
	game.surface_mode = false
	game.current_level = 1
	var entry: int = game.world.entry
	game.explored_caves = {entry: true}
	game.selected_cave = entry
	game.current_cave_id = entry
	game.unit_position = game.world.caves[entry].position
	game.call("_ensure_solid_room_rocks")
	var layout_before: Array = game.world.solid_room_rocks_v1.duplicate(true)
	var mask_before: PackedByteArray = game.world.walkable_mask.duplicate()
	game.world.erase("rock_spacing_version")
	game.call("_ensure_solid_room_rocks")
	assert(layout_before == game.world.solid_room_rocks_v1)
	assert(mask_before == game.world.walkable_mask)
	print("ROCK_SPACING_MIGRATION_STABLE")
	var blocked_count := 0
	for rock in game.world.get("solid_room_rocks_v1", []):
		var cell := Vector2i((rock.position / game.world.cell_size).floor())
		assert(game.world.walkable_mask[cell.y * game.world.grid_size.x + cell.x] == 0)
		assert(not game.call("_segment_is_walkable", rock.position, rock.position, true))
		blocked_count += 1
	assert(blocked_count > 0)
	var saved_rocks: Dictionary = bytes_to_var(var_to_bytes(game.world))
	assert(saved_rocks.solid_room_rocks_v1 == game.world.solid_room_rocks_v1)
	assert(saved_rocks.walkable_mask == game.world.walkable_mask)
	game.dev_mode = true
	var detours := 0
	for rock in game.world.solid_room_rocks_v1:
		var offset: float = game.world.cell_size * (2 if rock.get("blocked_cells", []).size() == 3 else 1)
		var left: Vector2 = rock.position - Vector2(offset, 0)
		var right: Vector2 = rock.position + Vector2(offset, 0)
		var route: Array = game.call("_find_path", left, right)
		assert(not route.is_empty())
		var previous := left
		for next: Vector2 in route:
			assert(game.call("_segment_is_walkable", previous, next, true))
			previous = next
		detours += 1
	game.dev_mode = false
	print("ROCK_DETOURS_AND_PERSISTENCE_OK count=%d" % detours)
	print("SOLID_ROCKS_BLOCK_MOVEMENT count=%d" % blocked_count)
	game.analysis_mode = true
	game.call("_update_view_mode_ui")
	game.call("_focus_cave", entry, 3.5)
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://reports/terra_pixelart_preview.png")
	print("FLOOR_PREVIEW_CAPTURED")
	var saved_minerals: Dictionary = game.mineral_types.duplicate()
	var ore_image: Image = game.MINERAL_ROCK_SPRITES.get_image()
	var ore_width: int = ore_image.get_width() / 4
	var hit_samples := 0
	for test_zoom in [0.8, 3.5, 8.0]:
		game.zoom_level = test_zoom
		for ore_index in range(3):
			game.mineral_types[entry] = ["ferro", "quars", "magnetita"][ore_index]
			var area: Rect2 = game.call("_mineral_sprite_rect", entry)
			assert(not game.call("_mineral_hit_test", entry, area.position - Vector2.ONE))
			for y in range(0, ore_image.get_height(), 16):
				for x in range(0, ore_width, 16):
					if ore_image.get_pixel(ore_index * ore_width + x, y).a < 0.2:
						continue
					var point := area.position + Vector2((x + 0.5) / ore_width,
						(y + 0.5) / ore_image.get_height()) * area.size
					assert(game.call("_mineral_hit_test", entry, point))
					hit_samples += 1
	game.zoom_level = 3.5
	print("MINERAL_FULL_SPRITE_HITS_OK samples=%d minerals=3 zooms=3" % hit_samples)
	for mineral in ["ferro", "quars", "magnetita"]:
		game.mineral_types[entry] = mineral
		game.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://reports/veta_%s.png" % mineral)
	game.mineral_types = saved_minerals
	# Render in a non-entry room, as normal deployment rules require.
	var beacon_room: int = (entry + 1) % game.world.caves.size()
	game.deployed_beacons[beacon_room] = true
	game.explored_caves[beacon_room] = true
	game.selected_cave = beacon_room
	game.dev_mode = true
	game.call("_focus_cave", beacon_room, 5.0)
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://reports/balisa_desplegada_preview.png")
	game.deployed_beacons.erase(beacon_room)
	game.explored_caves.erase(beacon_room)
	game.selected_cave = entry
	game.dev_mode = false
	game.call("_focus_cave", entry, 3.5)
	for corridor in game.world.corridors:
		if corridor.a != entry and corridor.b != entry:
			continue
		game.completed_gallery_traces[corridor.id] = true
		game.explored_caves[corridor.b if corridor.a == entry else corridor.a] = true
		game.call("_fit_discovered_map")
		game.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://reports/parets_sala_galeria.png")
		print("ROOM_AND_GALLERY_WALLS_CAPTURED")
		break
	for depth in [4, 7, 10, 13, 16, 19, 20]:
		game.current_level = depth
		game.cave_floor_textures.clear()
		game.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://reports/roques_parets_bioma_%d.png" % depth)
		print("BIOME_RENDERED %d" % depth)
	quit()
