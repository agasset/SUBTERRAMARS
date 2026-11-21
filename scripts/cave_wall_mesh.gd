extends RefCounted

# Immutable, world-anchored render geometry. No navigation/discovery state here.
const WALL = preload("res://assets/textures/paret_gruta.png")
const FORMATIONS = preload("res://assets/sprites/formacions_gruta.png")

static func _builder() -> Dictionary:
	return {"vertices": [], "colors": [], "uvs": []}

static func _triangle(builder: Dictionary, points: PackedVector2Array,
		colors: PackedColorArray, uvs: PackedVector2Array = PackedVector2Array()) -> void:
	for index in range(3):
		builder.vertices.append(Vector3(points[index].x, points[index].y, 0))
		builder.colors.append(colors[index] if colors.size() == 3 else colors[0])
		builder.uvs.append(uvs[index] if uvs.size() == 3 else Vector2.ZERO)

static func _quad(builder: Dictionary, points: PackedVector2Array,
		colors: PackedColorArray, uvs: PackedVector2Array = PackedVector2Array()) -> void:
	for index in [0, 1, 2, 0, 2, 3]:
		builder.vertices.append(Vector3(points[index].x, points[index].y, 0))
		builder.colors.append(colors[index] if colors.size() == 4 else colors[0])
		builder.uvs.append(uvs[index] if uvs.size() == 4 else Vector2.ZERO)

static func _stroke(builder: Dictionary, a: Vector2, b: Vector2, color: Color, width: float) -> void:
	var offset := (b - a).orthogonal().normalized() * width * 0.5
	_quad(builder, PackedVector2Array([a - offset, b - offset, b + offset, a + offset]), PackedColorArray([color]))

static func _mesh(builder: Dictionary) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	if builder.vertices.is_empty():
		return mesh
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array(builder.vertices)
	arrays[Mesh.ARRAY_COLOR] = PackedColorArray(builder.colors)
	arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array(builder.uvs)
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

static func build_group(spans: Array, origin: Vector2, palette: Array, seed_value: int, fade: bool) -> Array:
	var builders := [_builder(), _builder(), _builder()]
	for span in spans:
		var opacity := 1.0 - smoothstep(0.62, 1.0, float(span[3])) if fade else 1.0
		if opacity <= 0.01:
			continue
		var pieces := _build_arrays(span[0], span[1], float(span[2]), palette, seed_value)
		var delta: Vector2 = span[0] - origin
		var offset := Vector3(delta.x, delta.y * 0.5, 0)
		for i in range(3):
			var piece: Dictionary = pieces[i]
			for j in range(piece.vertices.size()):
				builders[i].vertices.append(piece.vertices[j] + offset)
				var ink: Color = piece.colors[j]
				ink.a *= opacity
				builders[i].colors.append(ink)
				builders[i].uvs.append(piece.uvs[j])
	return [_mesh(builders[0]), _mesh(builders[1]), _mesh(builders[2])]

static func build(start: Vector2, finish: Vector2, direction: float, palette: Array, seed_value: int) -> Array:
	var pieces := _build_arrays(start, finish, direction, palette, seed_value)
	return [_mesh(pieces[0]), _mesh(pieces[1]), _mesh(pieces[2])]

