extends SceneTree

const Generator = preload("res://scripts/world_generator.gd")
var navigation_probe: Node2D

func _initialize() -> void:
	var main_scene := load("res://scenes/main.tscn") as PackedScene
	navigation_probe = main_scene.instantiate() as Node2D
	root.add_child(navigation_probe)
	var rows: Array[Dictionary] = []
	var failures: Array[String] = []
	var sample_seeds: Array[int] = []
	for seed_value in range(50):
		sample_seeds.append(seed_value)
	sample_seeds.append(134027)
	for seed_value in sample_seeds:
		var first := Generator.generate(seed_value)
		var second := Generator.generate(seed_value)
		var canonical_first := _canonical(first)
		var canonical_second := _canonical(second)
		var same := canonical_first == canonical_second
		var count_ok: bool = first.caves.size() == 20
		var corridor_geometry_ok := _corridor_geometry_varied(first)
		var connected := _connected(first)
		var cave_spawns_ok := _all_cave_centers_walkable(first)
		var path_ok := _navigation_path_valid(first)
		var obstacle_ok := _obstacles_blocked(first)
		var visibility_ok := _visibility_blocked_by_obstacles(first)
		var scanner_scope_ok := _scanner_stays_in_current_cave(first)
		var exit_proximity_ok := _exit_discovery_by_proximity_valid(first)
		var exit_traversal_ok := _exit_traversal_valid(first)
		var player_map_ok := _player_map_scopes_to_explored(first)
		var scanner_selection_ok := _scanner_requires_selection_without_camera_change(first)
		var reveal_ok := _revelation_and_camera_valid(first)
		var isometric_mapping_ok := _isometric_projection_round_trip(first)
		var exit_returns_to_map_ok := _analysis_returns_to_map_on_exit(first)
		var spawn_ok: bool = first.entry >= 0 and first.entry < first.caves.size()
		var row := {"seed": seed_value, "caves": first.caves.size(), "corridors": first.corridors.size(), "obstacles": first.obstacles.size(), "corridor_geometry_varied": corridor_geometry_ok, "walkable_connected": connected, "cave_spawns_walkable": cave_spawns_ok, "pathfinding_valid": path_ok, "obstacles_blocked": obstacle_ok, "line_of_sight_blocked": visibility_ok, "scanner_current_cave_only": scanner_scope_ok, "exit_proximity_discovery_valid": exit_proximity_ok, "exit_traversal_valid": exit_traversal_ok, "player_map_hides_unexplored": player_map_ok, "scanner_selection_camera_valid": scanner_selection_ok, "reveal_and_camera_valid": reveal_ok, "isometric_mapping_round_trip": isometric_mapping_ok, "exiting_room_returns_to_map": exit_returns_to_map_ok, "spawn_valid": spawn_ok, "deterministic": same, "canonical_hash": hash(canonical_first), "fallback": first.fallback}
		rows.append(row)
		if not (same and count_ok and corridor_geometry_ok and connected and cave_spawns_ok and path_ok and obstacle_ok and visibility_ok and scanner_scope_ok and exit_proximity_ok and exit_traversal_ok and player_map_ok and scanner_selection_ok and reveal_ok and isometric_mapping_ok and exit_returns_to_map_ok and spawn_ok):
			failures.append("seed %d: %s" % [seed_value, JSON.stringify(row)])
	var report := {"generator_version": Generator.GENERATOR_VERSION, "sample_size": rows.size(), "passed": failures.is_empty(), "results": rows, "failures": failures}
	DirAccess.make_dir_recursive_absolute("res://reports")
	var file := FileAccess.open("res://reports/seed_validation_50.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(report, "\t"))
		file.close()
	print("SEED_VALIDATION_%d passed=%s failures=%d" % [rows.size(), str(failures.is_empty()), failures.size()])
	for failure in failures:
		push_error(failure)
	quit(0 if failures.is_empty() else 1)

func _analysis_returns_to_map_on_exit(world: Dictionary) -> bool:
	navigation_probe.set("world", world)
	var cave_id: int = world.entry
	var cave: Dictionary = world.caves[cave_id]
	var selected_corridor: Dictionary = {}
	for corridor in world.corridors:
		if corridor.a == cave_id or corridor.b == cave_id:
			selected_corridor = corridor
			break
	if selected_corridor.is_empty():
		return false
	var exit_position: Vector2 = selected_corridor.exit_a if selected_corridor.a == cave_id else selected_corridor.exit_b
	var exit_direction: Vector2 = selected_corridor.direction_a if selected_corridor.a == cave_id else selected_corridor.direction_b
	var start_position := exit_position - exit_direction * 5.0
	var target_position := exit_position + exit_direction * 12.0
	var path: Array[Vector2] = [target_position]
	navigation_probe.set("selected_cave", cave_id)
	navigation_probe.set("current_cave_id", cave_id)
	navigation_probe.set("analysis_mode", true)
	navigation_probe.set("zoom_level", 5.0)
	navigation_probe.set("unit_position", start_position)
	navigation_probe.set("move_path", path)
	navigation_probe.set("selected_route", path.duplicate())
	navigation_probe.set("move_target", target_position)
	navigation_probe.set("moving", true)
	navigation_probe.call("_process", 1.0)
	var returned_to_map: bool = not navigation_probe.get("analysis_mode") and int(navigation_probe.get("selected_cave")) == -1
	navigation_probe.set("moving", false)
	navigation_probe.set("move_path", [])
	return returned_to_map

func _canonical(world: Dictionary) -> String:
	var result: Array = []
	for cave in world.caves:
		var points: Array = []
		for point in cave.contour:
			points.append([point.x, point.y])
		result.append([cave.id, cave.position.x, cave.position.y, cave.radius, points])
	var links: Array = []
	for corridor in world.corridors:
		var points: Array = []
		for point in corridor.points:
			points.append([point.x, point.y])
		links.append([corridor.id, corridor.a, corridor.b, points, corridor.exit_a, corridor.exit_b, corridor.direction_a, corridor.direction_b])
	return JSON.stringify([world.seed, world.version, world.entry, result, links, world.obstacles, world.terrain_mask, world.walkable_mask])

func _isometric_projection_round_trip(world: Dictionary) -> bool:
	navigation_probe.set("world", world)
	navigation_probe.set("analysis_mode", true)
	navigation_probe.set("selected_cave", world.entry)
	navigation_probe.set("zoom_level", 4.7)
	navigation_probe.set("camera_offset", Vector2(37.0, -21.0))
	var cave: Dictionary = world.caves[world.entry]
	var points: Array[Vector2] = [cave.position, cave.position + cave.contour[0], cave.position + cave.contour[4], cave.position + Vector2(23.5, -41.25)]
	for point in points:
		var screen: Vector2 = navigation_probe.call("_world_to_screen", point)
		var restored: Vector2 = navigation_probe.call("_screen_to_world", screen)
		if restored.distance_to(point) > 0.001:
			navigation_probe.set("analysis_mode", false)
			return false
	navigation_probe.set("analysis_mode", false)
	return true

func _corridor_geometry_varied(world: Dictionary) -> bool:
	if world.corridors.size() < 2:
		return false
	var min_width := INF
	var max_width := -INF
	var curved_count := 0
	for corridor in world.corridors:
		var width: float = corridor.width
		if width < 24.0 or width > 48.0 or corridor.points.size() < 5:
			return false
		min_width = minf(min_width, width)
		max_width = maxf(max_width, width)
		var points: PackedVector2Array = corridor.points
		var start: Vector2 = points[0]
		var finish: Vector2 = points[points.size() - 1]
		var max_deviation := 0.0
		for index in range(1, points.size() - 1):
			var deviation: float = Geometry2D.get_closest_point_to_segment(points[index], start, finish).distance_to(points[index])
			max_deviation = maxf(max_deviation, deviation)
		if max_deviation >= 18.0:
			curved_count += 1
	return max_width - min_width >= 5.0 and curved_count >= ceili(float(world.corridors.size()) * 0.6)

func _connected(world: Dictionary) -> bool:
	var size: Vector2i = world.grid_size
	var mask: PackedByteArray = world.walkable_mask
	if world.caves.is_empty() or mask.is_empty():
		return false
	var start_pos: Vector2 = world.caves[world.entry].position
	var start_cell := Vector2i(floori(start_pos.x / world.cell_size), floori(start_pos.y / world.cell_size))
	var start_index := start_cell.y * size.x + start_cell.x
	if mask[start_index] == 0:
		return false
	var seen := PackedByteArray()
	seen.resize(mask.size())
	seen.fill(0)
	seen[start_index] = 1
	var queue: Array[int] = [start_index]
	var head := 0
	var reached := 0
	var directions: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]
	while head < queue.size():
		var current: int = queue[head]
		head += 1
		reached += 1
		var cell := Vector2i(current % size.x, current / size.x)
		for direction in directions:
			var next := cell + direction
			if next.x < 0 or next.x >= size.x or next.y < 0 or next.y >= size.y:
				continue
			var next_index := next.y * size.x + next.x
			if mask[next_index] == 1 and seen[next_index] == 0:
				seen[next_index] = 1
				queue.append(next_index)
	var walkable_count := 0
	for value in mask:
		if value == 1:
			walkable_count += 1
	return reached == walkable_count

