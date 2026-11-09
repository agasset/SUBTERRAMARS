extends Node2D

const Generator = preload("res://scripts/world_generator.gd")
const BG := Color("07111c")
const PANEL := Color("0c1b29")
const CYAN := Color("5de5ed")
const MUTED := Color("71909f")
const ORANGE := Color("ffac62")
const ANALYSIS_MIN_ZOOM := 2.8
const ANALYSIS_MAX_ZOOM := 7.0
const PREVIEW_ANALYSIS_ZOOM := 5.5
const ISO_AXIS_SCALE := 0.70
const ISO_VERTICAL_RATIO := 0.5

var world: Dictionary
var seed_value := 134027
var camera_offset := Vector2.ZERO
var zoom_level := 0.62
var selected_cave := -1
var selected_cave_focus := Vector2.ZERO
var analysis_mode := false
var unit_position := Vector2.ZERO
var move_target := Vector2.ZERO
var moving := false
var move_path: Array[Vector2] = []
var selected_route: Array[Vector2] = []
var chained_cave_id := -1
var chained_arrival := Vector2.ZERO
var revealed_mask := PackedByteArray()
var last_revealed_cell := Vector2i(-1, -1)
var current_cave_id := -1
var discovered_exits: Dictionary = {}
var show_graph := true
var show_contours := true
var show_route := true
var show_spawn := true
var dev_mode := false
var explored_caves: Dictionary = {}
var dragging := false
var drag_origin := Vector2.ZERO
var ui_root: Control
var mode_heading_label: Label
var seed_edit: LineEdit
var status_label: Label
var dev_toggle: CheckButton
var scan_button: Button
var new_game_button: Button
var map_return_button: Button
var level_panel: Control
var bottom_panel: Control
var analysis_tools_panel: Control
var analysis_scan_button: Button
var cave_heading_label: Label
var cave_count_label: Label
var access_heading_label: Label
var exit_count_label: Label

func _ready() -> void:
	_build_ui()
	_new_world(seed_value)
	get_viewport().size_changed.connect(queue_redraw)

func _process(delta: float) -> void:
	if moving:
		var remaining_distance := 145.0 * delta
		while remaining_distance > 0.0 and not move_path.is_empty():
			var difference: Vector2 = move_path[0] - unit_position
			var distance := difference.length()
			if distance <= remaining_distance:
				unit_position = move_path.pop_front()
				remaining_distance -= distance
			else:
				unit_position += difference / distance * remaining_distance
				remaining_distance = 0.0
		if move_path.is_empty():
			unit_position = move_target
			_update_current_cave()
			moving = false
			selected_route.clear()
			if chained_cave_id >= 0:
				var arrival_cave := chained_cave_id
				var arrival_position := chained_arrival
				chained_cave_id = -1
				if current_cave_id == arrival_cave:
					_start_arrival_movement(arrival_cave, arrival_position)
		else:
			selected_route = move_path.duplicate()
		var current_cell := Vector2i(floori(unit_position.x / world.cell_size), floori(unit_position.y / world.cell_size))
		if current_cell != last_revealed_cell:
			_reveal_around(unit_position, 5)
		_update_current_cave()
		_discover_exit_near_unit()
		queue_redraw()

func _draw() -> void:
	var view := _view_rect()
	if world.is_empty():
		return
	if analysis_mode:
		_draw_isometric_room()
		return
	# Subtle star-field marks anchored to world coordinates, visible in the map only.
	for i in range(90):
		var p := _world_to_screen(Vector2(fposmod(i * 197.3, 2200.0), fposmod(i * 113.7, 1500.0)))
		if view.has_point(p):
			draw_circle(p, 1.0, Color(0.15, 0.28, 0.36, 0.4))
	for corridor in world.corridors:
		if not _should_draw_corridor(corridor):
			continue
		var points: PackedVector2Array = corridor.points
		if points.size() < 2:
			continue
		var screen_points := PackedVector2Array()
		for p in points:
			screen_points.append(_world_to_screen(p))
		draw_polyline(screen_points, Color("183c49"), maxf(4.0, corridor.width * zoom_level), true)
		if show_graph:
			draw_polyline(screen_points, Color("347b89"), 1.3, true)
	if show_route and not selected_route.is_empty() and (not analysis_mode or _route_is_inside_selected_cave()):
		var route_points := PackedVector2Array([_world_to_screen(unit_position)])
		for point in selected_route:
			route_points.append(_world_to_screen(point))
		draw_polyline(route_points, Color(ORANGE, 0.48), 2.0, true)
	for cave in world.caves:
		if not _should_draw_cave(cave.id):
			continue
		var center := _world_to_screen(cave.position)
		var contour: PackedVector2Array = cave.contour
		var screen_contour := PackedVector2Array()
		for point in contour:
			screen_contour.append(center + point * zoom_level)
		screen_contour.append(screen_contour[0])
		var fill := Color("102a38") if cave.id != world.entry else Color("183a3e")
		draw_colored_polygon(screen_contour, fill)
		if show_contours:
			_draw_cave_outline(cave, CYAN if cave.id == selected_cave else Color("448b99"), 2.2 if cave.id == selected_cave else 1.3)
		if show_spawn and cave.id == world.entry:
			draw_circle(center, 7.0, ORANGE)
			draw_circle(center, 12.0, Color(ORANGE, 0.25), false, 1.2)
		if zoom_level > 0.95:
			draw_circle(center, 3.6, Color("72e7d1"))
		if zoom_level > 0.48 and zoom_level <= 0.82:
			draw_string(ThemeDB.fallback_font, center + Vector2(-4, 4), str(cave.id + 1), HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color("a9c8d1"))
	if zoom_level <= 0.82:
		_draw_cave_previews()
	if zoom_level > 0.82:
		_draw_unknown_overlay()
		_draw_cave_previews()
		for cave in world.caves:
			if not _should_draw_cave(cave.id):
				continue
			var center: Vector2 = cave.position
			var screen_center := _world_to_screen(center)
			var contour: PackedVector2Array = cave.contour
			var screen_contour := PackedVector2Array()
			for point in contour:
				screen_contour.append(screen_center + point * zoom_level)
			screen_contour.append(screen_contour[0])
			_draw_cave_outline(cave, CYAN if cave.id == selected_cave else Color("448b99"), 2.2 if cave.id == selected_cave else 1.3)
			if _is_revealed(center):
				draw_string(ThemeDB.fallback_font, screen_center + Vector2(-4, 4), str(cave.id + 1), HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color("a9c8d1"))
		for obstacle in world.obstacles:
			if _is_revealed(obstacle.position) and (not analysis_mode or _point_inside_selected_cave(obstacle.position)):
				_draw_obstacle(obstacle)
	var unit_screen := _world_to_screen(unit_position)
	draw_circle(unit_screen, maxf(4.5, 7.0 * zoom_level), ORANGE)
	draw_arc(unit_screen, maxf(7.0, 11.0 * zoom_level), 0, TAU, 16, Color("ffe2ba"), 1.4)

func _draw_isometric_room() -> void:
	if selected_cave < 0 or selected_cave >= world.caves.size():
		return
	var cave: Dictionary = world.caves[selected_cave]
	var contour: PackedVector2Array = cave.contour
	var room_is_known: bool = explored_caves.has(selected_cave)
	var local_bounds := Rect2(contour[0], Vector2.ZERO)
	for point in contour:
		local_bounds = local_bounds.expand(point)
	var min_cell_x := maxi(0, floori((cave.position.x + local_bounds.position.x) / world.cell_size))
	var max_cell_x := mini(world.grid_size.x - 1, ceili((cave.position.x + local_bounds.end.x) / world.cell_size))
	var min_cell_y := maxi(0, floori((cave.position.y + local_bounds.position.y) / world.cell_size))
	var max_cell_y := mini(world.grid_size.y - 1, ceili((cave.position.y + local_bounds.end.y) / world.cell_size))
	if room_is_known:
		_draw_isometric_walls(cave)
		var known_contour := PackedVector2Array()
		for point in contour:
			known_contour.append(_world_to_screen(cave.position + point))
		draw_colored_polygon(known_contour, Color("171419"))
	_draw_isometric_floor(cave, min_cell_x, max_cell_x, min_cell_y, max_cell_y)
	if room_is_known:
		# The short passage throat is layered over the floor to seal raster gaps;
		# the explorer is rendered afterward so it always stays in front.
		_draw_isometric_corridors(cave)
		_draw_isometric_contour(cave)
	for obstacle in world.obstacles:
		if _point_inside_selected_cave(obstacle.position) and _is_revealed(obstacle.position):
			_draw_isometric_obstacle(obstacle)
	if _point_inside_selected_cave(unit_position) or _point_inside_isometric_exit(unit_position, cave):
		_draw_isometric_explorer(unit_position)

