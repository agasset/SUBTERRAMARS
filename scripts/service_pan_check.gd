extends SceneTree
const Harness=preload("res://scripts/organism_preview.gd")
func _initialize() -> void: call_deferred("_run")
func _run() -> void:
	root.size=Vector2i(1440,900)
	var game=Harness.PreviewGame.new()
	root.add_child(game)
	game.set_process(false)
	game._new_world(134027)
	game._change_underground_level(1,-1)
	game.surface_mode=false
	game._ensure_solid_room_rocks()
	for menu in game.modifier_menus:
		assert(menu.get_parent() is HBoxContainer)
	game.owned_modifiers["boots_ice"]=true
	game.equipped_modifiers["botes"]="boots_ice"
	game._update_modifier_menus()
	for menu in game.modifier_menus:
		assert(menu.text==("MOD ✓" if menu.get_meta("equipment_slot")=="botes" else "MOD +"))
		assert(not menu.disabled)
	var boots_menu: MenuButton=game.modifier_menus[0]
	for menu in game.modifier_menus:
		if menu.get_meta("equipment_slot")=="botes": boots_menu=menu; break
	boots_menu.get_popup().id_pressed.emit(0)
	assert(game.equipped_modifiers.get("botes","")=="")
	boots_menu.get_popup().id_pressed.emit(0)
	assert(game.equipped_modifiers.get("botes","")=="boots_ice")
	game.defence_state.enabled=false
	game.defence_system.refresh_ui(game)
	assert(game.defence_state.enabled)
	assert(not game.defence_system.shield_inventory_toggle.visible)
	game.oxygen_seconds=1.0
	game._update_low_supply_warning(0)
	assert(game.warned_low_supplies.has(game.STRIP_OXYGEN_SLOT))
	game.oxygen_seconds=game._oxygen_capacity()
	game.suit_integrity=100.0
	game.warned_low_supplies[4]=true
	game._update_inventory_screen()
	assert(not game.warned_low_supplies.has(game.STRIP_OXYGEN_SLOT))
	assert(not game.warned_low_supplies.has(4))
	var room: int=game.world.entry
	game.selected_cave=room
	game.current_cave_id=room
	game.unit_position=game.world.caves[room].position
	game.explored_caves[room]=true
	for iso in [false,true]:
		game.analysis_mode=iso
		game._focus_cave(room,3.5 if iso else 0.62)
		game._update_view_mode_ui()
		game._layout_panels()
		var empty := Vector2.INF
		var view: Rect2=game._view_rect()
		for y in range(int(view.position.y)+210,int(view.end.y)-180,35):
			for x in range(int(view.position.x)+10,int(view.end.x)-10,35):
				var screen := Vector2(x,y)
				var point: Vector2=game._screen_to_world(screen)
				if game._over_ui(screen) or game._cave_at_position(point)>=0: continue
				var clear := true
				for corridor in game.world.corridors:
					if game._distance_to_polyline(point,corridor.points)<=float(corridor.width)*0.5: clear=false
				if clear: empty=screen; break
			if empty!=Vector2.INF: break
		assert(empty!=Vector2.INF)
		var before: Vector2=game.camera_offset
		var state := var_to_bytes([game.world,game.unit_position,game.revealed_mask])
		var press := InputEventMouseButton.new()
		press.button_index=MOUSE_BUTTON_RIGHT
		press.position=empty
		press.pressed=true
		game._input(press)
		assert(game.dragging)
		var motion := InputEventMouseMotion.new()
		motion.position=empty+Vector2(28,16)
		motion.relative=Vector2(28,16)
		game._input(motion)
		assert(game.camera_offset==before+Vector2(28,16))
		press.pressed=false
		game._input(press)
		assert(not game.dragging)
		assert(state==var_to_bytes([game.world,game.unit_position,game.revealed_mask]))
	game.analysis_mode=true
	game._focus_cave(room,4.5)
	game._update_view_mode_ui()
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://reports/oxidat_mes_suau.png")
	game._open_inventory(false)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	assert(game.inventory_window.size.x==game._inventory_tab_size(1).x)
	assert(game.inventory_level_meters.size()==game.inventory_condition_meters.size())
	assert(game.inventory_level_meters[0].value==game.equipped_boots+1)
	assert(game.inventory_condition_meters[2].value==100)
	root.get_texture().get_image().save_png("res://reports/inventari_barres_gran.png")
	game.surface_mode=true
	game.materials_in_pack=50
	game.flora_samples[room]=false
	game._update_research_panel()
	game._open_inventory(true)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var modifier_button: Button=game.modifier_buttons["boots_magma"]
	assert(not modifier_button.disabled)
	var iron: int=game.materials_in_pack
	modifier_button.pressed.emit()
	assert(game.owned_modifiers.has("boots_magma"))
	assert(game.equipped_modifiers.botes=="boots_magma")
	assert(game.materials_in_pack==iron-game.MODIFIER_MATERIAL_COST)
	modifier_button.pressed.emit()
	assert(not game.equipped_modifiers.has("botes"))
	modifier_button.pressed.emit()
	assert(game.equipped_modifiers.botes=="boots_magma")
	assert(game.materials_in_pack==iron-game.MODIFIER_MATERIAL_COST)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://reports/modificadors_costat_taller.png")
	game.inventory_window.hide()
	game.map_options_window.popup_centered(Vector2i(370,560))
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://reports/opcions_desencalla.png")
	print("SERVICE_PAN_OK warnings_clear=true right_drag_map_and_iso=true world_unchanged=true")
	game.queue_free()
	await process_frame
	await process_frame
	quit()
