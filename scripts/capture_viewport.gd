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
		instance.set("unit_position", exit_info.position + exit_info.direction * 12.0)
		instance.queue_redraw()
		await process_frame
		var passage_image := root.get_texture().get_image()
		var passage_path := "res://reports/sortida_isometrica.png"
		passage_error = passage_image.save_png(passage_path)
		print("SCREENSHOT %s error=%d size=%s" % [passage_path, passage_error, passage_image.get_size()])
	quit(0 if error == OK and dev_error == OK and analysis_error == OK and passage_error == OK else 1)