func _all_cave_centers_walkable(world: Dictionary) -> bool:
	var size: Vector2i = world.grid_size
	var mask: PackedByteArray = world.walkable_mask
	for cave in world.caves:
		var position: Vector2 = cave.position
		var cell := Vector2i(floori(position.x / world.cell_size), floori(position.y / world.cell_size))
		if mask[cell.y * size.x + cell.x] == 0:
			return false
	return true

func _navigation_path_valid(world: Dictionary) -> bool:
	navigation_probe.set("world", world)
	navigation_probe.set("dev_mode", true)
	var entry_position: Vector2 = world.caves[world.entry].position
	var target_position: Vector2 = entry_position
	var farthest_distance := -1.0
	for cave in world.caves:
		var distance: float = entry_position.distance_squared_to(cave.position)
		if distance > farthest_distance:
			farthest_distance = distance
			target_position = cave.position
	var path: Array = navigation_probe.call("_find_path", entry_position, target_position)
	if path.is_empty():
		return false
	var grid_size: Vector2i = world.grid_size
	var mask: PackedByteArray = world.walkable_mask
	var previous_cell := Vector2i(floori(entry_position.x / world.cell_size), floori(entry_position.y / world.cell_size))
	for point in path:
		var cell := Vector2i(floori(point.x / world.cell_size), floori(point.y / world.cell_size))
		if cell.x < 0 or cell.x >= grid_size.x or cell.y < 0 or cell.y >= grid_size.y:
			return false
		if mask[cell.y * grid_size.x + cell.x] == 0:
			return false
		if absi(cell.x - previous_cell.x) + absi(cell.y - previous_cell.y) != 1:
			return false
		previous_cell = cell
	return true