func _draw_isometric_floor(cave: Dictionary, min_x: int, max_x: int, min_y: int, max_y: int) -> void:
	var terrain: PackedByteArray = world.terrain_mask
	var revealed: PackedByteArray = revealed_mask
	var grid_width: int = world.grid_size.x
	var half_tile: float = world.cell_size * 0.25
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var index := y * grid_width + x
			if terrain[index] == 0 or revealed[index] == 0:
				continue
			var cell_center := Vector2((float(x) + 0.5) * world.cell_size, (float(y) + 0.5) * world.cell_size)
			if not Geometry2D.is_point_in_polygon(cell_center - cave.position, cave.contour):
				continue
			# Four subtiles per logical cell keep the isometric floor readable
			# without changing the generator's navigation or reveal resolution.
			for sub_y in range(2):
				for sub_x in range(2):
					var offset := Vector2((float(sub_x) - 0.5) * half_tile * 2.0, (float(sub_y) - 0.5) * half_tile * 2.0)
					var tile_center := cell_center + offset
					var corner_offset := Vector2(half_tile, half_tile)
					var tile_corners := [
						tile_center + Vector2(-corner_offset.x, -corner_offset.y),
						tile_center + Vector2(corner_offset.x, -corner_offset.y),
						tile_center + corner_offset,
						tile_center + Vector2(-corner_offset.x, corner_offset.y)
					]
					var tile_inside := true
					for corner in tile_corners:
						if not Geometry2D.is_point_in_polygon(corner - cave.position, cave.contour):
							tile_inside = false
							break
					if not tile_inside:
						continue
					var diamond := PackedVector2Array([
						_world_to_screen(tile_center + Vector2(-half_tile, -half_tile)),
						_world_to_screen(tile_center + Vector2(half_tile, -half_tile)),
						_world_to_screen(tile_center + Vector2(half_tile, half_tile)),
						_world_to_screen(tile_center + Vector2(-half_tile, half_tile))
					])
					var variation: int = posmod(x * 13 + y * 7 + sub_x * 3 + sub_y * 5 + seed_value, 5)
					var floor_color: Color = [Color("4a2b26"), Color("573127"), Color("442829"), Color("4d2b31"), Color("60402d")][variation]
					draw_colored_polygon(diamond, floor_color)
					draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]), Color("774034", 0.32), 0.55, true)

func _draw_isometric_walls(cave: Dictionary) -> void:
	var contour: PackedVector2Array = cave.contour
	var exits := _visible_exits_for_cave(cave.id)
	var screen_points := PackedVector2Array()
	for point in contour:
		screen_points.append(_world_to_screen(cave.position + point))
	var center_y := 0.0
	for point in screen_points:
		center_y += point.y
	center_y /= float(screen_points.size())
	var wall_height := 12.0 + zoom_level * 3.2
	for i in range(contour.size()):
		var a: Vector2 = cave.position + contour[i]
		var b: Vector2 = cave.position + contour[(i + 1) % contour.size()]
		var edge := b - a
		var edge_length := edge.length()
		if edge_length <= 0.001:
			continue
		var cuts: Array[Vector2] = []
		for exit_info in exits:
			var closest := Geometry2D.get_closest_point_to_segment(exit_info.position, a, b)
			if closest.distance_to(exit_info.position) > float(exit_info.width) * 0.5 + 4.0:
				continue
			var center_t := clampf((closest - a).dot(edge) / edge.length_squared(), 0.0, 1.0)
			var half_gap_t := (float(exit_info.width) * 0.5 + 4.0) / edge_length
			cuts.append(Vector2(maxf(0.0, center_t - half_gap_t), minf(1.0, center_t + half_gap_t)))
		cuts.sort_custom(func(left: Vector2, right: Vector2) -> bool: return left.x < right.x)
		var visible_ranges: Array[Vector2] = []
		var cursor := 0.0
		for cut in cuts:
			if cut.x > cursor:
				visible_ranges.append(Vector2(cursor, cut.x))
			cursor = maxf(cursor, cut.y)
		if cursor < 1.0:
			visible_ranges.append(Vector2(cursor, 1.0))
		for edge_range in visible_ranges:
			var start := _world_to_screen(a.lerp(b, edge_range.x))
			var finish := _world_to_screen(a.lerp(b, edge_range.y))
			var wall_direction := 1.0 if (start.y + finish.y) * 0.5 >= center_y else -1.0
			var wall_offset := Vector2(0, wall_height * wall_direction)
			draw_colored_polygon(PackedVector2Array([start, finish, finish + wall_offset, start + wall_offset]), Color("281c20") if finish.x >= start.x else Color("352026"))
			draw_line(start, start + wall_offset, Color("884735"), 1.0, true)
			draw_line(finish, finish + wall_offset, Color("170f15"), 1.0, true)

func _draw_isometric_contour(cave: Dictionary) -> void:
	var contour: PackedVector2Array = cave.contour
	var exits := _visible_exits_for_cave(cave.id)
	for i in range(contour.size()):
		var a: Vector2 = cave.position + contour[i]
		var b: Vector2 = cave.position + contour[(i + 1) % contour.size()]
		var edge := b - a
		var edge_length := edge.length()
		if edge_length <= 0.001:
			continue
		var cuts: Array[Vector2] = []
		for exit_info in exits:
			var closest := Geometry2D.get_closest_point_to_segment(exit_info.position, a, b)
			if closest.distance_to(exit_info.position) > float(exit_info.width) * 0.5 + 4.0:
				continue
			var center_t := clampf((closest - a).dot(edge) / edge.length_squared(), 0.0, 1.0)
			var half_gap_t := (float(exit_info.width) * 0.5 + 3.0) / edge_length
			cuts.append(Vector2(maxf(0.0, center_t - half_gap_t), minf(1.0, center_t + half_gap_t)))
		cuts.sort_custom(func(left: Vector2, right: Vector2) -> bool: return left.x < right.x)
		var cursor := 0.0
		for cut in cuts:
			if cut.x > cursor:
				draw_line(_world_to_screen(a.lerp(b, cursor)), _world_to_screen(a.lerp(b, cut.x)), Color("b75b37"), maxf(1.5, zoom_level * 0.55), true)
			cursor = maxf(cursor, cut.y)
		if cursor < 1.0:
			draw_line(_world_to_screen(a.lerp(b, cursor)), _world_to_screen(b), Color("b75b37"), maxf(1.5, zoom_level * 0.55), true)

func _draw_isometric_corridors(cave: Dictionary) -> void:
	# Render a discovered exit as the actual passage leaving the room, not as a
	# map-style dot. The passage uses the same generated path and reveal mask as
	# navigation; the far room stays hidden behind its unrevealed contour.
	for exit_info in _visible_exits_for_cave(cave.id):
		var corridor: Dictionary = {}
		for candidate in world.corridors:
			if candidate.id == exit_info.corridor_id:
				corridor = candidate
				break
		if corridor.is_empty():
			continue
		var centerline := _isometric_exit_stub(exit_info, corridor, cave)
		if centerline.size() >= 2:
			_draw_isometric_corridor_mesh(centerline, float(corridor.width))

