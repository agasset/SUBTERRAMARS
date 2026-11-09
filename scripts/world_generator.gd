extends RefCounted
class_name WorldGenerator

const CAVE_COUNT := 20
const WORLD_RECT := Rect2(0, 0, 2200, 1500)
const MIN_DISTANCE := 205.0
const CELL_SIZE := 10.0
const GRID_SIZE := Vector2i(220, 150)
const GENERATOR_VERSION := "p0b-2"

static func _seed_for(seed_value: int, domain: String, index: int) -> int:
	var text := "%d|%s|%d|%s" % [seed_value, GENERATOR_VERSION, index, domain]
	var hash_value: int = hash(text)
	return hash_value & 0x7fffffff

static func generate(seed_value: int) -> Dictionary:
	var caves: Array[Dictionary] = []
	var rng := RandomNumberGenerator.new()
	rng.seed = _seed_for(seed_value, "topology", 0)
	var points: Array[Vector2] = []
	var attempts := 0
	while points.size() < CAVE_COUNT and attempts < 12000:
		attempts += 1
		var point := Vector2(rng.randf_range(100, 2100), rng.randf_range(100, 1400))
		var valid := true
		for other in points:
			if point.distance_to(other) < MIN_DISTANCE:
				valid = false
				break
		if valid:
			points.append(point)
	if points.size() < CAVE_COUNT:
		return _fallback(seed_value)

	# Start at the western edge, then form a deterministic minimum-distance tree.
	var root := 0
	for i in range(points.size()):
		if points[i].x < points[root].x:
			root = i
	var connected := {root: true}
	var edges: Array[Vector2i] = []
	while connected.size() < points.size():
		var best_from := -1
		var best_to := -1
		var best_distance := INF
		for from_id in connected:
			for to_id in range(points.size()):
				if connected.has(to_id):
					continue
				var distance := points[from_id].distance_squared_to(points[to_id])
				if distance < best_distance:
					best_distance = distance
					best_from = from_id
					best_to = to_id
		edges.append(Vector2i(best_from, best_to))
		connected[best_to] = true
	# Add a few short optional loops.
	for i in range(points.size()):
		var nearest := -1
		var nearest_d := INF
		for j in range(points.size()):
			if i == j or _has_edge(edges, i, j):
				continue
			var d := points[i].distance_squared_to(points[j])
			if d < nearest_d:
				nearest_d = d
				nearest = j
		if nearest >= 0 and nearest_d < 520.0 * 520.0 and i < nearest:
			edges.append(Vector2i(i, nearest))

	for i in range(points.size()):
		var geometry_rng := RandomNumberGenerator.new()
		geometry_rng.seed = _seed_for(seed_value, "cave_geometry", i)
		var size_class := i % 3
		var radius: float = [52.0, 75.0, 105.0][size_class] * geometry_rng.randf_range(0.82, 1.18)
		var contour := PackedVector2Array()
		var count := 12
		for p in range(count):
			var angle := TAU * float(p) / count
			var r: float = radius * geometry_rng.randf_range(0.78, 1.22)
			contour.append(Vector2(cos(angle) * r * geometry_rng.randf_range(0.85, 1.2), sin(angle) * r * geometry_rng.randf_range(0.72, 1.12)))
		caves.append({"id": i, "position": points[i], "radius": radius, "contour": contour, "size_class": size_class})

	var corridors: Array[Dictionary] = []
	for edge_index in range(edges.size()):
		var edge: Vector2i = edges[edge_index]
		corridors.append(_make_corridor(seed_value, edge_index, edge.x, edge.y, caves))
	var obstacles := _build_obstacles(seed_value, caves, corridors)
	var masks := _build_masks(caves, corridors, obstacles)
	return {"seed": seed_value, "version": GENERATOR_VERSION, "caves": caves, "corridors": corridors, "obstacles": obstacles, "entry": root, "attempts": attempts, "fallback": false, "cell_size": CELL_SIZE, "grid_size": GRID_SIZE, "terrain_mask": masks.terrain, "walkable_mask": masks.walkable}

static func _has_edge(edges: Array[Vector2i], a: int, b: int) -> bool:
	for edge in edges:
		if (edge.x == a and edge.y == b) or (edge.x == b and edge.y == a):
			return true
	return false

static func _fallback(seed_value: int) -> Dictionary:
	var caves: Array[Dictionary] = []
	var edges: Array[Dictionary] = []
	for i in range(CAVE_COUNT):
		var p := Vector2(150 + float(i % 5) * 430, 180 + float(i / 5) * 350)
		var contour := PackedVector2Array()
		for j in range(12):
			var angle := TAU * float(j) / 12.0
			contour.append(Vector2(cos(angle) * 70, sin(angle) * 55))
		caves.append({"id": i, "position": p, "radius": 65.0, "contour": contour, "size_class": 1})
		if i > 0:
			var previous := i - 1 if i % 5 != 0 else i - 5
			edges.append(_make_corridor(seed_value, edges.size(), previous, i, caves))
	var obstacles := _build_obstacles(seed_value, caves, edges)
	var masks := _build_masks(caves, edges, obstacles)
	return {"seed": seed_value, "version": GENERATOR_VERSION, "caves": caves, "corridors": edges, "obstacles": obstacles, "entry": 0, "attempts": 12000, "fallback": true, "cell_size": CELL_SIZE, "grid_size": GRID_SIZE, "terrain_mask": masks.terrain, "walkable_mask": masks.walkable}

