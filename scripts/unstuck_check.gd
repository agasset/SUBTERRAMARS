extends SceneTree
const Harness=preload("res://scripts/organism_preview.gd")
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	var game=Harness.PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game._new_world(134027)
	game._change_underground_level(1,-1)
	game.surface_mode=false
	game._ensure_solid_room_rocks()
	var room: int=game.world.entry
	game.current_cave_id=room
	game.selected_cave=room
	game.explored_caves[room]=true
	game._reveal_entire_room(game.world.caves[room])
	game.oxygen_seconds=17.0
	game.suit_integrity=34.0
	game.defence_state.energy=29.0
	for iso in [false,true]:
		game.analysis_mode=iso
		var before: Vector2=game.unit_position
		var world_before := var_to_bytes([game.world,game.revealed_mask])
		game.move_path.assign([before+Vector2(20,0)])
		game.moving=true
		game.level_navigation_target=room
		var key := InputEventKey.new()
		key.keycode=KEY_F8
		key.pressed=true
		if iso: game._input(key)
		else: game.unstuck_navigation_button.pressed.emit()
		assert(not game.moving and game.move_path.is_empty() and game.level_navigation_target==-1)
		assert(game.unit_position.distance_to(before)<=30.01)
		assert(game._point_inside_cave_id(game.unit_position,room))
		assert(game._segment_is_walkable(game.unit_position,game.unit_position))
		assert(game.oxygen_seconds==17 and game.suit_integrity==34 and game.defence_state.energy==29)
		assert(world_before==var_to_bytes([game.world,game.revealed_mask]))
	print("UNSTUCK_OK map_and_iso=true bounded_same_room=true resources_and_world_unchanged=true")
	game.queue_free()
	await process_frame
	await process_frame
	quit()