func _isometric_exit_stub(exit_info: Dictionary, corridor: Dictionary, cave: Dictionary) -> PackedVector2Array:
	# Draw a short isometric throat from the exact wall opening. The map's
	# center-to-center tunnel path can bend independently of the room boundary,
	# so it must not be stretched across the chamber as a second floor layer.
	var outward: Vector2 = exit_info.direction.normalized()
	if outward.length_squared() < 0.001:
		return PackedVector2Array()
	var route: PackedVector2Array = corridor.points
	if corridor.b == cave.id:
		route = PackedVector2Array()
		for point_index in range(corridor.points.size() - 1, -1, -1):
			route.append(corridor.points[point_index])
	var nearest_index := 0
	var nearest_distance := INF
	for index in range(route.size()):
		var distance: float = route[index].distance_squared_to(exit_info.position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_index = index
	var route_tangent: Vector2 = (route[mini(nearest_index + 1, route.size() - 1)] - route[nearest_index]).normalized()
	var bend_side := signf(outward.cross(route_tangent))
	if is_zero_approx(bend_side):
		bend_side = 1.0 if posmod(int(corridor.id), 2) == 0 else -1.0
	var side := outward.orthogonal() * bend_side
	var length: float = clampf(float(cave.radius) * 0.30, 26.0, 40.0)
	var bend: float = clampf(float(corridor.width) * 0.14, 3.0, 7.0)
	var start: Vector2 = exit_info.position
	var control_a := start + outward * length * 0.34
	var control_b := start + outward * length * 0.72 + side * bend * 0.3
	var finish := start + outward * length + side * bend
	var points := PackedVector2Array()
	for step in range(9):
		var t := float(step) / 8.0
		var inverse := 1.0 - t
		points.append(inverse * inverse * inverse * start + 3.0 * inverse * inverse * t * control_a + 3.0 * inverse * t * t * control_b + t * t * t * finish)
	return points

func _point_inside_isometric_exit(point: Vector2, cave: Dictionary) -> bool:
	for exit_info in _visible_exits_for_cave(cave.id):
		for corridor in world.corridors:
			if corridor.id != exit_info.corridor_id:
				continue
			var centerline := _isometric_exit_stub(exit_info, corridor, cave)
			for index in range(centerline.size() - 1):
				var closest := Geometry2D.get_closest_point_to_segment(point, centerline[index], centerline[index + 1])
				if closest.distance_to(point) <= float(corridor.width) * 0.55:
					return true
	return false

func _draw_isometric_corridor_mesh(centerline: PackedVector2Array, width: float) -> void:
	var left_edge := PackedVector2Array()
	var right_edge := PackedVector2Array()
	for index in range(centerline.size()):
		var previous: Vector2 = centerline[maxi(0, index - 1)]
		var following: Vector2 = centerline[mini(centerline.size() - 1, index + 1)]
		var tangent := (following - previous).normalized()
		if tangent.length_squared() < 0.001:
			continue
		var normal := Vector2(-tangent.y, tangent.x) * width * 0.5
		left_edge.append(centerline[index] + normal)
		right_edge.append(centerline[index] - normal)
	if left_edge.size() < 2:
		return
	var vertical_height := clampf(width * zoom_level * 0.36, 5.0, 24.0)
	# Raised tunnel walls first, then the walkable floor over their lower edges.
	for index in range(left_edge.size() - 1):
		var left_a := _world_to_screen(left_edge[index])
		var left_b := _world_to_screen(left_edge[index + 1])
		var right_a := _world_to_screen(right_edge[index])
		var right_b := _world_to_screen(right_edge[index + 1])
		draw_colored_polygon(PackedVector2Array([left_a, left_b, left_b - Vector2(0, vertical_height), left_a - Vector2(0, vertical_height)]), Color("392126"))
		draw_colored_polygon(PackedVector2Array([right_a, right_b, right_b - Vector2(0, vertical_height), right_a - Vector2(0, vertical_height)]), Color("241a20"))
	var floor_shape := PackedVector2Array()
	for point in left_edge:
		floor_shape.append(_world_to_screen(point))
	for index in range(right_edge.size() - 1, -1, -1):
		floor_shape.append(_world_to_screen(right_edge[index]))
	draw_colored_polygon(floor_shape, Color("4a2927"))
	var left_rim := PackedVector2Array()
	var right_rim := PackedVector2Array()
	for point in left_edge:
		left_rim.append(_world_to_screen(point) - Vector2(0, vertical_height))
	for point in right_edge:
		right_rim.append(_world_to_screen(point) - Vector2(0, vertical_height))
	draw_polyline(left_rim, Color("b45c3d"), maxf(1.0, zoom_level * 0.22), true)
	draw_polyline(right_rim, Color("744136"), maxf(1.0, zoom_level * 0.18), true)

func _draw_isometric_obstacle(obstacle: Dictionary) -> void:
	var radius: float = obstacle.radius
	var base := PackedVector2Array()
	var top := PackedVector2Array()
	for i in range(7):
		var angle := TAU * float(i) / 7.0
		var shape_scale := 0.78 + 0.2 * float((i * 3 + obstacle.id) % 5) / 4.0
		var point: Vector2 = obstacle.position + Vector2(cos(angle), sin(angle)) * radius * shape_scale
		base.append(_world_to_screen(point) + Vector2(0, zoom_level * 2.5))
		top.append(_world_to_screen(point) - Vector2(0, radius * zoom_level * 0.28))
	var shadow := PackedVector2Array()
	for i in range(top.size()):
		shadow.append(top[i] + Vector2(3, zoom_level * 3.0))
	draw_colored_polygon(shadow, Color("090b10", 0.8))
	for i in range(top.size()):
		var next := (i + 1) % top.size()
		draw_colored_polygon(PackedVector2Array([base[i], base[next], top[next], top[i]]), Color("3a3d43") if i % 2 == 0 else Color("292d35"))
	draw_colored_polygon(top, Color("737b80"))
	draw_polyline(PackedVector2Array([top[0], top[1], top[2]]), Color("b1b8b0"), 1.2, true)

func _draw_isometric_explorer(position: Vector2) -> void:
	var screen := _world_to_screen(position)
	var scale := clampf(zoom_level * 0.28, 0.8, 1.6)
	var ground := PackedVector2Array()
	for i in range(12):
		var angle := TAU * float(i) / 12.0
		ground.append(screen + Vector2(cos(angle) * 13.0, sin(angle) * 5.0) * scale + Vector2(0, zoom_level * 2.0))
	draw_colored_polygon(ground, Color("100e12", 0.72))
	draw_colored_polygon(PackedVector2Array([screen + Vector2(-7, 1) * scale, screen + Vector2(-4, 11) * scale, screen + Vector2(4, 11) * scale, screen + Vector2(7, 1) * scale]), Color("263b43"))
	draw_rect(Rect2(screen + Vector2(-6, -15) * scale, Vector2(12, 16) * scale), Color("9b653d"))
	draw_rect(Rect2(screen + Vector2(-9, -14) * scale, Vector2(5, 13) * scale), Color("46747a"))
	draw_circle(screen + Vector2(0, -20) * scale, 6.0 * scale, Color("b2c5ba"))
	draw_circle(screen + Vector2(1, -20) * scale, 2.2 * scale, CYAN)
	draw_arc(screen, 14.0 * scale, 0, TAU, 16, Color("f5a34f"), 1.2)

func _build_ui() -> void:
	ui_root = Control.new()
	ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_root.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(ui_root)
	var left := _panel(Rect2(18, 18, 280, 145))
	ui_root.add_child(left)
	_add_label(left, "SUBTERRA: MARS", 18, CYAN, Vector2(16, 12), Vector2(248, 26))
	mode_heading_label = _add_label(left, "MAPA DE RECERCA   /   NIVELL 01", 10, MUTED, Vector2(16, 42), Vector2(248, 18))
	seed_edit = LineEdit.new()
	seed_edit.position = Vector2(16, 76)
	seed_edit.size = Vector2(145, 34)
	seed_edit.text = str(seed_value)
	seed_edit.placeholder_text = "Llavor"
	left.add_child(seed_edit)
	new_game_button = _button("NOVA PARTIDA", Vector2(168, 76), Vector2(96, 34))
	new_game_button.pressed.connect(_on_new_pressed)
	left.add_child(new_game_button)
	map_return_button = _button("TORNA AL MAPA", Vector2(16, 76), Vector2(248, 34))
	map_return_button.visible = false
	map_return_button.pressed.connect(_return_to_map)
	left.add_child(map_return_button)
	status_label = _add_label(left, "GENERADOR P0B · %s" % Generator.GENERATOR_VERSION, 10, Color("89b0bb"), Vector2(16, 116), Vector2(248, 18))

	level_panel = _panel(Rect2(0, 18, 280, 250))
	level_panel.size.y = 330
	level_panel.position = Vector2(1142, 18)
	ui_root.add_child(level_panel)
	_add_label(level_panel, "LECTURA DEL NIVELL", 13, CYAN, Vector2(16, 14), Vector2(248, 24))
	cave_heading_label = _add_label(level_panel, "COVES VISITADES", 10, MUTED, Vector2(16, 56), Vector2(115, 18))
	cave_count_label = _add_label(level_panel, "01", 19, Color("dcecf0"), Vector2(16, 74), Vector2(95, 28))
	access_heading_label = _add_label(level_panel, "SORTIDES", 10, MUTED, Vector2(140, 56), Vector2(105, 18))
	exit_count_label = _add_label(level_panel, "00", 19, ORANGE, Vector2(140, 74), Vector2(95, 28))
	_add_label(level_panel, "VISOR DE DESENVOLUPAMENT", 10, MUTED, Vector2(16, 119), Vector2(248, 18))
	var toggles := [ ["Graf", "graph"], ["Contorns", "contours"], ["Ruta", "route"], ["Aparició", "spawn"] ]
	for i in range(toggles.size()):
		var check := CheckButton.new()
		check.text = toggles[i][0]
		check.position = Vector2(12 + (i % 2) * 126, 146 + (i / 2) * 38)
		check.button_pressed = true
		check.add_theme_color_override("font_color", Color("b4ccd2"))
		check.toggled.connect(_on_overlay_toggled.bind(toggles[i][1]))
		level_panel.add_child(check)
	dev_toggle = CheckButton.new()
	dev_toggle.text = "MAPA COMPLET (DEV)"
	dev_toggle.position = Vector2(12, 218)
	dev_toggle.size = Vector2(248, 28)
	dev_toggle.button_pressed = false
	dev_toggle.tooltip_text = "Mostra tota la xarxa generada per inspeccionar llavors."
	dev_toggle.add_theme_font_size_override("font_size", 10)
	dev_toggle.add_theme_color_override("font_color", Color("b4ccd2"))
	dev_toggle.toggled.connect(_on_dev_mode_toggled)
	level_panel.add_child(dev_toggle)
	var focus_button := _button("INVESTIGA", Vector2(16, 262), Vector2(118, 36))
	focus_button.pressed.connect(_focus_selected_cave)
	level_panel.add_child(focus_button)
	scan_button = _button("ESCÀNER SALA", Vector2(146, 262), Vector2(118, 36))
	scan_button.tooltip_text = "Selecciona amb clic la sala actual per activar l'escàner."
	scan_button.pressed.connect(_scan_local)
	level_panel.add_child(scan_button)
	_update_scan_availability()

	bottom_panel = _panel(Rect2(0, 0, 520, 62))
	bottom_panel.position = Vector2(460, 820)
	ui_root.add_child(bottom_panel)
	_add_label(bottom_panel, "EXPLORADOR", 10, ORANGE, Vector2(16, 11), Vector2(110, 18))
	_add_label(bottom_panel, "CLIC DRET  ·  ORDRE DE MOVIMENT", 10, Color("9ab4bc"), Vector2(16, 33), Vector2(250, 18))
	_add_label(bottom_panel, "RODA  ZOOM     ESPAI + ARROSSEGAR  MOU CÀMERA", 9, MUTED, Vector2(275, 22), Vector2(230, 20))
	analysis_tools_panel = _panel(Rect2(0, 18, 220, 76))
	analysis_tools_panel.position = Vector2(1204, 18)
	ui_root.add_child(analysis_tools_panel)
	_add_label(analysis_tools_panel, "EINES D'EXPLORACIÓ", 10, MUTED, Vector2(12, 8), Vector2(196, 18))
	analysis_scan_button = _button("ESCÀNER SALA", Vector2(12, 34), Vector2(196, 32))
	analysis_scan_button.tooltip_text = "Escaneja la sala seleccionada on és l'explorador."
	analysis_scan_button.pressed.connect(_scan_local)
	analysis_tools_panel.add_child(analysis_scan_button)
	analysis_tools_panel.visible = false
	_update_scan_availability()

func _panel(rect: Rect2) -> Control:
	var panel := Control.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background := Panel.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL
	style.border_color = Color("1a4857")
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	background.add_theme_stylebox_override("panel", style)
	panel.add_child(background)
	return panel

func _add_label(parent: Control, value: String, font_size: int, color: Color, pos: Vector2, extent: Vector2) -> Label:
	var label := Label.new()
	label.text = value
	label.position = pos
	label.size = extent
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _button(value: String, pos: Vector2, extent: Vector2) -> Button:
	var button := Button.new()
	button.text = value
	button.position = pos
	button.size = extent
	button.add_theme_font_size_override("font_size", 10)
	button.add_theme_color_override("font_color", Color("06212a"))
	var style := StyleBoxFlat.new()
	style.bg_color = CYAN
	style.set_corner_radius_all(4)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	return button

func _on_new_pressed() -> void:
	var parsed := seed_edit.text.strip_edges().to_int()
	if seed_edit.text.strip_edges().is_empty():
		parsed = int(Time.get_unix_time_from_system())
	_new_world(parsed)

func _new_world(value: int) -> void:
	seed_value = value
	var start_time := Time.get_ticks_msec()
	world = Generator.generate(seed_value)
	var elapsed := Time.get_ticks_msec() - start_time
	selected_cave = -1
	selected_cave_focus = Vector2.ZERO
	analysis_mode = false
	unit_position = world.caves[world.entry].position
	move_target = unit_position
	moving = false
	move_path.clear()
	selected_route.clear()
	chained_cave_id = -1
	current_cave_id = world.entry
	discovered_exits.clear()
	explored_caves.clear()
	explored_caves[world.entry] = true
	revealed_mask.resize(world.terrain_mask.size())
	revealed_mask.fill(0)
	last_revealed_cell = Vector2i(-1, -1)
	_reveal_around(unit_position, 5)
	camera_offset = Vector2.ZERO
	if is_instance_valid(status_label):
		status_label.text = "LLAVOR %d · %d ms · %s" % [seed_value, elapsed, "RESERVA" if world.fallback else "P0B"]
	_update_map_stats()
	_update_scan_availability()
	_update_view_mode_ui()
	camera_offset = -(unit_position - Generator.WORLD_RECT.size * 0.5) * zoom_level
	queue_redraw()

func _on_overlay_toggled(value: bool, overlay: String) -> void:
	match overlay:
		"graph": show_graph = value
		"contours": show_contours = value
		"route": show_route = value
		"spawn": show_spawn = value
	queue_redraw()

func _on_dev_mode_toggled(value: bool) -> void:
	dev_mode = value
	_update_map_stats()
	queue_redraw()

func _update_map_stats() -> void:
	if not is_instance_valid(cave_heading_label) or world.is_empty():
		return
	cave_heading_label.text = "COVES TOTALS" if dev_mode else "COVES VISITADES"
	cave_count_label.text = str(world.caves.size() if dev_mode else explored_caves.size())
	access_heading_label.text = "CONNEXIONS" if dev_mode else "SORTIDES"
	exit_count_label.text = str(_exit_count(current_cave_id))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_at(event.position, 1.16)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_at(event.position, 1.0 / 1.16)
		elif event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			dragging = true
			drag_origin = event.position
		elif event.button_index == MOUSE_BUTTON_MIDDLE and not event.pressed:
			dragging = false
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and not _over_ui(event.position):
			var order := _resolve_order_target(_screen_to_world(event.position))
			if not order.is_empty():
				var target: Vector2 = order.position
				var path := _find_path(unit_position, target)
				if not path.is_empty():
					chained_cave_id = int(order.cave_id)
					chained_arrival = world.caves[chained_cave_id].position if chained_cave_id >= 0 else Vector2.ZERO
					move_path = path
					selected_route = path.duplicate()
					move_target = move_path.back()
					moving = true
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not _over_ui(event.position):
			_select_cave(event.position)
	elif event is InputEventMouseMotion and dragging:
		camera_offset += event.relative
		queue_redraw()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		dragging = true
	elif event is InputEventKey and not event.pressed and event.keycode == KEY_SPACE:
		dragging = false
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and analysis_mode:
		_return_to_map()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_E:
		_scan_local()

func _zoom_at(screen_position: Vector2, factor: float) -> void:
	var before := _screen_to_world(screen_position)
	zoom_level = clampf(zoom_level * factor, 0.28, 8.0)
	var projected_after := _world_to_screen(before)
	camera_offset += screen_position - projected_after
	queue_redraw()

func _select_cave(screen_position: Vector2) -> void:
	var point := _screen_to_world(screen_position)
	var nearest := -1
	var nearest_focus := Vector2.ZERO
	var distance := 95.0 / zoom_level
	for cave in world.caves:
		var candidate_focus: Vector2
		var candidate_distance: float
		if _should_draw_cave(cave.id):
			candidate_focus = cave.position
			candidate_distance = candidate_focus.distance_to(point)
		else:
			candidate_focus = _nearest_visible_preview_cell(cave.id, point)
			if candidate_focus.x < 0.0:
				continue
			candidate_distance = candidate_focus.distance_to(point)
			if candidate_distance > maxf(18.0 / zoom_level, world.cell_size * 1.5):
				continue
		if candidate_distance < distance:
			distance = candidate_distance
			nearest = cave.id
			nearest_focus = candidate_focus
	if nearest >= 0:
		selected_cave = nearest
		selected_cave_focus = nearest_focus
		analysis_mode = true
		selected_route.clear()
		if _should_draw_cave(nearest):
			selected_route = _find_path(unit_position, world.caves[nearest].position)
		_update_scan_availability()
		_update_view_mode_ui()
		var requested_zoom := _analysis_zoom_for_cave(nearest) if _should_draw_cave(nearest) else PREVIEW_ANALYSIS_ZOOM
		_focus_world_position(nearest_focus, requested_zoom)

func _update_scan_availability() -> void:
	if is_instance_valid(scan_button):
		scan_button.disabled = selected_cave != current_cave_id
	if is_instance_valid(analysis_scan_button):
		analysis_scan_button.disabled = selected_cave != current_cave_id

func _focus_selected_cave() -> void:
	if selected_cave < 0 or selected_cave >= world.caves.size():
		return
	analysis_mode = true
	_update_view_mode_ui()
	var requested_zoom := _analysis_zoom_for_cave(selected_cave) if _should_draw_cave(selected_cave) else PREVIEW_ANALYSIS_ZOOM
	var focus_position: Vector2 = world.caves[selected_cave].position if _should_draw_cave(selected_cave) else selected_cave_focus
	_focus_world_position(focus_position, requested_zoom)

func _focus_cave(cave_id: int, requested_zoom: float) -> void:
	if cave_id < 0 or cave_id >= world.caves.size():
		return
	_focus_world_position(world.caves[cave_id].position, requested_zoom)

func _focus_world_position(position: Vector2, requested_zoom: float) -> void:
	zoom_level = maxf(zoom_level, requested_zoom)
	if analysis_mode and selected_cave >= 0 and selected_cave < world.caves.size():
		var cave: Dictionary = world.caves[selected_cave]
		camera_offset = -_iso_project_relative(position, cave.position) * zoom_level
	else:
		camera_offset = -((position - Generator.WORLD_RECT.size * 0.5) * zoom_level)
	queue_redraw()

func _analysis_zoom_for_cave(cave_id: int) -> float:
	var bounds := Rect2()
	var cave: Dictionary = world.caves[cave_id]
	var contour: PackedVector2Array = cave.contour
	if contour.is_empty():
		return ANALYSIS_MIN_ZOOM
	bounds = Rect2(_iso_project_relative(cave.position + contour[0], cave.position), Vector2.ZERO)
	for point in contour:
		bounds = bounds.expand(_iso_project_relative(cave.position + point, cave.position))
	var available_size := _view_rect().size * Vector2(0.84, 0.84)
	var horizontal_fit := available_size.x / maxf(bounds.size.x, 1.0)
	var vertical_fit := available_size.y / maxf(bounds.size.y, 1.0)
	return clampf(minf(horizontal_fit, vertical_fit), ANALYSIS_MIN_ZOOM, ANALYSIS_MAX_ZOOM)

func _update_view_mode_ui() -> void:
	if not is_instance_valid(mode_heading_label):
		return
	if analysis_mode and selected_cave >= 0 and selected_cave < world.caves.size():
		mode_heading_label.text = "EXPLORACIÓ DE SALA %02d" % (selected_cave + 1)
		seed_edit.visible = false
		new_game_button.visible = false
		map_return_button.visible = true
		if not explored_caves.has(selected_cave):
			status_label.text = "FRAGMENT VISIBLE · SALA NO ESCANEJADA"
		elif selected_cave == current_cave_id:
			status_label.text = "SALA ACTUAL · ESCÀNER DISPONIBLE"
		else:
			status_label.text = "SALA EXPLORADA · VISUALITZACIÓ"
	else:
		analysis_mode = false
		mode_heading_label.text = "MAPA DE RECERCA   /   NIVELL 01"
		seed_edit.visible = true
		new_game_button.visible = true
		map_return_button.visible = false
	if is_instance_valid(level_panel):
		level_panel.visible = not analysis_mode
	if is_instance_valid(bottom_panel):
		bottom_panel.visible = not analysis_mode
	if is_instance_valid(analysis_tools_panel):
		analysis_tools_panel.visible = analysis_mode

func _return_to_map() -> void:
	analysis_mode = false
	selected_cave = -1
	selected_cave_focus = Vector2.ZERO
	selected_route.clear()
	zoom_level = 0.62
	camera_offset = -((unit_position - Generator.WORLD_RECT.size * 0.5) * zoom_level)
	_update_scan_availability()
	_update_view_mode_ui()
	queue_redraw()

func _nearest_visible_preview_cell(cave_id: int, point: Vector2) -> Vector2:
	var cave: Dictionary = world.caves[cave_id]
	var terrain: PackedByteArray = world.terrain_mask
	var revealed: PackedByteArray = revealed_mask
	var grid_size: Vector2i = world.grid_size
	var radius: float = cave.radius * 1.5
	var min_x := maxi(0, floori((cave.position.x - radius) / world.cell_size))
	var max_x := mini(grid_size.x - 1, ceili((cave.position.x + radius) / world.cell_size))
	var min_y := maxi(0, floori((cave.position.y - radius) / world.cell_size))
	var max_y := mini(grid_size.y - 1, ceili((cave.position.y + radius) / world.cell_size))
	var nearest := Vector2(-1.0, -1.0)
	var nearest_distance := INF
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var index := y * grid_size.x + x
			if terrain[index] == 0 or revealed[index] == 0:
				continue
			var cell_center := Vector2((float(x) + 0.5) * world.cell_size, (float(y) + 0.5) * world.cell_size)
			if not Geometry2D.is_point_in_polygon(cell_center - cave.position, cave.contour):
				continue
			var candidate_distance := point.distance_squared_to(cell_center)
			if candidate_distance < nearest_distance:
				nearest_distance = candidate_distance
				nearest = cell_center
	return nearest

func _find_path(from: Vector2, to: Vector2) -> Array[Vector2]:
	var path: Array[Vector2] = []
	var grid_size: Vector2i = world.grid_size
	var cell_size: float = world.cell_size
	var mask: PackedByteArray = world.walkable_mask
	var start := _nearest_walkable_cell(Vector2i(floori(from.x / cell_size), floori(from.y / cell_size)), 3)
	var goal := _nearest_walkable_cell(Vector2i(floori(to.x / cell_size), floori(to.y / cell_size)), 0)
	if start.x < 0 or goal.x < 0:
		return path
	var start_index := start.y * grid_size.x + start.x
	var goal_index := goal.y * grid_size.x + goal.x
	var previous := PackedInt32Array()
	previous.resize(grid_size.x * grid_size.y)
	previous.fill(-2)
	previous[start_index] = -1
	var queue: Array[int] = [start_index]
	var queue_head := 0
	var directions: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]
	while queue_head < queue.size() and previous[goal_index] == -2:
		var current: int = queue[queue_head]
		queue_head += 1
		var cell := Vector2i(current % grid_size.x, current / grid_size.x)
		for direction in directions:
			var next := cell + direction
			if next.x < 0 or next.x >= grid_size.x or next.y < 0 or next.y >= grid_size.y:
				continue
			var next_index := next.y * grid_size.x + next.x
			if mask[next_index] == 0 or (not dev_mode and revealed_mask[next_index] == 0) or previous[next_index] != -2:
				continue
			previous[next_index] = current
			queue.append(next_index)
	if previous[goal_index] == -2:
		return path
	var reversed_path: Array[int] = []
	var cursor := goal_index
	while cursor != -1:
		reversed_path.append(cursor)
		cursor = previous[cursor]
	reversed_path.reverse()
	for index in range(1, reversed_path.size()):
		var cell_index: int = reversed_path[index]
		path.append(Vector2((float(cell_index % grid_size.x) + 0.5) * cell_size, (float(cell_index / grid_size.x) + 0.5) * cell_size))
	return path