static func _make_corridor(seed_value: int, corridor_id: int, cave_a_id: int, cave_b_id: int, caves: Array[Dictionary]) -> Dictionary:
	var cave_a: Dictionary = caves[cave_a_id]
	var cave_b: Dictionary = caves[cave_b_id]
	var start: Vector2 = cave_a.position
	var finish: Vector2 = cave_b.position
	var travel := finish - start
	var perpendicular := travel.orthogonal().normalized()
	var rng := RandomNumberGenerator.new()
	rng.seed = _seed_for(seed_value, "corridor_geometry", corridor_id)
	var bend: float = clampf(travel.length() * rng.randf_range(0.10, 0.22), 35.0, 180.0) * (-1.0 if rng.randf() < 0.5 else 1.0)
	var secondary_bend: float = rng.randf_range(-55.0, 55.0)
	var margin := 52.0
	var control_a := start + travel * 0.28 + perpendicular * bend
	var control_b := start + travel * 0.72 + perpendicular * (bend * 0.62 + secondary_bend)
	control_a.x = clampf(control_a.x, margin, WORLD_RECT.size.x - margin)
	control_a.y = clampf(control_a.y, margin, WORLD_RECT.size.y - margin)
	control_b.x = clampf(control_b.x, margin, WORLD_RECT.size.x - margin)
	control_b.y = clampf(control_b.y, margin, WORLD_RECT.size.y - margin)
	var points := PackedVector2Array()
	var steps := 10
	for step in range(steps + 1):
		var t := float(step) / float(steps)
		var inverse := 1.0 - t
		var point := inverse * inverse * inverse * start + 3.0 * inverse * inverse * t * control_a + 3.0 * inverse * t * t * control_b + t * t * t * finish
		points.append(point)
	var direction_a: Vector2 = (points[1] - points[0]).normalized()
	var direction_b: Vector2 = (points[points.size() - 2] - points[points.size() - 1]).normalized()
	var size_bias := (float(cave_a.size_class) + float(cave_b.size_class)) * 0.5
	var width: float = rng.randf_range(24.0 + size_bias * 3.0, 36.0 + size_bias * 6.0)
	return {"id": corridor_id, "a": cave_a_id, "b": cave_b_id, "points": points, "exit_a": _exit_position(cave_a, direction_a), "exit_b": _exit_position(cave_b, direction_b), "direction_a": direction_a, "direction_b": direction_b, "width": width}

static func _build_obstacles(seed_value: int, caves: Array[Dictionary], corridors: Array[Dictionary]) -> Array[Dictionary]:
	var obstacles: Array[Dictionary] = []
	for cave in caves:
		var rng := RandomNumberGenerator.new()
		rng.seed = _seed_for(seed_value, "obstacle", cave.id)
		var center: Vector2 = cave.position
		var contour: PackedVector2Array = cave.contour
		var placed := false
		for attempt in range(16):
			var angle := rng.randf_range(0.0, TAU)
			var distance: float = cave.radius * rng.randf_range(0.34, 0.48)
			var candidate := center + Vector2(cos(angle), sin(angle)) * distance
			if not Geometry2D.is_point_in_polygon(candidate - center, contour):
				continue
			var clear := true
			for corridor in corridors:
				var points: PackedVector2Array = corridor.points
				for segment in range(points.size() - 1):
					if Geometry2D.get_closest_point_to_segment(candidate, points[segment], points[segment + 1]).distance_to(candidate) < 31.0:
						clear = false
						break
				if not clear:
					break
			if clear:
				obstacles.append({"id": obstacles.size(), "cave_id": cave.id, "position": candidate, "radius": 12.0 + rng.randf_range(0.0, 5.0)})
				placed = true
				break
		if not placed:
			continue
	return obstacles

static func _exit_position(cave: Dictionary, direction: Vector2) -> Vector2:
	var center: Vector2 = cave.position
	var contour: PackedVector2Array = cave.contour
	var last_inside := center
	var max_distance: float = cave.radius * 1.6
	var steps := ceili(max_distance * 2.0)
	for step in range(1, steps + 1):
		var candidate := center + direction * (float(step) * 0.5)
		if not Geometry2D.is_point_in_polygon(candidate - center, contour):
			break
		last_inside = candidate
	return last_inside

