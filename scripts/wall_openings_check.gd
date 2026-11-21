extends SceneTree

const Game = preload("res://scripts/main.gd")

func _initialize() -> void:
	var game := Game.new()
	var cave := {"position": Vector2.ZERO, "contour": PackedVector2Array([
		Vector2(-50, -50), Vector2(50, -50), Vector2(50, 50), Vector2(-50, 50)])}
	var openings: Array[PackedVector2Array] = [PackedVector2Array([
		Vector2(-10, -70), Vector2(10, -70), Vector2(10, -40), Vector2(-10, -40)])]
	var spans: Array = game.call("_build_room_wall_spans", cave, openings)
	var length := 0.0
	for span in spans:
		length += span[0].distance_to(span[1])
	assert(absf(length - 380.0) < 0.01, "Only the exact 20-unit passage should be open")
	openings.clear()
	openings.append(PackedVector2Array([Vector2(40, -60), Vector2(60, -60), Vector2(60, -40), Vector2(40, -40)]))
	spans = game.call("_build_room_wall_spans", cave, openings)
	length = 0
	for span in spans:
		length += span[0].distance_to(span[1])
	assert(absf(length - 380.0) < 0.01, "A corner opening must trim both edges exactly")
	openings.clear()
	spans = game.call("_build_room_wall_spans", cave, openings)
	length = 0
	for span in spans:
		length += span[0].distance_to(span[1])
	assert(absf(length - 400.0) < 0.01, "Undiscovered exits must leave a continuous wall")
	# A completed gallery starts exactly at the room boundary: the cutter must
	# extend inside the room instead of leaving a wall across the whole mouth.
	cave.id = 0
	game.world = {"corridors": [{"id": 0, "a": 0, "b": 1, "width": 20.0,
		"exit_a": Vector2(0, -50), "exit_b": Vector2(0, -100),
		"direction_a": Vector2.UP, "direction_b": Vector2.DOWN,
		"points": PackedVector2Array([Vector2(0, -50), Vector2(0, -100)])}]}
	game.completed_gallery_traces[0] = true
	var exits: Array[Dictionary] = [{"corridor_id": 0, "position": Vector2(0, -50), "direction": Vector2.UP, "width": 20.0}]
	openings = game.call("_room_wall_openings", cave, exits)
	spans = game.call("_build_room_wall_spans", cave, openings)
	for span in spans:
		assert(Geometry2D.get_closest_point_to_segment(Vector2(0, -50), span[0], span[1]).distance_to(Vector2(0, -50)) > 5.0,
			"A completed gallery mouth must be free of wall")
	# Concave upper/lower edges must follow their outward normal, not centre Y.
	var concave := {"position": Vector2.ZERO, "contour": PackedVector2Array([
		Vector2(-50,-50), Vector2(50,-50), Vector2(50,50), Vector2(10,50),
		Vector2(10,-20), Vector2(-10,-20), Vector2(-10,50), Vector2(-50,50)])}
	openings.clear()
	for reversed in [false, true]:
		if reversed: concave.contour.reverse()
		spans = game.call("_build_room_wall_spans", concave, openings)
		for span in spans:
			var middle: Vector2 = (span[0] + span[1]) * 0.5
			if is_equal_approx(middle.y, -20.0):
				assert(span[2] > 0, "Concave foreground rim must not rise into a tall fin")
			if is_equal_approx(middle.y, -50.0):
				assert(span[2] < 0, "Rear wall must retain its height")
	game.free()
	print("WALL_OPENINGS_EXACT_WIDTH_CORNER_AND_CLOSED_OK")
	quit()