func _resolve_order_target(point: Vector2) -> Dictionary:
	# A click inside a revealed neighboring room is a room movement order,
	# even when the small room lies close to its connecting mouth.
	var containing_cave := -1
	for cave in world.caves:
		if Geometry2D.is_point_in_polygon(point - cave.position, cave.contour):
			containing_cave = cave.id
			break
	if containing_cave >= 0 and containing_cave != current_cave_id:
		var reachable_room := _reachable_revealed_cells(unit_position)
		var room_target := _nearest_revealed_walkable_in_cave(containing_cave, point, reachable_room)
		if room_target.x >= 0:
			return {"position": Vector2((float(room_target.x) + 0.5) * world.cell_size, (float(room_target.y) + 0.5) * world.cell_size), "cave_id": -1}
	var exit_cave := _known_exit_cave(point)
	if exit_cave >= 0:
		var reachable_for_exit := _reachable_revealed_cells(unit_position)
		var exit_target := _nearest_revealed_walkable_in_cave(exit_cave, point, reachable_for_exit)
		if exit_target.x >= 0:
			return {"position": Vector2((float(exit_target.x) + 0.5) * world.cell_size, (float(exit_target.y) + 0.5) * world.cell_size), "cave_id": exit_cave}
		return {}
	var reachable := _reachable_revealed_cells(unit_position)
	if containing_cave >= 0:
		var cave_target := _nearest_revealed_walkable_in_cave(containing_cave, point, reachable)
		if cave_target.x >= 0:
			return {"position": Vector2((float(cave_target.x) + 0.5) * world.cell_size, (float(cave_target.y) + 0.5) * world.cell_size), "cave_id": -1}
	if dev_mode or _is_revealed(point):
		var origin := Vector2i(floori(point.x / world.cell_size), floori(point.y / world.cell_size))
		var target_cell := _nearest_reachable_cell(origin, 3, reachable)
		if target_cell.x >= 0:
			return {"position": Vector2((float(target_cell.x) + 0.5) * world.cell_size, (float(target_cell.y) + 0.5) * world.cell_size), "cave_id": -1}
	return {}