func _obstacles_blocked(world: Dictionary) -> bool:
	var size: Vector2i = world.grid_size
	var walkable: PackedByteArray = world.walkable_mask
	for obstacle in world.obstacles:
		var cell := Vector2i(floori(obstacle.position.x / world.cell_size), floori(obstacle.position.y / world.cell_size))
		if walkable[cell.y * size.x + cell.x] != 0:
			return false
	return true

func _visibility_blocked_by_obstacles(world: Dictionary) -> bool:
	navigation_probe.set("world", world)
	var size: Vector2i = world.grid_size
	var walkable: PackedByteArray = world.walkable_mask
	var directions: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]
	for obstacle in world.obstacles:
		var center := Vector2i(floori(obstacle.position.x / world.cell_size), floori(obstacle.position.y / world.cell_size))
		for direction in directions:
			var start := center - direction * 3
			var finish := center + direction * 3
			if start.x < 0 or start.x >= size.x or start.y < 0 or start.y >= size.y:
				continue
			if finish.x < 0 or finish.x >= size.x or finish.y < 0 or finish.y >= size.y:
				continue
			if walkable[start.y * size.x + start.x] == 0 or walkable[finish.y * size.x + finish.x] == 0:
				continue
			if not navigation_probe.call("_has_line_of_sight", start, finish):
				return true
	return false

