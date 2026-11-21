extends RefCounted

const FRAME = preload("res://assets/ui/marc_registre.svg")

static func frame() -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = FRAME
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		style.set_texture_margin(side, 10)
		style.set_content_margin(side, 12)
	return style

static func flat(fill: Color, edge: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(1)
	style.set_content_margin_all(8)
	return style

static func build() -> Theme:
	var result := Theme.new()
	var font := ThemeDB.fallback_font.duplicate() as FontFile
	font.multichannel_signed_distance_field = true
	font.msdf_size = 48
	font.msdf_pixel_range = 8
	result.default_font = font
	result.default_font_size = 15
	for type in ["Panel", "PanelContainer", "PopupPanel", "PopupMenu", "AcceptDialog", "TabContainer"]:
		result.set_stylebox("panel", type, frame())
	var window := frame()
	window.expand_margin_top = 30
	window.expand_margin_left = 4
	window.expand_margin_right = 4
	window.expand_margin_bottom = 4
	result.set_stylebox("embedded_border", "Window", window)
	result.set_stylebox("embedded_unfocused_border", "Window", window)
	result.set_color("title_color", "Window", Color("e4f1f1"))
	result.set_color("title_outline_modulate", "Window", Color.TRANSPARENT)
	result.set_font_size("title_font_size", "Window", 18)
	result.set_constant("title_height", "Window", 30)
	result.set_constant("close_h_offset", "Window", 24)
	result.set_constant("close_v_offset", "Window", 22)
	for type in ["Button", "OptionButton", "MenuButton"]:
		for state in ["normal", "hover", "pressed", "disabled", "focus"]:
			var edge := Color("5de5ed") if state in ["hover", "focus"] else Color("527f89")
			if state == "pressed": edge = Color("ed9954")
			result.set_stylebox(state, type, flat(Color("0d242d") if state != "disabled" else Color("0a151b"), edge))
		result.set_color("font_color", type, Color("dcecf0"))
		result.set_color("font_hover_color", type, Color.WHITE)
	for type in ["TabContainer", "TabBar"]:
		result.set_stylebox("tab_selected", type, flat(Color("15313a"), Color("5de5ed")))
		result.set_stylebox("tab_unselected", type, flat(Color("08151c"), Color("35515b")))
		result.set_stylebox("tab_hovered", type, flat(Color("15313a"), Color("e6904c")))
		result.set_stylebox("tab_disabled", type, flat(Color("081218"), Color("24363e")))
	result.set_stylebox("normal", "LineEdit", flat(Color("08151c"), Color("35515b")))
	result.set_stylebox("focus", "LineEdit", flat(Color("08151c"), Color("5de5ed")))
	result.set_stylebox("hover", "PopupMenu", flat(Color("15313a"), Color("5de5ed")))
	return result