func _nearest_revealed_walkable_in_cave(cave_id: int, point: Vector2, reachable: PackedByteArray) -> Vector2i:
	var cave: Dictionary = world.caves[cave_id]
	var grid_size: Vector2i = world.grid_size
	var walkable: PackedByteArray = world.walkable_mask
	var radius: float = cave.radius * 1.5
	var min_x := maxi(0, floori((cave.position.x - radius) / world.cell_size))
	var max_x := mini(grid_size.x - 1, ceili((cave.position.x + radius) / world.cell_size))
	var min_y := maxi(0, floori((cave.position.y - radius) / world.cell_size))
	var max_y := mini(grid_size.y - 1, ceili((cave.position.y + radius) / world.cell_size))
	var best := Vector2i(-1, -1)
	var best_distance := INF
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var index := y * grid_size.x + x
			if walkable[index] == 0 or reachable[index] == 0:
				continue
			var cell_center := Vector2((float(x) + 0.5) * world.cell_size, (float(y) + 0.5) * world.cell_size)
			if not Geometry2D.is_point_in_polygon(cell_center - cave.position, cave.contour):
				continue
			var distance: float = point.distance_squared_to(cell_center)
			if distance < best_distance:
				best_distance = distance
				best = Vector2i(x, y)
	return best

func _reachable_revealed_cells(from: Vector2) -> PackedByteArray:
	var grid_size: Vector2i = world.grid_size
	var walkable: PackedByteArray = world.walkable_mask
	var reachable := PackedByteArray()
	reachable.resize(grid_size.x * grid_size.y)
	reachable.fill(0)
	var start := _nearest_walkable_cell(Vector2i(floori(from.x / world.cell_size), floori(from.y / world.cell_size)), 3)
	if start.x < 0:
		return reachable
	var start_index := start.y * grid_size.x + start.x
	reachable[start_index] = 1
	var queue: Array[int] = [start_index]
	var head := 0
	var directions: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]
	while head < queue.size():
		var current: int = queue[head]
		head += 1
		var cell := Vector2i(current % grid_size.x, current / grid_size.x)
		for direction in directions:
			var next := cell + direction
			if next.x < 0 or next.x >= grid_size.x or next.y < 0 or next.y >= grid_size.y:
				continue
			var next_index := next.y * grid_size.x + next.x
			if reachable[next_index] == 1 or walkable[next_index] == 0 or (not dev_mode and revealed_mask[next_index] == 0):
				continue
			reachable[next_index] = 1
			queue.append(next_index)
	return reachable