func _scanner_stays_in_current_cave(world: Dictionary) -> bool:
	navigation_probe.set("world", world)
	navigation_probe.set("dev_mode", false)
	navigation_probe.set("dev_mode", false)
	var cave_id: int = world.entry
	var cave: Dictionary = world.caves[cave_id]
	navigation_probe.set("current_cave_id", cave_id)
	navigation_probe.set("unit_position", cave.position)
	navigation_probe.set("explored_caves", {cave_id: true})
	var revealed := PackedByteArray()
	revealed.resize(world.terrain_mask.size())
	revealed.fill(0)
	navigation_probe.set("revealed_mask", revealed)
	navigation_probe.set("discovered_exits", {})
	navigation_probe.call("_scan_current_cave")
	var expected_exits := 0
	for corridor in world.corridors:
		if corridor.a == cave_id or corridor.b == cave_id:
			expected_exits += 1
	if navigation_probe.call("_exit_count", cave_id) != expected_exits:
		return false
	var exits: Dictionary = navigation_probe.get("discovered_exits")
	for key in exits:
		if not key.begins_with("%d:" % cave_id):
			return false
	for other_cave in world.caves:
		if other_cave.id != cave_id and navigation_probe.call("_is_revealed", other_cave.position):
			return false
	for corridor in world.corridors:
		if corridor.a != cave_id and corridor.b != cave_id:
			continue
		var destination_id: int = corridor.b if corridor.a == cave_id else corridor.a
		var destination: Dictionary = world.caves[destination_id]
		var arrival: Vector2 = navigation_probe.call("_arrival_point", destination_id, corridor.id)
		if not navigation_probe.call("_is_revealed", arrival) or navigation_probe.call("_is_revealed", destination.position):
			return false
		var revealed_cells_in_preview := 0
		var revealed_mask: PackedByteArray = navigation_probe.get("revealed_mask")
		var terrain_mask: PackedByteArray = world.terrain_mask
		var grid_size: Vector2i = world.grid_size
		for y in range(grid_size.y):
			for x in range(grid_size.x):
				var index := y * grid_size.x + x
				if terrain_mask[index] == 1 and revealed_mask[index] == 1:
					var point := Vector2((float(x) + 0.5) * world.cell_size, (float(y) + 0.5) * world.cell_size)
					if Geometry2D.is_point_in_polygon(point - destination.position, destination.contour):
						revealed_cells_in_preview += 1
		if revealed_cells_in_preview == 0:
			return false
		if navigation_probe.call("_should_draw_cave", destination_id):
			return false
		var room_order: Dictionary = navigation_probe.call("_resolve_order_target", destination.position)
		if room_order.is_empty() or int(room_order.cave_id) != -1:
			return false
		var order_target: Vector2 = room_order.position
		if not navigation_probe.call("_is_revealed", order_target) or not Geometry2D.is_point_in_polygon(order_target - destination.position, destination.contour):
			return false
		var order_path: Array = navigation_probe.call("_find_path", cave.position, order_target)
		if order_path.is_empty() or not _path_uses_walkable_revealed(order_path, world, navigation_probe.get("revealed_mask")):
			return false
	return not exits.is_empty()

func _exit_traversal_valid(world: Dictionary) -> bool:
	navigation_probe.set("world", world)
	navigation_probe.set("dev_mode", false)
	var source_id: int = world.entry
	var source: Dictionary = world.caves[source_id]
	navigation_probe.set("current_cave_id", source_id)
	navigation_probe.set("unit_position", source.position)
	var revealed := PackedByteArray()
	revealed.resize(world.terrain_mask.size())
	revealed.fill(0)
	navigation_probe.set("revealed_mask", revealed)
	navigation_probe.set("discovered_exits", {})
	navigation_probe.call("_scan_current_cave")
	var corridors: Array = world.corridors
	for corridor in corridors:
		if corridor.a != source_id and corridor.b != source_id:
			continue
		var exit_position: Vector2 = corridor.exit_a if corridor.a == source_id else corridor.exit_b
		var exit_direction: Vector2 = corridor.direction_a if corridor.a == source_id else corridor.direction_b
		var destination_id: int = corridor.b if corridor.a == source_id else corridor.a
		var clicked_mouth: Vector2 = exit_position + exit_direction * 12.0
		if navigation_probe.call("_known_exit_cave", clicked_mouth) != destination_id:
			return false
		var arrival: Vector2 = navigation_probe.call("_arrival_point", destination_id, corridor.id)
		var first_leg: Array = navigation_probe.call("_find_path", source.position, arrival)
		if first_leg.is_empty() or not _path_uses_walkable_revealed(first_leg, world, navigation_probe.get("revealed_mask")):
			return false
		navigation_probe.set("unit_position", arrival)
		navigation_probe.set("current_cave_id", source_id)
		navigation_probe.set("moving", true)
		navigation_probe.set("chained_cave_id", destination_id)
		navigation_probe.call("_update_current_cave")
		if navigation_probe.get("current_cave_id") != destination_id or navigation_probe.call("_should_draw_cave", destination_id):
			return false
		if navigation_probe.call("_is_revealed", world.caves[destination_id].position):
			return false
		navigation_probe.call("_scan_current_cave")
		if not navigation_probe.call("_should_draw_cave", destination_id):
			return false
		navigation_probe.set("moving", false)
		navigation_probe.set("chained_cave_id", -1)
		navigation_probe.set("zoom_level", 1.5)
		if not navigation_probe.call("_should_draw_corridor", corridor):
			return false
		var destination_center: Vector2 = world.caves[destination_id].position
		var second_leg: Array = navigation_probe.call("_find_path", arrival, destination_center)
		if not second_leg.is_empty() and not _path_uses_walkable_revealed(second_leg, world, navigation_probe.get("revealed_mask")):
			return false
		return true
	return false