static func _build_arrays(start: Vector2, finish: Vector2, direction: float, palette: Array, seed_value: int) -> Array:
	var count := maxi(1, ceili(start.distance_to(finish) / 3.5))
	var foot := PackedVector2Array()
	var crest := PackedVector2Array()
	var ledge := PackedVector2Array()
	var faces := _builder()
	var strokes := _builder()
	var formations := _builder()
	var shade := Color(palette[2]).lightened(0.08)
	var dark := Color(palette[0]).darkened(0.35)
	for i in range(count + 1):
		var point := start.lerp(finish, float(i) / count)
		var phase := float(posmod(seed_value, 997))
		var noise_value := 0.5 + sin(point.x * 0.12 + point.y * 0.08 + phase) * 0.28 + sin(point.x * 0.31 - point.y * 0.18) * 0.12
		var height := (7.0 if direction > 0 else 17.0) * (0.72 + noise_value * 0.56)
		var delta := point - start
		var ground := Vector2(delta.x, delta.y * 0.5)
		foot.append(ground)
		var relief := snappedf(sin(point.x*0.24 + point.y*0.17 + phase)*1.25,0.25)
		var top := ground + Vector2(relief*0.55, direction * height)
		crest.append(top)
		ledge.append(ground.lerp(top,0.52) + Vector2(relief, -absf(relief)*0.6))
	for i in range(count):
		var p := start.lerp(finish, float(i) / count)
		var q := start.lerp(finish, float(i + 1) / count)
		var u := (p.x + p.y) / 22.0
		var v := (q.x + q.y) / 22.0
		var middle_ink := Color(palette[1]).lerp(shade,0.35)
		_quad(faces, PackedVector2Array([foot[i], foot[i + 1], ledge[i + 1], ledge[i]]),
			PackedColorArray([dark,dark,middle_ink,middle_ink]),
			PackedVector2Array([Vector2(u,0.8),Vector2(v,0.8),Vector2(v,0.42),Vector2(u,0.42)]))
		_quad(faces, PackedVector2Array([ledge[i], ledge[i + 1], crest[i + 1], crest[i]]),
			PackedColorArray([middle_ink.darkened(0.12),middle_ink.darkened(0.12),shade,shade]),
			PackedVector2Array([Vector2(u,0.42),Vector2(v,0.42),Vector2(v,0),Vector2(u,0)]))
		_stroke(strokes,ledge[i],ledge[i+1],Color(Color(palette[2]).lightened(0.05),0.40),0.35)
		var thickness := Vector2(0, direction * 2.5)
		var cap_ink := Color(palette[1]).lightened(0.1)
		_quad(faces, PackedVector2Array([crest[i], crest[i + 1], crest[i + 1] + thickness, crest[i] + thickness]),
			PackedColorArray([cap_ink, cap_ink, shade, shade]),
			PackedVector2Array([Vector2(u, 0.1), Vector2(v, 0.1), Vector2(v, 0.25), Vector2(u, 0.25)]))
		if i % 2 == 0:
			_stroke(strokes, crest[i], foot[i].lerp(crest[i], 0.28), Color(Color(palette[0]).darkened(0.5), 0.7), 0.4)
		_stroke(strokes, foot[i], foot[i + 1], Color(Color(palette[0]).darkened(0.6), 0.7), 0.8)
	var cell_size := Vector2(FORMATIONS.get_size()) / Vector2(4, 2)
	for i in range(1, count - 1):
		var point := start.lerp(finish, float(i) / count)
		var key := posmod(hash([seed_value, Vector2i(point.floor()), "speleothems_v1"]), 1000)
		if i % 3 != 1 or key % 5 > 2:
			continue
		var hanging := key % 2 == 0
		var source := Rect2(Vector2(key % 4, 0 if hanging else 1) * cell_size, cell_size)
		var face_height := absf(crest[i].y - foot[i].y)
		var size := Vector2.ONE * minf(face_height * (0.62 + float(key % 17) / 100.0), 12.0)
		var face_top := crest[i] if direction < 0 else foot[i]
		var attachment := face_top if hanging else foot[i]
		var anchor := Vector2(0.5, 0.18 if hanging else 0.85)
		var rect := Rect2(attachment - size * anchor, size)
		var tint := Color(palette[1]).lerp(Color(palette[2]), 0.65)
		var texture_size := Vector2(FORMATIONS.get_size())
		_quad(formations, PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]),
			PackedColorArray([tint]), PackedVector2Array([source.position / texture_size,
			Vector2(source.end.x, source.position.y) / texture_size, source.end / texture_size,
			Vector2(source.position.x, source.end.y) / texture_size]))
	return [faces, strokes, formations]