func _nearest_reachable_cell(origin: Vector2i, search_radius: int, reachable: PackedByteArray) -> Vector2i:
	var grid_size: Vector2i = world.grid_size
	for radius in range(search_radius + 1):
		for y in range(origin.y - radius, origin.y + radius + 1):
			for x in range(origin.x - radius, origin.x + radius + 1):
				if x < 0 or x >= grid_size.x or y < 0 or y >= grid_size.y:
					continue
				if maxi(absi(x - origin.x), absi(y - origin.y)) != radius:
					continue
				var index := y * grid_size.x + x
				if reachable[index] == 1:
					return Vector2i(x, y)
	return Vector2i(-1, -1)

func _nearest_walkable_cell(origin: Vector2i, search_radius: int) -> Vector2i:
	var grid_size: Vector2i = world.grid_size
	var mask: PackedByteArray = world.walkable_mask
	for radius in range(search_radius + 1):
		for y in range(origin.y - radius, origin.y + radius + 1):
			for x in range(origin.x - radius, origin.x + radius + 1):
				if x < 0 or x >= grid_size.x or y < 0 or y >= grid_size.y:
					continue
				if maxi(absi(x - origin.x), absi(y - origin.y)) != radius:
					continue
				if mask[y * grid_size.x + x] == 1:
					return Vector2i(x, y)
	return Vector2i(-1, -1)

func _reveal_around(center: Vector2, radius_cells: int) -> void:
	var size: Vector2i = world.grid_size
	var terrain: PackedByteArray = world.terrain_mask
	var cell_size: float = world.cell_size
	var center_cell := Vector2i(floori(center.x / cell_size), floori(center.y / cell_size))
	var radius_squared := radius_cells * radius_cells
	for y in range(maxi(0, center_cell.y - radius_cells), mini(size.y, center_cell.y + radius_cells + 1)):
		for x in range(maxi(0, center_cell.x - radius_cells), mini(size.x, center_cell.x + radius_cells + 1)):
			var offset := Vector2i(x, y) - center_cell
			var index := y * size.x + x
			if offset.length_squared() <= radius_squared and terrain[index] == 1 and _has_line_of_sight(center_cell, Vector2i(x, y)):
				revealed_mask[index] = 1
	last_revealed_cell = center_cell
	queue_redraw()

func _has_line_of_sight(start: Vector2i, finish: Vector2i) -> bool:
	if start == finish:
		return true
	var size: Vector2i = world.grid_size
	var walkable: PackedByteArray = world.walkable_mask
	var terrain: PackedByteArray = world.terrain_mask
	var distance := maxi(absi(finish.x - start.x), absi(finish.y - start.y))
	for step in range(1, distance + 1):
		var amount := float(step) / float(distance)
		var cell := Vector2i(roundi(lerpf(float(start.x), float(finish.x), amount)), roundi(lerpf(float(start.y), float(finish.y), amount)))
		if cell == finish:
			return true
		if cell.x < 0 or cell.x >= size.x or cell.y < 0 or cell.y >= size.y:
			return false
		if walkable[cell.y * size.x + cell.x] == 0:
			return false
	return true

func _is_revealed(point: Vector2) -> bool:
	var size: Vector2i = world.grid_size
	var x := floori(point.x / world.cell_size)
	var y := floori(point.y / world.cell_size)
	if x < 0 or x >= size.x or y < 0 or y >= size.y:
		return false
	return revealed_mask[y * size.x + x] == 1

func _scan_local() -> void:
	if world.is_empty() or selected_cave != current_cave_id:
		return
	_scan_current_cave()
	if is_instance_valid(status_label):
		status_label.text = "ESCÀNER SALA %02d · SORTIDES %d" % [current_cave_id + 1, _exit_count(current_cave_id)]
	_update_map_stats()

func _scan_current_cave() -> void:
	if current_cave_id < 0 or current_cave_id >= world.caves.size():
		return
	var cave: Dictionary = world.caves[current_cave_id]
	explored_caves[current_cave_id] = true
	var contour: PackedVector2Array = cave.contour
	var center: Vector2 = cave.position
	var grid_size: Vector2i = world.grid_size
	var terrain: PackedByteArray = world.terrain_mask
	var center_cell := Vector2i(floori(unit_position.x / world.cell_size), floori(unit_position.y / world.cell_size))
	var protected_center_cells: Dictionary = {}
	for other_cave in world.caves:
		if other_cave.id != current_cave_id and not explored_caves.has(other_cave.id):
			protected_center_cells[Vector2i(floori(other_cave.position.x / world.cell_size), floori(other_cave.position.y / world.cell_size))] = true
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var index := y * grid_size.x + x
			if terrain[index] == 0:
				continue
			var cell_center := Vector2((float(x) + 0.5) * world.cell_size, (float(y) + 0.5) * world.cell_size)
			if not protected_center_cells.has(Vector2i(x, y)) and Geometry2D.is_point_in_polygon(cell_center - center, contour) and _has_line_of_sight(center_cell, Vector2i(x, y)):
				revealed_mask[index] = 1
	for corridor in world.corridors:
		if corridor.a == current_cave_id or corridor.b == current_cave_id:
			discovered_exits[_exit_key(current_cave_id, corridor.id)] = true
			_reveal_corridor_access(corridor)
	last_revealed_cell = Vector2i(floori(unit_position.x / world.cell_size), floori(unit_position.y / world.cell_size))
	_update_map_stats()
	queue_redraw()

func _update_current_cave() -> void:
	for cave in world.caves:
		if Geometry2D.is_point_in_polygon(unit_position - cave.position, cave.contour):
			if current_cave_id != cave.id:
				current_cave_id = cave.id
				if is_instance_valid(status_label):
					status_label.text = "EXPLORANT LA SALA %02d" % (current_cave_id + 1)
				_update_map_stats()
				_update_scan_availability()
			return

func _discover_exit_near_unit() -> void:
	if current_cave_id < 0 or current_cave_id >= world.caves.size():
		return
	var newly_discovered := false
	for corridor in world.corridors:
		var exit_position := Vector2.ZERO
		if corridor.a == current_cave_id:
			exit_position = corridor.exit_a
		elif corridor.b == current_cave_id:
			exit_position = corridor.exit_b
		else:
			continue
		var key := _exit_key(current_cave_id, corridor.id)
		if discovered_exits.has(key) or unit_position.distance_to(exit_position) > maxf(26.0, float(corridor.width) * 0.5):
			continue
		discovered_exits[key] = true
		_reveal_corridor_access(corridor)
		newly_discovered = true
	if newly_discovered:
		if is_instance_valid(status_label):
			status_label.text = "SORTIDA LOCALITZADA · SALA %02d" % (current_cave_id + 1)
		_update_map_stats()
		queue_redraw()