func _exit_discovery_by_proximity_valid(world: Dictionary) -> bool:
	navigation_probe.set("world", world)
	navigation_probe.set("dev_mode", false)
	var cave_id: int = world.entry
	navigation_probe.set("current_cave_id", cave_id)
	navigation_probe.set("unit_position", world.caves[cave_id].position)
	navigation_probe.set("explored_caves", {cave_id: true})
	var revealed := PackedByteArray()
	revealed.resize(world.terrain_mask.size())
	revealed.fill(0)
	navigation_probe.set("revealed_mask", revealed)
	navigation_probe.set("discovered_exits", {})
	for corridor in world.corridors:
		if corridor.a != cave_id and corridor.b != cave_id:
			continue
		var exit_position: Vector2 = corridor.exit_a if corridor.a == cave_id else corridor.exit_b
		navigation_probe.set("unit_position", exit_position)
		navigation_probe.call("_discover_exit_near_unit")
		var exits: Dictionary = navigation_probe.get("discovered_exits")
		if not exits.has("%d:%d" % [cave_id, corridor.id]):
			return false
		for key in exits:
			if not key.begins_with("%d:" % cave_id):
				return false
		var destination_id: int = corridor.b if corridor.a == cave_id else corridor.a
		if navigation_probe.call("_is_revealed", world.caves[destination_id].position):
			return false
		return not navigation_probe.call("_should_draw_cave", destination_id)
	return false

func _path_uses_walkable_revealed(path: Array, world: Dictionary, revealed: PackedByteArray) -> bool:
	var size: Vector2i = world.grid_size
	var walkable: PackedByteArray = world.walkable_mask
	for point in path:
		var cell := Vector2i(floori(point.x / world.cell_size), floori(point.y / world.cell_size))
		if cell.x < 0 or cell.x >= size.x or cell.y < 0 or cell.y >= size.y:
			return false
		var index := cell.y * size.x + cell.x
		if walkable[index] == 0 or revealed[index] == 0:
			return false
	return true

func _player_map_scopes_to_explored(world: Dictionary) -> bool:
	navigation_probe.set("world", world)
	navigation_probe.set("dev_mode", false)
	if not is_instance_valid(navigation_probe.get("ui_root")):
		navigation_probe.call("_build_ui")
	if navigation_probe.call("_over_ui", Vector2(1300, 500)):
		return false
	if not navigation_probe.call("_over_ui", Vector2(1300, 100)):
		return false
	navigation_probe.set("zoom_level", 0.62)
	var entry: int = world.entry
	navigation_probe.set("current_cave_id", entry)
	navigation_probe.set("unit_position", world.caves[entry].position)
	navigation_probe.set("explored_caves", {entry: true})
	var revealed := PackedByteArray()
	revealed.resize(world.terrain_mask.size())
	revealed.fill(0)
	navigation_probe.set("revealed_mask", revealed)
	navigation_probe.set("discovered_exits", {})
	navigation_probe.call("_scan_current_cave")
	for cave in world.caves:
		if navigation_probe.call("_should_draw_cave", cave.id) != (cave.id == entry):
			return false
	var visible_exit_link := false
	for corridor in world.corridors:
		var expected_visible: bool = navigation_probe.get("discovered_exits").has("%d:%d" % [entry, corridor.id])
		if navigation_probe.call("_should_draw_corridor", corridor) != expected_visible:
			return false
		visible_exit_link = visible_exit_link or expected_visible
	if not visible_exit_link:
		return false
	var remote_cave: Dictionary = world.caves[(entry + 1) % world.caves.size()]
	if navigation_probe.call("_find_path", world.caves[entry].position, remote_cave.position).size() != 0:
		return false
	navigation_probe.set("explored_caves", {entry: true, remote_cave.id: true})
	navigation_probe.set("current_cave_id", remote_cave.id)
	navigation_probe.set("zoom_level", 1.5)
	if not navigation_probe.call("_should_draw_cave", entry) or not navigation_probe.call("_should_draw_cave", remote_cave.id):
		return false
	navigation_probe.set("explored_caves", {entry: true})
	navigation_probe.set("current_cave_id", entry)
	navigation_probe.set("dev_mode", true)
	for cave in world.caves:
		if not navigation_probe.call("_should_draw_cave", cave.id):
			return false
	for corridor in world.corridors:
		if not navigation_probe.call("_should_draw_corridor", corridor):
			return false
	navigation_probe.set("dev_mode", false)
	navigation_probe.set("analysis_mode", true)
	navigation_probe.set("selected_cave", remote_cave.id)
	if navigation_probe.call("_should_draw_cave", remote_cave.id) or navigation_probe.call("_should_draw_cave", entry):
		return false
	navigation_probe.set("explored_caves", {entry: true, remote_cave.id: true})
	if not navigation_probe.call("_should_draw_cave", remote_cave.id) or navigation_probe.call("_should_draw_cave", entry):
		return false
	for corridor in world.corridors:
		var connected_to_selected: bool = corridor.a == remote_cave.id or corridor.b == remote_cave.id
		if navigation_probe.call("_should_draw_corridor", corridor) != (connected_to_selected and navigation_probe.get("discovered_exits").has("%d:%d" % [remote_cave.id, corridor.id])):
			return false
	navigation_probe.set("analysis_mode", false)
	return true

