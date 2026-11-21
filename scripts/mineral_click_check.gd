extends SceneTree
class Probe extends "res://scripts/main.gd":
	var clicks := 0
	func _ready() -> void:
		_build_ui()
		_layout_panels()
	func _save_active_profile() -> bool:
		return true
	func _collect_material() -> void:
		clicks += 1
class ActualGame extends "res://scripts/main.gd":
	func _ready() -> void:
		_build_ui()
		_layout_panels()
	func _save_active_profile() -> bool:
		return true
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var game := Probe.new()
	root.add_child(game)
	game.set_process(false)
	game.call("_new_world", 134027)
	game.surface_mode = false
	game.analysis_mode = true
	var room: int = game.world.entry
	game.selected_cave = room
	game.current_cave_id = room
	game.explored_caves[room] = true
	game.material_sites[room] = game.world.caves[room].position
	game.call("_focus_cave", room, 3.5)
	var samples := 0
	for mineral in ["ferro", "quars", "magnetita"]:
		game.mineral_types[room] = mineral
		for zoom in [0.8, 3.5, 8.0]:
			game.zoom_level = zoom
			var area: Rect2 = game.call("_mineral_sprite_rect", room)
			for fraction in [Vector2(0.5, 0.5), Vector2(0.5, 0.6), Vector2(0.5, 0.65)]:
				var point: Vector2 = area.position + area.size * fraction
				assert(game.call("_mineral_hit_test", room, point))
				samples += 1
			assert(not game.call("_mineral_hit_test", room, area.position))
	# Put the actual ore over the elevator to exercise input priority.
	game.zoom_level = 3.5
	game.material_sites[room] = game.call("_level_access_position", room)
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	var rect: Rect2 = game.call("_mineral_sprite_rect", room)
	click.position = rect.position + rect.size * Vector2(0.5, 0.7)
	assert(not game.call("_over_ui", click.position))
	game.call("_input", click)
	assert(game.clicks == 1)
	# A selected neighbouring room must not disable the actual room's ore.
	game.unit_position = game.world.caves[room].position
	var neighbor: int = (room + 1) % game.world.caves.size()
	game.explored_caves[neighbor] = true
	var prior_anchor: Vector2 = game.call("_world_to_screen", game.material_sites[room])
	game.selected_cave = neighbor
	game.camera_offset += prior_anchor - Vector2(game.call("_world_to_screen", game.material_sites[room]))
	game.call("_input", click)
	assert(game.clicks == 2 and game.selected_cave == room)
	# A visible ore in another room acknowledges the click without extracting,
	# moving the explorer or revealing additional data.
	game.material_sites[neighbor] = game.material_sites[room]
	game.mineral_types[neighbor] = "quars"
	game.material_sites[room] += Vector2(80, 80)
	var before_position: Vector2 = game.unit_position
	game.call("_input", click)
	assert(game.clicks == 2)
	assert(game.status_label.text.begins_with("ENTRA A LA SALA"))
	assert(game.unit_position == before_position and game.selected_cave == room)
	# Unknown neighbouring ore is never picked, even at the same screen point.
	game.explored_caves.erase(neighbor)
	game.visited_caves.erase(neighbor)
	game.material_sites.erase(neighbor)
	assert(not game.call("_try_click_mineral", click.position))
	var actual := ActualGame.new()
	root.add_child(actual)
	actual.set_process(false)
	actual.call("_new_world", 134027)
	actual.surface_mode = false
	actual.analysis_mode = true
	actual.current_cave_id = room
	actual.selected_cave = room
	actual.unit_position = actual.world.caves[room].position
	actual.explored_caves[room] = true
	actual.material_sites[room] = actual.unit_position
	actual.mineral_types[room] = "ferro"
	actual.call("_collect_material")
	assert(actual.mining_cave == room)
	actual.call("_collect_material")
	assert(actual.action_notice_label.text == "EXTRACCIÓ EN CURS")
	actual.mining_cave = -1
	actual.bio_scan_room = room
	actual.call("_collect_material")
	assert(actual.action_notice_label.text.begins_with("ACABA L’ACCIÓ"))
	actual.bio_scan_room = -1
	actual.mineral_types[room] = "quars"
	actual.call("_collect_material")
	assert(actual.mining_cave == -1 and actual.action_notice_label.text.to_upper().contains("CAPÇAL"))
	print("MINERAL_SILHOUETTE_AND_INPUT_OK samples=%d" % samples)
	quit()