func _known_exit_cave(target: Vector2) -> int:
	for exit_info in _visible_exits_for_cave(current_cave_id):
		var mouth_center: Vector2 = exit_info.position + exit_info.direction * 12.0
		if target.distance_to(mouth_center) > 42.0 / zoom_level:
			continue
		for corridor in world.corridors:
			if corridor.id == exit_info.corridor_id:
				return corridor.b if corridor.a == current_cave_id else corridor.a
	return -1

func _known_exit_corridor(target: Vector2) -> int:
	for exit_info in _visible_exits_for_cave(current_cave_id):
		var mouth_center: Vector2 = exit_info.position + exit_info.direction * 12.0
		if target.distance_to(mouth_center) <= 42.0 / zoom_level:
			return exit_info.corridor_id
	return -1

func _arrival_point(cave_id: int, corridor_id: int = -1) -> Vector2:
	for corridor in world.corridors:
		if corridor_id >= 0 and corridor.id != corridor_id:
			continue
		var origin := Vector2.ZERO
		if corridor.a == cave_id:
			origin = corridor.exit_a - corridor.direction_a * 16.0
		elif corridor.b == cave_id:
			origin = corridor.exit_b - corridor.direction_b * 16.0
		else:
			continue
		var origin_cell := Vector2i(floori(origin.x / world.cell_size), floori(origin.y / world.cell_size))
		var grid_size: Vector2i = world.grid_size
		var walkable: PackedByteArray = world.walkable_mask
		var cave: Dictionary = world.caves[cave_id]
		for radius in range(5):
			for y in range(origin_cell.y - radius, origin_cell.y + radius + 1):
				for x in range(origin_cell.x - radius, origin_cell.x + radius + 1):
					if x < 0 or x >= grid_size.x or y < 0 or y >= grid_size.y or maxi(absi(x - origin_cell.x), absi(y - origin_cell.y)) != radius:
						continue
					var index := y * grid_size.x + x
					var cell_center := Vector2((float(x) + 0.5) * world.cell_size, (float(y) + 0.5) * world.cell_size)
					if walkable[index] == 1 and Geometry2D.is_point_in_polygon(cell_center - cave.position, cave.contour):
						return cell_center
	return world.caves[cave_id].position

func _reveal_corridor_access(corridor: Dictionary) -> void:
	var points: PackedVector2Array = corridor.points
	var radius_cells := int(ceil(float(corridor.width) * 0.5 / world.cell_size))
	var size: Vector2i = world.grid_size
	var walkable: PackedByteArray = world.walkable_mask
	var terrain: PackedByteArray = world.terrain_mask
	for segment in range(points.size() - 1):
		var start: Vector2 = points[segment]
		var finish: Vector2 = points[segment + 1]
		var steps := maxi(1, ceili(start.distance_to(finish) / (world.cell_size * 0.45)))
		for step in range(steps + 1):
			var point := start.lerp(finish, float(step) / float(steps))
			var cell := Vector2i(floori(point.x / world.cell_size), floori(point.y / world.cell_size))
			for oy in range(-radius_cells, radius_cells + 1):
				for ox in range(-radius_cells, radius_cells + 1):
					if Vector2(ox, oy).length() > float(radius_cells) + 0.15:
						continue
					var x := cell.x + ox
					var y := cell.y + oy
					if x >= 0 and x < size.x and y >= 0 and y < size.y:
						var index := y * size.x + x
						var cell_center := Vector2((float(x) + 0.5) * world.cell_size, (float(y) + 0.5) * world.cell_size)
						var inside_other_cave := false
						for cave in world.caves:
							if cave.id != current_cave_id and Geometry2D.is_point_in_polygon(cell_center - cave.position, cave.contour):
								inside_other_cave = true
								break
						# Keep the discovered mouth visible through the current room's fog,
						# while preserving unexplored destination rooms.
						if terrain[index] == 1 and not inside_other_cave:
							revealed_mask[index] = 1
	# Reveal a small apron on both sides of the cave threshold so fog-of-war
	# cannot leave square notches where the corridor meets the room wall.
	var exit_position: Vector2 = corridor.exit_a if corridor.a == current_cave_id else corridor.exit_b
	var aperture_radius: float = float(corridor.width) * 0.75 + world.cell_size
	var aperture_min := Vector2i(maxi(0, floori((exit_position.x - aperture_radius) / world.cell_size)), maxi(0, floori((exit_position.y - aperture_radius) / world.cell_size)))
	var aperture_max := Vector2i(mini(size.x - 1, ceili((exit_position.x + aperture_radius) / world.cell_size)), mini(size.y - 1, ceili((exit_position.y + aperture_radius) / world.cell_size)))
	for y in range(aperture_min.y, aperture_max.y + 1):
		for x in range(aperture_min.x, aperture_max.x + 1):
			var index := y * size.x + x
			if terrain[index] == 0:
				continue
			var cell_center := Vector2((float(x) + 0.5) * world.cell_size, (float(y) + 0.5) * world.cell_size)
			if cell_center.distance_to(exit_position) > aperture_radius:
				continue
			var inside_other_cave := false
			for cave in world.caves:
				if cave.id != current_cave_id and Geometry2D.is_point_in_polygon(cell_center - cave.position, cave.contour):
					inside_other_cave = true
					break
			if not inside_other_cave:
				revealed_mask[index] = 1
	var destination: int = corridor.b if corridor.a == current_cave_id else corridor.a
	var arrival := _arrival_point(destination, corridor.id)
	var arrival_cell := Vector2i(floori(arrival.x / world.cell_size), floori(arrival.y / world.cell_size))
	var preview_radius := 4
	for oy in range(-preview_radius, preview_radius + 1):
		for ox in range(-preview_radius, preview_radius + 1):
			var x := arrival_cell.x + ox
			var y := arrival_cell.y + oy
			if x < 0 or x >= size.x or y < 0 or y >= size.y or Vector2(ox, oy).length() > float(preview_radius):
				continue
			var overlaps_unscanned_center := false
			for cave in world.caves:
				if explored_caves.has(cave.id):
					continue
				var center_cell := Vector2i(floori(cave.position.x / world.cell_size), floori(cave.position.y / world.cell_size))
				if Vector2i(x, y) == center_cell:
					overlaps_unscanned_center = true
					break
			if overlaps_unscanned_center:
				continue
			var index := y * size.x + x
			if walkable[index] == 1:
				revealed_mask[index] = 1

func _start_arrival_movement(cave_id: int, arrival: Vector2) -> void:
	var path := _find_path(unit_position, arrival)
	if path.is_empty():
		return
	move_path = path
	selected_route = path.duplicate()
	move_target = path.back()
	moving = true

func _exit_key(cave_id: int, corridor_id: int) -> String:
	return "%d:%d" % [cave_id, corridor_id]

func _should_draw_cave(cave_id: int) -> bool:
	if analysis_mode:
		return cave_id == selected_cave and explored_caves.has(cave_id)
	if dev_mode:
		return true
	return explored_caves.has(cave_id)

func _should_draw_corridor(corridor: Dictionary) -> bool:
	if analysis_mode:
		if corridor.a != selected_cave and corridor.b != selected_cave:
			return false
		return dev_mode or discovered_exits.has(_exit_key(selected_cave, corridor.id))
	if dev_mode:
		return true
	return discovered_exits.has(_exit_key(corridor.a, corridor.id)) or discovered_exits.has(_exit_key(corridor.b, corridor.id))

func _exit_count(cave_id: int) -> int:
	var count := 0
	for corridor in world.corridors:
		if (corridor.a == cave_id or corridor.b == cave_id) and discovered_exits.has(_exit_key(cave_id, corridor.id)):
			count += 1
	return count

func _draw_cave_outline(cave: Dictionary, color: Color, line_width: float) -> void:
	var contour: PackedVector2Array = cave.contour
	var center: Vector2 = cave.position
	var exits := _visible_exits_for_cave(cave.id)
	for index in range(contour.size()):
		var a := center + contour[index]
		var b := center + contour[(index + 1) % contour.size()]
		var edge := b - a
		var edge_length := edge.length()
		if edge_length <= 0.001:
			continue
		var cuts: Array[Vector2] = []
		for exit_info in exits:
			var closest := Geometry2D.get_closest_point_to_segment(exit_info.position, a, b)
			if closest.distance_to(exit_info.position) > float(exit_info.width) * 0.5 + 4.0:
				continue
			var center_t := clampf((closest - a).dot(edge) / edge.length_squared(), 0.0, 1.0)
			var half_gap_t := (float(exit_info.width) * 0.5 + 3.0) / edge_length
			cuts.append(Vector2(maxf(0.0, center_t - half_gap_t), minf(1.0, center_t + half_gap_t)))
		cuts.sort_custom(func(left: Vector2, right: Vector2) -> bool: return left.x < right.x)
		var cursor := 0.0
		for cut in cuts:
			if cut.x > cursor:
				draw_line(_world_to_screen(a.lerp(b, cursor)), _world_to_screen(a.lerp(b, cut.x)), color, line_width, true)
			cursor = maxf(cursor, cut.y)
		if cursor < 1.0:
			draw_line(_world_to_screen(a.lerp(b, cursor)), _world_to_screen(b), color, line_width, true)