func _scanner_requires_selection_without_camera_change(world: Dictionary) -> bool:
	navigation_probe.set("world", world)
	var cave: Dictionary = world.caves[world.entry]
	navigation_probe.set("current_cave_id", world.entry)
	navigation_probe.set("unit_position", cave.position)
	navigation_probe.set("zoom_level", 0.62)
	var original_camera := Vector2(17.0, -23.0)
	navigation_probe.set("camera_offset", original_camera)
	navigation_probe.set("selected_cave", -1)
	navigation_probe.set("explored_caves", {})
	if not is_instance_valid(navigation_probe.get("scan_button")):
		navigation_probe.call("_build_ui")
	var revealed := PackedByteArray()
	revealed.resize(world.terrain_mask.size())
	revealed.fill(0)
	navigation_probe.set("revealed_mask", revealed)
	navigation_probe.set("discovered_exits", {})
	navigation_probe.call("_reveal_around", cave.position, 5)
	navigation_probe.call("_update_scan_availability")
	var scan_button := navigation_probe.get("scan_button") as Button
	if not scan_button.disabled:
		return false
	var revealed_before: int = navigation_probe.call("_revealed_count")
	navigation_probe.call("_scan_local")
	if navigation_probe.get("explored_caves").has(world.entry) or int(navigation_probe.call("_revealed_count")) != revealed_before:
		return false
	navigation_probe.set("selected_cave", world.entry)
	navigation_probe.set("selected_cave_focus", cave.position)
	navigation_probe.call("_update_scan_availability")
	if scan_button.disabled:
		return false
	var expected_zoom: float = navigation_probe.get("zoom_level")
	var expected_offset: Vector2 = navigation_probe.get("camera_offset")
	navigation_probe.call("_scan_local")
	return navigation_probe.get("explored_caves").has(world.entry) and absf(float(navigation_probe.get("zoom_level")) - expected_zoom) <= 0.001 and navigation_probe.get("camera_offset").distance_to(expected_offset) <= 0.1

func _revelation_and_camera_valid(world: Dictionary) -> bool:
	navigation_probe.set("world", world)
	var start: Vector2 = world.caves[world.entry].position
	navigation_probe.set("unit_position", start)
	var revealed := PackedByteArray()
	revealed.resize(world.terrain_mask.size())
	revealed.fill(0)
	navigation_probe.set("revealed_mask", revealed)
	navigation_probe.call("_reveal_around", start, 5)
	var initial_count: int = navigation_probe.call("_revealed_count")
	var before: PackedByteArray = navigation_probe.get("revealed_mask").duplicate()
	var initial_position: Vector2 = navigation_probe.get("unit_position")
	navigation_probe.set("zoom_level", 1.5)
	navigation_probe.set("camera_offset", Vector2(120, -80))
	if navigation_probe.get("revealed_mask") != before or navigation_probe.get("unit_position") != initial_position:
		return false
	return initial_count > 0

func _count_walkable(mask: PackedByteArray) -> int:
	var count := 0
	for value in mask:
		if value == 1:
			count += 1
	return count