static func _build_masks(caves: Array[Dictionary], corridors: Array[Dictionary], obstacles: Array[Dictionary]) -> Dictionary:
	var mask := PackedByteArray()
	mask.resize(GRID_SIZE.x * GRID_SIZE.y)
	mask.fill(0)
	for cave in caves:
		var center: Vector2 = cave.position
		var contour: PackedVector2Array = cave.contour
		var radius: float = cave.radius * 1.35
		var min_x := maxi(0, floori((center.x - radius) / CELL_SIZE))
		var max_x := mini(GRID_SIZE.x - 1, ceili((center.x + radius) / CELL_SIZE))
		var min_y := maxi(0, floori((center.y - radius) / CELL_SIZE))
		var max_y := mini(GRID_SIZE.y - 1, ceili((center.y + radius) / CELL_SIZE))
		for y in range(min_y, max_y + 1):
			for x in range(min_x, max_x + 1):
				var point := Vector2((float(x) + 0.5) * CELL_SIZE, (float(y) + 0.5) * CELL_SIZE) - center
				if Geometry2D.is_point_in_polygon(point, contour):
					mask[y * GRID_SIZE.x + x] = 1
	for corridor in corridors:
		var points: PackedVector2Array = corridor.points
		var radius_cells := int(ceil(float(corridor.width) * 0.5 / CELL_SIZE))
		for segment in range(points.size() - 1):
			var start: Vector2 = points[segment]
			var finish: Vector2 = points[segment + 1]
			var steps := maxi(1, ceili(start.distance_to(finish) / (CELL_SIZE * 0.45)))
			for step in range(steps + 1):
				var world_point := start.lerp(finish, float(step) / float(steps))
				var cell := Vector2i(floori(world_point.x / CELL_SIZE), floori(world_point.y / CELL_SIZE))
				for oy in range(-radius_cells, radius_cells + 1):
					for ox in range(-radius_cells, radius_cells + 1):
						if Vector2(ox, oy).length() > float(radius_cells) + 0.15:
							continue
						var x := cell.x + ox
						var y := cell.y + oy
						if x >= 0 and x < GRID_SIZE.x and y >= 0 and y < GRID_SIZE.y:
							mask[y * GRID_SIZE.x + x] = 1
	_prune_isolated_cells(mask)
	var terrain_mask := mask.duplicate()
	var obstacle_index := 0
	while obstacle_index < obstacles.size():
		var obstacle: Dictionary = obstacles[obstacle_index]
		var center: Vector2 = obstacle.position
		var radius: float = obstacle.radius
		var min_x := maxi(0, floori((center.x - radius) / CELL_SIZE))
		var max_x := mini(GRID_SIZE.x - 1, ceili((center.x + radius) / CELL_SIZE))
		var min_y := maxi(0, floori((center.y - radius) / CELL_SIZE))
		var max_y := mini(GRID_SIZE.y - 1, ceili((center.y + radius) / CELL_SIZE))
		var changed_cells: Array[int] = []
		for y in range(min_y, max_y + 1):
			for x in range(min_x, max_x + 1):
				var point := Vector2((float(x) + 0.5) * CELL_SIZE, (float(y) + 0.5) * CELL_SIZE)
				var cell_index := y * GRID_SIZE.x + x
				if point.distance_to(center) <= radius and mask[cell_index] == 1:
					mask[cell_index] = 0
					changed_cells.append(cell_index)
		if not _mask_is_connected(mask):
			for cell_index in changed_cells:
				mask[cell_index] = 1
			obstacles.remove_at(obstacle_index)
		else:
			obstacle_index += 1
	return {"terrain": terrain_mask, "walkable": mask}

static func _prune_isolated_cells(mask: PackedByteArray) -> void:
	var isolated: Array[int] = []
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var index := y * GRID_SIZE.x + x
			if mask[index] == 0:
				continue
			var neighbors := 0
			if x > 0 and mask[index - 1] == 1: neighbors += 1
			if x + 1 < GRID_SIZE.x and mask[index + 1] == 1: neighbors += 1
			if y > 0 and mask[index - GRID_SIZE.x] == 1: neighbors += 1
			if y + 1 < GRID_SIZE.y and mask[index + GRID_SIZE.x] == 1: neighbors += 1
			if neighbors == 0:
				isolated.append(index)
	for index in isolated:
		mask[index] = 0

static func _mask_is_connected(mask: PackedByteArray) -> bool:
	var start := -1
	var walkable_count := 0
	for index in range(mask.size()):
		if mask[index] == 1:
			walkable_count += 1
			if start < 0:
				start = index
	if start < 0:
		return false
	var visited := PackedByteArray()
	visited.resize(mask.size())
	visited.fill(0)
	visited[start] = 1
	var queue: Array[int] = [start]
	var head := 0
	var directions: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]
	while head < queue.size():
		var current: int = queue[head]
		head += 1
		var cell := Vector2i(current % GRID_SIZE.x, current / GRID_SIZE.x)
		for direction in directions:
			var next := cell + direction
			if next.x < 0 or next.x >= GRID_SIZE.x or next.y < 0 or next.y >= GRID_SIZE.y:
				continue
			var next_index := next.y * GRID_SIZE.x + next.x
			if mask[next_index] == 1 and visited[next_index] == 0:
				visited[next_index] = 1
				queue.append(next_index)
	return queue.size() == walkable_count