func _visible_exits_for_cave(cave_id: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for corridor in world.corridors:
		if corridor.a == cave_id and (dev_mode or discovered_exits.has(_exit_key(cave_id, corridor.id))):
			result.append({"corridor_id": corridor.id, "position": corridor.exit_a, "direction": corridor.direction_a, "width": corridor.width})
		elif corridor.b == cave_id and (dev_mode or discovered_exits.has(_exit_key(cave_id, corridor.id))):
			result.append({"corridor_id": corridor.id, "position": corridor.exit_b, "direction": corridor.direction_b, "width": corridor.width})
	return result

func _draw_cave_previews() -> void:
	var terrain: PackedByteArray = world.terrain_mask
	var revealed: PackedByteArray = revealed_mask
	var grid_size: Vector2i = world.grid_size
	var cell_screen_size: float = world.cell_size * zoom_level
	for cave in world.caves:
		if analysis_mode and cave.id != selected_cave:
			continue
		if _should_draw_cave(cave.id):
			continue
		var radius: float = cave.radius * 1.5
		var min_x := maxi(0, floori((cave.position.x - radius) / world.cell_size))
		var max_x := mini(grid_size.x - 1, ceili((cave.position.x + radius) / world.cell_size))
		var min_y := maxi(0, floori((cave.position.y - radius) / world.cell_size))
		var max_y := mini(grid_size.y - 1, ceili((cave.position.y + radius) / world.cell_size))
		for y in range(min_y, max_y + 1):
			for x in range(min_x, max_x + 1):
				var index := y * grid_size.x + x
				if terrain[index] == 0 or revealed[index] == 0:
					continue
				var cell_center := Vector2((float(x) + 0.5) * world.cell_size, (float(y) + 0.5) * world.cell_size)
				if not Geometry2D.is_point_in_polygon(cell_center - cave.position, cave.contour):
					continue
				var screen_center := _world_to_screen(cell_center)
				var preview_color := Color("15505a") if cave.id == selected_cave else Color("102a38")
				draw_rect(Rect2(screen_center - Vector2.ONE * cell_screen_size * 0.5, Vector2.ONE * cell_screen_size), preview_color)

func _known_exit_target(point: Vector2) -> Vector2:
	var nearest_target := Vector2(-1.0, -1.0)
	var nearest_distance := 42.0 / zoom_level
	for exit_info in _visible_exits_for_cave(current_cave_id):
		var mouth_center: Vector2 = exit_info.position + exit_info.direction * 12.0
		var distance: float = point.distance_to(mouth_center)
		if distance < nearest_distance:
			nearest_distance = distance
			var cell_size: float = world.cell_size
			var preferred: Vector2 = exit_info.position - exit_info.direction * 12.0
			var origin := Vector2i(floori(preferred.x / cell_size), floori(preferred.y / cell_size))
			var best_cell := Vector2i(-1, -1)
			var best_cell_distance := INF
			for radius in range(4):
				for y in range(origin.y - radius, origin.y + radius + 1):
					for x in range(origin.x - radius, origin.x + radius + 1):
						if maxi(absi(x - origin.x), absi(y - origin.y)) != radius:
							continue
						var cell := Vector2i(x, y)
						var candidate := Vector2((float(x) + 0.5) * cell_size, (float(y) + 0.5) * cell_size)
						if not _is_revealed(candidate):
							continue
						var nearest_walkable: Vector2i = _nearest_walkable_cell(cell, 0)
						if nearest_walkable.x < 0:
							continue
						var candidate_distance: float = candidate.distance_squared_to(preferred)
						if candidate_distance < best_cell_distance:
							best_cell_distance = candidate_distance
							best_cell = nearest_walkable
				if best_cell.x >= 0:
					break
			if best_cell.x >= 0:
				nearest_target = Vector2((float(best_cell.x) + 0.5) * cell_size, (float(best_cell.y) + 0.5) * cell_size)
	return nearest_target

func _revealed_count() -> int:
	var count := 0
	for value in revealed_mask:
		if value == 1:
			count += 1
	return count

func _draw_unknown_overlay() -> void:
	var grid_size: Vector2i = world.grid_size
	var terrain: PackedByteArray = world.terrain_mask
	var cell_size: float = world.cell_size
	for y in range(grid_size.y):
		var run_start := -1
		for x in range(grid_size.x + 1):
			var unknown := false
			if x < grid_size.x:
				var index := y * grid_size.x + x
				unknown = terrain[index] == 1 and revealed_mask[index] == 0
			if unknown and run_start < 0:
				run_start = x
			elif not unknown and run_start >= 0:
				var world_start := Vector2(float(run_start) * cell_size, float(y) * cell_size)
				var world_end := Vector2(float(x) * cell_size, float(y + 1) * cell_size)
				var screen_start := _world_to_screen(world_start)
				var screen_end := _world_to_screen(world_end)
				draw_rect(Rect2(screen_start, screen_end - screen_start), Color("03080e"))
				run_start = -1

func _draw_obstacle(obstacle: Dictionary) -> void:
	var center: Vector2 = _world_to_screen(obstacle.position)
	var radius: float = obstacle.radius * zoom_level
	draw_circle(center + Vector2(2, 3) * zoom_level, radius, Color("020509", 0.8))
	var polygon := PackedVector2Array()
	for i in range(7):
		var angle := TAU * float(i) / 7.0
		var scale := 0.78 + 0.2 * float((i * 3 + obstacle.id) % 5) / 4.0
		polygon.append(center + Vector2(cos(angle), sin(angle)) * radius * scale)
	draw_colored_polygon(polygon, Color("647b7c"))
	draw_polyline(PackedVector2Array([polygon[0], polygon[1], polygon[2]]), Color("a2b5aa"), 1.4)

func _point_inside_selected_cave(point: Vector2) -> bool:
	if selected_cave < 0 or selected_cave >= world.caves.size():
		return false
	var cave: Dictionary = world.caves[selected_cave]
	return Geometry2D.is_point_in_polygon(point - cave.position, cave.contour)

func _route_is_inside_selected_cave() -> bool:
	if not _point_inside_selected_cave(unit_position):
		return false
	for point in selected_route:
		if not _point_inside_selected_cave(point):
			return false
	return true

func _over_ui(point: Vector2) -> bool:
	if not is_instance_valid(ui_root):
		return false
	for child in ui_root.get_children():
		if child is Control and child.get_global_rect().has_point(point):
			return true
	return false

func _view_rect() -> Rect2:
	var viewport_size := Vector2(1440, 900)
	if is_inside_tree():
		viewport_size = get_viewport_rect().size
	if analysis_mode:
		return Rect2(Vector2.ZERO, viewport_size)
	return Rect2(306, 0, viewport_size.x - 606, viewport_size.y)

func _world_to_screen(point: Vector2) -> Vector2:
	var view := _view_rect()
	if analysis_mode and selected_cave >= 0 and selected_cave < world.caves.size():
		var cave: Dictionary = world.caves[selected_cave]
		return view.get_center() + camera_offset + _iso_project_relative(point, cave.position) * zoom_level
	return view.get_center() + camera_offset + (point - Generator.WORLD_RECT.size * 0.5) * zoom_level

func _screen_to_world(point: Vector2) -> Vector2:
	var view := _view_rect()
	if analysis_mode and selected_cave >= 0 and selected_cave < world.caves.size():
		var cave: Dictionary = world.caves[selected_cave]
		var iso_point := (point - view.get_center() - camera_offset) / zoom_level / ISO_AXIS_SCALE
		var diagonal_sum: float = iso_point.y / ISO_VERTICAL_RATIO
		var world_x: float = (diagonal_sum + iso_point.x) * 0.5
		var world_y: float = (diagonal_sum - iso_point.x) * 0.5
		return cave.position + Vector2(world_x, world_y)
	return Generator.WORLD_RECT.size * 0.5 + (point - view.get_center() - camera_offset) / zoom_level

func _iso_project_relative(point: Vector2, origin: Vector2) -> Vector2:
	var delta := point - origin
	return Vector2(delta.x - delta.y, (delta.x + delta.y) * ISO_VERTICAL_RATIO) * ISO_AXIS_SCALE
