extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	var instance := scene.instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	await process_frame
	instance.set("selected_cave", instance.world.entry)
	instance.call("_scan_local")
	await process_frame
	var image := root.get_texture().get_image()
	var path := "res://reports/prototip_screenshot.png"
	var error := image.save_png(path)
	print("SCREENSHOT %s error=%d size=%s" % [path, error, image.get_size()])
	var map_world: Dictionary = instance.get("world")
	var detected_cave_id: int = (int(map_world.entry) + 1) % map_world.caves.size()
	var detected_cave: Dictionary = map_world.caves[detected_cave_id]
	var approach_position: Vector2 = detected_cave.position + detected_cave.contour[0] + Vector2(60.0, 0.0)
	instance.set("moving", false)
	instance.set("analysis_mode", false)
	instance.set("selected_cave", -1)
	instance.set("unit_position", approach_position)
	instance.call("_reveal_around", approach_position, 5)
	instance.call("_detect_caves_near_unit")
	instance.set("camera_offset", -((approach_position - Vector2(1100.0, 750.0)) * float(instance.get("zoom_level"))))
	instance.queue_redraw()
	await process_frame
	var detection_image := root.get_texture().get_image()
	var detection_path := "res://reports/deteccio_cova_proximitat.png"
	var detection_error := detection_image.save_png(detection_path)
	print("SCREENSHOT %s error=%d detected=%s" % [detection_path, detection_error, instance.get("detected_caves").has(detected_cave_id)])
	var dev_toggle := instance.get("dev_toggle") as CheckButton
	dev_toggle.button_pressed = true
	instance.call("_on_dev_mode_toggled", true)
	await process_frame
	var dev_image := root.get_texture().get_image()
	var dev_path := "res://reports/mapa_complet_dev.png"
	var dev_error := dev_image.save_png(dev_path)
	print("SCREENSHOT %s error=%d size=%s" % [dev_path, dev_error, dev_image.get_size()])
	dev_toggle.button_pressed = false
	instance.call("_on_dev_mode_toggled", false)
	var active_world: Dictionary = instance.get("world")
	var analysis_cave_id: int = active_world.entry
	instance.set("analysis_mode", true)
	instance.set("selected_cave", analysis_cave_id)
	instance.call("_update_scan_availability")
	instance.call("_update_view_mode_ui")
	var analysis_zoom: float = instance.call("_analysis_zoom_for_cave", analysis_cave_id)
	instance.call("_focus_cave", analysis_cave_id, analysis_zoom)
	await process_frame
	var analysis_image := root.get_texture().get_image()
	var analysis_path := "res://reports/mode_analisi_sala.png"
	var analysis_error := analysis_image.save_png(analysis_path)
	print("SCREENSHOT %s error=%d size=%s zoom=%.2f" % [analysis_path, analysis_error, analysis_image.get_size(), analysis_zoom])
	var exits: Array = instance.call("_visible_exits_for_cave", analysis_cave_id)
	var passage_error := ERR_FILE_CANT_WRITE
	if not exits.is_empty():
		var exit_info: Dictionary = exits[0]
		var cave: Dictionary = active_world.caves[analysis_cave_id]
		var inside_room: Vector2 = cave.position.lerp(exit_info.position, 0.6)
		instance.set("unit_position", inside_room)
		instance.queue_redraw()
		await process_frame
		var passage_image := root.get_texture().get_image()
		var passage_path := "res://reports/sortida_isometrica.png"
		passage_error = passage_image.save_png(passage_path)
		print("SCREENSHOT %s error=%d size=%s" % [passage_path, passage_error, passage_image.get_size()])
		var corridor: Dictionary = {}
		for candidate in active_world.corridors:
			if candidate.id == exit_info.corridor_id:
				corridor = candidate
				break
		if not corridor.is_empty():
			var beyond_room: Vector2 = exit_info.position + exit_info.direction * 12.0
			var blocked_route: Array[Vector2] = [inside_room, beyond_room]
			var map_route: Array[Vector2] = [beyond_room]
			instance.set("moving", false)
			instance.set("move_path", [])
			instance.set("selected_route", [])
			instance.set("chained_cave_id", -1)
			instance.set("unit_position", inside_room)
			instance.set("move_path", blocked_route)
			instance.set("move_target", beyond_room)
			instance.set("selected_route", blocked_route.duplicate())
			instance.set("moving", true)
			instance.call("_process", 1.0)
			print("INSPECTION_EXIT_BLOCKED analysis_mode=%s inside_room=%s moving=%s" % [instance.get("analysis_mode"), instance.call("_point_inside_cave_id", instance.get("unit_position"), analysis_cave_id), instance.get("moving")])
			instance.call("_exit_inspection")
			instance.set("move_path", map_route)
			instance.set("move_target", beyond_room)
			instance.set("selected_route", map_route.duplicate())
			instance.set("moving", true)
			instance.call("_process", 1.0)
			instance.set("moving", false)
			await process_frame
			var transition_image := root.get_texture().get_image()
			var transition_path := "res://reports/transicio_mapa_tunel.png"
			var transition_error := transition_image.save_png(transition_path)
			print("SCREENSHOT %s error=%d size=%s map_mode=%s corridor_visible=%s" % [transition_path, transition_error, transition_image.get_size(), not instance.get("analysis_mode"), instance.call("_should_draw_corridor", corridor)])
			passage_error = maxi(passage_error, transition_error)
	quit(0 if error == OK and detection_error == OK and dev_error == OK and analysis_error == OK and passage_error == OK else 1)
