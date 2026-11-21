extends Node2D

const Generator = preload("res://scripts/world_generator.gd")
const LocalSaveStore = preload("res://scripts/local_save_store.gd")
const OrganismTraits = preload("res://scripts/organism_traits.gd")
const CampaignRules = preload("res://scripts/campaign_rules.gd")
const ExpeditionDefence = preload("res://scripts/expedition_defence.gd")
var defence_system := ExpeditionDefence.new()
var defence_state: Dictionary = ExpeditionDefence.defaults()
var campaign_biome_order: Array = CampaignRules.CLASSIC_ORDER.duplicate()
var discovered_biomes: Dictionary = {}
var navigation_marker: Dictionary = {}
var marker_return_pending := false
var place_marker_button: Button
var return_marker_button: Button
var navigation_marker_texture: Texture2D

func _biome_at_depth(depth: int) -> int:
	return CampaignRules.biome_at_depth(depth,campaign_biome_order)

func _biome_exit_requirement() -> String:
	return CampaignRules.requirement(_biome_at_depth(current_level))

func _biome_exit_is_ready() -> bool:
	return not CampaignRules.is_boundary(current_level) or CampaignRules.requirement_met(self,_biome_at_depth(current_level))

func _notice_biome_exit_requirement() -> void:
	depth_trip_target = -1
	_action_notice("DESCENS BLOQUEJAT · Requereix %s. Compra al taller o activa el modificador des de l’inventari." % _biome_exit_requirement())
const AUTOSAVE_SECONDS := 3.0
const SAVED_GAME_FIELDS := [
	"seed_value", "current_level", "surface_mode", "analysis_mode", "current_cave_id",
	"selected_cave", "selected_cave_focus", "unit_position", "explorer_facing", "zoom_level", "camera_offset",
	"health", "medkits", "oxygen_seconds", "oxygen_cartridges", "suit_tier", "suit_integrity",
	"mining_tool", "mining_tool_integrity", "equipped_boots", "boots_integrity", "bio_scanner_tier", "bio_scanner_integrity",
	"flashlight_on", "flashlight_charge", "flashlight_spares", "crafted_beacons", "materials_in_pack",
	"quartz_in_pack", "magnetite_in_pack", "ladder_uses_spent", "repair_kit_uses_spent",
	"supply_tiers", "owned_modifiers", "equipped_modifiers", "equipment_research_spent",
	"rockfall_cooldown", "last_revealed_cell", "isometric_passage_id", "inspection_corridor_id",
	"inspection_destination_cave_id", "inspect_on_cave_arrival", "moving", "move_path", "move_target",
	"chained_cave_id", "chained_arrival", "level_navigation_target", "use_elevator_on_arrival",
	"center_map_during_move", "mining_cave", "mining_remaining", "bio_scan_room", "bio_scan_fauna",
	"bio_scan_elapsed", "selected_flora", "selected_fauna", "rockfall_clear_remaining"
]
var active_profile_id := ""
var active_profile_name := ""
var autosave_elapsed := 0.0
var profiles_dialog: AcceptDialog
var restart_run_dialog: ConfirmationDialog
var profiles_list: OptionButton
var profile_name_input: LineEdit
var profiles_status: Label
var save_profile_button: Button
var load_profile_button: Button
var delete_profile_button: Button
var delete_profile_dialog: ConfirmationDialog
var pending_profile_deletion := ""
var history_dialog: AcceptDialog
var history_text: RichTextLabel
var expedition_history: Array[Dictionary] = []
var expedition_record: Dictionary = {}
var biological_register: Dictionary = {}
var biological_photos: Dictionary = {}
const BG := Color("07111c")
const PANEL := Color("0c1b29")
const CYAN := Color("5de5ed")
const MUTED := Color("71909f")
const ORANGE := Color("ffac62")
const ISOMETRIC_ORGANISM_SIZE := 2.2
const ANALYSIS_MIN_ZOOM := 1.4
const ANALYSIS_MAX_ZOOM := 7.0
const ANALYSIS_ENTRY_ZOOM_FACTOR := 0.85
const MAP_ENTRY_ZOOM := 0.90
const SIDE_PANEL_SCALE := 0.82
const ACCESSIBLE_GALLERY_COLOR := Color("abbeff")
const BLOCKED_GALLERY_COLOR := Color("ff6b65")
const MAP_MIN_ZOOM := 0.12
const ISO_VERTICAL_RATIO := 0.5
const LEVEL_EXIT_BEACON_COLOR := Color("ffbf61")
const CAVE_DETECTION_MARGIN := 80.0
const OXIDIZED_BASE_TEXTURE = preload("res://assets/sprites/base_coves_oxidades_arran_terra.png")
const OXIDIZED_FLOOR_TEXTURE = preload("res://assets/textures/terra_oxidada.png")
const CRYSTALLINE_BASE_TEXTURE = preload("res://assets/sprites/base_cavernes_cristallines.png")
const CRYSTALLINE_FLOOR_TEXTURE = preload("res://assets/textures/terra_cristallina.png")
const OTHER_BIOME_FLOORS = preload("res://assets/textures/terres_biomes_atlas.png")
const OTHER_BIOME_BASES = preload("res://assets/sprites/bases_biomes_atlas.png")
const OTHER_BIOME_PROFILES := [7, 10, 13, 16, 19, 20]
var biome_material_textures: Dictionary = {}
var biome_module_textures: Dictionary = {}
var game_audio: Node
var action_notice_label: Label
var action_notice_tween: Tween
const BIOME_POOLS = preload("res://assets/sprites/basses_biomes_planes.png")
var render_surface_details: Dictionary = {}
const OXIDIZED_FLOOR_WORLD_PERIOD := 32.0
const BIOME_ROCK_SPRITES = preload("res://assets/sprites/roques_biomes.png")
const ROCK_VARIATIONS = preload("res://assets/sprites/roques_variants.png")
const CAVE_WALL_TEXTURE = preload("res://assets/textures/paret_gruta.png")
const CAVE_FORMATIONS = preload("res://assets/sprites/formacions_gruta.png")
const SurfaceBaseArt = preload("res://scripts/surface_base_art.gd")
var surface_base_art := SurfaceBaseArt.new()
const CaveWallMesh = preload("res://scripts/cave_wall_mesh.gd")
const OrganismPixelArt = preload("res://scripts/organism_pixel_art.gd")
const MINERAL_ROCK_SPRITES = preload("res://assets/sprites/jaciments_minerals.png")
const RESEARCH_MICROSCOPE = preload("res://assets/sprites/microscopi_recerca.png")
var research_hud_texture: ImageTexture
const EXPLORER_SPRITE = preload("res://assets/sprites/explorador_pixel_art.png")
const ELEVATOR_SPRITE = preload("res://assets/sprites/ascensor_pixel_art.png")
const DESCENT_SHAFT_SPRITE = preload("res://assets/sprites/acces_descens.png")
var descent_shaft_image: Image
const DEPLOYED_BEACON_SPRITE = preload("res://assets/sprites/balisa_desplegada.png")
const ROOM_LANTERN = preload("res://assets/sprites/fanals.png")
const GALLERY_FLOOR_LIGHT = preload("res://assets/sprites/llum_galeria.png")

var world: Dictionary
var seed_value := 134027
var camera_offset := Vector2.ZERO
var zoom_level := 0.62
var selected_cave := -1
var selected_cave_focus := Vector2.ZERO
var analysis_mode := false
var surface_mode := true
var current_level := 0
var inactive_levels: Dictionary = {}
const OXIDIZED_CAVES_NAME := "Coves oxidades"
var descent_access := -1
var lower_level_button: Button
var repair_folding_ladder_button: Button
const STRIP_LADDER_SLOT := 12
var folding_ladder_icon: HBoxContainer
var repair_kit_footer: HBoxContainer
var repair_kit_urgent := false
const FOLDING_LADDER_REPAIR_COST := 2
var use_elevator_on_arrival := false
const CAMPAIGN_DEPTH := 20
const DEPTH_REWARDS := {
	4: "+1 balisa inicial",
	7: "+1 bateria del casc de recanvi",
	10: "+1 ús inicial de la caixa d’eines",
	13: "+1 reserva d’oxigen inicial",
	16: "+1 farmaciola inicial",
	19: "+1 ús inicial de l’escala plegable",
}
var deepest_reached := 0
var depth_zone_headings: Dictionary = {}

func _profile_biome_name(depth: int) -> String:
	var biome := _biome_at_depth(maxi(1,depth))
	return str(DEPTH_ZONE_NAMES[biome]) if discovered_biomes.has(biome) else "Bioma per descobrir"
var starting_rewards_depth := 0
var rewards_dialog: AcceptDialog
const DEPTH_ZONE_NAMES := {
	1: OXIDIZED_CAVES_NAME,
	4: "Cavernes cristal·lines",
	7: "Galeries glacials",
	10: "Jardins subterranis",
	13: "Fractures geotèrmiques",
	16: "Abisme biològic",
	19: "El Llindar",
	20: "El Nucli",
}
const BIOME_ROCK := {
	1: ["352528", "68473a", "805043"],
	4: ["252037", "675081", "ad8cd0"],
	7: ["203448", "537c96", "8bc1db"],
	10: ["27342a", "507750", "8cad66"],
	13: ["392422", "834937", "c77144"],
	16: ["241c32", "573763", "95659c"],
	19: ["222a30", "625742", "a89662"],
	20: ["1c3036", "40686e", "74b9b8"],
}
const DEPTH_CATEGORIES := ["Sales explorades", "Galeries recorregudes", "Flora analitzada", "Fauna observada", "Vetes descobertes"]
var depth_diagram: ScrollContainer
var depth_rows: Array[Button] = []
var depth_percentages: Array[Label] = []
var depth_trip_target := -1
var pending_depth_action: Callable
var depth_trip_dialog: ConfirmationDialog
const LEVEL_STATE_FIELDS := [
	"world", "walked_gallery_spans", "completed_gallery_traces", "revealed_mask",
	"discovered_exits", "cave_floor_textures", "explored_caves", "visited_caves",
	"detected_caves", "deployed_beacons", "used_beacons", "flora_sites",
	"flora_species_by_room", "analyzed_flora", "fauna_sites", "fauna_species_by_room",
	"fauna_patrol_ends", "fauna_time", "fauna_pause", "seen_fauna", "analyzed_fauna", "flora_samples", "fauna_samples",
	"material_sites", "mineral_types", "collected_materials", "rockfall_corridor_id", "rockfall_position",
	"rockfall_remaining", "rockfall_hit", "descent_access"
]
var inspect_on_cave_arrival := false
var inspection_destination_cave_id := -1
var unit_position := Vector2.ZERO
var isometric_passage_id := -1
var center_map_during_move := false
var explorer_facing := Vector2.DOWN
var move_target := Vector2.ZERO
var moving := false
var move_path: Array[Vector2] = []
var walked_gallery_spans: Dictionary = {}
var completed_gallery_traces: Dictionary = {}
var selected_route: Array[Vector2] = []
var inspection_corridor_id := -1
const ROCKFALL_CHANCE := 0.14
const ROCKFALL_SECONDS := 12.0
const ROCKFALL_SUIT_WEAR := 12.0
const ROCKFALL_TOOL_WEAR := 5.0
const ROCKFALL_CLEAR_SECONDS := 5.0
var rockfall_clear_remaining := 0.0
var rockfall_tool_countdown: Label
var rockfall_corridor_id := -1
var rockfall_remaining := 0.0
var rockfall_cooldown := 0.0
var rockfall_hit := false
var health := 100.0
const NO_OXYGEN_HEALTH_PER_SECOND := 8.0
const BROKEN_BOOTS_HEALTH_PER_UNIT := 0.025
var medkits := 1
const MEDKIT_COST := 2
const STRIP_HEALTH_SLOT := 15
var medkit_button: Button
var buy_medkit_button: Button
var rockfall_position := Vector2.ZERO
var chained_cave_id := -1
var chained_arrival := Vector2.ZERO
var revealed_mask := PackedByteArray()
var last_revealed_cell := Vector2i(-1, -1)
var current_cave_id := -1
var discovered_exits: Dictionary = {}
var cave_floor_textures: Dictionary = {}
# Transient rendering caches are never serialized into a profile/world.
var render_cache_world: Dictionary = {}
var render_cache_level := -1
var render_room_polygons: Array[PackedVector2Array] = []
var render_room_bounds: Array[Rect2] = []
var render_corridor_walls: Dictionary = {}
var render_visible_gallery_walls: Array = []
var render_wall_meshes: Dictionary = {}
var render_wall_groups: Dictionary = {}
var render_room_wall_spans: Dictionary = {}
var render_active_passage_id := -1
var render_corridor_floors: Dictionary = {}
var render_room_lights: Dictionary = {}
var render_gallery_lights: Dictionary = {}

var show_graph := true
var show_contours := true
var show_spawn := true
var dev_mode := false
var explored_caves: Dictionary = {}
var visited_caves: Dictionary = {}
var detected_caves: Dictionary = {}
var dragging := false
var drag_origin := Vector2.ZERO
var ui_root: Control
var mode_heading_label: Label
const OXYGEN_CAPACITY := 1800.0
const LOW_SUPPLY_PERCENT := 10.0
var low_supply_label: Label
var low_supply_warning_time := 0.0
var warned_low_supplies: Dictionary[int, bool] = {}
var oxygen_reserve_card_button: Button
var beacon_card_button: Button
var equipment_action_buttons: Array[Button] = []
var pulsing_equipment_actions: Dictionary[Button, bool] = {}
var helmet_battery_card_button: Button
var oxygen_seconds := OXYGEN_CAPACITY
const BEACON_RANGE := 650.0
const BEACON_STOCK := 2
var deployed_beacons: Dictionary = {}
var used_beacons: Dictionary = {}
var beacon_signal_meter: ProgressBar
var beacon_footer: HBoxContainer
const BEACON_CRAFT_COST := 2
const OXYGEN_CRAFT_COST := 1
const OXYGEN_CARTRIDGE_SECONDS := 300.0
var suit_integrity := 100.0
var suit_tier := 0
var craft_suit_button: Button
const MINING_TOOLS := ["Pic manual", "Trepant", "Extractor"]
const MINING_SECONDS := [6.0, 4.0, 2.0]
const MINING_WEAR_PER_DEPOSIT := [8.0, 6.0, 4.0]
const MINING_REPAIR_COST := 1
var mining_tool := 0
var mining_tool_integrity := 100.0
var repair_mining_tool_button: Button
const BOOT_MODELS := ["Estàndard", "Lleugeres", "Impulsades"]
const BOOT_SPEEDS := [145.0, 175.0, 210.0]
const BOOT_WEAR_PER_UNIT := 0.00125
const BOOT_REPAIR_COST := 1
var equipped_boots := 0
var boots_integrity := 100.0
var boots_offer: Label
var boots_button: Button
var repair_boots_button: Button
const REPAIR_KIT_COST := 2
const FIELD_REPAIR_AMOUNT := 30.0
enum FieldRepair { SUIT, BOOTS, MINING_TOOL, BIO_SCANNER }
var repair_kit_uses_spent := 0
const STRIP_QUARTZ_SLOT := 16
const STRIP_MAGNETITE_SLOT := 17
const STRIP_MEDKIT_SLOT := 18
var quartz_in_pack := 0
var magnetite_in_pack := 0
var mineral_types: Dictionary = {}
var mineral_hit_image: Image
var mineral_hit_silhouettes: Dictionary = {}
var resource_card_regions: Dictionary = {}
var room_lantern_corner_cache: Dictionary = {}
var buy_repair_kit_button: Button
var use_repair_kit_button: Button
var field_repair_menu: PopupMenu
const OXYGEN_REFILL_COST := 2
const SUIT_REPAIR_COST := 1
const HELMET_BATTERY_COST := 1
var refill_oxygen_button: Button
var repair_suit_button: Button
var buy_helmet_battery_button: Button
var inventory_window: AcceptDialog
var inventory_tabs: TabContainer
var inventory_values: Array[Label] = []
var inventory_details: Array[Label] = []
var inventory_level_meters: Array[ProgressBar] = []
var inventory_condition_meters: Array[ProgressBar] = []
var inventory_strip_values: Array[Label] = []
var inventory_strip_meters: Dictionary[int, ProgressBar] = {}
var helmet_light_card: PanelContainer
var helmet_light_card_button: Button
var helmet_light_card_idle: StyleBox
var helmet_light_card_glow: StyleBoxFlat
var light_warning_label: Label
var light_warning_tween: Tween
var light_warning_strength := 0.0
var warned_dark_movement := false
const STRIP_MINING_SLOT := 3
var field_action_cards: Dictionary[int, PanelContainer] = {}
var field_action_progress: Dictionary[int, float] = {}
var field_action_completed_until: Dictionary[int, int] = {}
const RESOURCE_GAIN_DURATION_MS := 1600
var resource_gain_cards: Dictionary[int, PanelContainer] = {}
var resource_previous_counts: Dictionary[int, int] = {}
var resource_gains: Dictionary[int, Vector2i] = {}
const INVENTORY_TITLES := ["Ferro", "Balises", "Reserves d’oxigen",
	"Eina de mineria", "Vestit espacial", "Llum del casc", "Punts de recerca", "Mostres recollides", "Registres i fotos", "Botes", "Caixa d’eines", "Escàner biològic", "Escala plegable"]
const STRIP_BIO_SCANNER_SLOT := 11
const STRIP_BATTERY_SLOT := 13
const STRIP_OXYGEN_SLOT := 14
const BIO_SCANNER_REPAIR_COST := 1
var bio_scanner_tier := 0
var bio_scanner_integrity := 100.0
var bio_scan_room := -1
var bio_scan_fauna := false
var bio_scan_elapsed := 0.0
var upgrade_bio_scanner_button: Button
var repair_bio_scanner_button: Button
var mining_offer: Label
var workshop_materials_balance: Label
const SUPPLY_UPGRADES := {
	"oxygen_tank": ["Dipòsit d’oxigen", "+2 min de capacitat per nivell", 120.0],
	"oxygen_reserve": ["Reserva d’oxigen", "+30 s per reserva i nivell", 30.0],
	"helmet_light": ["Bateria del casc", "+20 s per nivell", 20.0],
	"beacon": ["Balisa", "+50 unitats d’abast per nivell", 50.0],
	"medkit": ["Farmaciola", "Més vida recuperada per ús", 65.0 / 19.0],
	"repair_kit": ["Caixa d’eines", "Més integritat recuperada per ús", 70.0 / 19.0],
	"ladder": ["Escala plegable", "+1 ús per nivell", 1.0],
}
const EQUIPMENT_MODIFIERS := {
	"boots_magma": ["botes", "Sola tèrmica", "Redueix el desgast sobre roca calenta i magma.", "calent"],
	"boots_water": ["botes", "Sola de drenatge", "Manté la velocitat en terreny inundat.", "aigua"],
	"boots_ice": ["botes", "Grampons", "Manté la velocitat i redueix el desgast sobre gel.", "gel"],
	"suit_hot": ["vestit", "Aïllament tèrmic", "Redueix el desgast per calor.", "calent"],
	"suit_cold": ["vestit", "Aïllament criogènic", "Redueix el desgast per fred.", "gel"],
	"mining_crystal": ["mineria", "Capçal de precisió", "Permet extreure quars de les vetes cristal·lines.", "quars"],
	"mining_hard": ["mineria", "Capçal reforçat", "Permet extreure magnetita de les vetes dures.", "magnetita"],
	"scanner_ferric": ["escaner", "Filtre espectral fèrric", "Detecta la molsa i l’escarabat fèrrics.", "ferric"],
	"scanner_abyss": ["escaner", "Filtre de bioluminescència", "Filtra la interferència bioluminescent del pas a les zones profundes.", "abyss"],
	"weapon_focus": ["arma","Pols concentrat","+25% de dany; consumeix 15 d’energia per tret en lloc de 12.","focus"],
	"weapon_efficiency": ["arma","Condensador eficient","Consumeix 9 d’energia per tret en lloc de 12, mantenint el dany.","efficiency"],
	"shield_hardening": ["escut","Camp reforçat","Redueix un 20% el dany rebut mentre l’escut té càrrega.","hardening"],
	"shield_recovery": ["escut","Regeneració ràpida","Regenera 9 punts/s després de 4 s fora de perill, en lloc de 6 punts/s després de 6 s.","recovery"],
}
const MODIFIER_MATERIAL_COST := 3
const MODIFIER_RESEARCH_COST := 1
var owned_modifiers: Dictionary[String, bool] = {}
var equipped_modifiers: Dictionary[String, String] = {}
var modifier_buttons: Dictionary[String, Button] = {}
var modifier_menus: Array[MenuButton] = []

func _add_modifier_menu(parent: Control, slot: String) -> void:
	if parent is VBoxContainer and parent.get_child_count()>0:
		var title := parent.get_child(0)
		var heading := HBoxContainer.new()
		parent.add_child(heading)
		parent.move_child(heading,0)
		title.reparent(heading)
		parent=heading
	var menu := MenuButton.new()
	menu.set_meta("equipment_slot", slot)
	menu.add_theme_font_size_override("font_size", 13)
	menu.custom_minimum_size=Vector2(48,28)
	menu.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	var frame := StyleBoxFlat.new()
	frame.bg_color=Color("153744")
	frame.border_color=Color("55c9d7")
	frame.set_border_width_all(1)
	frame.set_content_margin_all(4)
	menu.add_theme_stylebox_override("normal",frame)
	menu.add_theme_stylebox_override("hover",frame)
	menu.get_popup().id_pressed.connect(func(index: int) -> void:
		_apply_equipment_modifier(str(menu.get_popup().get_item_metadata(index))))
	parent.add_child(menu)
	modifier_menus.append(menu)

func _update_modifier_menus() -> void:
	for menu in modifier_menus:
		var slot: String = menu.get_meta("equipment_slot")
		var active: String = equipped_modifiers.get(slot, "")
		menu.text = "MOD ✓" if not active.is_empty() else "MOD +"
		menu.add_theme_color_override("font_color",Color("72f5ad") if not active.is_empty() else MUTED)
		menu.tooltip_text = (str(EQUIPMENT_MODIFIERS[active][1]) + " · Actiu\n") if not active.is_empty() else "Cap modificador actiu\n"
		menu.tooltip_text += "Activa o desactiva els modificadors adquirits des de qualsevol lloc."
		var popup := menu.get_popup()
		popup.clear()
		for id: String in EQUIPMENT_MODIFIERS:
			if EQUIPMENT_MODIFIERS[id][0] != slot or not owned_modifiers.has(id): continue
			var index := popup.item_count
			popup.add_check_item(str(EQUIPMENT_MODIFIERS[id][1]))
			popup.set_item_metadata(index, id)
			popup.set_item_checked(index, active == id)
		if popup.item_count==0:
			popup.add_item("Cap modificador adquirit · Compra’n a Equip i millores")
			popup.set_item_disabled(0,true)
			menu.tooltip_text="MODIFICADORS · Encara no en tens cap per a aquest equip. Compra’n a la base, a Equip i millores."
		else:
			menu.tooltip_text="CLICA MOD PER TRIAR · "+menu.tooltip_text
		menu.disabled=false
const MAX_EQUIPMENT_LEVEL := 20
var equipment_research_spent := 0
var supply_tiers: Dictionary[String, int] = {}
var ladder_uses_spent := 0
var supply_upgrade_buttons: Dictionary[String, Button] = {}
var supply_upgrade_offers: Dictionary[String, Label] = {}
var suit_upgrade_offer: Label
var scanner_upgrade_offer: Label
var mining_tool_button: Button
var material_sites: Dictionary = {}
var collected_materials: Dictionary = {}
var materials_in_pack := 0
var death_dialog: AcceptDialog
var victory_dialog: AcceptDialog
var expedition_completed := false
var crafted_beacons := 0
var oxygen_cartridges := 0
var flashlight_on := false
var helmet_light_zone_lit := true
const FLASHLIGHT_BATTERY_SECONDS := 180.0
const FLASHLIGHT_SPARE_BATTERIES := 1
var flashlight_charge := FLASHLIGHT_BATTERY_SECONDS
var flashlight_spares := FLASHLIGHT_SPARE_BATTERIES
var craft_beacon_button: Button
var craft_oxygen_button: Button
var seed_edit: LineEdit
var status_label: Label
var dev_toggle: CheckButton
var new_game_button: Button
var map_return_button: Button
var center_explorer_button: Button
var descend_button: Button
var base_return_button: Button
var biome_base_return_button: Button
var level_navigation_target := -1
var descend_navigation_button: Button
var unstuck_navigation_button: Button
var level_panel: Control
var equipment_bar: PanelContainer
var level_title_label: Label
var room_progress_label: Label
var room_details_label: Label
var room_details_panel: Control
var room_details_title: Label
var room_details_status: Label
var room_details_meter: ProgressBar
var room_details_rows: VBoxContainer
var room_details_signature := ""
var mining_cave := -1
var mining_remaining := 0.0
var navigation_panel: Control
var inspect_room_button: Button
var fit_map_button: Button
var map_legend_panel: Control
var map_options_section: Control
var map_options_window: AcceptDialog
var show_signal_rings := true
var show_beacon_waves := true
var beacon_waves_toggle: CheckButton
var show_findings := true
const FLASHLIGHT_USABLE_DOT := 0.68
const FLORA_SPECIES := {
	"falguera": {"name": "Falguera de llum", "description": "Els brots emeten una llum verda i creixen arran de terra."},
	"coral": {"name": "Corall de basalt", "description": "Les branques violetes creixen en ventall entre les esquerdes de la roca."},
	"molsa_ferrica": {"name": "Molsa fèrrica", "description": "Forma coixinets de color coure sobre la roca oxidada."},
	"coral_prismatic": {"biome": 4, "form": "coral", "color": "73e4ed", "name": "Corall prismàtic", "description": "Les branques turquesa creixen entre cristalls."},
	"molsa_glacial": {"biome": 7, "form": "molsa", "color": "addfff", "name": "Molsa de gebre", "description": "Els coixinets blaus creixen sobre la roca freda."},
	"falguera_jardi": {"biome": 10, "color": "c3ee78", "name": "Falguera de jardí", "description": "Els brots verd llima s’obren en arc."},
	"coral_termic": {"biome": 13, "form": "coral", "color": "fa8254", "name": "Corall tèrmic", "description": "Els brots ataronjats ressegueixen les fissures càlides."},
	"molsa_abissal": {"biome": 16, "form": "molsa", "color": "e197f4", "name": "Molsa abissal", "description": "Forma coixinets rosats a la roca profunda."},
	"coral_llindar": {"biome": 19, "form": "coral", "color": "ffdb80", "name": "Corall del Llindar", "description": "Les puntes daurades es despleguen en ventall."},
	"falguera_nucli": {"biome": 20, "color": "f1f4ff", "name": "Falguera del Nucli", "description": "Els brots pàl·lids destaquen sobre la roca del fons."},
}
var flora_sites: Dictionary = {}
var flora_species_by_room: Dictionary = {}
var analyzed_flora: Dictionary = {}
const FAUNA_SPECIES := {
	"depredador_oxidat":{"biome":1,"predator":true,"color":"c96545","name":"Mantis cuirassada","description":"Depredador amb dues extremitats de tall. El seu atac es pot esquivar durant la preparació."},
	"depredador_cristalli":{"biome":4,"predator":true,"color":"b587e4","name":"Escorpí de geoda","description":"Un depredador de closca cristal·lina i cua recurvada."},
	"depredador_glacial":{"biome":7,"predator":true,"color":"a9e6ff","name":"Salamandra de glaç","description":"Mandíbules potents i cresta de gel. Es mou sobre el mateix sòl que l’explorador."},
	"depredador_jardi":{"biome":10,"predator":true,"color":"8dd39e","name":"Aranya de les espores","description":"Caçador de potes llargues entre les formacions vegetals."},
	"depredador_termic":{"biome":13,"predator":true,"color":"ed8055","name":"Mantis de brasa","description":"Una variant cuirassada que resisteix l’entorn tèrmic."},
	"depredador_abissal":{"biome":16,"predator":true,"color":"81d8d8","name":"Assetjador abissal","description":"Depredador de sensors bioluminescents i extremitats angulars."},
	"depredador_llindar":{"biome":19,"predator":true,"color":"e3c68b","name":"Escorpí del Llindar","description":"Variant de les zones profundes, amb atacs especialment perillosos."},
	"depredador_nucli":{"biome":20,"predator":true,"color":"b8e8ee","name":"Assetjador del Nucli","description":"La variant més letal. L’escut, la distància i els polsos poden donar temps per retirar-se."},
	"escarabat": {"name": "Escarabat de cendra", "description": "Un petit escarabat amb una closca ambre."},
	"isopode": {"name": "Isòpode de pissarra", "description": "Una criatura de closca blavosa i segmentada que camina a poc a poc."},
	"escarabat_ferric": {"name": "Escarabat fèrric", "description": "La closca rogenca es confon amb la pols de ferro de les galeries."},
	"isopode_cristalli": {"biome": 4, "segmented": true, "color": "bcb0ff", "name": "Isòpode cristal·lí", "description": "La closca violeta està dividida en plaques brillants."},
	"isopode_glacial": {"biome": 7, "segmented": true, "color": "93e2f6", "name": "Isòpode glacial", "description": "Camina lentament amb una closca blau cel."},
	"escarabat_jardi": {"biome": 10, "color": "9ee57a", "name": "Escarabat de jardí", "description": "Té una closca verda i potes fines."},
	"escarabat_termic": {"biome": 13, "color": "ff7651", "name": "Escarabat tèrmic", "description": "La closca de color brasa destaca sobre el terra."},
	"isopode_abissal": {"biome": 16, "segmented": true, "color": "cb86ed", "name": "Isòpode abissal", "description": "Les plaques rosades li protegeixen el llom."},
	"escarabat_llindar": {"biome": 19, "color": "f5d37c", "name": "Escarabat del Llindar", "description": "Té una closca daurada i ovalada."},
	"isopode_nucli": {"biome": 20, "segmented": true, "color": "e3edf2", "name": "Isòpode del Nucli", "description": "Les plaques clares li donen un aspecte nacrat."},
}
var fauna_sites: Dictionary = {}
const FAUNA_VARIANT_COLORS := ["f2ae61", "ef716b", "98dc79", "75d8ee", "c398f1", "e7e4ca"]
const FAUNA_VARIANT_COLOR_NAMES := ["ambre", "corall", "verd", "blau", "violeta", "ivori"]
const FAUNA_VARIANT_SIZES := ["molt petit", "petit", "mitjà", "gran", "molt gran"]
const FAUNA_VARIANT_PATTERNS := ["llis", "una franja", "dues franges", "taques"]
var fauna_species_by_room: Dictionary = {}
var fauna_patrol_ends: Dictionary = {}
var fauna_time := 0.0
var fauna_pause: Dictionary = {}

func _advance_fauna(delta: float) -> void:
	var room := _cave_at_position(unit_position)
	var previous := _fauna_position(room) if fauna_sites.has(room) else Vector2.INF
	fauna_time += delta
	if previous == Vector2.INF: return
	var proposed := _fauna_position(room)
	if proposed.distance_to(unit_position) < 22.0 and proposed.distance_to(unit_position) < previous.distance_to(unit_position):
		fauna_pause[room] = float(fauna_pause.get(room, 0.0)) + delta

func _fauna_blocks_player_step(start: Vector2, finish: Vector2) -> bool:
	var room := _cave_at_position(finish)
	if moving and room>=0 and _cave_at_position(start)==room:
		return false # Ordered travel through a room has priority over animal bodies.
	if not fauna_sites.has(room): return false
	var animal := _fauna_position(room)
	return Geometry2D.get_closest_point_to_segment(animal, start, finish).distance_to(animal) < 22.0 and finish.distance_to(animal) < start.distance_to(animal)

func _detour_around_fauna() -> Array[Vector2]:
	var result: Array[Vector2] = []
	if move_path.is_empty(): return result
	var goal: Vector2 = move_path[0]
	var room := _cave_at_position(unit_position)
	if room<0 or _cave_at_position(goal)!=room: return result
	var cell_size: float = world.cell_size
	var start := Vector2i((unit_position/cell_size).floor())
	var queue: Array[Vector2i] = [start]
	var previous := {start:start}
	var reached := Vector2i(-1,-1)
	var head := 0
	while head<queue.size() and head<4096:
		var cell := queue[head]
		head+=1
		var point := unit_position if cell==start else (Vector2(cell)+Vector2.ONE*0.5)*cell_size
		if not _fauna_blocks_player_step(point,goal) and _segment_is_walkable(point,goal) and point.distance_to(goal)<cell_size*2.0:
			reached=cell
			break
		for direction in [Vector2i.RIGHT,Vector2i.LEFT,Vector2i.UP,Vector2i.DOWN]:
			var next: Vector2i = cell+direction
			if previous.has(next): continue
			var next_point := (Vector2(next)+Vector2.ONE*0.5)*cell_size
			if not _point_inside_cave_id(next_point,room): continue
			if not _segment_is_walkable(point,next_point) or _fauna_blocks_player_step(point,next_point): continue
			previous[next]=cell
			queue.append(next)
	if reached.x<0: return result
	result.append(goal)
	while reached!=start:
		result.push_front((Vector2(reached)+Vector2.ONE*0.5)*cell_size)
		reached=previous[reached]
	return result
var fauna_path_world: Dictionary = {}
var fauna_safe_paths: Dictionary = {}
var seen_fauna: Dictionary = {}
var analyzed_fauna: Dictionary = {}
var selected_fauna := -1
var flora_samples: Dictionary = {}
var fauna_samples: Dictionary = {}
var selected_flora := -1
var collect_flora_button: Button
var bio_action_bar: HBoxContainer
const EQUIPMENT_FOOTER_HEIGHT := 30.0
const EQUIPMENT_ICON_HEIGHT := 26.0
var flora_catalog: AcceptDialog
var flora_catalog_text: Label
var catalog_grid: GridContainer
var field_photos: Dictionary = {}
var discovery_dialog: AcceptDialog
var discovery_portrait: Control
var discovery_photo: TextureRect
var discovery_species := ""
var discovery_is_fauna := false
var saved_photo_bytes: Dictionary = {}
var taking_field_photo := false
var discovery_capture_pending := false
var field_camera_button: Button
var base_catalog_button: Button
var catalogs_panel: Control
var cave_count_label: Label
var exit_count_label: Label
var blocked_exit_count_label: Label
var level_progress_strip: HBoxContainer
var level_progress_values: Array[Label] = []
var level_progress_meters: Array[ProgressBar] = []

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	_build_ui()
	_new_world(seed_value)
	get_viewport().size_changed.connect(_layout_panels)
	equipment_bar.resized.connect(_layout_panels)
	level_progress_strip.resized.connect(_layout_panels, CONNECT_DEFERRED)
	_layout_panels()
	_resume_autosave()

func _process(delta: float) -> void:
	_ensure_solid_room_rocks()
	if discovery_capture_pending or discovery_dialog.visible or delete_profile_dialog.visible:
		return
	if inventory_window.visible or field_repair_menu.visible: return
	if death_dialog.visible or victory_dialog.visible or profiles_dialog.visible or depth_trip_dialog.visible or restart_run_dialog.visible or rewards_dialog.visible or history_dialog.visible:
		return
	autosave_elapsed += delta
	if autosave_elapsed >= AUTOSAVE_SECONDS:
		_save_active_profile()
	_update_rockfall(delta)
	defence_system.tick(self,delta)
	if health<=0: return
	if analysis_mode and moving and inspection_corridor_id >= 0 and rockfall_corridor_id < 0 and rockfall_cooldown <= 0.0 and randf() < delta / 180.0 and _cave_at_position(unit_position) < 0:
		_warn_of_rockfall(inspection_corridor_id, true)
	if not surface_mode and not world.is_empty():
		_update_automatic_helmet_light(unit_position)
		_update_flashlight_charge(delta)
		var pressure_wear: float = [0.0, 0.03, 0.10, 0.15][mini(current_level, 3)]
		var environment := _room_environment(_cave_at_position(unit_position))
		var temperature_wear := 0.06 if environment == "calent" or environment == "gel" else 0.0
		if _modifier_protects("vestit", environment):
			temperature_wear *= 0.2
		suit_integrity = maxf(0.0, suit_integrity - delta * (pressure_wear * (1.0 - float(suit_tier) * 0.04) + temperature_wear))
		var time_without_oxygen := maxf(0.0, delta - oxygen_seconds)
		oxygen_seconds = maxf(0.0, oxygen_seconds - delta)
		if oxygen_seconds <= 0.0 and oxygen_cartridges > 0:
			_use_oxygen_cartridge()
		if oxygen_seconds <= 0.0 and time_without_oxygen > 0.0:
			health = maxf(0.0, health - time_without_oxygen * NO_OXYGEN_HEALTH_PER_SECOND)
			_update_health_display()
			if health <= 0.0:
				_end_expedition("OXIGEN ESGOTAT")
				return
		var emergency := _expedition_emergency()
		if not emergency.is_empty():
			_end_expedition(emergency)
			return
		_update_oxygen_display()
		_update_suit_display()
	_update_mining(delta)
	_update_bio_scan(delta)
	_update_field_action_cards()
	_update_resource_gain_cards()
	if not surface_mode:
		_advance_fauna(delta)
	if moving and analysis_mode:
		if selected_cave != current_cave_id:
			moving = false
			move_path.clear()
			selected_route.clear()
			chained_cave_id = -1
			if is_instance_valid(status_label):
				status_label.text = "SURT D'INSPECCIÓ PER MOURE'T ENTRE SALES"
	if moving and rockfall_clear_remaining <= 0.0:
		var remaining_distance := _movement_speed() * delta
		while remaining_distance > 0.0 and not move_path.is_empty():
			var difference: Vector2 = move_path[0] - unit_position
			var distance := difference.length()
			var next_position: Vector2
			var reaches_waypoint: bool = distance <= remaining_distance
			if reaches_waypoint:
				next_position = move_path[0]
				remaining_distance -= distance
			else:
				next_position = unit_position + difference / distance * remaining_distance
				remaining_distance = 0.0
			var can_light_step := flashlight_on or (flashlight_charge > 0.0 and helmet_light_zone_lit and not _has_ambient_light(next_position))
			if not can_light_step and not _is_discovered_move_segment(unit_position, next_position):
				if _cave_at_position(unit_position) >= 0:
					move_target = unit_position
					move_path.clear()
					chained_cave_id = -1
					use_elevator_on_arrival = false
					level_navigation_target = -1
				if not warned_dark_movement:
					_show_light_warning(_world_to_screen(unit_position), "PAS BLOQUEJAT")
					warned_dark_movement = true
				break
			warned_dark_movement = false
			var next_room := _cave_at_position(next_position)
			if next_room >= 0 and next_room != current_cave_id and not _can_enter_room_with_signal(next_room, inspection_corridor_id):
				move_target = unit_position
				move_path.clear()
				chained_cave_id = -1
				status_label.text = "FORA D’ABAST · CAL UNA BALISA"
				break
			if analysis_mode and not inspect_on_cave_arrival and selected_cave == current_cave_id and not _point_inside_cave_id(next_position, selected_cave):
				var gallery: Dictionary = _inspection_gallery()
				if gallery.is_empty() or (next_room != inspection_destination_cave_id and not _point_inside_corridor(next_position, gallery)):
					moving = false
					move_target = unit_position
					move_path.clear()
					selected_route.clear()
					chained_cave_id = -1
					remaining_distance = 0.0
					break
			if _rockfall_blocks_step(next_position, next_room):
				status_label.text = "PAS BLOQUEJAT · CLICA EL SENYAL TARONJA PER NETEJAR"
				break
			if _fauna_blocks_player_step(unit_position, next_position):
				var detour := _detour_around_fauna()
				if not detour.is_empty():
					move_path.pop_front()
					for index in range(detour.size()-1,-1,-1): move_path.push_front(detour[index])
				else:
					moving=false
					status_label.text="PAS OCUPAT PER FAUNA · TRIA UN ALTRE PUNT"
				break
			_apply_rockfall(next_position)
			if level_navigation_target < 0:
				_record_gallery_step(unit_position, next_position)
			var distance_walked := unit_position.distance_to(next_position)
			var distance_with_broken_boots := maxf(0.0, distance_walked - boots_integrity / _boots_wear_per_unit())
			boots_integrity = maxf(0.0, boots_integrity - distance_walked * _boots_wear_per_unit())
			if distance_with_broken_boots > 0.0:
				health = maxf(0.0, health - distance_with_broken_boots * BROKEN_BOOTS_HEALTH_PER_UNIT)
				_update_health_display()
			if not unit_position.is_equal_approx(next_position):
				explorer_facing = unit_position.direction_to(next_position)
			unit_position = next_position
			_update_automatic_helmet_light(unit_position)
			if health <= 0.0:
				_end_expedition("FERIDES PER CAMINAR AMB LES BOTES TRENCADES")
				return
			if reaches_waypoint:
				move_path.pop_front()
			_update_current_cave(true)
		if move_path.is_empty():
			# The last validated waypoint is the arrival; never jump to an
			# original click beyond the reachable portion of the route.
			move_target = unit_position
			_update_current_cave()
			moving = false
			if analysis_mode:
				inspect_on_cave_arrival = false
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
			var reveal_cave_id := _cave_at_position(unit_position)
			var reveal_radius := 3 if reveal_cave_id >= 0 and not explored_caves.has(reveal_cave_id) else 5
			if reveal_radius == 3 and _supply_tier("helmet_light") >= 3:
				reveal_radius = 4
			if flashlight_on:
				reveal_radius += 1
			_reveal_around(unit_position, reveal_radius)
		_update_current_cave()
		_update_beacon_status()
		_discover_exit_near_unit()
		_detect_caves_near_unit()
		_update_boots_display()
		_refresh_room_progress()
		if analysis_mode and selected_cave == current_cave_id and not dragging:
			_focus_world_position(unit_position, zoom_level)
		queue_redraw()
	if use_elevator_on_arrival and not moving:
		use_elevator_on_arrival = false
		_use_selected_level_access()
	if level_navigation_target >= 0 and not moving:
		var target := level_navigation_target
		level_navigation_target = -1
		_finish_level_navigation(target)
	if center_map_during_move:
		if not surface_mode and not analysis_mode:
			_focus_world_position(unit_position, zoom_level)
		if not moving or analysis_mode or surface_mode:
			center_map_during_move = false
	_update_base_return_availability()
	_detect_fauna_near_unit()
	_update_flora_button()
	if room_progress_label.visible:
		room_progress_label.queue_redraw()
	_update_field_equipment_buttons()
	_update_equipment_action_pulses()
	_update_low_supply_warning(delta)
	var entry := int(world.get("entry", -1))
	var animate_beacons := entry >= 0 and show_beacon_waves
	if _fauna_is_visible() or (not surface_mode and animate_beacons):
		queue_redraw()

func _draw() -> void:
	if world.is_empty():
		return
	if surface_mode:
		_draw_surface_base()
		return
	var view := _view_rect()
	if analysis_mode:
		_draw_isometric_room()
		_draw_rockfall()
		_draw_room_tooltip()
		return
	# Subtle star-field marks anchored to world coordinates, visible in the map only.
	for i in range(90):
		var p := _world_to_screen(Vector2(fposmod(i * 197.3, 2200.0), fposmod(i * 113.7, 1500.0)))
		if view.has_point(p):
			draw_circle(p, 1.0, Color(0.15, 0.28, 0.36, 0.4))
	var icon_scale := clampf(zoom_level / MAP_ENTRY_ZOOM, 0.42, 1.15)
	_draw_signal_ranges()
	for corridor in world.corridors:
		if not _should_draw_corridor(corridor) and not walked_gallery_spans.has(corridor.id):
			continue
		_draw_map_gallery(corridor)
	for cave in world.caves:
		if not _should_draw_cave(cave.id):
			continue
		var center := _world_to_screen(cave.position)
		var contour := _rounded_map_contour(cave.contour)
		var screen_contour := PackedVector2Array()
		for point in contour:
			screen_contour.append(center + point * zoom_level)
		screen_contour.append(screen_contour[0])
		var fill := Color("102a38") if cave.id != world.entry else Color("183a3e")
		if _room_is_complete(cave.id):
			fill = Color("254938")
		draw_colored_polygon(screen_contour, fill)
		if show_spawn and cave.id == world.entry:
			draw_circle(center, 7.0 * icon_scale, ORANGE)
			draw_circle(center, 12.0 * icon_scale, Color(ORANGE, 0.25), false, 1.2 * icon_scale)
		if zoom_level > 0.48 and zoom_level <= 0.82:
			draw_string(ThemeDB.fallback_font, center + Vector2(-4, 4) * icon_scale, str(cave.id + 1), HORIZONTAL_ALIGNMENT_CENTER, -1, maxi(7, roundi(11 * icon_scale)), Color("a9c8d1"))
	if zoom_level <= 0.82:
		_draw_cave_previews()
	if zoom_level > 0.82:
		_draw_cave_previews()
		for cave in world.caves:
			if not _should_draw_cave(cave.id):
				continue
			var center: Vector2 = cave.position
			var screen_center := _world_to_screen(center)
			if _is_revealed(center):
				draw_string(ThemeDB.fallback_font, screen_center + Vector2(-4, 4) * icon_scale, str(cave.id + 1), HORIZONTAL_ALIGNMENT_CENTER, -1, maxi(7, roundi(11 * icon_scale)), Color("a9c8d1"))
		for obstacle in world.obstacles:
			if (dev_mode or visited_caves.has(obstacle.cave_id)) and _is_revealed(obstacle.position):
				_draw_obstacle(obstacle)
	_draw_connected_map_outline()
	for cave in world.caves:
		if deployed_beacons.has(cave.id):
			var signal_center := _world_to_screen(cave.position)
			_draw_beacon_waves(signal_center, _beacon_range() * zoom_level, 1.0, Color("abbeff"))
			_draw_beacon_light(signal_center + Vector2(0, -38) * icon_scale, icon_scale, Color("abbeff"))
		if show_findings and _fauna_is_visible_in_room(cave.id):
			var fauna_marker := _world_to_screen(fauna_sites[cave.id])
			if explored_caves.has(cave.id):
				fauna_marker = _world_to_screen(cave.position) + Vector2(-20, -19) * icon_scale
			var observed := analyzed_fauna.has(cave.id)
			_draw_fauna_map_badge(self, fauna_marker, fauna_species_by_room.get(cave.id, "escarabat"), icon_scale, observed)
			if not observed:
				draw_string(ThemeDB.fallback_font, fauna_marker + Vector2(-15, 4) * icon_scale, "!", HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(7, roundi(12 * icon_scale)), ORANGE)
		if not explored_caves.has(cave.id):
			if show_findings and analyzed_flora.has(cave.id):
				_draw_flora_symbol(self, _world_to_screen(flora_sites[cave.id]), 0.85 * icon_scale, flora_species_by_room[cave.id])
			continue
		var marker := _world_to_screen(cave.position) + Vector2(0, -19) * icon_scale
		if cave.id == world.entry:
			_draw_beacon_waves(_world_to_screen(cave.position), _beacon_range() * zoom_level, 1.0, LEVEL_EXIT_BEACON_COLOR)
		if _has_level_elevator(cave.id):
			var access_text := _level_access_label(cave.id, true)
			_draw_elevator_sign(_world_to_screen(_level_access_position(cave.id)) + Vector2(0,22), access_text, cave.id != world.entry, maxf(0.95,icon_scale), _is_unopened_shaft(cave.id))
		if _is_biome_workshop(cave.id):
			_draw_workshop_badge(self, marker + Vector2(21, -19) * icon_scale, icon_scale)
		if _is_final_room(cave.id):
			_draw_final_room_marker(_world_to_screen(cave.position), icon_scale)
		var tasks := _room_tasks(cave.id)
		if tasks.x == tasks.y:
			_draw_room_complete_badge(self, marker, icon_scale)
		else:
			_draw_room_state_badge(marker, icon_scale, true)
		if show_findings and _flora_is_visible_in_room(cave.id):
			var plant_marker := marker + Vector2(-20, 0) * icon_scale
			_draw_flora_symbol(self, plant_marker, 0.7 * icon_scale, flora_species_by_room[cave.id])
			if not analyzed_flora.has(cave.id):
				draw_string(ThemeDB.fallback_font, plant_marker + Vector2(-13, 2) * icon_scale, "!", HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(7, roundi(12 * icon_scale)), ORANGE)
		if _has_accessible_pending_galleries(cave.id):
			_draw_room_state_badge(marker + Vector2(18, 0) * icon_scale, icon_scale, false)
		if show_findings:
			if _has_undetectable_trace(cave.id, false):
				_draw_biological_trace(self, marker + Vector2(-15, -18) * icon_scale, false, icon_scale)
			if _has_undetectable_trace(cave.id, true):
				_draw_biological_trace(self, marker + Vector2(15, -18) * icon_scale, true, icon_scale)
	for cave in world.caves:
		if cave.id != current_cave_id and not _can_inspect_cave(cave.id):
			continue
		for exit_info in _visible_exits_for_cave(cave.id):
			var gallery := _corridor_by_id(exit_info.corridor_id)
			if gallery.is_empty():
				continue
			var destination: int = gallery.b if gallery.a == cave.id else gallery.a
			var reachable := _can_enter_room_with_signal(destination, gallery.id, cave.id, false)
			if reachable and _can_inspect_cave(destination):
				continue
			var mouth := _world_to_screen(exit_info.position + exit_info.direction * 12.0)
			if not reachable:
				draw_line(_world_to_screen(exit_info.position), mouth, BLOCKED_GALLERY_COLOR, 1.5, true)
			draw_circle(mouth, 5.5 * icon_scale, PANEL, true, -1.0, true)
			draw_circle(mouth, 5.5 * icon_scale, ACCESSIBLE_GALLERY_COLOR if reachable else BLOCKED_GALLERY_COLOR, false, 1.5, true)
	var unit_screen := _world_to_screen(unit_position)
	draw_circle(unit_screen, 7.0 * icon_scale, ORANGE)
	draw_arc(unit_screen, 11.0 * icon_scale, 0, TAU, 16, Color("ffe2ba"), 1.4)
	if explored_caves.has(world.entry):
		_draw_beacon_light(_world_to_screen(world.caves[world.entry].position), icon_scale, LEVEL_EXIT_BEACON_COLOR)

	_draw_rockfall()
	_draw_room_tooltip()

func _room_gallery_progress(cave_id: int) -> Vector2i:
	var progress := Vector2i.ZERO
	for corridor in world.corridors:
		if corridor.a == cave_id or corridor.b == cave_id:
			progress.y += 1
			progress.x += int(completed_gallery_traces.has(corridor.id))
	return progress

func _room_tasks(cave_id: int) -> Vector2i:
	var progress := _room_gallery_progress(cave_id)
	progress += Vector2i(int(explored_caves.has(cave_id)), 1)
	for pair in [[flora_sites, analyzed_flora], [fauna_sites, analyzed_fauna], [material_sites, collected_materials]]:
		if pair[0].has(cave_id):
			progress += Vector2i(int(pair[1].has(cave_id)), 1)
	return progress

func _draw_room_complete_badge(canvas: CanvasItem, center: Vector2, icon_scale: float) -> void:
	var gold := Color("ffd17e")
	canvas.draw_circle(center, 8.0 * icon_scale, PANEL, true, -1.0, true)
	canvas.draw_circle(center, 8.0 * icon_scale, gold, false, 1.0, true)
	var star := PackedVector2Array()
	for index in range(10):
		var radius := (5.8 if index % 2 == 0 else 2.6) * icon_scale
		star.append(center + Vector2.from_angle(-PI * 0.5 + TAU * index / 10.0) * radius)
	canvas.draw_colored_polygon(star, gold)

func _draw_workshop_badge(canvas: CanvasItem, center: Vector2, icon_scale: float = 1.0) -> void:
	var outline := PackedVector2Array()
	for point in [Vector2(-9, 7), Vector2(-9, -1), Vector2(0, -8), Vector2(9, -1), Vector2(9, 7)]:
		outline.append(center + point * icon_scale)
	canvas.draw_colored_polygon(outline, PANEL)
	outline.append(outline[0])
	canvas.draw_polyline(outline, CYAN, 1.4, true)
	canvas.draw_rect(Rect2(center + Vector2(-2.5, 1) * icon_scale, Vector2(5, 6) * icon_scale), CYAN)

func _room_is_complete(cave_id: int) -> bool:
	if not explored_caves.has(cave_id):
		return false
	var progress := _room_tasks(cave_id)
	return progress.x == progress.y

func _draw_room_tooltip() -> void:
	pass # Details are displayed in the fixed right-hand panel.

func _room_detail_lines(cave_id: int) -> PackedStringArray:
	var lines := PackedStringArray()
	if explored_caves.has(cave_id):
		var galleries := _room_gallery_progress(cave_id)
		lines = PackedStringArray(["Escaneig complet", "Galeries recorregudes · %d/%d" % [galleries.x, galleries.y]])
		var closed := 0
		for exit_info in _visible_exits_for_cave(cave_id):
			if not _is_gallery_exit_accessible(_corridor_by_id(exit_info.corridor_id),cave_id): closed+=1
		if closed>0: lines.append("Galeries tancades · %d" % closed)
		for item in [
			[flora_sites, analyzed_flora, "Flora analitzada", "Flora pendent d’analitzar"],
			[fauna_sites, analyzed_fauna, "Fauna observada", "Fauna pendent d’observar"],
			[material_sites, collected_materials, "Veta extreta", "Veta pendent de minar"],
		]:
			if item[0].has(cave_id):
				lines.append(item[2] if item[1].has(cave_id) else item[3])
		if _room_needs_ferric_filter(cave_id):
			lines.append("Cal el filtre espectral fèrric")
		if cave_id == world.entry:
			lines.append("↑ Superfície · 0" if current_level == 1 else "↑ Accés a l’estrat −%d" % (current_level - 1))
		if _has_descent_elevator(cave_id):
			lines.append("↓ Accés a l’estrat −%d" % (current_level + 1))
		if _is_biome_workshop(cave_id):
			lines.append(_biome_base_name(current_level))
		if current_level<20 and (cave_id==world.entry or cave_id==descent_access):
			var ready := CampaignRules.requirement_met(self,_biome_at_depth(current_level))
			lines.append(("Equip preparat · " if ready else "Per superar el bioma · ") + _biome_exit_requirement())
	else:
		lines.append("Escaneig · %d%%" % floori(_room_reveal_ratio(world.caves[cave_id]) * 100.0))
	return lines

func _hovered_room(mouse: Vector2) -> int:
	var point := _screen_to_world(mouse)
	for cave in world.caves:
		if not _can_inspect_cave(cave.id):
			continue
		var contour: PackedVector2Array = _rounded_map_contour(cave.contour) if not analysis_mode and explored_caves.has(cave.id) else cave.contour
		if Geometry2D.is_point_in_polygon(point - cave.position, contour):
			return cave.id
	if show_findings and not analysis_mode:
		var scale := clampf(zoom_level / MAP_ENTRY_ZOOM, 0.42, 1.15)
		for cave in world.caves:
			if not explored_caves.has(cave.id):
				continue
			var center := _world_to_screen(cave.position)
			for fauna in [false, true]:
				var marker := center + Vector2(15 if fauna else -15, -37) * scale
				if mouse.distance_to(marker + Vector2(5, 0) * scale) <= 16.0 * scale and _has_undetectable_trace(cave.id, fauna):
					return cave.id
	return -1

func _update_rockfall(delta: float) -> void:
	rockfall_cooldown = maxf(0.0, rockfall_cooldown - delta)
	if rockfall_clear_remaining > 0.0:
		rockfall_clear_remaining = maxf(0.0, rockfall_clear_remaining - delta)
		if rockfall_clear_remaining <= 0.0:
			var wear := ROCKFALL_TOOL_WEAR if mining_tool_integrity >= ROCKFALL_TOOL_WEAR else 0.0
			mining_tool_integrity -= wear
			rockfall_remaining = 0.0
			rockfall_corridor_id = -1
			_update_equipment_display()
			status_label.text = "PAS NETEJAT · EINA DE MINERIA −%d%%" % int(wear) if wear > 0.0 else "PAS NETEJAT A MÀ"
		queue_redraw()
	if rockfall_remaining <= 0.0:
		return
	rockfall_remaining = maxf(0.0, rockfall_remaining - delta)
	if rockfall_remaining <= 0.0:
		if status_label.text.begins_with("DESPRENIMENT"):
			status_label.text = "LA POLS S’HA ASSENTAT · RETIRA LES PEDRES"
	queue_redraw()

func _warn_of_rockfall(corridor_id: int, inside: bool = false) -> bool:
	if corridor_id < 0 or rockfall_corridor_id >= 0 or rockfall_cooldown > 0.0 or (not inside and randf() >= ROCKFALL_CHANCE):
		return false
	var corridor := _corridor_by_id(corridor_id)
	if corridor.is_empty():
		return false
	var from_a: bool = corridor.a == current_cave_id
	var mouth: Vector2 = corridor.exit_a if from_a else corridor.exit_b
	var direction: Vector2 = corridor.direction_a if from_a else corridor.direction_b
	var target := mouth + direction * 30.0
	var route: PackedVector2Array = corridor.points
	var best_distance := INF
	for index in range(route.size() - 1):
		var point := Geometry2D.get_closest_point_to_segment(target, route[index], route[index + 1])
		var distance := point.distance_squared_to(target)
		if distance < best_distance and _cave_at_position(point) < 0:
			best_distance = distance
			rockfall_position = point
	if inside:
		rockfall_position = unit_position
	elif best_distance == INF:
		return false
	rockfall_corridor_id = corridor_id
	rockfall_remaining = ROCKFALL_SECONDS
	rockfall_cooldown = 25.0
	rockfall_hit = false
	status_label.text = "DESPRENIMENT · APROPA’T A LES PEDRES PER NETEJAR"
	if inside:
		_apply_rockfall(unit_position)
	queue_redraw()
	return true

func _apply_rockfall(point: Vector2) -> void:
	if rockfall_remaining <= 0.0 or rockfall_hit or point.distance_to(rockfall_position) > 14.0 or _cave_at_position(point) >= 0:
		return
	rockfall_hit = true
	suit_integrity = maxf(0.0, suit_integrity - ROCKFALL_SUIT_WEAR)
	health = maxf(0.0, health - 25.0)
	_update_equipment_display()
	status_label.text = "DESPRENIMENT · VIDA −25 · VESTIT −12"

func _rockfall_blocks_step(next_position: Vector2, next_room: int) -> bool:
	if rockfall_corridor_id < 0:
		return false
	var corridor := _corridor_by_id(rockfall_corridor_id)
	if corridor.is_empty():
		return false
	if next_room < 0 and _cave_at_position(unit_position) >= 0 and (current_cave_id == corridor.a or current_cave_id == corridor.b):
		var mouth: Vector2 = corridor.exit_a if current_cave_id == corridor.a else corridor.exit_b
		if next_position.distance_to(mouth) <= 48.0 and _point_inside_corridor(next_position, corridor):
			return true
	return next_position.distance_to(rockfall_position) <= 36.0 and next_position.distance_squared_to(rockfall_position) < unit_position.distance_squared_to(rockfall_position)

func _clear_rockfall_at(screen_position: Vector2) -> bool:
	if rockfall_corridor_id < 0:
		return false
	var target := rockfall_position
	var corridor := _corridor_by_id(rockfall_corridor_id)
	if not corridor.is_empty():
		for mouth: Vector2 in [corridor.exit_a, corridor.exit_b]:
			if _is_revealed(mouth) and screen_position.distance_to(_world_to_screen(mouth)) < screen_position.distance_to(_world_to_screen(target)):
				target = mouth
	if screen_position.distance_to(_world_to_screen(target)) > 24.0:
		return false
	if unit_position.distance_to(target) > 48.0:
		status_label.text = "APROPA’T A LES PEDRES PER RETIRAR-LES"
	elif rockfall_clear_remaining > 0.0:
		return true
	elif mining_cave >= 0 or bio_scan_room >= 0:
		status_label.text = "ACABA L’ACCIÓ EN CURS ABANS DE RETIRAR LES PEDRES"
	elif mining_tool_integrity < ROCKFALL_TOOL_WEAR and rockfall_remaining > 0.0:
		status_label.text = "ESPERA QUE S’ASSENTI LA POLS PER RETIRAR LES PEDRES A MÀ"
	else:
		rockfall_clear_remaining = ROCKFALL_CLEAR_SECONDS
		status_label.text = "RETIRANT LES PEDRES"
		queue_redraw()
	return true

func _draw_rockfall() -> void:
	if rockfall_corridor_id < 0:
		return
	var corridor := _corridor_by_id(rockfall_corridor_id)
	if corridor.is_empty():
		return
	var scale := _isometric_object_scale() if analysis_mode else clampf(zoom_level / MAP_ENTRY_ZOOM, 0.42, 1.0)
	var elapsed := ROCKFALL_SECONDS - rockfall_remaining
	var rubble := _world_to_screen(rockfall_position)
	if analysis_mode:
		var tangent: Vector2 = Vector2(corridor.exit_b - corridor.exit_a).normalized()
		var across := tangent.orthogonal()
		for i in range(9):
			var offset := across * float(i % 3 - 1) * 4.0 + tangent * float(int(i / 3) - 1) * 3.0
			_draw_biome_rock_sprite(rockfall_position + offset, 4.5 + float(i % 3), 1 + posmod(rockfall_corridor_id + i * 3, 7))
		if rockfall_remaining > 0.0 and elapsed < 5.0:
			for i in range(4):
				var phase := fposmod(elapsed * 1.4 + float(i) * 0.23, 1.0)
				var offset := across * float(i - 2) * 2.5 + Vector2(0, -lerpf(24.0, 0.0, phase))
				_draw_biome_rock_sprite(rockfall_position + offset, 1.5 + float(i % 2), 1 + posmod(i * 2 + rockfall_corridor_id, 7))
	else:
		draw_rect(Rect2(rubble - Vector2(5, 3), Vector2(10, 6)), Color("ad7759"))
	if rockfall_clear_remaining > 0.0:
		var remaining := _rockfall_clear_percent()
		var label_position := rubble + Vector2(-30, -22.0 * scale)
		draw_string_outline(ThemeDB.fallback_font, label_position, "%d%%" % remaining, HORIZONTAL_ALIGNMENT_CENTER, 60, 15, 4, BG)
		draw_string(ThemeDB.fallback_font, label_position, "%d%%" % remaining, HORIZONTAL_ALIGNMENT_CENTER, 60, 15, ORANGE)
	for mouth: Vector2 in [corridor.exit_a, corridor.exit_b]:
		if _is_revealed(mouth):
			var marker := _world_to_screen(mouth)
			var radius := maxf(5.0, 9.0 * scale)
			draw_circle(marker, radius, PANEL, true, -1.0, true)
			draw_circle(marker, radius, ORANGE, false, 1.5, true)
			draw_line(marker - Vector2(0, radius * 0.5), marker + Vector2(0, radius * 0.1), ORANGE, 1.5, true)
			draw_circle(marker + Vector2(0, radius * 0.45), 1.0, ORANGE)
	if rockfall_remaining <= 0.0:
		return
	for mouth in [corridor.exit_a, corridor.exit_b]:
		if not _is_revealed(mouth):
			continue
		var center := _world_to_screen(mouth)
		for index in range(12):
			var phase := fposmod(elapsed * 1.15 + float(index) * 0.21, 1.0)
			var offset := Vector2(sin(float(index) * 4.1) * (7.0 + phase * 15.0), lerpf(-24.0, 8.0, phase))
			var particle_size := maxf(1.0, roundf((2.0 + phase * 3.0) * scale))
			draw_rect(Rect2((center + offset * scale).round(), Vector2.ONE * particle_size), Color(0.91, 0.63, 0.40, 0.65 * (1.0 - phase)))

func _draw_signal_ranges(target: CanvasItem = null) -> void:
	if not show_signal_rings or taking_field_photo:
		return
	_draw_signal_range(world.entry, Color("72e7d1"), target)
	for cave_id in deployed_beacons:
		_draw_signal_range(cave_id, Color("abbeff"), target)

func _draw_signal_range(cave_id: int, color: Color, target: CanvasItem = null) -> void:
	var painter: CanvasItem = self if target == null else target
	var center := _world_to_screen(world.caves[cave_id].position)
	var radius := _beacon_range() * zoom_level
	var vertical_ratio := ISO_VERTICAL_RATIO if analysis_mode else 1.0
	for index in range(80):
		var angle := TAU * float(index) / 80.0
		var end_angle := angle + TAU * 0.58 / 80.0
		var start := center + Vector2(cos(angle), sin(angle) * vertical_ratio) * radius
		var finish := center + Vector2(cos(end_angle), sin(end_angle) * vertical_ratio) * radius
		painter.draw_line(start, finish, Color(color, 0.40 if analysis_mode else 0.28), 1.2, true)

func _draw_map_gallery(corridor: Dictionary) -> void:
	for span in _map_gallery_spans(corridor):
		var screen_points := PackedVector2Array()
		var joined := _map_gallery_span_at_mouths(span, corridor)
		for point in joined:
			screen_points.append(_world_to_screen(point))
		_draw_map_gallery_span(screen_points, float(corridor.width))
		if walked_gallery_spans.has(corridor.id):
			_draw_gallery_signal(joined, corridor)

func _draw_gallery_signal(span: PackedVector2Array, corridor: Dictionary) -> void:
	var sources := _signal_sources()
	var run := PackedVector2Array()
	for index in range(span.size() - 1):
		var start := span[index]
		var finish := span[index + 1]
		for interval in _covered_segment_intervals(start, finish, sources):
			var first := _world_to_screen(start.lerp(finish, interval.x))
			if not run.is_empty() and not run[run.size() - 1].is_equal_approx(first):
				_draw_map_gallery_span(run, float(corridor.width), Color("285571"))
				run.clear()
			if run.is_empty():
				run.append(first)
			run.append(_world_to_screen(start.lerp(finish, interval.y)))
	_draw_map_gallery_span(run, float(corridor.width), Color("285571"))

func _map_gallery_spans(corridor: Dictionary) -> Array:
	if dev_mode:
		return [corridor.points]
	if completed_gallery_traces.has(corridor.id):
		var points: PackedVector2Array = corridor.points
		var start := _project_to_polyline(corridor.exit_a, points)
		var finish := _project_to_polyline(corridor.exit_b, points)
		var span := PackedVector2Array([corridor.exit_a])
		span.append_array(points.slice(int(start.segment) + 1, int(finish.segment) + 1))
		span.append(corridor.exit_b)
		if explored_caves.has(corridor.a):
			span.insert(0, corridor.exit_a - corridor.direction_a * float(corridor.width) * 0.5)
		if explored_caves.has(corridor.b):
			span.append(corridor.exit_b - corridor.direction_b * float(corridor.width) * 0.5)
		return [span]
	return _drawn_gallery_spans(corridor)

func _drawn_gallery_spans(corridor: Dictionary) -> Array[PackedVector2Array]:
	var result: Array[PackedVector2Array] = []
	var route: PackedVector2Array = corridor.points
	var intervals: Array[Vector2] = []
	for trace: PackedVector2Array in walked_gallery_spans.get(corridor.id, []):
		var first := float(route.size())
		var last := -1.0
		for point in trace:
			var projection := _project_to_polyline(point, route)
			var position := float(projection.segment)+float(projection.t)
			first=minf(first,position)
			last=maxf(last,position)
		if last-first>0.0001: intervals.append(Vector2(first,last))
	intervals.sort_custom(func(a: Vector2,b: Vector2) -> bool: return a.x<b.x)
	var merged: Array[Vector2] = []
	for interval in intervals:
		if not merged.is_empty() and interval.x<=merged[-1].y+0.0001:
			merged[-1]=Vector2(merged[-1].x,maxf(merged[-1].y,interval.y))
		else: merged.append(interval)
	for interval in merged:
		var first_segment := mini(floori(interval.x),route.size()-2)
		var last_segment := mini(floori(interval.y),route.size()-2)
		var span := PackedVector2Array([route[first_segment].lerp(route[first_segment+1],interval.x-first_segment)])
		for index in range(first_segment+1,last_segment+1): span.append(route[index])
		var end := route[last_segment].lerp(route[last_segment+1],interval.y-last_segment)
		if not span[-1].is_equal_approx(end): span.append(end)
		result.append(span)
	return result

func _map_gallery_span_at_mouths(span: PackedVector2Array, corridor: Dictionary) -> PackedVector2Array:
	if dev_mode or completed_gallery_traces.has(corridor.id) or span.size() < 2:
		return span
	var result := span.duplicate()
	for end in range(2):
		for cave_id in [corridor.a, corridor.b]:
			var mouth: Vector2 = corridor.exit_a if cave_id == corridor.a else corridor.exit_b
			var direction: Vector2 = corridor.direction_a if cave_id == corridor.a else corridor.direction_b
			var reach: float = float(corridor.width) * 0.5 + world.cell_size
			var distance := result[0].distance_to(mouth)
			if distance > reach or distance > result[result.size() - 1].distance_to(mouth):
				continue
			var first_outside := 1
			var transition_length: float = float(corridor.width) * 1.35
			while first_outside < result.size() - 1 and result[first_outside].distance_to(mouth) < transition_length:
				first_outside += 1
			var join := result[first_outside]
			var tangent := (join - mouth).normalized()
			if first_outside + 1 < result.size():
				var next_direction := (result[first_outside + 1] - join).normalized()
				if next_direction.dot(tangent) > 0.3:
					tangent = next_direction
			var handle := mouth.distance_to(join) / 3.0
			var curve := PackedVector2Array()
			if explored_caves.has(cave_id):
				curve.append(mouth - direction * float(corridor.width) * 0.5)
			for step in range(8):
				var t := float(step) / 8.0
				curve.append(mouth.bezier_interpolate(mouth + direction * handle, join - tangent * handle, join, t))
			result = result.slice(first_outside)
			curve.append_array(result)
			result = curve
			break
		result.reverse()
	return result

func _draw_map_gallery_span(points: PackedVector2Array, width: float, color: Color = Color("183c49")) -> void:
	if points.size() < 2:
		return
	for polygon in _map_gallery_polygons(points, width):
		draw_colored_polygon(polygon, color)

func _map_gallery_polygons(points: PackedVector2Array, width: float) -> Array[PackedVector2Array]:
	return Geometry2D.offset_polyline(points, maxf(2.0, width * zoom_level * 0.225), Geometry2D.JOIN_ROUND, Geometry2D.END_ROUND)

func _rounded_map_contour(contour: PackedVector2Array) -> PackedVector2Array:
	var rounded := PackedVector2Array()
	for index in range(contour.size()):
		var corner := contour[index]
		var start := corner.lerp(contour[posmod(index - 1, contour.size())], 0.22)
		var finish := corner.lerp(contour[(index + 1) % contour.size()], 0.22)
		for step in range(5):
			var t := float(step) / 4.0
			rounded.append(start.lerp(corner, t).lerp(corner.lerp(finish, t), t))
	return rounded

func _draw_connected_map_outline() -> void:
	if not show_contours:
		return
	var outlines: Array[PackedVector2Array] = []
	var room_mouths: Array[Array] = []
	var open_mouths: Array[Dictionary] = []
	for cave in world.caves:
		if not explored_caves.has(cave.id):
			continue
		var polygon := PackedVector2Array()
		for point in _rounded_map_contour(cave.contour):
			polygon.append(_world_to_screen(cave.position + point))
		outlines.append(polygon)
		var mouths: Array[PackedVector2Array] = []
		for exit_info in _visible_exits_for_cave(cave.id):
			var depth: Vector2 = exit_info.direction * (float(exit_info.width) * 0.5 + world.cell_size)
			var mouth: Vector2 = exit_info.position
			var axis := PackedVector2Array([_world_to_screen(mouth - depth), _world_to_screen(mouth + depth)])
			mouths.append_array(Geometry2D.offset_polyline(axis, maxf(2.0, float(exit_info.width) * zoom_level * 0.225) + 0.75, Geometry2D.JOIN_ROUND, Geometry2D.END_BUTT))
		room_mouths.append(mouths)
	for corridor in world.corridors:
		if not _should_draw_corridor(corridor) and not walked_gallery_spans.has(corridor.id):
			continue
		for span in _map_gallery_spans(corridor):
			var points := PackedVector2Array()
			var joined_span := _map_gallery_span_at_mouths(span, corridor)
			for point in joined_span:
				points.append(_world_to_screen(point))
			if points.size() < 2:
				continue
			if not dev_mode:
				var half_width := maxf(2.0, float(corridor.width) * zoom_level * 0.225)
				for endpoint in [joined_span[0], joined_span[joined_span.size() - 1]]:
					for cave_id in [corridor.a, corridor.b]:
						if explored_caves.has(cave_id):
							continue
						var mouth: Vector2 = corridor.exit_a if cave_id == corridor.a else corridor.exit_b
						if _point_inside_cave_id(endpoint, cave_id) or endpoint.distance_to(mouth) <= world.cell_size:
							open_mouths.append({"center": _world_to_screen(endpoint), "radius": half_width + 0.75})
							break
			for polygon in _map_gallery_polygons(points, float(corridor.width)):
				# Unify repeated traversals before clipping shared edges.
				var combined: PackedVector2Array = polygon
				var gallery_index := room_mouths.size()
				while gallery_index < outlines.size():
					var merged := Geometry2D.merge_polygons(combined, outlines[gallery_index])
					if merged.size() == 1:
						combined = merged[0]
						outlines.remove_at(gallery_index)
						gallery_index = room_mouths.size()
					else:
						gallery_index += 1
				outlines.append(combined)
	for index in range(outlines.size()):
		var polygon := outlines[index]
		if polygon.size() < 3:
			continue
		polygon.append(polygon[0])
		if index < room_mouths.size():
			var room_edges: Array[PackedVector2Array] = [polygon]
			for mouth in room_mouths[index]:
				var remaining: Array[PackedVector2Array] = []
				for edge in room_edges:
					remaining.append_array(Geometry2D.clip_polyline_with_polygon(edge, mouth))
				room_edges = remaining
			for edge in room_edges:
				if edge.size() > 1:
					draw_polyline(edge, Color("448b99"), 1.3, true)
			continue
		var visible_edges: Array[PackedVector2Array] = [polygon]
		for other_index in range(outlines.size()):
			if other_index == index:
				continue
			var clipped: Array[PackedVector2Array] = []
			for edge in visible_edges:
				clipped.append_array(Geometry2D.clip_polyline_with_polygon(edge, outlines[other_index]))
			visible_edges = clipped
			if visible_edges.is_empty():
				break
		for edge in visible_edges:
			for point_index in range(edge.size() - 1):
				_draw_outline_edge(edge[point_index], edge[point_index + 1], open_mouths)

func _draw_outline_edge(a: Vector2, b: Vector2, mouths: Array[Dictionary]) -> void:
	var length := a.distance_to(b)
	if length < 0.001:
		return
	var direction := (b - a) / length
	var cuts: Array[Vector2] = []
	for mouth in mouths:
		var offset: Vector2 = mouth.center - a
		var along := offset.dot(direction)
		var half_gap_squared: float = mouth.radius * mouth.radius - (offset - direction * along).length_squared()
		if half_gap_squared <= 0.0:
			continue
		var half_gap := sqrt(half_gap_squared)
		var start := maxf(0.0, along - half_gap)
		var finish := minf(length, along + half_gap)
		if start < finish:
			cuts.append(Vector2(start, finish))
	cuts.sort_custom(func(left: Vector2, right: Vector2) -> bool: return left.x < right.x)
	var cursor := 0.0
	for cut in cuts:
		if cut.x > cursor:
			draw_line(a + direction * cursor, a + direction * cut.x, Color("448b99"), 1.3, true)
		cursor = maxf(cursor, cut.y)
	if cursor < length:
		draw_line(a + direction * cursor, b, Color("448b99"), 1.3, true)

func _record_gallery_step(start: Vector2, finish: Vector2) -> void:
	if start.is_equal_approx(finish):
		return
	var middle := start.lerp(finish, 0.5)
	if _cave_at_position(middle) >= 0:
		return
	var nearest_id := -1
	var nearest_distance := INF
	for corridor in world.corridors:
		var distance := _distance_to_polyline(middle, corridor.points)
		# The rasterized walking mask extends past the visual half-width.
		var mask_radius: float = ceilf(float(corridor.width) * 0.5 / world.cell_size) * world.cell_size
		if distance < nearest_distance and distance <= mask_radius + world.cell_size:
			nearest_id = int(corridor.id)
			nearest_distance = distance
	if nearest_id < 0:
		return
	if completed_gallery_traces.has(nearest_id):
		return
	var spans: Array = walked_gallery_spans.get(nearest_id, [])
	if spans.is_empty() or not spans.back()[spans.back().size() - 1].is_equal_approx(start):
		spans.append(PackedVector2Array([start, finish]))
	else:
		var span: PackedVector2Array = spans.pop_back()
		if span.size() >= 2 and (start - span[span.size() - 2]).normalized().dot((finish - start).normalized()) > 0.99999:
			span[span.size() - 1] = finish
		else:
			span.append(finish)
		spans.append(span)
	walked_gallery_spans[nearest_id] = spans

func _surface_art_scale() -> float:
	var available := _view_rect().size
	return clampf(minf(available.x / 900.0, available.y / 750.0), 0.65, 2.2)

func _surface_elevator_extent() -> Vector2:
	return Vector2(56, 32) * _surface_art_scale()

func _draw_surface_base() -> void:
	var size := get_viewport_rect().size
	var scale := _surface_art_scale()
	var hatch := _surface_hatch_center()
	surface_base_art.draw(self, size, hatch, scale, seed_value)
	_draw_elevator_platform(hatch, _surface_elevator_extent())
	_draw_elevator_sign(hatch + Vector2(0, 55) * scale, "BAIXA A L’ESTRAT -1", true, minf(1.8, 1.15 * scale))
	var explorer := hatch + Vector2(-87, -17) * scale
	draw_colored_polygon(_surface_ellipse_points(explorer, 12 * scale, 4.5 * scale, 20), Color("101014"))
	_draw_explorer_sprite(explorer, 1.2 * scale, explorer_facing, false)

func _surface_hatch_center() -> Vector2:
	var viewport_size := Vector2(1440, 900)
	if is_inside_tree():
		viewport_size = get_viewport_rect().size
	return viewport_size * 0.5 + Vector2(4, 109)

func _surface_ellipse_points(center: Vector2, radius_x: float, radius_y: float, point_count: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(point_count):
		var angle := TAU * float(index) / float(point_count)
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	return points

func _draw_surface_ellipse(center: Vector2, radius_x: float, radius_y: float, color: Color) -> void:
	draw_colored_polygon(_surface_ellipse_points(center, radius_x, radius_y, 32), color)

func _draw_surface_module(rect: Rect2, color: Color, accent: Color, label: String) -> void:
	var depth := Vector2(25, -38)
	var front_left := rect.position
	var front_right := Vector2(rect.end.x, rect.position.y)
	var roof := PackedVector2Array([front_left, front_right, front_right + depth, front_left + depth])
	var shadow := PackedVector2Array([rect.position + Vector2(11, 18), rect.end + Vector2(33, 20), rect.end + Vector2(67, -15), rect.position + Vector2(40, -15)])
	draw_colored_polygon(shadow, Color("211c23"))
	draw_colored_polygon(PackedVector2Array([front_right, front_right + depth, rect.end + depth, rect.end]), color.darkened(0.48))
	draw_rect(rect, color.darkened(0.23))
	draw_colored_polygon(roof, color)
	draw_line(front_left, front_right, accent, 2.2, true)
	draw_rect(Rect2(rect.position + Vector2(8, rect.size.y - 8), Vector2(rect.size.x - 16, 3)), color.darkened(0.56))
	for index in range(3):
		var window := Rect2(rect.position + Vector2(14 + index * 30, 13), Vector2(24, 14))
		draw_rect(window.grow(2), Color("303039"))
		draw_rect(window, Color("1c414e"))
		draw_line(window.position + Vector2(3, 2), window.position + Vector2(20, 2), accent, 2.0)
	var service_door := Rect2(rect.position + Vector2(rect.size.x - 39, 11), Vector2(25, 34))
	draw_rect(service_door, color.darkened(0.53))
	draw_rect(service_door, color.lightened(0.15), false, 1.0)
	draw_circle(service_door.position + Vector2(19, 17), 2.0, accent)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(11, rect.size.y - 11), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("f0e4d9"))

func _ensure_cave_render_cache() -> void:
	if is_same(render_cache_world, world) and render_cache_level == current_level:
		return
	render_cache_world = world
	render_cache_level = current_level
	render_room_polygons.clear()
	render_room_bounds.clear()
	render_corridor_walls.clear()
	render_wall_meshes.clear()
	render_wall_groups.clear()
	render_room_wall_spans.clear()
	render_corridor_floors.clear()
	render_room_lights.clear()
	render_surface_details.clear()
	render_gallery_lights.clear()
	for room in world.caves:
		var polygon := PackedVector2Array()
		var bounds := Rect2(room.position + room.contour[0], Vector2.ZERO)
		for point in room.contour:
			var absolute: Vector2 = room.position + point
			polygon.append(absolute)
			bounds = bounds.expand(absolute)
		render_room_polygons.append(polygon)
		render_room_bounds.append(bounds)

func _render_segment_on_screen(a: Vector2, b: Vector2, margin: float = 0.0) -> bool:
	var start := _world_to_screen(a)
	var finish := _world_to_screen(b)
	var bounds := Rect2(start, Vector2.ZERO).expand(finish).grow(maxf(1.0, margin))
	return get_viewport_rect().intersects(bounds)

func _render_path_on_screen(points: PackedVector2Array, margin: float) -> bool:
	for i in range(points.size() - 1):
		if _render_segment_on_screen(points[i], points[i + 1], margin):
			return true
	return false

func _cached_corridor_wall_spans(edges: Dictionary) -> Array:
	var key := hash([edges.left, edges.right])
	if render_corridor_walls.has(key):
		return render_corridor_walls[key]
	var spans: Array = []
	for side_index in range(2):
		var side: PackedVector2Array = edges.left if side_index == 0 else edges.right
		var other: PackedVector2Array = edges.right if side_index == 0 else edges.left
		for index in range(side.size() - 1):
			var pieces: Array[PackedVector2Array] = [PackedVector2Array([side[index], side[index + 1]])]
			var bounds := Rect2(side[index], Vector2.ZERO).expand(side[index + 1]).grow(0.01)
			for room_index in range(render_room_polygons.size()):
				if not bounds.intersects(render_room_bounds[room_index]):
					continue
				var remaining: Array[PackedVector2Array] = []
				for piece in pieces:
					remaining.append_array(Geometry2D.clip_polyline_with_polygon(piece, render_room_polygons[room_index]))
				pieces = remaining
				if pieces.is_empty():
					break
			for piece in pieces:
				if piece.size() >= 2:
					spans.append([piece[0], piece[1], 1.0 if side[index].y > other[index].y else -1.0,
						float(index + 1) / float(side.size() - 1)])
	if render_corridor_walls.size() >= 256:
		render_corridor_walls.clear()
	render_corridor_walls[key] = spans
	return spans

func _draw_isometric_room() -> void:
	_ensure_cave_render_cache()
	render_visible_gallery_walls.clear()
	if selected_cave < 0 or selected_cave >= world.caves.size():
		return
	var cave: Dictionary = world.caves[selected_cave]
	var gallery := _inspection_gallery()
	if gallery.is_empty() and isometric_passage_id >= 0:
		gallery = _corridor_by_id(isometric_passage_id)
		if not gallery.is_empty() and gallery.a != cave.id and gallery.b != cave.id:
			gallery = {}
	var in_gallery := (not gallery.is_empty() or (moving and inspect_on_cave_arrival)) and _cave_at_position(unit_position) < 0
	var passage_id := int(gallery.get("id", -1))
	render_active_passage_id = passage_id
	var occupied_room := _cave_at_position(unit_position)
	var visible_rooms: Array[Dictionary] = []
	for corridor in world.corridors:
		if corridor.id == passage_id or _gallery_has_lamps(corridor):
			_draw_isometric_passage(corridor, corridor.points)
		else:
			for span in _drawn_gallery_spans(corridor):
				_draw_isometric_passage(corridor, span)
	for room in world.caves:
		if room.id != cave.id and not _can_inspect_cave(room.id) and (gallery.is_empty() or (room.id != gallery.a and room.id != gallery.b)):
			continue
		var extent := Vector2.ONE * float(room.radius) * zoom_level * 2.0
		if room.id != cave.id and not get_viewport_rect().intersects(Rect2(_world_to_screen(room.position) - extent, extent * 2.0)):
			continue
		visible_rooms.append(room)
		_draw_isometric_corridors(room, passage_id)
		_draw_isometric_room_terrain(room, room.id == occupied_room)
		if _has_level_elevator(room.id):
			_draw_isometric_base_access(room)
	var room_lit := _room_is_fully_lit(cave.id)
	_draw_cave_lighting(flashlight_on and cave.id == current_cave_id, _point_in_lit_gallery(unit_position) if in_gallery else room_lit)
	for corridor in world.corridors:
		if _gallery_has_lamps(corridor):
			_draw_gallery_lamps(_isometric_corridor_edges(corridor.points, float(corridor.width) * 0.65))
	for room in visible_rooms:
		if _room_is_fully_lit(room.id):
			_draw_room_lamps(room, room.id == world.entry or _has_descent_elevator(room.id))
	for room in visible_rooms:
		if not taking_field_photo and _room_is_complete(room.id):
			var scale := _isometric_object_scale()
			_draw_room_complete_badge(self, _world_to_screen(room.position) + Vector2(0, -38) * scale, scale)
	_draw_depth_sorted_objects(visible_rooms, in_gallery or _point_inside_selected_cave(unit_position) or _point_inside_isometric_exit(unit_position, cave) or _point_inside_connected_corridor(unit_position, cave))
	if mining_cave == cave.id:
		_draw_mining_progress(cave.id)
	if bio_scan_room == cave.id:
		var progress: float = bio_scan_elapsed / _bio_scan_duration(bio_scanner_tier)
		_draw_field_progress(_world_to_screen(_bio_scan_target(cave.id, bio_scan_fauna)) - Vector2(0, 22), progress, CYAN)

func _depth_order_less(a: Dictionary, b: Dictionary) -> bool:
	if not is_equal_approx(a.point.y, b.point.y):
		return a.point.y < b.point.y
	return a.order < b.order

func _draw_depth_sorted_objects(rooms: Array[Dictionary], include_player: bool) -> void:
	var objects: Array[Dictionary] = []
	for item in world.get("recovery_caches_v1",[]):
		if not item.recovered and _is_revealed(item.position): objects.append({"kind":"recovery","point":item.position,"data":item,"order":1})
	for group in render_visible_gallery_walls:
		for span in group.spans:
			objects.append({"kind": "wall", "point": (span[0] + span[1]) * 0.5, "data": span, "order": 0, "fade": group.fade})
	for room in rooms:
		var scanned := explored_caves.has(room.id)
		for detail in world.get("ambience_v1", []):
			if detail.cave_id == room.id and (scanned or _is_revealed(detail.position)):
				objects.append({"kind":"ambience", "point":detail.position, "data":detail, "order":1})
		if scanned:
			for span in _room_wall_spans_for_cave(room):
				objects.append({"kind": "wall", "point": (span[0] + span[1]) * 0.5, "data": span, "order": 0})
		for rock in world.get("solid_room_rocks_v1", []):
			if rock.cave_id != room.id:
				continue
			var visible := true
			for offset in [Vector2.ZERO, Vector2(-7, 0), Vector2(7, 0), Vector2(0, -7), Vector2(0, 7)]:
				if not scanned and not _is_revealed(rock.position + offset): visible = false
			if visible:
				objects.append({"kind": "rock", "point": rock.position, "data": rock, "order": 1})
		for obstacle in world.obstacles:
			if _point_inside_cave_id(obstacle.position, room.id) and (scanned or _is_revealed(obstacle.position)):
				objects.append({"kind": "obstacle", "point": obstacle.position, "data": obstacle, "order": 1})
		if _material_rock_is_visible(room.id):
			objects.append({"kind": "mineral", "point": material_sites[room.id], "data": room.id, "order": 1})
		if _flora_is_visible_in_room(room.id):
			objects.append({"kind": "flora", "point": flora_sites[room.id], "data": room.id, "order": 2})
		if _fauna_is_visible_in_room(room.id):
			objects.append({"kind": "fauna", "point": _fauna_position(room.id), "data": room.id, "order": 3})
		for animal in [false, true]:
			var sites := fauna_sites if animal else flora_sites
			if _has_undetectable_trace(room.id, animal) and (_room_is_fully_lit(room.id) or _is_revealed(sites[room.id])):
				objects.append({"kind": "ghost", "point": _fauna_position(room.id) if animal else sites[room.id], "data": animal, "order": 3})
		if _room_is_fully_lit(room.id):
			for corner in _room_lantern_corners(room.contour):
				var anchor: Vector2 = _room_lamp_anchor(room, corner)
				objects.append({"kind": "lamp", "point": anchor, "data": null, "order": 2})
		var fixture_anchor: Vector2 = room.position
		if _is_biome_workshop(room.id):
			var footprint := _biome_base_footprint(room)
			if footprint.size() == 4:
				fixture_anchor = (footprint[0] + footprint[1] + footprint[2] + footprint[3]) * 0.25
		objects.append({"kind": "fixtures", "point": fixture_anchor, "data": room, "order": 2})
	if include_player and not taking_field_photo:
		objects.append({"kind": "player", "point": unit_position, "data": null, "order": 4})
	objects.sort_custom(_depth_order_less)
	var pending_walls: Array = []
	var pending_fade := false
	for object in objects:
		if object.kind == "wall":
			var fade: bool = object.get("fade", false)
			if not pending_walls.is_empty() and fade != pending_fade:
				_draw_wall_group(pending_walls, ["depth_batch", pending_walls, pending_fade], pending_walls[0][0], pending_fade)
				pending_walls = []
			pending_fade = fade
			pending_walls.append(object.data)
			continue
		if not pending_walls.is_empty():
			_draw_wall_group(pending_walls, ["depth_batch", pending_walls, pending_fade], pending_walls[0][0], pending_fade)
			pending_walls = []
		match object.kind:
			"recovery": defence_system.draw_cache(self,self,object.data)
			"ambience": preload("res://scripts/cave_ambience.gd").draw(self, object.data)
			"rock":
				if object.data.get("landmark",false): preload("res://scripts/biome_landmarks.gd").draw(self,object.data)
				else: _draw_biome_rock_sprite(object.point, float(object.data.get("visual_radius", float(object.data.radius) * 2.0)), int(object.data.variant))
			"obstacle": _draw_isometric_obstacle(object.data)
			"mineral": _draw_mineral_rock(object.data)
			"flora": _draw_flora_symbol(self, _world_to_screen(object.point), 1.4 * _isometric_organism_scale(), flora_species_by_room[object.data])
			"fauna": _draw_isometric_fauna(object.point, object.data)
			"ghost": _draw_ghost_organism(object.point, object.data)
			"fixtures": _draw_isometric_room_fixtures(object.data)
			"lamp":
				var extent := Vector2(4.5, 13) * zoom_level
				draw_texture_rect_region(ROOM_LANTERN, Rect2((_world_to_screen(object.point) - extent * Vector2(0.5, 0.98)).round(), extent), Rect2(310, 35, 275, 790))
			"player": _draw_isometric_explorer(unit_position)
	if not pending_walls.is_empty():
		_draw_wall_group(pending_walls, ["depth_batch", pending_walls, pending_fade], pending_walls[0][0], pending_fade)

	# Exit markers remain readable above the wall/object drawing pass.
	for room in rooms:
		_draw_isometric_exit_markers(room)
		if _has_level_elevator(room.id):
			_draw_elevator_sign(_world_to_screen(_level_access_position(room.id))+Vector2(0,22),_level_access_label(room.id),room.id!=world.entry,clampf(zoom_level/3.5,1.1,1.6),_is_unopened_shaft(room.id))

func _draw_isometric_exit_markers(cave: Dictionary) -> void:
	for exit_info in _visible_exits_for_cave(cave.id):
		var corridor := _corridor_by_id(exit_info.corridor_id)
		if corridor.is_empty(): continue
		var blocked := not _is_gallery_exit_accessible(corridor,cave.id)
		if not blocked and _gallery_was_crossed(corridor): continue
		var marker := _world_to_screen(exit_info.position+exit_info.direction*8.0)
		var scale := clampf(zoom_level/3.5,1.35,1.8)
		draw_set_transform(marker,0.0,Vector2.ONE*scale)
		draw_circle(Vector2.ZERO,13.0,Color("030a0e"))
		if blocked:
			_draw_blocked_exit_badge(self,Vector2.ZERO,1.0)
		else:
			draw_circle(Vector2.ZERO,10.0,Color("091e29"))
			draw_circle(Vector2.ZERO,10.0,Color("bcefff"),false,2.0,true)
			draw_string(ThemeDB.fallback_font,Vector2(-10,5),"?",HORIZONTAL_ALIGNMENT_CENTER,20,15,Color("e6fbff"))
		draw_set_transform(Vector2.ZERO)

func _draw_ghost_organism(point: Vector2, animal: bool) -> void:
	if not animal:
		var room := _cave_at_position(point)
		var species: String = flora_species_by_room.get(room,"falguera")
		var recipe := OrganismPixelArt.plant_recipe(species)
		if not recipe.is_empty():
			OrganismPixelArt.draw_plant(self,_world_to_screen(point),1.4*_isometric_organism_scale(),recipe,0.0,hash(species)&0x7fffffff,true)
			return
	var texture: Texture2D = OrganismPixelArt.BODY if animal else OrganismPixelArt.PLANT
	var grid := Vector2(4, 4) if animal else Vector2(4, 3)
	var cell := Vector2(texture.get_size()) / grid
	var size := Vector2(22, 22 * cell.y / cell.x) * _isometric_organism_scale()
	var source := Rect2(Vector2.ZERO if animal else Vector2(cell.x, 0), cell)
	draw_texture_rect_region(texture, Rect2(_world_to_screen(point) - size * Vector2(0.5,0.85),size), source, Color(0.65,0.85,0.9,0.32))
	if not animal:
		var leaf_size := size * 0.65
		for offset in [Vector2(-3,-6), Vector2(3,-9)]:
			draw_texture_rect_region(texture, Rect2(_world_to_screen(point) + offset * _isometric_organism_scale() - leaf_size * Vector2(0.5,0.5), leaf_size), Rect2(Vector2(cell.x * 2,0),cell),Color(0.65,0.85,0.9,0.32))

func _draw_isometric_room_features(cave_id: int) -> void:
	if _material_rock_is_visible(cave_id):
		_draw_mineral_rock(cave_id)
	if _flora_is_visible_in_room(cave_id):
		var plant_screen := _world_to_screen(flora_sites[cave_id])
		_draw_flora_symbol(self, plant_screen, 1.4 * _isometric_organism_scale(), flora_species_by_room[cave_id])
	if _fauna_is_visible_in_room(cave_id):
		_draw_isometric_fauna(_fauna_position(cave_id), cave_id)

func _mineral_sprite_rect(cave_id: int) -> Rect2:
	var cell_size := Vector2(MINERAL_ROCK_SPRITES.get_size()) / Vector2(4, 1)
	var size := Vector2(24.0, 24.0 * cell_size.y / cell_size.x) * zoom_level
	var anchor := _world_to_screen(material_sites[cave_id])
	return Rect2((anchor - size * Vector2(0.5, 0.79)).round(), size)

func _mineral_hit_test(cave_id: int, screen_point: Vector2) -> bool:
	if not _material_is_visible(cave_id):
		return false
	var area := _mineral_sprite_rect(cave_id)
	if not area.has_point(screen_point):
		return false
	if mineral_hit_image == null:
		mineral_hit_image = MINERAL_ROCK_SPRITES.get_image()
	var index := ["ferro", "quars", "magnetita"].find(_mineral_type(cave_id))
	if index < 0:
		return false
	var cell_width := mineral_hit_image.get_width() / 4
	var uv := (screen_point - area.position) / area.size
	if not mineral_hit_silhouettes.has(index):
		# A whole rock is one target, including cracks between its slabs.
		# Cache its outer silhouette; transparent atlas margins stay unclickable.
		var outline := PackedVector2Array()
		for row in range(mineral_hit_image.get_height()):
			var first := -1
			var last := -1
			for column in range(int(cell_width)):
				if mineral_hit_image.get_pixel(index * int(cell_width) + column, row).a >= 0.15:
					if first < 0:
						first = column
					last = column
			if first >= 0:
				outline.append(Vector2(first, row))
				outline.append(Vector2(first, row + 1))
				outline.append(Vector2(last + 1, row))
				outline.append(Vector2(last + 1, row + 1))
		mineral_hit_silhouettes[index] = Geometry2D.convex_hull(outline)
	return Geometry2D.is_point_in_polygon(uv * Vector2(cell_width, mineral_hit_image.get_height()), mineral_hit_silhouettes[index])

func _draw_mineral_rock(cave_id: int) -> void:
	var index := 3
	if _material_is_visible(cave_id):
		index = ["ferro", "quars", "magnetita"].find(_mineral_type(cave_id))
		if index < 0:
			index = 3
	var cell_size := Vector2(MINERAL_ROCK_SPRITES.get_size()) / Vector2(4, 1)
	var source := Rect2(Vector2(index * cell_size.x, 0), cell_size)
	var sprite_rect := _mineral_sprite_rect(cave_id)
	var anchor := _world_to_screen(material_sites[cave_id])
	var biome := _biome_at_depth(current_level)
	var tint := Color(BIOME_ROCK[biome][2]).lerp(Color.WHITE, 0.65)
	var ore_colors := [Color("f3b46d"), Color("e6d9ff"), Color("9ccee9")]
	var clock := float(Time.get_ticks_msec()) / 1000.0 + float(cave_id) * 1.73
	var pulse := 0.5 + 0.5 * sin(clock * 1.8)
	if index < 3:
		var ore_color: Color = ore_colors[index]
		var center := anchor - Vector2(0, 3.0) * zoom_level
		for ring in range(4, 0, -1):
			var halo := _surface_ellipse_points(center, (7.0 + ring * 1.6) * zoom_level,
				(2.5 + ring * 0.6) * zoom_level, 20)
			draw_colored_polygon(halo, Color(ore_color, (0.012 + pulse * 0.008)))
		# Keep the painted mineral readable without replacing its texture.
		tint = tint.lerp(Color.WHITE, 0.22 + pulse * 0.12)
	draw_texture_rect_region(MINERAL_ROCK_SPRITES,
		sprite_rect, source, tint, false, true)
	if index < 3 and not taking_field_photo:
		var highlights := [Vector2(-3.5, -6.5), Vector2(1.5, -9.0), Vector2(5.5, -4.5)]
		for i in range(highlights.size()):
			var shimmer := pow(maxf(0.0, sin(clock * 2.4 + i * 2.1)), 10.0)
			if shimmer < 0.08:
				continue
			var point: Vector2 = (anchor + highlights[i] * zoom_level).round()
			var pixel := maxf(1.0, roundf(zoom_level * 0.35))
			var ink := Color(Color(ore_colors[index]).lerp(Color.WHITE, 0.7), shimmer * 0.85)
			draw_rect(Rect2(point - Vector2(pixel * 1.5, pixel * 0.5), Vector2(pixel * 3, pixel)), ink)
			draw_rect(Rect2(point - Vector2(pixel * 0.5, pixel * 1.5), Vector2(pixel, pixel * 3)), ink)

func _draw_isometric_room_fixtures(cave: Dictionary) -> void:
	var beacon_position := _world_to_screen(cave.position)
	if _is_final_room(cave.id) and explored_caves.has(cave.id):
		_draw_final_room_marker(beacon_position, _isometric_object_scale())
	var beacon_scale := minf(zoom_level / 4.0, 1.6)
	if deployed_beacons.has(cave.id):
		_draw_deployed_beacon(cave.id)
	if cave.id == world.entry:
		_draw_beacon_light(beacon_position, beacon_scale, LEVEL_EXIT_BEACON_COLOR)
		if _is_biome_workshop(cave.id):
			_draw_biome_base_module(cave)

func _biome_module_texture(profile: int) -> Texture2D:
	if profile == 1: return OXIDIZED_BASE_TEXTURE
	if profile == 4: return CRYSTALLINE_BASE_TEXTURE
	if biome_module_textures.has(profile): return biome_module_textures[profile]
	var index := OTHER_BIOME_PROFILES.find(profile)
	if index < 0: return null
	var texture := AtlasTexture.new()
	texture.atlas = OTHER_BIOME_BASES
	var cell := Vector2(OTHER_BIOME_BASES.get_size()) / Vector2(3, 2)
	texture.region = Rect2(Vector2(index % 3, floori(float(index) / 3.0)) * cell, cell)
	texture.filter_clip = true
	biome_module_textures[profile] = texture
	return texture

func _draw_biome_base_module(cave: Dictionary) -> void:
	var footprint := _biome_base_footprint(cave)
	if footprint.is_empty():
		return
	var profile := _biome_at_depth(current_level)
	var base_texture := _biome_module_texture(profile)
	if base_texture != null:
		var anchor := Vector2.ZERO
		for point in footprint:
			anchor += point
		anchor /= float(footprint.size())
		var footprint_scale := footprint[0].distance_to(footprint[1]) / 52.0
		var sprite_size := Vector2(base_texture.get_size()) * zoom_level * (float(OXIDIZED_BASE_TEXTURE.get_width()) / float(base_texture.get_width())) * 0.034 * footprint_scale
		if profile in OTHER_BIOME_PROFILES:
			# Atlas cells have tighter padding than the original standalone module.
			sprite_size *= 0.62
		# The contact point is the bottom of the front support, not the image margin.
		var contact := 0.96 if profile in OTHER_BIOME_PROFILES else 0.88
		var sprite_rect := Rect2(_world_to_screen(anchor) - sprite_size * Vector2(0.5, contact), sprite_size)
		draw_texture_rect(base_texture, sprite_rect, false)
		return
	var ground := PackedVector2Array()
	var roof := PackedVector2Array()
	var scale := _isometric_object_scale()
	var height := Vector2(0, -15.0 * zoom_level)
	for corner in footprint:
		var screen := _world_to_screen(corner)
		ground.append(screen)
		roof.append(screen + height)
	var palette := _biome_base_palette(current_level)
	var accent: Color = palette.accent
	var secondary: Color = palette.secondary
	var shell: Color = palette.shell
	var shell_light: Color = palette.shell_light
	# Low, stepped shadow keeps the footprint visibly seated on the same projected floor.
	draw_colored_polygon(PackedVector2Array([
		ground[0] + Vector2(0, 2.0 * scale), ground[1] + Vector2(0, 2.0 * scale),
		ground[2] + Vector2(0, 2.0 * scale), ground[3] + Vector2(0, 2.0 * scale),
	]), Color("080d13", 0.92))
	# Four short feet touch the rock plane; their top anchors use the room's world projection.
	for index in range(4):
		var foot := ground[index].lerp(ground[(index + 1) % 4], 0.5)
		var foot_size := 2.0 * scale
		draw_rect(Rect2(foot + Vector2(-foot_size, -foot_size * 0.25), Vector2(foot_size * 2.0, foot_size)), Color("101820"))
	draw_colored_polygon(PackedVector2Array([ground[0], ground[1], ground[2], ground[3]]), Color("11151d"))
	draw_colored_polygon(PackedVector2Array([ground[1], ground[2], roof[2], roof[1]]), shell)
	draw_colored_polygon(PackedVector2Array([ground[2], ground[3], roof[3], roof[2]]), Color("202b35"))
	draw_colored_polygon(PackedVector2Array([ground[0], ground[1], roof[1], roof[0]]), Color("131d27"))
	draw_colored_polygon(roof, shell_light)
	draw_polyline(PackedVector2Array([roof[0], roof[1], roof[2], roof[3], roof[0]]), Color("a3aeb0"), maxf(1.0, scale))
	# Roof service panels and a high contrast front edge survive the normal entry zoom.
	var roof_mid := roof[0].lerp(roof[2], 0.5)
	draw_line(roof[0].lerp(roof[1], 0.18), roof[0].lerp(roof[1], 0.82), Color("313d47"), maxf(1.0, scale))
	draw_rect(Rect2(roof_mid + Vector2(-3.0, -1.5) * scale, Vector2(6.0, 3.0) * scale), Color("354653"))
	var front_a := ground[3]
	var front_b := ground[2]
	# Biome accent strip beside the recognizable entry door.
	_draw_base_front_panel(front_a, front_b, height, Rect2(0.08, 0.35, 0.08, 0.54), secondary)
	_draw_base_front_panel(front_a, front_b, height, Rect2(0.19, 0.42, 0.22, 0.24), Color("101c26"))
	_draw_base_front_panel(front_a, front_b, height, Rect2(0.215, 0.48, 0.17, 0.12), accent)
	_draw_base_front_panel(front_a, front_b, height, Rect2(0.48, 0.0, 0.32, 0.78), Color("d47b45"))
	_draw_base_front_panel(front_a, front_b, height, Rect2(0.515, 0.0, 0.25, 0.71), Color("121b24"))
	_draw_base_front_panel(front_a, front_b, height, Rect2(0.545, 0.12, 0.035, 0.38), accent)
	_draw_base_front_panel(front_a, front_b, height, Rect2(0.83, 0.36, 0.07, 0.16), accent)
	_draw_base_front_panel(front_a, front_b, height, Rect2(0.92, 0.31, 0.035, 0.12), secondary)
	for index in range(3):
		var stripe := front_a.lerp(front_b, 0.12 + index * 0.09)
		draw_line(stripe - height * 0.15, stripe + (front_b - front_a) * 0.035 - height * 0.72, Color("75818a"), maxf(1.0, scale))
	# Twin service lamps make the front face read as an occupied entrance, not a crate.
	var lamp_left := front_a.lerp(front_b, 0.43) + height * 0.72
	var lamp_right := front_a.lerp(front_b, 0.86) + height * 0.72
	draw_rect(Rect2(lamp_left - Vector2(1.5, 1.5) * scale, Vector2(3.0, 2.5) * scale), accent)
	draw_rect(Rect2(lamp_right - Vector2(1.5, 1.5) * scale, Vector2(3.0, 2.5) * scale), secondary)
	# Antenna mast and beacon remain on the roof and use the same camera transform.
	var mast := roof[0].lerp(roof[1], 0.67)
	var mast_tip := mast + height * 0.55
	draw_line(mast, mast_tip, Color("a7bac2"), maxf(1.0, scale))
	draw_rect(Rect2(mast_tip - Vector2(1.5, 1.5) * scale, Vector2(3.0, 3.0) * scale), accent)
	draw_rect(Rect2(mast_tip + Vector2(2.0, 0.5) * scale, Vector2(2.0, 1.5) * scale), secondary)
	if _isometric_object_scale() >= 0.60:
		var label_position := roof[0].lerp(roof[2], 0.5) + height * 0.65
		draw_string(ThemeDB.fallback_font, label_position - Vector2(130, 5),
			_biome_base_name(current_level), HORIZONTAL_ALIGNMENT_CENTER, 260, 12, accent)

func _biome_base_palette(depth: int) -> Dictionary:
	var profile := _biome_at_depth(depth)
	var accents := {
		1: [Color("54d7e7"), Color("e69a59"), Color("202c37"), Color("596878")],
		4: [Color("c39aff"), Color("f1a66b"), Color("292334"), Color("635875")],
		7: [Color("86d8f5"), Color("f1b66c"), Color("1c303d"), Color("536c7a")],
		10: [Color("a5df78"), Color("f1a66b"), Color("233127"), Color("596b51")],
		13: [Color("ff9667"), Color("f5cb72"), Color("34231f"), Color("745144")],
		16: [Color("e27be0"), Color("ffac62"), Color("2b2131"), Color("66516b")],
		19: [Color("d3bd7a"), Color("ff9e68"), Color("2e302c"), Color("6a6654")],
		20: [Color("75d6ce"), Color("ffc071"), Color("203034"), Color("53696b")],
	}
	var colors: Array = accents.get(profile, accents[1])
	return {"accent": colors[0], "secondary": colors[1], "shell": colors[2], "shell_light": colors[3]}

func _biome_base_footprint(cave: Dictionary) -> PackedVector2Array:
	if cave.id == world.get("entry", -1) and world.has("base_solid_footprint_v1"):
		return world.base_solid_footprint_v1
	var contour: PackedVector2Array = cave.contour
	var right := Vector2.from_angle(PI / 6.0)
	var forward := right.orthogonal()
	var positions := Array(contour)
	var access_local: Vector2 = _level_access_position(cave.id) - cave.position if cave.id == world.get("entry", -1) else Vector2.ZERO
	positions.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.distance_squared_to(access_local) > b.distance_squared_to(access_local))
	# Older saves retain smaller entry rooms: search progressively smaller modules too.
	for size: float in [1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2]:
		for inset: float in [0.62, 0.54, 0.70, 0.78, 0.44]:
			for position: Vector2 in positions:
				var anchor: Vector2 = position * inset
				var footprint := PackedVector2Array()
				var nearest_access_distance := INF
				for corner in [Vector2(-26, -17), Vector2(26, -17), Vector2(26, 17), Vector2(-26, 17)]:
					var point: Vector2 = anchor + (right * corner.x + forward * corner.y) * size
					if not Geometry2D.is_point_in_polygon(point, contour):
						break
					nearest_access_distance = minf(nearest_access_distance, point.distance_to(access_local))
					footprint.append(cave.position + point)
				if footprint.size() != 4 or nearest_access_distance < 14.0:
					continue
				# Reserve the actual projected sprite rectangle, including its height.
				# Ground distance alone cannot prevent the roof covering the elevator.
				var projected_anchor := Vector2(anchor.x, anchor.y * ISO_VERTICAL_RATIO)
				var visual_size := Vector2(OXIDIZED_BASE_TEXTURE.get_size()) * 0.034 * size
				var visual_rect := Rect2(projected_anchor - Vector2(visual_size.x * 0.5, visual_size.y), visual_size)
				var access_projected := Vector2(access_local.x, access_local.y * ISO_VERTICAL_RATIO)
				var access_rect := Rect2(access_projected - Vector2(12, 10), Vector2(24, 25))
				if not visual_rect.intersects(access_rect):
					return footprint
	return PackedVector2Array()

func _draw_base_front_panel(a: Vector2, b: Vector2, height: Vector2, area: Rect2, ink: Color) -> void:
	var left := a.lerp(b, area.position.x)
	var right := a.lerp(b, area.end.x)
	draw_colored_polygon(PackedVector2Array([
		left + height * area.position.y, right + height * area.position.y,
		right + height * area.end.y, left + height * area.end.y,
	]), ink)

func _is_final_room(cave_id: int) -> bool:
	return current_level == CAMPAIGN_DEPTH and cave_id >= 0 and cave_id == world.get("objective", -1)

func _draw_final_room_marker(center: Vector2, marker_scale: float) -> void:
	var radius := 10.0 * marker_scale
	var diamond := PackedVector2Array([Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT])
	for index in range(diamond.size()):
		diamond[index] = center + diamond[index] * radius
	draw_colored_polygon(diamond, PANEL)
	diamond.append(diamond[0])
	draw_polyline(diamond, CYAN, 1.5, true)
	draw_circle(center, radius * 0.36, CYAN)

func _draw_isometric_room_terrain(cave: Dictionary, occupied: bool) -> void:
	var contour: PackedVector2Array = cave.contour
	var room_is_scanned: bool = explored_caves.has(cave.id)
	var floor_tint := Color.WHITE
	if current_level==1: floor_tint=Color(0.76,0.88,0.94)
	if occupied:
		floor_tint *= Color(1.28, 1.23, 1.12)
	var local_bounds := Rect2(contour[0], Vector2.ZERO)
	for point in contour:
		local_bounds = local_bounds.expand(point)
	var min_cell_x := maxi(0, floori((cave.position.x + local_bounds.position.x) / world.cell_size))
	var max_cell_x := mini(world.grid_size.x - 1, ceili((cave.position.x + local_bounds.end.x) / world.cell_size))
	var min_cell_y := maxi(0, floori((cave.position.y + local_bounds.position.y) / world.cell_size))
	var max_cell_y := mini(world.grid_size.y - 1, ceili((cave.position.y + local_bounds.end.y) / world.cell_size))
	if room_is_scanned:
		var known_contour := PackedVector2Array()
		for point in contour:
			known_contour.append(_world_to_screen(cave.position + point))
		draw_colored_polygon(known_contour, Color("432e2c"))
	_draw_isometric_floor(cave, min_cell_x, max_cell_x, min_cell_y, max_cell_y, floor_tint)
	preload("res://scripts/cave_ambience.gd").draw_floor_relief(self,cave,floor_tint)
	_draw_room_surface_details(cave)

func _room_surface_details(cave: Dictionary) -> Array:
	_ensure_cave_render_cache()
	if render_surface_details.has(cave.id): return render_surface_details[cave.id]
	var result: Array = preload("res://scripts/cave_wet_features.gd").pools(self,cave)
	render_surface_details[cave.id]=result
	return result

func _draw_room_surface_details(cave: Dictionary) -> void:
	var profile := [1,4,7,10,13,16,19,20].find(_biome_at_depth(current_level))
	var cell := Vector2(1.0 / 4.0, 1.0 / 2.0)
	var origin := Vector2(profile % 4, floori(float(profile) / 4.0)) * cell
	var uvs := PackedVector2Array([origin, origin + Vector2(cell.x,0), origin + cell, origin + Vector2(0,cell.y)])
	for pool in _room_surface_details(cave):
		var shape := PackedVector2Array()
		for point in pool.shape: shape.append(_world_to_screen(point))
		var mapped := PackedVector2Array()
		for uv in pool.get("local_uvs",[]): mapped.append(origin+uv*cell)
		draw_polygon(shape, PackedColorArray([Color.WHITE]), mapped if not mapped.is_empty() else uvs, BIOME_POOLS)

func _draw_room_state_badge(marker: Vector2, icon_scale: float, completed: bool, canvas: CanvasItem = self) -> void:
	var color := Color("72e7d1") if completed else ACCESSIBLE_GALLERY_COLOR
	canvas.draw_circle(marker, 7.5 * icon_scale, Color("0b2525") if completed else PANEL, true, -1.0, true)
	canvas.draw_circle(marker, 7.5 * icon_scale, color, false, 1.0, true)
	if completed:
		canvas.draw_polyline(PackedVector2Array([marker + Vector2(-3, 0) * icon_scale, marker + Vector2(-1, 2) * icon_scale, marker + Vector2(3, -2) * icon_scale]), color, 1.6, true)
	else:
		canvas.draw_string(ThemeDB.fallback_font, marker + Vector2(-8, 4) * icon_scale, "?", HORIZONTAL_ALIGNMENT_CENTER, 16 * icon_scale, maxi(7, roundi(11 * icon_scale)), color)

func _draw_isometric_room_badges() -> void:
	var cave_id := _hud_room_id()
	if room_progress_label.text == "GALERIA" or cave_id < 0:
		return
	var center := Vector2(room_progress_label.size.x * 0.5, 50.0)
	var completed := explored_caves.has(cave_id)
	if completed and _room_needs_ferric_filter(cave_id):
		room_progress_label.draw_string(ThemeDB.fallback_font, Vector2(0, 73),
			"ESCÀNER · CAL EL FILTRE ESPECTRAL FÈRRIC", HORIZONTAL_ALIGNMENT_CENTER,
			room_progress_label.size.x, 12, Color("ffd17e"))
	var badges: Array[String] = []
	if show_findings and _flora_is_visible_in_room(cave_id):
		badges.append("flora")
	elif show_findings and completed and _has_undetectable_trace(cave_id, false):
		badges.append("flora_trace")
	if show_findings and _fauna_is_visible_in_room(cave_id):
		badges.append("fauna")
	elif show_findings and completed and _has_undetectable_trace(cave_id, true):
		badges.append("fauna_trace")
	if _mineral_site_discovered(cave_id):
		badges.append("mineral")
	if completed:
		badges.append("complete" if _room_is_complete(cave_id) else "completed")
		if _has_accessible_pending_galleries(cave_id):
			badges.append("galleries")
	if cave_id == world.entry and completed:
		badges.append("up")
	if _has_descent_elevator(cave_id):
		badges.append("down")
	if _is_biome_workshop(cave_id) and completed:
		badges.append("workshop")
	for exit_info in _visible_exits_for_cave(cave_id):
		if not _is_gallery_exit_accessible(_corridor_by_id(exit_info.corridor_id), cave_id):
			badges.append("blocked")
			break
	for index in range(badges.size()):
		var marker := center + Vector2((float(index) - (badges.size() - 1) * 0.5) * 29.0, 0)
		match badges[index]:
			"completed", "galleries":
				_draw_room_state_badge(marker, 1.0, badges[index] == "completed", room_progress_label)
			"complete":
				_draw_room_complete_badge(room_progress_label, marker, 1.0)
			"up", "down":
				_draw_elevator_icon(room_progress_label, marker, badges[index] == "down", 0.9)
			"workshop":
				_draw_workshop_badge(room_progress_label, marker)
			"blocked":
				_draw_blocked_exit_badge(room_progress_label, marker, 0.75)
			"mineral":
				_draw_mineral_badge(room_progress_label, marker, collected_materials.has(cave_id))
			"flora_trace", "fauna_trace":
				_draw_biological_trace(room_progress_label, marker, badges[index] == "fauna_trace")
			"flora":
				_draw_flora_symbol(room_progress_label, marker + Vector2(0, 8), 1.12, flora_species_by_room[cave_id])
				if not analyzed_flora.has(cave_id):
					room_progress_label.draw_string(ThemeDB.fallback_font, marker + Vector2(-13, 4), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, ORANGE)
			"fauna":
				var observed := analyzed_fauna.has(cave_id)
				_draw_fauna_map_badge(room_progress_label, marker, fauna_species_by_room.get(cave_id, "escarabat"), 1.2, false, true)
				if not observed:
					room_progress_label.draw_string(ThemeDB.fallback_font, marker + Vector2(-13, 4), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, ORANGE)

func _draw_biological_trace(canvas: CanvasItem, center: Vector2, fauna: bool, marker_scale: float = 1.0) -> void:
	var ink := Color("f3bb70") if fauna else Color("93d8ab")
	canvas.draw_arc(center, 8.0 * marker_scale, -PI * 0.35, PI * 1.4, 16, ink, 1.0, true)
	if fauna:
		for offset in [Vector2(-3, -2), Vector2(2, -4), Vector2(0, 2)]:
			canvas.draw_circle(center + offset * marker_scale, 1.65 * marker_scale, ink, true, -1.0, true)
	else:
		canvas.draw_polyline(PackedVector2Array([center + Vector2(0, 5) * marker_scale, center,
			center + Vector2(-4, -4) * marker_scale, center, center + Vector2(4, -5) * marker_scale]), ink, 1.4, true)
	canvas.draw_string(ThemeDB.fallback_font, center + Vector2(11, 5) * marker_scale,
		"?", HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(7, roundi(12 * marker_scale)), ink)

func _draw_mineral_badge(canvas: CanvasItem, center: Vector2, extracted: bool = false) -> void:
	var rock := PackedVector2Array([
		center + Vector2(-9, 2), center + Vector2(-6, -6), center + Vector2(4, -8),
		center + Vector2(9, -1), center + Vector2(6, 6), center + Vector2(-4, 8),
	])
	canvas.draw_colored_polygon(rock, Color("687579"))
	canvas.draw_polyline(PackedVector2Array([
		center + Vector2(-6, 2), center + Vector2(-2, -2),
		center + Vector2(1, 0), center + Vector2(6, -3),
	]), Color("9edbb8") if extracted else Color("f6cb75"), 1.7, true)
	if not extracted:
		canvas.draw_string(ThemeDB.fallback_font, center + Vector2(11, 4), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, ORANGE)

func _draw_blocked_exit_badge(canvas: CanvasItem, center: Vector2, marker_scale: float) -> void:
	canvas.draw_circle(center, 10.0 * marker_scale, PANEL, true, -1.0, true)
	canvas.draw_circle(center, 10.0 * marker_scale, BLOCKED_GALLERY_COLOR, false, 1.4, true)
	canvas.draw_arc(center + Vector2(0, -2) * marker_scale, 3.0 * marker_scale, PI, TAU, 12, BLOCKED_GALLERY_COLOR, 1.3, true)
	canvas.draw_rect(Rect2(center + Vector2(-4, -2) * marker_scale, Vector2(8, 7) * marker_scale), BLOCKED_GALLERY_COLOR)

func _draw_mining_progress(cave_id: int) -> void:
	var progress: float = 1.0 - mining_remaining / _mining_duration(mining_tool)
	_draw_field_progress(_material_marker_position(cave_id) - Vector2(0, 16), progress, Color("ffe3a0"), "EXTRAIENT...")

func _isometric_object_scale() -> float:
	return minf(1.0, zoom_level / 3.5)

func _isometric_organism_scale() -> float:
	# Organisms belong to world space; only HUD markers use the capped object scale.
	return zoom_level / 3.5 * ISOMETRIC_ORGANISM_SIZE

func _organism_photo_frame(species_id: String, fauna: bool, center: Vector2) -> Rect2:
	var frame := Rect2(center - Vector2(54, 40), Vector2(108, 80))
	if fauna and str(species_id).begins_with("depredador_"):
		return frame.merge(Rect2(center-Vector2(12,15.2)*zoom_level,Vector2(24,16)*zoom_level).grow(8))
	var recipe := _fauna_variant(species_id) if fauna else OrganismPixelArt.plant_recipe(species_id)
	if not recipe.is_empty():
		var bounds := OrganismPixelArt.animal_hit_rect(center, _isometric_organism_scale(), recipe) if fauna else OrganismPixelArt.plant_hit_rect(center, 1.4 * _isometric_organism_scale(), recipe)
		frame = frame.merge(bounds.grow(8.0))
	return frame

func _draw_field_progress(anchor: Vector2, progress: float, color: Color, title: String = "ESCANEJANT...") -> void:
	if taking_field_photo:
		return
	var caption := "%d%%" % floori(progress * 100.0)
	var view := _view_rect()
	var panel_scale := clampf(zoom_level / 5.0, 0.65, 1.35)
	var extent := Vector2(190, 62) * panel_scale
	var origin := (anchor + Vector2(18, -68) * panel_scale).clamp(view.position + Vector2(4, 4), view.end - extent - Vector2(4, 4)).round()
	draw_set_transform(origin, 0.0, Vector2.ONE * panel_scale)
	var border := _inventory_frame_outline(Rect2(0, 0, 190, 62), 6)
	draw_colored_polygon(border, Color("050e12"))
	border.append(border[0])
	draw_polyline(border, Color("527f89"), 1.0, false)
	draw_string(ThemeDB.fallback_font, Vector2(10, 22), title, HORIZONTAL_ALIGNMENT_LEFT, 170, 15, color)
	draw_rect(Rect2(10, 34, 126, 15), Color("12313b"))
	draw_rect(Rect2(10, 34, floorf(126 * clampf(progress, 0, 1)), 15), color)
	draw_string(ThemeDB.fallback_font, Vector2(140, 48), caption, HORIZONTAL_ALIGNMENT_LEFT, 46, 14, color)
	draw_set_transform(Vector2.ZERO)

func _has_level_elevator(cave_id: int) -> bool:
	return cave_id >= 0 and (cave_id == world.get("entry", -1) or _has_descent_elevator(cave_id))

func _has_descent_elevator(cave_id: int) -> bool:
	return current_level >= 1 and current_level < CAMPAIGN_DEPTH and cave_id >= 0 and cave_id == descent_access and explored_caves.has(cave_id)

func _draw_beacon_waves(center: Vector2, reach: float, vertical_ratio: float, color: Color, target: CanvasItem = null) -> void:
	if not show_beacon_waves or taking_field_photo:
		return
	var painter: CanvasItem = self if target == null else target
	var cycle_seconds := 12.8
	for wave in range(2):
		var phase := fposmod(fauna_time / cycle_seconds + wave * 0.5, 1.0)
		var radius := maxf(1.0, reach * phase)
		var points := _surface_ellipse_points(center, radius, radius * vertical_ratio, 96)
		points.append(points[0])
		painter.draw_polyline(points, Color(color, lerpf(0.46, 0.18, smoothstep(0.8, 1.0, phase))), 1.4, true)

func _draw_deployed_beacon(cave_id: int) -> void:
	var anchor := _world_to_screen(world.caves[cave_id].position)
	var source := Rect2(600, 40, 570, 800)
	var size := Vector2(8.0, 8.0 * source.size.y / source.size.x) * zoom_level
	var glow := _surface_ellipse_points(anchor, 4.0 * zoom_level, 1.6 * zoom_level, 20)
	draw_colored_polygon(glow, Color(0.1, 0.85, 1.0, 0.10))
	draw_texture_rect_region(DEPLOYED_BEACON_SPRITE,
		Rect2((anchor - size * Vector2(0.5, 0.97)).round(), size), source, Color.WHITE, false, true)

func _draw_beacon_light(center: Vector2, scale: float, beacon_color: Color) -> void:
	for radius in [13.0, 10.0, 7.0]:
		draw_circle(center, radius * scale, Color(beacon_color, 0.09), true, -1.0, true)
	var tip := 5.0 * scale
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(0, -tip), center + Vector2(tip, 0),
		center + Vector2(0, tip), center + Vector2(-tip, 0)]), beacon_color)
	draw_circle(center, 2.0 * scale, Color("eff2ff"), true, -1.0, true)

func _room_lantern_corners(contour: PackedVector2Array) -> PackedVector2Array:
	if contour.size() <= 4:
		return contour
	var key := hash(contour)
	if room_lantern_corner_cache.has(key):
		return room_lantern_corner_cache[key]
	var best := PackedVector2Array()
	var best_min := -1.0
	var best_sum := -1.0
	for a in range(contour.size() - 3):
		for b in range(a + 1, contour.size() - 2):
			for c in range(b + 1, contour.size() - 1):
				for d in range(c + 1, contour.size()):
					var points := PackedVector2Array([contour[a], contour[b], contour[c], contour[d]])
					var nearest := INF
					var total := 0.0
					for i in range(3):
						for j in range(i + 1, 4):
							var distance := points[i].distance_squared_to(points[j])
							nearest = minf(nearest, distance)
							total += distance
					if nearest > best_min or (is_equal_approx(nearest, best_min) and total > best_sum):
						best = points
						best_min = nearest
						best_sum = total
	if room_lantern_corner_cache.size() >= 512:
		room_lantern_corner_cache.clear()
	room_lantern_corner_cache[key] = best
	return best

func _render_mesh_transform(origin: Vector2) -> Transform2D:
	return Transform2D(Vector2(zoom_level, 0), Vector2(0, zoom_level), _world_to_screen(origin))

func _render_project_delta(point: Vector2) -> Vector2:
	return Vector2(point.x, point.y * ISO_VERTICAL_RATIO)

func _room_lamp_anchor(cave: Dictionary, corner: Vector2) -> Vector2:
	for inset in [16.0, 22.0, 30.0, 40.0]:
		var point: Vector2 = cave.position + corner.move_toward(Vector2.ZERO, inset)
		if _point_inside_cave_id(point, cave.id) and _distance_to_cave_boundary(point, cave) >= 10.0:
			return point
	return cave.position + corner.move_toward(Vector2.ZERO, 40.0)

func _draw_room_lamps(cave: Dictionary, _at_entry: bool) -> void:
	if not render_room_lights.has(cave.id):
		var glow_mesh := CaveWallMesh._builder()
		var lamp_mesh := CaveWallMesh._builder()
		var source := Rect2(310, 35, 275, 790)
		var texture_size := Vector2(ROOM_LANTERN.get_size())
		var lamp_uvs := PackedVector2Array([source.position / texture_size,
			Vector2(source.end.x, source.position.y) / texture_size, source.end / texture_size,
			Vector2(source.position.x, source.end.y) / texture_size])
		for corner in _room_lantern_corners(cave.contour):
			var anchor: Vector2 = _render_project_delta(_room_lamp_anchor(cave, corner) - Vector2(cave.position))
			var glow := _surface_ellipse_points(anchor, 28.5, 14.44, 24)
			var bright := Color(1.0, 0.61, 0.24, 0.14)
			for segment in range(glow.size()):
				CaveWallMesh._triangle(glow_mesh, PackedVector2Array([anchor, glow[segment], glow[(segment + 1) % glow.size()]]),
					PackedColorArray([bright, Color(bright, 0), Color(bright, 0)]))
			var rect := Rect2(anchor - Vector2(4.5, 13) * Vector2(0.5, 0.98), Vector2(4.5, 13))
			CaveWallMesh._quad(lamp_mesh, PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]),
				PackedColorArray([Color.WHITE]), lamp_uvs)
		render_room_lights[cave.id] = [CaveWallMesh._mesh(glow_mesh), CaveWallMesh._mesh(lamp_mesh)]
	var meshes: Array = render_room_lights[cave.id]
	var transform := _render_mesh_transform(cave.position)
	draw_mesh(meshes[0], null, transform)

func _draw_cave_lighting(_light_on: bool, _room_lit: bool) -> void:
	pass # The shared lighting overlay runs after all world objects.

func _draw_isometric_fauna(position: Vector2, cave_id: int) -> void:
	var hostile := defence_system.predator(self,cave_id)
	if not hostile.is_empty():
		defence_system.draw_creature(self,hostile)
		return
	var direction := Vector2.RIGHT
	if fauna_patrol_ends.has(cave_id):
		var origin: Vector2 = fauna_sites[cave_id]
		direction = origin.direction_to(fauna_patrol_ends[cave_id])
	direction *= 0.38 * ISOMETRIC_ORGANISM_SIZE
	var across := direction.orthogonal()
	var species_id: String = fauna_species_by_room.get(cave_id, "escarabat")
	var variant := _fauna_variant(species_id)
	if OrganismPixelArt.supports_animal(species_id):
		var velocity := _fauna_position(cave_id, 0.12) - _fauna_position(cave_id, -0.12)
		var facing := velocity
		if facing.is_zero_approx():
			facing = direction
			if fauna_patrol_ends.has(cave_id) and position.distance_to(fauna_patrol_ends[cave_id]) < 1.0:
				facing = -direction
		facing.y *= ISO_VERTICAL_RATIO
		OrganismPixelArt.draw_animal(self, _world_to_screen(position), _isometric_organism_scale(),
			variant, facing, 0.0 if taking_field_photo else fauna_time,
			not velocity.is_zero_approx() and not taking_field_photo, FAUNA_VARIANT_COLORS)
		return
	if not variant.is_empty():
		_draw_fauna_variant(self, _world_to_screen(position), species_id, variant, _isometric_organism_scale())
		return
	var color := _fauna_color(species_id)
	if _fauna_is_segmented(species_id):
		_draw_isometric_isopod(position, direction, across, color)
		return
	draw_colored_polygon(_fauna_ground_ellipse(position, direction, across, Vector2(8, 5)), Color("231b1c"))
	for stride in [-4.0, 0.0, 4.0]:
		for side in [-1.0, 1.0]:
			var joint: Vector2 = position + direction * stride + across * side * 2.0
			var foot: Vector2 = joint + across * side * 4.0 - direction * 1.5
			draw_line(_world_to_screen(joint), _world_to_screen(foot), Color("ce9454"), 1.6, true)
	var shell := _fauna_ground_ellipse(position, direction, across, Vector2(6, 3.8))
	draw_colored_polygon(shell, color)
	draw_colored_polygon(_fauna_ground_ellipse(position + direction * 5.0, direction, across, Vector2(2.7, 2.2)), Color("b67642"))
	draw_line(_world_to_screen(position - direction * 4.0), _world_to_screen(position + direction * 4.0), Color("945632"), 1.2, true)

func _draw_isometric_isopod(position: Vector2, axis: Vector2, across: Vector2, color: Color) -> void:
	draw_colored_polygon(_fauna_ground_ellipse(position, axis, across, Vector2(11, 5)), Color("202532"))
	for segment in range(-2, 3):
		var center := position + axis * (float(segment) * 3.2)
		var width := 4.5 - absf(float(segment)) * 0.6
		for side in [-1.0, 1.0]:
			var foot: Vector2 = center + across * side * (width + 2.0) - axis * 1.0
			draw_line(_world_to_screen(center), _world_to_screen(foot), Color("9da9bb"), 1.2, true)
		var plate := _fauna_ground_ellipse(center, axis, across, Vector2(2.6, width))
		draw_colored_polygon(plate, color if segment % 2 == 0 else color.darkened(0.27))

func _fauna_ground_ellipse(center: Vector2, axis: Vector2, across: Vector2, radii: Vector2) -> PackedVector2Array:
	var polygon := PackedVector2Array()
	for index in range(16):
		var angle := TAU * float(index) / 16.0
		polygon.append(_world_to_screen(center + axis * cos(angle) * radii.x + across * sin(angle) * radii.y))
	return polygon

func _draw_isometric_base_access(cave: Dictionary) -> void:
	var center := _world_to_screen(_level_access_position(cave.id))
	var extent := _underground_elevator_extent()
	if not _is_unopened_shaft(cave.id):
		var scale := _isometric_object_scale()
		draw_set_transform(center, 0.0, Vector2.ONE * scale)
		_draw_elevator_platform(Vector2.ZERO, extent / scale)
		draw_set_transform(Vector2.ZERO)
		return
	draw_texture_rect(DESCENT_SHAFT_SPRITE,_descent_shaft_rect(cave.id),false)

func _descent_shaft_rect(cave_id: int) -> Rect2:
	var width := _underground_elevator_extent().x*2.6
	var size := Vector2(width,width*float(DESCENT_SHAFT_SPRITE.get_height())/DESCENT_SHAFT_SPRITE.get_width())
	return Rect2((_world_to_screen(_level_access_position(cave_id))-size*Vector2(0.5,0.64)).round(),size)

func _descent_shaft_hit(point: Vector2, cave_id: int) -> bool:
	if not _is_unopened_shaft(cave_id): return false
	var rect := _descent_shaft_rect(cave_id)
	if not rect.has_point(point): return false
	if descent_shaft_image==null: descent_shaft_image=DESCENT_SHAFT_SPRITE.get_image()
	var uv := (point-rect.position)/rect.size
	var pixel := Vector2i(uv*Vector2(descent_shaft_image.get_size())).min(descent_shaft_image.get_size()-Vector2i.ONE).max(Vector2i.ZERO)
	return descent_shaft_image.get_pixelv(pixel).a>=0.15

func _is_unopened_shaft(cave_id: int) -> bool:
	return _has_descent_elevator(cave_id) and not inactive_levels.has(current_level + 1)

func _underground_elevator_extent() -> Vector2:
	return Vector2(maxf(22.0 * _isometric_object_scale(), zoom_level * 7.5), maxf(12.0 * _isometric_object_scale(), zoom_level * 3.8))

func _elevator_outline(center: Vector2, extent: Vector2) -> PackedVector2Array:
	var outline := PackedVector2Array()
	for corner in [Vector2(-0.78, -1), Vector2(0.78, -1), Vector2(1, -0.64), Vector2(1, 0.64),
			Vector2(0.78, 1), Vector2(-0.78, 1), Vector2(-1, 0.64), Vector2(-1, -0.64)]:
		outline.append(center + corner * extent)
	return outline

func _draw_elevator_platform(center: Vector2, extent: Vector2) -> void:
	# The platform deck stays on the existing ground anchor and interaction area.
	var source := Rect2(215, 160, 1345, 610)
	var width := extent.x * 2.1
	var size := Vector2(width, width * source.size.y / source.size.x)
	draw_texture_rect_region(ELEVATOR_SPRITE,
		Rect2((center - size * Vector2(0.5, 0.56)).round(), size), source, Color.WHITE, false, true)

func _level_access_label(cave_id: int, short: bool = false) -> String:
	if cave_id != world.entry:
		if not _biome_exit_is_ready():
			return "Equip pendent" if short else "DESCENS BLOQUEJAT · PREPARA L’EQUIP"
		var depth := -(current_level + 1)
		if _is_unopened_shaft(cave_id):
			return "Forat · %d" % depth if short else ("BAIXA AMB L’ESCALA · %d" % depth if _ladder_uses_left() > 0 else "ESCALA ESGOTADA")
		return "Estrat %d" % depth if short else "BAIXA A L’ESTRAT %d" % depth
	if current_level == 1:
		return "Base · 0" if short else "PUJA A LA BASE · 0"
	var depth := -(current_level - 1)
	return "Estrat %d" % depth if short else "PUJA A L’ESTRAT %d" % depth

func _draw_elevator_icon(canvas: CanvasItem, center: Vector2, down: bool, scale: float) -> void:
	var size := Vector2(16, 18) * scale
	var frame := Rect2(center - size * 0.5, size)
	canvas.draw_rect(frame, PANEL)
	canvas.draw_rect(frame, LEVEL_EXIT_BEACON_COLOR, false, 1.2, true)
	var direction := Vector2.DOWN if down else Vector2.UP
	var tip := center + direction * 5.0 * scale
	canvas.draw_line(center - direction * 4.0 * scale, tip, LEVEL_EXIT_BEACON_COLOR, 1.5, true)
	canvas.draw_polyline(PackedVector2Array([tip - direction * 3.5 * scale - Vector2.RIGHT * 3.0 * scale,
		tip, tip - direction * 3.5 * scale + Vector2.RIGHT * 3.0 * scale]), LEVEL_EXIT_BEACON_COLOR, 1.5, true)

func _draw_elevator_sign(center: Vector2, caption: String, down: bool, scale: float, shaft: bool = false) -> void:
	var font := ThemeDB.fallback_font
	var font_size := maxi(9, roundi(13 * scale))
	var width := font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var start := center - Vector2((width + 22.0 * scale) * 0.5, 0)
	var plate := Rect2(start-Vector2(8,12)*scale,Vector2(width+38*scale,26*scale))
	draw_rect(plate,Color("08131a"))
	draw_rect(plate,Color("d39a4d"),false,1.5)
	var icon_center := start + Vector2(8.0 * scale, 0)
	_draw_elevator_icon(self, icon_center, down, scale)
	draw_string(font, start + Vector2(22.0 * scale, font_size * 0.32), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, LEVEL_EXIT_BEACON_COLOR)

func _room_reveal_ratio(cave: Dictionary) -> float:
	var contour: PackedVector2Array = cave.contour
	if contour.is_empty():
		return 0.0
	var bounds := Rect2(contour[0] + cave.position, Vector2.ZERO)
	for point in contour:
		bounds = bounds.expand(point + cave.position)
	var min_x := maxi(0, floori(bounds.position.x / world.cell_size))
	var max_x := mini(world.grid_size.x - 1, ceili(bounds.end.x / world.cell_size))
	var min_y := maxi(0, floori(bounds.position.y / world.cell_size))
	var max_y := mini(world.grid_size.y - 1, ceili(bounds.end.y / world.cell_size))
	var total := 0
	var visible := 0
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var index: int = y * world.grid_size.x + x
			var center := Vector2((float(x) + 0.5) * world.cell_size, (float(y) + 0.5) * world.cell_size)
			if world.terrain_mask[index] == 0 or not Geometry2D.is_point_in_polygon(center - cave.position, contour):
				continue
			total += 1
			if revealed_mask[index] == 1:
				visible += 1
	return float(visible) / float(maxi(1, total))

func _draw_isometric_floor(cave: Dictionary, min_x: int, max_x: int, min_y: int, max_y: int, tint: Color) -> void:
	if analysis_mode:
		_draw_textured_cave_floor(cave, tint)
		return
	var terrain: PackedByteArray = world.terrain_mask
	var revealed: PackedByteArray = revealed_mask
	var grid_width: int = world.grid_size.x
	# Keep the scan fog, but use the same world-anchored floor material as the
	# fully scanned room so visible cells read as part of one continuous surface.
	var half_tile: float = world.cell_size * 0.5
	var room_shape := PackedVector2Array()
	for point in cave.contour:
		room_shape.append(cave.position + point)
	var texture := _get_cave_room_floor_texture(cave.id)
	var previous_repeat := texture_repeat
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var index := y * grid_width + x
			if terrain[index] == 0 or revealed[index] == 0:
				continue
			var cell_center := Vector2((float(x) + 0.5) * world.cell_size, (float(y) + 0.5) * world.cell_size)
			var world_points := PackedVector2Array([
				cell_center + Vector2(-half_tile, -half_tile),
				cell_center + Vector2(half_tile, -half_tile),
				cell_center + Vector2(half_tile, half_tile),
				cell_center + Vector2(-half_tile, half_tile)
			])
			for clipped_shape in Geometry2D.intersect_polygons(world_points, room_shape):
				_draw_textured_floor_shape(clipped_shape, texture, tint)
	texture_repeat = previous_repeat

func _draw_textured_floor_shape(shape: PackedVector2Array, texture: Texture2D, tint: Color) -> void:
	var triangles := Geometry2D.triangulate_polygon(shape)
	for index in range(0, triangles.size(), 3):
		var triangle := PackedVector2Array()
		var uvs := PackedVector2Array()
		var colors := PackedColorArray()
		for vertex_index in range(3):
			var world_point: Vector2 = shape[triangles[index + vertex_index]]
			triangle.append(_world_to_screen(world_point))
			uvs.append(_floor_material_uv(world_point, texture))
			colors.append(tint)
		draw_polygon(triangle, colors, uvs, texture)

func _draw_textured_cave_floor(cave: Dictionary, tint: Color) -> void:
	var contour: PackedVector2Array = cave.contour
	var screen_points := PackedVector2Array()
	var uvs := PackedVector2Array()
	var colors := PackedColorArray()
	for point in contour:
		screen_points.append(_world_to_screen(cave.position + point))
		uvs.append(_floor_material_uv(cave.position + point, _get_cave_room_floor_texture(cave.id)))
		colors.append(tint)
	var previous_repeat := texture_repeat
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	draw_polygon(screen_points, colors, uvs, _get_cave_room_floor_texture(cave.id))
	texture_repeat = previous_repeat

func _get_cave_room_floor_texture(cave_id: int) -> Texture2D:
	if _biome_at_depth(current_level) == 1:
		return OXIDIZED_FLOOR_TEXTURE
	if _biome_at_depth(current_level) == 4:
		return CRYSTALLINE_FLOOR_TEXTURE
	var profile := _biome_at_depth(current_level)
	var index := OTHER_BIOME_PROFILES.find(profile)
	if index >= 0:
		if not biome_material_textures.has(profile):
			var cell := Vector2i(OTHER_BIOME_FLOORS.get_size()) / Vector2i(3, 2)
			var region := Rect2i(Vector2i(index % 3, floori(float(index) / 3.0)) * cell, cell)
			# Repeat the isolated material, never the whole multi-biome atlas.
			biome_material_textures[profile] = ImageTexture.create_from_image(OTHER_BIOME_FLOORS.get_image().get_region(region))
		return biome_material_textures[profile]
	return _get_cave_floor_texture(cave_id)

func _floor_material_uv(point: Vector2, texture: Texture2D) -> Vector2:
	# UVs are normalized: one complete material tile covers a fixed world area.
	var period := OXIDIZED_FLOOR_WORLD_PERIOD if texture in [OXIDIZED_FLOOR_TEXTURE, CRYSTALLINE_FLOOR_TEXTURE] or texture in biome_material_textures.values() else 256.0
	return point / period

func _get_cave_floor_texture(cave_id: int) -> Texture2D:
	if cave_floor_textures.has(cave_id):
		return cave_floor_textures[cave_id]
	var cave_seed: int = int(posmod(seed_value * 48611 + cave_id * 7919 + 24681357, 0x7fffffff))
	var coarse := FastNoiseLite.new()
	coarse.seed = cave_seed
	coarse.frequency = 0.025
	coarse.fractal_octaves = 4
	coarse.fractal_gain = 0.58
	var detail := FastNoiseLite.new()
	detail.seed = cave_seed ^ 0x5f3759df
	detail.frequency = 0.12
	var image := Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var palette: Array = BIOME_ROCK[_biome_at_depth(current_level)]
	var dark_rock := Color(palette[0])
	var warm_rock := Color(palette[1])
	match _room_environment(cave_id):
		"aigua":
			dark_rock = dark_rock.lerp(Color("24363b"), 0.55)
			warm_rock = warm_rock.lerp(Color("3d6466"), 0.55)
		"gel":
			dark_rock = dark_rock.lerp(Color("353b50"), 0.55)
			warm_rock = warm_rock.lerp(Color("627f9b"), 0.55)
		"calent":
			dark_rock = dark_rock.lerp(Color("482522"), 0.55)
			warm_rock = warm_rock.lerp(Color("a25332"), 0.55)
	for y in range(256):
		for x in range(256):
			var broad_value: float = coarse.get_noise_2d(float(x), float(y))
			var grain_value: float = detail.get_noise_2d(float(x), float(y))
			var shade: float = clampf(0.50 + broad_value * 0.34 + grain_value * 0.12, 0.0, 1.0)
			image.set_pixel(x, y, dark_rock.lerp(warm_rock, shade))
	var texture := ImageTexture.create_from_image(image)
	cave_floor_textures[cave_id] = texture
	return texture

func _ensure_solid_room_rocks() -> void:
	if surface_mode or world.is_empty() or int(world.get("rock_spacing_version", 0)) >= 2:
		if not surface_mode and not world.is_empty():
			_ensure_rock_ground_footprints()
			_ensure_material_clearance()
			_ensure_biome_base_collision()
			preload("res://scripts/cave_ambience.gd").ensure(self)
			defence_system.ensure(self)
		return
	var rocks: Array[Dictionary] = []
	var mask: PackedByteArray = world.walkable_mask.duplicate()
	var grid: Vector2i = world.grid_size
	var cell_size: float = world.cell_size
	# Old records identify cells that were open before their rock was added.
	for old_rock in world.get("solid_room_rocks_v1", []):
		var old_cell := Vector2i((old_rock.position / cell_size).floor())
		for restored_cell in old_rock.get("blocked_cells", [old_cell]):
			mask[restored_cell.y * grid.x + restored_cell.x] = 1
	for cave in world.caves:
		var rng := RandomNumberGenerator.new()
		rng.seed = hash([int(world.seed), "solid_room_rocks_spaced_v2", cave.id])
		var bounds := Rect2(cave.contour[0], Vector2.ZERO)
		for corner in cave.contour:
			bounds = bounds.expand(corner)
		var count := 0
		for attempt in range(192):
			if count >= clampi(roundi(float(cave.radius) / 24.0), 2, 6):
				break
			var raw: Vector2 = cave.position + Vector2(rng.randf_range(bounds.position.x, bounds.end.x), rng.randf_range(bounds.position.y, bounds.end.y))
			var cell := Vector2i((raw / cell_size).floor())
			var point := (Vector2(cell) + Vector2.ONE * 0.5) * cell_size
			var variant := rng.randi_range(0, 8)
			if cell.x < 2 or cell.y < 2 or cell.x >= grid.x - 2 or cell.y >= grid.y - 2:
				continue
			if not Geometry2D.is_point_in_polygon(point - cave.position, cave.contour) or _distance_to_cave_boundary(point, cave) < 16.0:
				continue
			if point.distance_to(cave.position) < maxf(26.0, float(cave.radius) * 0.32) or point.distance_to(unit_position) < 20.0 or _decoration_near_fixture(point, cave):
				continue
			var index := cell.y * grid.x + cell.x
			# Only remove a cell surrounded by an open ring: every route through
			# this cell has a replacement around it, preserving connectivity.
			var ring_clear := true
			for oy in range(-1, 2):
				for ox in range(-1, 2):
					if mask[(cell.y + oy) * grid.x + cell.x + ox] == 0:
						ring_clear = false
			if not ring_clear:
				continue
			var spaced := true
			for obstacle in world.obstacles:
				if point.distance_to(obstacle.position) < float(obstacle.radius) + 18.0:
					spaced = false
			for rock in rocks:
				if point.distance_to(rock.position) < maxf(32.0, float(cave.radius) * 0.48):
					spaced = false
			if not spaced:
				continue
			# Do not introduce a blocker beneath an active saved route.
			var route_start := unit_position
			for route_point in move_path:
				if Geometry2D.get_closest_point_to_segment(point, route_start, route_point).distance_to(point) < 18.0:
					spaced = false
				route_start = route_point
			if not spaced:
				continue
			mask[index] = 0
			rocks.append({"position": point, "cave_id": cave.id, "variant": variant, "radius": cell_size * 0.5})
			count += 1
	world.walkable_mask = mask
	world["solid_room_rocks_v1"] = rocks
	world["rock_spacing_version"] = 2
	world.erase("rock_ground_footprints_v1")
	_ensure_rock_ground_footprints()
	_ensure_material_clearance()
	_ensure_biome_base_collision()
	preload("res://scripts/cave_ambience.gd").ensure(self)
	defence_system.ensure(self)

func _base_mask_reaches_exits(mask: PackedByteArray, cave: Dictionary) -> bool:
	var grid: Vector2i = world.grid_size
	var points: Array[Vector2] = [_level_access_position(cave.id)]
	for corridor in world.corridors:
		if corridor.a == cave.id: points.append(corridor.exit_a)
		if corridor.b == cave.id: points.append(corridor.exit_b)
	var goals: Dictionary = {}
	var source := -1
	for point in points:
		var cell := Vector2i((point / world.cell_size).floor())
		var found := -1
		for radius in range(3):
			for y in range(maxi(0,cell.y-radius), mini(grid.y,cell.y+radius+1)):
				for x in range(maxi(0,cell.x-radius),mini(grid.x,cell.x+radius+1)):
					if mask[y*grid.x+x] != 0: found = y*grid.x+x; break
				if found >= 0: break
			if found >= 0: break
		if found < 0: return false
		goals[found] = true
		if source < 0: source = found
	var queue: Array[int] = [source]
	var seen: Dictionary = {source:true}
	var cursor := 0
	while cursor < queue.size():
		var index: int = queue[cursor]
		cursor += 1
		goals.erase(index)
		if goals.is_empty(): return true
		var cell := Vector2i(index % grid.x, int(index / grid.x))
		for direction in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var next: Vector2i = cell + direction
			if next.x < 0 or next.y < 0 or next.x >= grid.x or next.y >= grid.y: continue
			var next_index := next.y*grid.x+next.x
			if mask[next_index] != 0 and not seen.has(next_index):
				seen[next_index] = true
				queue.append(next_index)
	return false

func _ensure_biome_base_collision() -> void:
	if world.get("base_solid_v1",false) or not _depth_has_workshop(current_level): return
	var cave: Dictionary = world.caves[world.entry]
	var original := _biome_base_footprint(cave)
	if original.size() != 4: return
	# A legacy save may have the explorer inside the formerly passable module.
	# Let it leave before enabling the collider; never teleport it during input.
	if Geometry2D.is_point_in_polygon(unit_position, original): return
	var center := Vector2.ZERO
	for point in original: center += point
	center /= 4.0
	for factor in [1.0,0.85,0.7,0.55,0.4,0.25]:
		var footprint := PackedVector2Array()
		for point in original: footprint.append(center + (point-center)*factor)
		var expanded := Geometry2D.offset_polygon(footprint,3.0)
		var mask: PackedByteArray = world.walkable_mask.duplicate()
		var blocked: Array[Vector2i] = []
		var bounds := Rect2(footprint[0],Vector2.ZERO)
		for point in footprint: bounds = bounds.expand(point)
		bounds = bounds.grow(world.cell_size)
		for y in range(maxi(0,floori(bounds.position.y/world.cell_size)),mini(world.grid_size.y,ceili(bounds.end.y/world.cell_size))):
			for x in range(maxi(0,floori(bounds.position.x/world.cell_size)),mini(world.grid_size.x,ceili(bounds.end.x/world.cell_size))):
				var point := (Vector2(x,y)+Vector2.ONE*0.5)*float(world.cell_size)
				for polygon in expanded:
					if Geometry2D.is_point_in_polygon(point,polygon):
						mask[y*world.grid_size.x+x] = 0
						blocked.append(Vector2i(x,y))
		if blocked.is_empty() or not _base_mask_reaches_exits(mask,cave): continue
		world.walkable_mask = mask
		world["base_solid_footprint_v1"] = footprint
		world["base_solid_cells_v1"] = blocked
		world["base_solid_v1"] = true
		fauna_safe_paths.clear()
		return

func _material_position_is_clear(point: Vector2, cave_id: int) -> bool:
	var cave: Dictionary = world.caves[cave_id]
	if not _point_inside_cave_id(point, cave_id) or _distance_to_cave_boundary(point, cave) < 18.0:
		return false
	if not _segment_is_walkable(point, point, true): return false
	for obstacle in world.obstacles:
		if point.distance_to(obstacle.position) < float(obstacle.radius) + 18.0: return false
	for rock in world.get("solid_room_rocks_v1", []):
		if point.distance_to(rock.position) < float(rock.get("visual_radius", 10.0)) + 18.0: return false
	for sites in [flora_sites, fauna_sites]:
		if sites.has(cave_id) and point.distance_to(sites[cave_id]) < 24.0: return false
	return true

func _ensure_material_clearance() -> void:
	if world.get("material_clearance_v1", false) or mining_cave >= 0: return
	for cave_id in material_sites:
		if collected_materials.has(cave_id): continue
		var origin: Vector2 = material_sites[cave_id]
		if _material_position_is_clear(origin, cave_id): continue
		var found := false
		for ring in range(1, 9):
			for i in range(16):
				var point := origin + Vector2.from_angle(TAU * float(i) / 16.0) * float(ring * 8)
				if not explored_caves.has(cave_id) and _is_revealed(origin) and not _is_revealed(point): continue
				if _material_position_is_clear(point, cave_id):
					material_sites[cave_id] = point
					found = true
					break
			if found: break
	world["material_clearance_v1"] = true
	fauna_safe_paths.clear()

func _ensure_rock_ground_footprints() -> void:
	if world.get("rock_ground_footprints_v1", false):
		return
	var mask: PackedByteArray = world.walkable_mask.duplicate()
	var grid: Vector2i = world.grid_size
	var cell_size: float = world.cell_size
	for rock in world.get("solid_room_rocks_v1", []):
		var cell := Vector2i((rock.position / cell_size).floor())
		var safe := cell.x >= 2 and cell.x < grid.x - 2 and cell.y >= 1 and cell.y < grid.y - 1
		# A clear ring guarantees a detour around the wider rock footprint.
		for oy in range(-1, 2):
			for ox in range(-2, 3):
				if not safe: break
				if ox == 0 and oy == 0: continue
				if mask[(cell.y + oy) * grid.x + cell.x + ox] == 0: safe = false
		for offset in [-1, 1]:
			var point: Vector2 = rock.position + Vector2(offset * cell_size, 0)
			if point.distance_to(unit_position) < cell_size * 1.5: safe = false
			for route_point in move_path:
				if point.distance_to(route_point) < cell_size: safe = false
		rock["visual_radius"] = float(rock.radius) * (2.0 if safe else 1.0)
		rock["blocked_cells"] = [cell]
		if safe:
			for offset in [-1, 1]:
				var blocked := cell + Vector2i(offset, 0)
				mask[blocked.y * grid.x + blocked.x] = 0
				rock.blocked_cells.append(blocked)
	world.walkable_mask = mask
	world["rock_ground_footprints_v1"] = true

func _draw_procedural_rock_details(cave: Dictionary) -> void:
	for rock in world.get("solid_room_rocks_v1", []):
		if rock.cave_id != cave.id:
			continue
		var visible := true
		for offset in [Vector2.ZERO, Vector2(-7, 0), Vector2(7, 0), Vector2(0, -7), Vector2(0, 7)]:
			if not explored_caves.has(cave.id) and not _is_revealed(rock.position + offset):
				visible = false
		if visible:
			_draw_biome_rock_sprite(rock.position, float(rock.get("visual_radius", float(rock.radius) * 2.0)), int(rock.variant))

func _draw_biome_rock_sprite(position: Vector2, radius: float, variant: int) -> void:
	var biome := _biome_at_depth(current_level)
	var palette: Array = BIOME_ROCK[biome]
	var native := variant == 0 or (biome != 1 and variant % 3 != 1)
	var texture: Texture2D = BIOME_ROCK_SPRITES if native else ROCK_VARIATIONS
	var index: int = [1, 4, 7, 10, 13, 16, 19, 20].find(biome) if native else mini(variant, 7) - 1
	var cell_size := Vector2(texture.get_size()) / Vector2(4, 2)
	var source := Rect2(Vector2(index % 4, floori(float(index) / 4.0)) * cell_size, cell_size)
	var size := Vector2(radius * 2.0, radius * 2.0 * cell_size.y / cell_size.x) * zoom_level
	var tint := Color.WHITE if native else Color(palette[2]).lerp(Color.WHITE, 0.15)
	var contact := 0.78 if native else 0.89
	draw_texture_rect_region(texture, Rect2((_world_to_screen(position) - size * Vector2(0.5, contact)).round(), size), source, tint, false, true)

func _decoration_near_fixture(point: Vector2, cave: Dictionary) -> bool:
	if _has_level_elevator(cave.id) and point.distance_to(_level_access_position(cave.id)) < 22.0:
		return true
	if _is_biome_workshop(cave.id):
		var footprint := _biome_base_footprint(cave)
		if footprint.size() == 4 and Geometry2D.is_point_in_polygon(point, footprint):
			return true
	for corridor in world.corridors:
		if corridor.a == cave.id and point.distance_to(corridor.exit_a) < 14.0:
			return true
		if corridor.b == cave.id and point.distance_to(corridor.exit_b) < 14.0:
			return true
	for sites in [flora_sites, fauna_sites, material_sites]:
		if sites.has(cave.id) and point.distance_to(sites[cave.id]) < 10.0:
			return true
	return false

func _room_exit_uses_full_gallery(corridor_id: int) -> bool:
	return completed_gallery_traces.has(corridor_id) or corridor_id == render_active_passage_id

func _room_wall_openings(cave: Dictionary, exits: Array[Dictionary]) -> Array[PackedVector2Array]:
	var openings: Array[PackedVector2Array] = []
	for exit_info in exits:
		var corridor := _corridor_by_id(exit_info.corridor_id)
		if corridor.is_empty():
			continue
		# Cut exactly the strip that is rendered, including its taper and bends.
		var route: PackedVector2Array = corridor.points if _room_exit_uses_full_gallery(corridor.id) else _isometric_exit_stub(exit_info, corridor, cave)
		if _room_exit_uses_full_gallery(corridor.id):
			# A butt cap exactly on the room boundary is numerically ambiguous for
			# polygon clipping. Extend the cut into both rooms, as the stubs do.
			route = route.duplicate()
			if route.size() >= 2:
				route.insert(0, Vector2(corridor.exit_a) - Vector2(corridor.direction_a).normalized() * 10.0)
				route.append(Vector2(corridor.exit_b) - Vector2(corridor.direction_b).normalized() * 10.0)
		var edges := _isometric_corridor_edges(route, float(corridor.width) * 0.65)
		if edges.is_empty():
			continue
		var polygon: PackedVector2Array = edges.left.duplicate()
		var opposite: PackedVector2Array = edges.right.duplicate()
		opposite.reverse()
		polygon.append_array(opposite)
		openings.append(polygon)
	return openings

func _build_room_wall_spans(cave: Dictionary, openings: Array[PackedVector2Array], depth_step: float = 8.0) -> Array:
	var spans: Array = []
	var contour: PackedVector2Array = cave.contour
	var signed_area := 0.0
	for i in range(contour.size()):
		signed_area += contour[i].cross(contour[(i + 1) % contour.size()])
	for i in range(contour.size()):
		var a: Vector2 = cave.position + contour[i]
		var b: Vector2 = cave.position + contour[(i + 1) % contour.size()]
		var pieces: Array[PackedVector2Array] = [PackedVector2Array([a, b])]
		for opening in openings:
			var remaining: Array[PackedVector2Array] = []
			for piece in pieces:
				remaining.append_array(Geometry2D.clip_polyline_with_polygon(piece, opening))
			pieces = remaining
		for piece in pieces:
			for j in range(piece.size() - 1):
				if piece[j].distance_squared_to(piece[j + 1]) < 0.0001:
					continue
				# The local outward normal determines the visible face, including
				# concave corners. Position relative to the room centre does not.
				var tangent := (b - a).normalized()
				var outward_y := -tangent.x * (1.0 if signed_area >= 0.0 else -1.0)
				var direction := minf(-0.12, outward_y) if outward_y < -0.01 else 1.0
				# Short spans keep a long diagonal wall from hiding an interior lamp
				# merely because the far end has a greater painter depth.
				var count := maxi(1, ceili(piece[j].distance_to(piece[j + 1]) / depth_step))
				for part in range(count):
					spans.append([piece[j].lerp(piece[j + 1], float(part) / count), piece[j].lerp(piece[j + 1], float(part + 1) / count), direction, 0.0])
	return spans

func _room_wall_spans_for_cave(cave: Dictionary) -> Array:
	var exits := _visible_exits_for_cave(cave.id)
	# A fully drawn passage must also open its destination mouth, even if its
	# per-room exit marker has not yet been registered on arrival.
	for corridor in world.corridors:
		if not _room_exit_uses_full_gallery(corridor.id) or (corridor.a != cave.id and corridor.b != cave.id):
			continue
		var found := false
		for exit_info in exits:
			if exit_info.corridor_id == corridor.id:
				found = true
		if not found:
			exits.append({"corridor_id": corridor.id, "position": corridor.exit_a if corridor.a == cave.id else corridor.exit_b,
				"direction": corridor.direction_a if corridor.a == cave.id else corridor.direction_b, "width": corridor.width})
	var full_gallery_flags: Array[bool] = []
	for exit_info in exits:
		full_gallery_flags.append(_room_exit_uses_full_gallery(exit_info.corridor_id))
	var depth_step := 32.0 if zoom_level < 1.5 else 8.0
	var key := hash([cave.id, exits, full_gallery_flags, depth_step])
	if not render_room_wall_spans.has(key):
		render_room_wall_spans[key] = _build_room_wall_spans(cave, _room_wall_openings(cave, exits), depth_step)
	return render_room_wall_spans[key]

func _draw_isometric_walls(cave: Dictionary) -> void:
	_draw_wall_group(_room_wall_spans_for_cave(cave), ["room", cave.id, _room_wall_spans_for_cave(cave)], cave.position)

func _draw_wall_group(spans: Array, identity: Array, origin: Vector2, fade: bool = false) -> void:
	var key := hash([identity, _biome_at_depth(current_level)])
	if not render_wall_groups.has(key):
		if render_wall_groups.size() >= 4096:
			render_wall_groups.clear()
		var palette: Array = BIOME_ROCK[_biome_at_depth(current_level)]
		render_wall_groups[key] = CaveWallMesh.build_group(spans, origin, palette, int(world.seed), fade)
	var meshes: Array = render_wall_groups[key]
	var transform := _render_mesh_transform(origin)
	for i in range(3):
		var mesh: ArrayMesh = meshes[i]
		if mesh.get_surface_count() > 0:
			draw_mesh(mesh, CAVE_WALL_TEXTURE if i == 0 else (CAVE_FORMATIONS if i == 2 else null), transform)

func _draw_cave_wall_face(start: Vector2, finish: Vector2, direction: float, opacity: float = 1.0) -> void:
	if opacity <= 0.01:
		return
	var world_start := _screen_to_world(start).snapped(Vector2(0.001, 0.001))
	var world_finish := _screen_to_world(finish).snapped(Vector2(0.001, 0.001))
	if world_start.distance_squared_to(world_finish) < 0.01 or not _render_segment_on_screen(world_start, world_finish, 24.0 * zoom_level):
		return
	var key := hash([world_start, world_finish, direction])
	if not render_wall_meshes.has(key):
		if render_wall_meshes.size() >= 4096:
			render_wall_meshes.clear()
		var palette: Array = BIOME_ROCK[_biome_at_depth(current_level)]
		render_wall_meshes[key] = CaveWallMesh.build(world_start, world_finish, direction, palette, int(world.seed))
	var meshes: Array = render_wall_meshes[key]
	var transform := Transform2D(Vector2(zoom_level, 0), Vector2(0, zoom_level), _world_to_screen(world_start))
	var tint := Color(1, 1, 1, opacity)
	for i in range(3):
		var mesh: ArrayMesh = meshes[i]
		if mesh.get_surface_count() > 0:
			draw_mesh(mesh, CAVE_WALL_TEXTURE if i == 0 else (CAVE_FORMATIONS if i == 2 else null), transform, tint)

func _draw_isometric_contour(cave: Dictionary, ink: Color) -> void:
	var outline := PackedVector2Array()
	for point in cave.contour:
		outline.append(cave.position + point)
	outline.append(outline[0])
	var visible_edges: Array[PackedVector2Array] = [outline]
	for exit_info in _visible_exits_for_cave(cave.id):
		var corridor := _corridor_by_id(exit_info.corridor_id)
		if corridor.is_empty():
			continue
		var stub := _isometric_exit_stub(exit_info, corridor, cave)
		if stub.size() < 2:
			continue
		var edges := _isometric_corridor_edges(stub, float(corridor.width) * 0.65)
		if edges.is_empty():
			continue
		var strip: PackedVector2Array = edges.left.duplicate()
		var right: PackedVector2Array = edges.right.duplicate()
		right.reverse()
		strip.append_array(right)
		var clipped: Array[PackedVector2Array] = []
		for edge in visible_edges:
			clipped.append_array(Geometry2D.clip_polyline_with_polygon(edge, strip))
		visible_edges = clipped
	for edge in visible_edges:
		var screen := PackedVector2Array()
		for point in edge:
			screen.append(_world_to_screen(point))
		if screen.size() >= 2:
			draw_polyline(screen, ink, maxf(1.2, zoom_level * 0.3), true)

func _draw_isometric_corridors(cave: Dictionary, passage_id: int) -> void:
	# Draw each gallery as a coplanar textured floor strip. The same world-space
	# UVs as the room make the overlapping mouth blend without polygon booleans.
	for exit_info in _visible_exits_for_cave(cave.id):
		var corridor: Dictionary = {}
		for candidate in world.corridors:
			if candidate.id == exit_info.corridor_id:
				corridor = candidate
				break
		if corridor.is_empty() or corridor.id == passage_id or _gallery_has_lamps(corridor):
			continue
		var mouth_already_drawn := false
		for span in _drawn_gallery_spans(corridor):
			if _distance_to_polyline(exit_info.position,span)<1.0: mouth_already_drawn=true; break
		if mouth_already_drawn: continue
		var centerline := _isometric_exit_stub(exit_info, corridor, cave)
		if centerline.size() >= 2:
			var edges := _isometric_corridor_edges(centerline, float(corridor.width) * 0.65)
			if edges.is_empty():
				continue
			_draw_world_textured_corridor(edges, cave.id)
			if _gallery_has_lamps(corridor):
				_draw_gallery_lamps(edges)
			var room_polygon := PackedVector2Array()
			for point in cave.contour:
				room_polygon.append(cave.position + point)
			for side in [edges.left, edges.right]:
				for index in range(side.size() - 1):
					var progress := float(index) / float(side.size() - 1)
					var segment := PackedVector2Array([side[index], side[index + 1]])
					for outside in Geometry2D.clip_polyline_with_polygon(segment, room_polygon):
						if outside.size() >= 2:
							draw_line(_world_to_screen(outside[0]), _world_to_screen(outside[1]), Color("805043", 1.0 - progress), maxf(1.2, zoom_level * 0.3), true)


func _draw_isometric_passage(gallery: Dictionary, points: PackedVector2Array) -> void:
	if not _render_path_on_screen(points, (float(gallery.width) + 24.0) * zoom_level):
		return
	var edges := _isometric_corridor_edges(points, float(gallery.width) * 0.65)
	if edges.is_empty():
		return
	_draw_world_textured_corridor(edges, gallery.a, false)
	for side in [edges.left, edges.right]:
		var screen_side := PackedVector2Array()
		for point in side:
			screen_side.append(_world_to_screen(point))
		draw_polyline(screen_side, Color("805043"), maxf(1.2, zoom_level * 0.3), true)

func _has_accessible_pending_galleries(cave_id: int) -> bool:
	for exit_info in _visible_exits_for_cave(cave_id):
		var corridor := _corridor_by_id(exit_info.corridor_id)
		if not _gallery_was_crossed(corridor) and _is_gallery_exit_accessible(corridor, cave_id):
			return true
	return false

func _gallery_has_lamps(corridor: Dictionary) -> bool:
	return not corridor.is_empty() and completed_gallery_traces.has(corridor.id)

func _point_in_lit_gallery(point: Vector2) -> bool:
	var active := _inspection_gallery() if analysis_mode else {}
	if not active.is_empty():
		return _gallery_has_lamps(active) and _point_inside_corridor(point, active)
	for corridor_id in completed_gallery_traces:
		var corridor := _corridor_by_id(corridor_id)
		if not corridor.is_empty() and _point_inside_corridor(point, corridor):
			return true
	return false

func _draw_gallery_lamps(edges: Dictionary) -> void:
	if edges.is_empty() or not _render_path_on_screen(edges.left, 10.0 * zoom_level):
		return
	var left: PackedVector2Array = edges.left
	var right: PackedVector2Array = edges.right
	var glow_radius := 12.0 * _isometric_object_scale() / zoom_level
	var key := hash([left, right, glow_radius])
	if not render_gallery_lights.has(key):
		var glows := CaveWallMesh._builder()
		var lamps := CaveWallMesh._builder()
		var origin := left[0]
		var distance_to_lamp := 14.0
		var texture_size := Vector2(GALLERY_FLOOR_LIGHT.get_size())
		var source := Rect2(360, 785, 535, 340)
		var uvs := PackedVector2Array([source.position / texture_size,
			Vector2(source.end.x, source.position.y) / texture_size, source.end / texture_size,
			Vector2(source.position.x, source.end.y) / texture_size])
		for index in range(left.size() - 1):
			var start := (left[index] + right[index]) * 0.5
			var finish := (left[index + 1] + right[index + 1]) * 0.5
			var length := start.distance_to(finish)
			if length <= 0.001:
				continue
			while distance_to_lamp < length:
				var progress := distance_to_lamp / length
				var axis := start.lerp(finish, progress)
				if _cave_at_position(axis) < 0:
					var position: Vector2 = axis
					var center := _render_project_delta(position - origin)
					var ring := _surface_ellipse_points(center, glow_radius, glow_radius, 16)
					for j in range(ring.size()):
						CaveWallMesh._triangle(glows, PackedVector2Array([center, ring[j], ring[(j + 1) % ring.size()]]), PackedColorArray([Color(1.0, 0.74, 0.37, 0.12)]))
					var along := (finish - start).normalized()
					var across := along.orthogonal()
					var points := PackedVector2Array()
					for corner in [Vector2(-3, -2.7), Vector2(3, -2.7), Vector2(3, 2.7), Vector2(-3, 2.7)]:
						points.append(_render_project_delta(position + along * corner.x + across * corner.y - origin))
					CaveWallMesh._quad(lamps, points, PackedColorArray([Color.WHITE]), uvs)
				distance_to_lamp += 35.0
			distance_to_lamp -= length
		if render_gallery_lights.size() >= 256:
			render_gallery_lights.clear()
		render_gallery_lights[key] = [CaveWallMesh._mesh(glows), CaveWallMesh._mesh(lamps)]
	var meshes: Array = render_gallery_lights[key]
	var transform := _render_mesh_transform(left[0])
	for i in range(2):
		var mesh: ArrayMesh = meshes[i]
		if mesh.get_surface_count() > 0:
			draw_mesh(mesh, null if i == 0 else GALLERY_FLOOR_LIGHT, transform)

func _draw_gallery_floor_light(position: Vector2, along: Vector2) -> void:
	# Rotate on the logical ground plane BEFORE projection, not in screen space.
	# The source artwork already has a compressed isometric footprint.
	var across := along.orthogonal()
	var points := PackedVector2Array()
	for corner in [Vector2(-3, -2.7), Vector2(3, -2.7), Vector2(3, 2.7), Vector2(-3, 2.7)]:
		points.append(_world_to_screen(position + along * corner.x + across * corner.y))
	var texture_size := Vector2(GALLERY_FLOOR_LIGHT.get_size())
	var source := Rect2(360, 785, 535, 340)
	var uvs := PackedVector2Array([source.position / texture_size,
		Vector2(source.end.x, source.position.y) / texture_size, source.end / texture_size,
		Vector2(source.position.x, source.end.y) / texture_size])
	draw_polygon(points, PackedColorArray([Color.WHITE]), uvs, GALLERY_FLOOR_LIGHT)

func _gallery_was_crossed(corridor: Dictionary) -> bool:
	var mouth_a: Vector2 = corridor.exit_a
	var mouth_b: Vector2 = corridor.exit_b
	var tolerance: float = minf(float(corridor.width) * 0.65, mouth_a.distance_to(mouth_b) * 0.3)
	for span in walked_gallery_spans.get(corridor.id, []):
		if _distance_to_polyline(mouth_a, span) <= tolerance and _distance_to_polyline(mouth_b, span) <= tolerance:
			return true
	return false

func _draw_world_textured_corridor(edges: Dictionary, cave_id: int, fade_at_end: bool = true) -> void:
	var texture := _get_cave_room_floor_texture(cave_id)
	var left: PackedVector2Array = edges.left
	var right: PackedVector2Array = edges.right
	var key := hash([left, right, cave_id, fade_at_end])
	if not render_corridor_floors.has(key):
		var builder := CaveWallMesh._builder()
		for index in range(left.size() - 1):
			var alpha_a := 1.0 - smoothstep(0.62, 1.0, float(index) / float(left.size() - 1)) if fade_at_end else 1.0
			var alpha_b := 1.0 - smoothstep(0.62, 1.0, float(index + 1) / float(left.size() - 1)) if fade_at_end else 1.0
			var vertices := [left[index], right[index], left[index + 1], right[index + 1]]
			var alphas := [alpha_a, alpha_a, alpha_b, alpha_b]
			for triangle_indices in [[0, 1, 2], [2, 1, 3]]:
				var triangle := PackedVector2Array()
				var uvs := PackedVector2Array()
				var colors := PackedColorArray()
				for vertex_index in triangle_indices:
					var world_point: Vector2 = vertices[vertex_index]
					triangle.append(_render_project_delta(world_point - left[0]))
					uvs.append(_floor_material_uv(world_point, texture))
					colors.append(Color(1, 1, 1, alphas[vertex_index]))
				CaveWallMesh._triangle(builder, triangle, colors, uvs)
		if render_corridor_floors.size() >= 256:
			render_corridor_floors.clear()
		render_corridor_floors[key] = CaveWallMesh._mesh(builder)
	draw_mesh(render_corridor_floors[key], texture, _render_mesh_transform(left[0]),Color(0.76,0.88,0.94) if current_level==1 else Color.WHITE)
	preload("res://scripts/cave_ambience.gd").draw_gallery_relief(self,edges,fade_at_end)
	# Room and passage walls must share the same depth/lighting pass and palette.
	render_visible_gallery_walls.append({"spans": _cached_corridor_wall_spans(edges), "fade": fade_at_end})

func _isometric_exit_stub(exit_info: Dictionary, corridor: Dictionary, cave: Dictionary) -> PackedVector2Array:
	# Start slightly inside the room so the corridor floor overlaps the cave
	# floor. This removes a black seam and gives both surfaces the same plane.
	var outward: Vector2 = exit_info.direction.normalized()
	if outward.length_squared() < 0.001:
		return PackedVector2Array()
	var route: PackedVector2Array = corridor.points
	if route.size() < 3:
		return PackedVector2Array()
	if corridor.b == cave.id:
		var reversed_route := PackedVector2Array()
		for point_index in range(route.size() - 1, -1, -1):
			reversed_route.append(route[point_index])
		route = reversed_route
	var mouth: Vector2 = exit_info.position
	var projection := _project_to_polyline(mouth, route)
	var points := PackedVector2Array([mouth - outward * 10.0, mouth])
	var remaining: float = float(corridor.width) * 0.75
	for index in range(int(projection.segment) + 1, route.size()):
		var previous := points[points.size() - 1]
		var distance := previous.distance_to(route[index])
		if distance <= 0.001:
			continue
		var length := minf(distance, remaining)
		var steps := maxi(1, ceili(length / 3.0))
		for step in range(1, steps + 1):
			points.append(previous.lerp(route[index], length / distance * float(step) / float(steps)))
		remaining -= length
		if remaining <= 0.001:
			break
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

func _point_inside_connected_corridor(point: Vector2, cave: Dictionary) -> bool:
	for exit_info in _visible_exits_for_cave(cave.id):
		for corridor in world.corridors:
			if corridor.id != exit_info.corridor_id:
				continue
			var points: PackedVector2Array = corridor.points
			for index in range(points.size() - 1):
				var closest := Geometry2D.get_closest_point_to_segment(point, points[index], points[index + 1])
				if closest.distance_to(point) <= float(corridor.width) * 0.55:
					return true
	return false

func _inspection_gallery() -> Dictionary:
	for corridor in world.corridors:
		if corridor.id == inspection_corridor_id and (corridor.a == selected_cave or corridor.b == selected_cave):
			return corridor
	return {}

func _point_inside_corridor(point: Vector2, corridor: Dictionary) -> bool:
	var route: PackedVector2Array = corridor.points
	var mask_radius: float = (ceilf(float(corridor.width) * 0.5 / world.cell_size) + 0.7) * world.cell_size
	for index in range(route.size() - 1):
		var closest := Geometry2D.get_closest_point_to_segment(point, route[index], route[index + 1])
		if closest.distance_to(point) <= mask_radius:
			return true
	return false

func _visible_gallery_at(point: Vector2) -> Dictionary:
	if _point_inside_cave_id(point, selected_cave):
		return {}
	var cave: Dictionary = world.caves[selected_cave]
	var nearest: Dictionary = {}
	var nearest_distance := INF
	for corridor in world.corridors:
		if corridor.a != selected_cave and corridor.b != selected_cave:
			continue
		var spans: Array = [corridor.points] if _gallery_has_lamps(corridor) else _drawn_gallery_spans(corridor)
		for span: PackedVector2Array in spans:
			var distance := _isometric_gallery_hit_distance(point, span, float(corridor.width) * 0.65)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest = corridor
	for exit_info in _visible_exits_for_cave(selected_cave):
		var corridor := _corridor_by_id(exit_info.corridor_id)
		if corridor.is_empty() or _gallery_has_lamps(corridor):
			continue
		var centerline := _isometric_exit_stub(exit_info, corridor, cave)
		var distance := _isometric_gallery_hit_distance(point, centerline, float(corridor.width) * 0.65)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = corridor
	return nearest

func _isometric_gallery_hit_distance(point: Vector2, centerline: PackedVector2Array, width: float) -> float:
	var edges := _isometric_corridor_edges(centerline, width)
	if edges.is_empty():
		return INF
	var left: PackedVector2Array = edges.left
	var right: PackedVector2Array = edges.right
	var distance := INF
	for index in range(left.size() - 1):
		if Geometry2D.point_is_inside_triangle(point, left[index], right[index], left[index + 1]) or Geometry2D.point_is_inside_triangle(point, left[index + 1], right[index], right[index + 1]):
			var center := (left[index] + right[index]) * 0.5
			var next_center := (left[index + 1] + right[index + 1]) * 0.5
			distance = minf(distance, point.distance_squared_to(Geometry2D.get_closest_point_to_segment(point, center, next_center)))
	return distance

func _isometric_corridor_edges(centerline: PackedVector2Array, width: float) -> Dictionary:
	var left_edge := PackedVector2Array()
	var right_edge := PackedVector2Array()
	for index in range(centerline.size()):
		var previous: Vector2 = centerline[maxi(0, index - 1)]
		var following: Vector2 = centerline[mini(centerline.size() - 1, index + 1)]
		var tangent := (following - previous).normalized()
		if tangent.length_squared() < 0.001:
			continue
		# Width belongs to the world geometry, like the aperture and walkable mask.
		# Screen-space width inflated the strip and made each opening a broad slab.
		var progress := float(index) / float(centerline.size() - 1)
		var half_width := width * 0.5 * lerpf(1.0, 0.62, progress * progress)
		var normal := tangent.orthogonal() * half_width
		left_edge.append(centerline[index] + normal)
		right_edge.append(centerline[index] - normal)
	if left_edge.size() < 2:
		return {}
	return {"left": left_edge, "right": right_edge}

func _draw_isometric_obstacle(obstacle: Dictionary) -> void:
	if float(obstacle.radius) >= 12.0:
		_draw_biome_rock_sprite(obstacle.position, float(obstacle.radius), int(obstacle.id) % 9)
		return
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

func _draw_explorer_sprite(feet: Vector2, scale: float, facing: Vector2, walking: bool) -> void:
	var column := OrganismPixelArt.facing_index(Vector2(facing.x, facing.y * ISO_VERTICAL_RATIO))
	var frame := int(floor(fauna_time * 7.0)) % 2 if walking and not taking_field_photo else 0
	var cell := Vector2(EXPLORER_SPRITE.get_size()) / Vector2(4, 2)
	var source := Rect2(Vector2(column, frame) * cell, cell)
	var size := Vector2(62, 62 * cell.y / cell.x) * scale
	var contact := 0.90 if frame == 0 else 0.89
	draw_texture_rect_region(EXPLORER_SPRITE,
		Rect2((feet - size * Vector2(0.5, contact)).round(), size), source, Color.WHITE, false, true)

func _draw_isometric_explorer(position: Vector2) -> void:
	var screen := _world_to_screen(position)
	var scale := minf(zoom_level * 0.28, 1.6)
	var ground := _surface_ellipse_points(screen, 11 * scale, 4 * scale, 20)
	draw_colored_polygon(ground, Color("100e12", 0.65))
	_draw_explorer_sprite(screen, scale, explorer_facing, moving)

func _build_profiles_dialog() -> void:
	profiles_dialog = AcceptDialog.new()
	profiles_dialog.title = "Perfils i partides locals"
	profiles_dialog.ok_button_text = "TANCA"
	profiles_dialog.exclusive = true
	add_child(profiles_dialog)
	var contents := VBoxContainer.new()
	contents.custom_minimum_size.x = 410
	contents.add_theme_constant_override("separation", 10)
	profiles_dialog.add_child(contents)
	profiles_status = _add_equipment_label(contents, "", 13, CYAN)
	profiles_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	profiles_list = OptionButton.new()
	profiles_list.custom_minimum_size.y = 36
	profiles_list.item_selected.connect(func(_index: int) -> void: _refresh_profile_buttons())
	contents.add_child(profiles_list)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	contents.add_child(actions)
	save_profile_button = _button("DESA LA PARTIDA ACTIVA", Vector2.ZERO, Vector2(0, 34))
	load_profile_button = _button("CARREGA EL PERFIL", Vector2.ZERO, Vector2(0, 34), true)
	for button in [save_profile_button, load_profile_button]:
		button.custom_minimum_size.y = 34
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		actions.add_child(button)
	save_profile_button.pressed.connect(_manual_save_profile)
	load_profile_button.pressed.connect(_load_selected_profile)
	contents.add_child(HSeparator.new())
	profile_name_input = LineEdit.new()
	profile_name_input.placeholder_text = "Nom del perfil nou"
	profile_name_input.max_length = 32
	contents.add_child(profile_name_input)
	var create_button := _button("CREA PERFIL", Vector2.ZERO, Vector2(0, 34))
	create_button.custom_minimum_size.y = 34
	create_button.pressed.connect(_create_local_profile)
	contents.add_child(create_button)
	var history_button := _button("HISTORIAL D’EXPEDICIONS", Vector2.ZERO, Vector2(0, 34), true)
	history_button.custom_minimum_size.y = 34
	history_button.pressed.connect(func() -> void:
		profiles_dialog.hide()
		_show_expedition_history.call_deferred())
	contents.add_child(history_button)
	history_dialog = AcceptDialog.new()
	history_dialog.title = "Historial d’expedicions"
	history_dialog.ok_button_text = "TANCA"
	history_dialog.exclusive = true
	add_child(history_dialog)
	history_text = RichTextLabel.new()
	history_dialog.add_child(history_text)
	var restart_button := _button("REINICIA LA RUN", Vector2.ZERO, Vector2(0, 34), true)
	restart_button.custom_minimum_size.y = 34
	restart_button.pressed.connect(_confirm_run_restart)
	contents.add_child(restart_button)
	delete_profile_button = _button("ELIMINA EL PERFIL SELECCIONAT", Vector2.ZERO, Vector2(0, 34), true)
	delete_profile_button.custom_minimum_size.y = 34
	delete_profile_button.add_theme_color_override("font_color", BLOCKED_GALLERY_COLOR)
	delete_profile_button.pressed.connect(_confirm_delete_profile)
	contents.add_child(delete_profile_button)
	delete_profile_dialog = ConfirmationDialog.new()
	delete_profile_dialog.title = "Elimina totes les dades del perfil"
	delete_profile_dialog.ok_button_text = "ELIMINA DEFINITIVAMENT"
	delete_profile_dialog.cancel_button_text = "CANCEL·LA"
	delete_profile_dialog.dialog_autowrap = true
	delete_profile_dialog.exclusive = true
	delete_profile_dialog.confirmed.connect(_delete_selected_profile, CONNECT_DEFERRED)
	delete_profile_dialog.canceled.connect(func() -> void:
		pending_profile_deletion = ""
		_open_profiles.call_deferred())
	add_child(delete_profile_dialog)
	restart_run_dialog = ConfirmationDialog.new()
	restart_run_dialog.title = "Reinicia l’expedició"
	restart_run_dialog.dialog_text = "Començaràs a la superfície, amb l’equip inicial i una llavor nova. El mapa i els recursos es reiniciaran. El catàleg biològic i l’historial es conservaran."
	restart_run_dialog.dialog_autowrap = true
	restart_run_dialog.ok_button_text = "REINICIA"
	restart_run_dialog.cancel_button_text = "CANCEL·LA"
	restart_run_dialog.exclusive = true
	restart_run_dialog.confirmed.connect(_restart_current_run)
	restart_run_dialog.canceled.connect(_open_profiles, CONNECT_DEFERRED)
	add_child(restart_run_dialog)

func _confirm_run_restart() -> void:
	profiles_dialog.hide()
	restart_run_dialog.popup_centered(Vector2i(460, 0))

func _restart_current_run() -> void:
	if not _save_active_profile():
		_open_profiles()
		profiles_status.text = "No s’ha pogut desar la partida abans de reiniciar."
		return
	var previous := _capture_saved_game()
	_start_run_with_new_seed()
	if not _save_active_profile():
		_restore_saved_game(previous)
		_open_profiles()
		profiles_status.text = "No s’ha pogut desar la run nova. S’ha recuperat l’expedició anterior."

func _open_profiles() -> void:
	_refresh_profiles_list()
	profiles_status.text = "Desament automàtic · %s" % (active_profile_name if not active_profile_id.is_empty() else "Partida local")
	profiles_dialog.popup_centered(Vector2i(460, 0))

func _confirm_delete_profile() -> void:
	var index := profiles_list.selected
	if index < 0:
		return
	pending_profile_deletion = profiles_list.get_item_metadata(index)
	delete_profile_dialog.dialog_text = "Vols eliminar «%s»? S’esborraran la partida, la còpia de reserva, les fites, l’historial, el catàleg biològic i les fotos. Aquesta acció és irreversible." % profiles_list.get_item_text(index)
	profiles_dialog.hide()
	delete_profile_dialog.popup_centered(Vector2i(460, 0))

func _clear_profile_progress() -> void:
	deepest_reached = 0
	discovered_biomes.clear()
	expedition_history.clear()
	expedition_record.clear()
	biological_register.clear()
	biological_photos.clear()

func _delete_selected_profile() -> void:
	var id := pending_profile_deletion
	pending_profile_deletion = ""
	if LocalSaveStore.delete_profile(id) != OK:
		_open_profiles()
		profiles_status.text = "No s’han pogut eliminar tots els fitxers del perfil."
		return
	var current_slot := LocalSaveStore.AUTOMATIC_SLOT if active_profile_id.is_empty() else active_profile_id
	if id == current_slot:
		active_profile_id = ""
		active_profile_name = ""
		autosave_elapsed = 0.0
		LocalSaveStore.remember_active_slot(LocalSaveStore.AUTOMATIC_SLOT)
		_clear_profile_progress()
		_start_run_with_new_seed()
		if id != LocalSaveStore.AUTOMATIC_SLOT:
			_resume_autosave()
	_open_profiles()
	profiles_status.text = "Perfil eliminat."

func _new_expedition_record(run_seed: int, depth: int = 0) -> Dictionary:
	return {"seed": run_seed, "depth": depth, "started": Time.get_datetime_string_from_system(false, true),
		"ended": "", "outcome": "En curs", "reason": "", "milestones": []}

func _finish_expedition_record(outcome: String, reason: String = "") -> void:
	if expedition_record.is_empty() or expedition_record.outcome == "Mort":
		return
	expedition_record.outcome = outcome
	expedition_record.reason = reason
	expedition_record.ended = Time.get_datetime_string_from_system(false, true)

func _record_expedition_milestone(title: String) -> void:
	if not expedition_record.is_empty():
		expedition_record.milestones.append({"title": title, "depth": current_level,
			"date": Time.get_datetime_string_from_system(false, true)})

func _show_expedition_history() -> void:
	var records := expedition_history.duplicate()
	records.append(expedition_record)
	var deaths := 0
	for record in records:
		if record.outcome == "Mort":
			deaths += 1
	var lines := PackedStringArray(["Expedicions: %d   ·   Morts: %d   ·   Rècord de profunditat: %d" % [records.size(), deaths, -deepest_reached]])
	for index in range(records.size() - 1, -1, -1):
		var record: Dictionary = records[index]
		lines.append("\nExpedició %d · %s · Profunditat: %d · Llavor: %d" % [index + 1, record.outcome, -int(record.depth), record.seed])
		lines.append("Inici: %s%s" % [record.started, " · Final: " + record.ended if not record.ended.is_empty() else ""])
		if not record.reason.is_empty():
			lines.append(record.reason)
		for milestone in record.milestones:
			lines.append("  %s · Estrat %d · %s" % [milestone.date, -int(milestone.depth), milestone.title])
	history_text.text = "\n".join(lines)
	history_dialog.popup_centered(Vector2i(620, 480))
	history_text.scroll_to_line(0)

func _refresh_profiles_list() -> void:
	profiles_list.clear()
	var profiles := LocalSaveStore.list_profiles()
	if active_profile_id.is_empty() or not LocalSaveStore.read_profile(LocalSaveStore.AUTOMATIC_SLOT).is_empty():
		profiles_list.add_item("Partida local")
		profiles_list.set_item_metadata(0, LocalSaveStore.AUTOMATIC_SLOT)
		if active_profile_id.is_empty():
			profiles_list.select(0)
	var ids := profiles.keys()
	ids.sort_custom(func(a: String, b: String) -> bool: return profiles[a].naturalnocasecmp_to(profiles[b]) < 0)
	for id in ids:
		var index := profiles_list.item_count
		profiles_list.add_item(profiles[id])
		profiles_list.set_item_metadata(index, id)
		if id == active_profile_id:
			profiles_list.select(index)
	if profiles_list.selected < 0 and profiles_list.item_count > 0:
		profiles_list.select(0)
	_refresh_profile_buttons()

func _refresh_profile_buttons() -> void:
	save_profile_button.disabled = false
	load_profile_button.disabled = profiles_list.selected < 0
	delete_profile_button.disabled = profiles_list.selected < 0

func _create_local_profile() -> void:
	var profile_name := profile_name_input.text.strip_edges()
	if profile_name.is_empty():
		profiles_status.text = "Escriu un nom per al perfil."
		return
	var id := LocalSaveStore.profile_id(profile_name)
	if LocalSaveStore.list_profiles().has(id):
		profiles_status.text = "Aquest perfil ja existeix. El pots carregar de la llista."
		return
	# The first profile adopts the current expedition. Subsequent profiles start independently.
	if not active_profile_id.is_empty():
		if not _save_active_profile():
			profiles_status.text = "No s’ha pogut desar la partida activa."
			return
		var previous := _capture_saved_game()
		_clear_profile_progress()
		_new_world(randi_range(0, 0x7fffffff))
		if LocalSaveStore.write_profile(id, profile_name, _capture_saved_game()) != OK:
			_restore_saved_game(previous)
			profiles_status.text = "No s’ha pogut crear el perfil."
			return
	elif LocalSaveStore.write_profile(id, profile_name, _capture_saved_game()) != OK:
		profiles_status.text = "No s’ha pogut crear el perfil."
		return
	else:
		LocalSaveStore.delete_profile(LocalSaveStore.AUTOMATIC_SLOT)
	active_profile_id = id
	active_profile_name = profile_name
	LocalSaveStore.remember_active_slot(id)
	autosave_elapsed = 0.0
	seed_edit.text = str(seed_value)
	profile_name_input.clear()
	_refresh_profiles_list()
	profiles_status.text = "Perfil creat i partida desada: %s" % profile_name

func _manual_save_profile() -> void:
	profiles_status.text = "Partida desada." if _save_active_profile() else "No s’ha pogut desar la partida."

func _load_selected_profile() -> void:
	if profiles_list.selected < 0:
		return
	var id: String = profiles_list.get_item_metadata(profiles_list.selected)
	if not _save_active_profile():
		profiles_status.text = "No s’ha pogut desar la partida activa."
		return
	var profile := LocalSaveStore.read_profile(id, _valid_saved_game)
	if profile.is_empty():
		profiles_status.text = "La partida no es pot carregar o té un format incompatible."
		return
	active_profile_id = "" if id == LocalSaveStore.AUTOMATIC_SLOT else id
	active_profile_name = "" if active_profile_id.is_empty() else profile.name
	LocalSaveStore.remember_active_slot(id)
	autosave_elapsed = 0.0
	profiles_dialog.hide()
	_restore_saved_game(profile.game)

func _resume_autosave() -> void:
	var id := LocalSaveStore.active_slot()
	var profile := LocalSaveStore.read_profile(id, _valid_saved_game)
	if profile.is_empty() and id != LocalSaveStore.AUTOMATIC_SLOT:
		id = LocalSaveStore.AUTOMATIC_SLOT
		profile = LocalSaveStore.read_profile(id, _valid_saved_game)
	if profile.is_empty():
		return
	if id != LocalSaveStore.AUTOMATIC_SLOT:
		active_profile_id = id
		active_profile_name = profile.name
	_restore_saved_game(profile.game)

func _save_active_profile() -> bool:
	autosave_elapsed = 0.0
	if world.is_empty():
		return false
	var id := LocalSaveStore.AUTOMATIC_SLOT if active_profile_id.is_empty() else active_profile_id
	var profile_name := "Partida local" if active_profile_id.is_empty() else active_profile_name
	return LocalSaveStore.write_profile(id, profile_name, _capture_saved_game()) == OK

func _capture_saved_game() -> Dictionary:
	var game := {}
	for field in SAVED_GAME_FIELDS:
		game[field] = get(field)
	game["level"] = _serializable_level(_level_snapshot())
	var levels := {}
	for depth in inactive_levels:
		levels[depth] = _serializable_level(inactive_levels[depth])
	game["inactive_levels"] = levels
	var photos := {}
	for species in field_photos:
		if not saved_photo_bytes.has(species):
			var texture: Texture2D = field_photos[species]
			saved_photo_bytes[species] = texture.get_image().save_png_to_buffer()
		photos[species] = saved_photo_bytes[species]
	game["photos"] = photos
	game["death_message"] = death_dialog.dialog_text if death_dialog.visible else ""
	game["depth_trip_target"] = depth_trip_target
	game["expedition_completed"] = expedition_completed
	game["deepest_reached"] = deepest_reached
	game["campaign_biome_order"] = campaign_biome_order.duplicate()
	game["navigation_marker"]=navigation_marker.duplicate(true)
	game["marker_return_pending"]=marker_return_pending
	game["discovered_biomes"] = discovered_biomes.duplicate()
	game["defence_state"] = defence_state.duplicate()
	game["starting_rewards_depth"] = starting_rewards_depth
	game["expedition_history"] = expedition_history
	game["expedition_record"] = expedition_record
	game["biological_register"] = biological_register
	game["biological_photos"] = biological_photos
	game["show_beacon_waves"] = show_beacon_waves
	return game.duplicate(true)

func _serializable_level(state: Dictionary) -> Dictionary:
	var stored := state.duplicate()
	stored.erase("cave_floor_textures")
	return stored

func _valid_saved_level(state: Dictionary) -> bool:
	for field in LEVEL_STATE_FIELDS:
		if field == "cave_floor_textures":
			continue
		if field=="fauna_pause" and not state.has(field): continue
		if not state.has(field) or typeof(state[field]) != typeof(get(field)):
			return false
	var saved_world: Dictionary = state.world
	return saved_world.get("caves") is Array and not saved_world.caves.is_empty() and saved_world.get("corridors") is Array and saved_world.get("grid_size") is Vector2i and saved_world.get("walkable_mask") is PackedByteArray and saved_world.get("terrain_mask") is PackedByteArray and state.revealed_mask.size() == saved_world.terrain_mask.size()

func _valid_saved_game(game: Dictionary) -> bool:
	if game.has("campaign_biome_order") and (not game.campaign_biome_order is Array or not CampaignRules.valid_order(game.campaign_biome_order)):
		return false
	if game.has("discovered_biomes") and not game.discovered_biomes is Dictionary: return false
	if game.has("defence_state") and not game.defence_state is Dictionary: return false
	for field in SAVED_GAME_FIELDS:
		if not game.has(field) or typeof(game[field]) != typeof(get(field)):
			return false
	if game.current_level < 0 or game.current_level > CAMPAIGN_DEPTH or not game.get("level") is Dictionary or not _valid_saved_level(game.level):
		return false
	if not game.get("inactive_levels") is Dictionary or not game.get("photos") is Dictionary or not game.get("death_message") is String:
		return false
	for state in game.inactive_levels.values():
		if not state is Dictionary or not _valid_saved_level(state):
			return false
	return true

func _restore_saved_game(game: Dictionary) -> void:
	navigation_marker=game.get("navigation_marker",{}).duplicate(true)
	marker_return_pending=bool(game.get("marker_return_pending",false))
	var saved_order: Array = game.get("campaign_biome_order",CampaignRules.CLASSIC_ORDER)
	campaign_biome_order = saved_order.duplicate() if CampaignRules.valid_order(saved_order) else CampaignRules.CLASSIC_ORDER.duplicate()
	discovered_biomes = game.get("discovered_biomes",{}).duplicate()
	defence_state=ExpeditionDefence.restored(game.get("defence_state",{}))
	defence_system.reset()
	show_beacon_waves = bool(game.get("show_beacon_waves", true))
	beacon_waves_toggle.set_pressed_no_signal(show_beacon_waves)
	expedition_completed = bool(game.get("expedition_completed", false))
	depth_trip_target = clampi(int(game.get("depth_trip_target", -1)), -1, CAMPAIGN_DEPTH)
	for field in SAVED_GAME_FIELDS:
		var current = get(field)
		if current is Array or current is Dictionary:
			current.assign(game[field])
		else:
			set(field, game[field])
	inactive_levels = game.inactive_levels
	expedition_history.assign(game.get("expedition_history", []))
	expedition_record = game.get("expedition_record", {})
	biological_register = game.get("biological_register", {})
	biological_photos = game.get("biological_photos", {})
	deepest_reached = clampi(int(game.get("deepest_reached", 0)), 0, CAMPAIGN_DEPTH)
	deepest_reached = maxi(deepest_reached, current_level)
	if current_level>0: discovered_biomes[_biome_at_depth(current_level)] = true
	for depth in inactive_levels:
		if not inactive_levels[depth].get("visited_caves", {}).is_empty():
			deepest_reached = maxi(deepest_reached, clampi(int(depth), 0, CAMPAIGN_DEPTH))
	if not game.has("discovered_biomes"):
		for start: int in CampaignRules.STARTS:
			if start<=deepest_reached: discovered_biomes[_biome_at_depth(start)] = true
	starting_rewards_depth = clampi(int(game.get("starting_rewards_depth", 0)), 0, deepest_reached)
	if expedition_record.is_empty():
		var depth := current_level
		for previous_depth in inactive_levels:
			depth = maxi(depth, int(previous_depth))
		expedition_record = _new_expedition_record(seed_value, depth)
		if not game.death_message.is_empty():
			_finish_expedition_record("Mort", game.death_message.get_slice("\n", 0))
		elif expedition_completed:
			_finish_expedition_record("Completada")
	for state in inactive_levels.values():
		state["cave_floor_textures"] = {}
		state["fauna_pause"] = state.get("fauna_pause",{})
	for field in LEVEL_STATE_FIELDS:
		set(field, game.level.get(field, {}))
	if current_level == 3 and descent_access < 0:
		descent_access = _pick_descent_access()
	helmet_light_zone_lit = surface_mode or _has_ambient_light(unit_position)
	field_photos.clear()
	saved_photo_bytes.clear()
	for species in game.photos:
		var bytes = game.photos[species]
		var picture := Image.new()
		if bytes is PackedByteArray and picture.load_png_from_buffer(bytes) == OK:
			field_photos[species] = ImageTexture.create_from_image(picture)
			saved_photo_bytes[species] = bytes
	_remember_current_biology()
	selected_route.assign(move_path)
	dragging = false
	warned_dark_movement = false
	resource_gains.clear()
	resource_previous_counts.clear()
	field_action_completed_until.clear()
	seed_edit.text = str(seed_value)
	_update_map_stats()
	_update_view_mode_ui()
	_update_field_action_cards()
	_update_beacon_status()
	queue_redraw()
	if not game.death_message.is_empty():
		death_dialog.dialog_text = _death_summary(game.death_message.get_slice("\n", 0))
		death_dialog.popup_centered(Vector2i(440, 0))
	elif depth_trip_target >= 0 and not moving:
		_continue_depth_trip.call_deferred()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and is_instance_valid(seed_edit):
		_save_active_profile()

func _build_ui() -> void:
	game_audio = preload("res://scripts/game_audio.gd").new()
	add_child(game_audio)
	var lighting := preload("res://scripts/cave_lighting.gd").new()
	add_child(lighting)
	add_child(preload("res://scripts/beacon_overlay.gd").new())
	add_child(preload("res://scripts/defence_overlay.gd").new())
	var shared_ui_theme := preload("res://scripts/interface_theme.gd").build()
	child_entered_tree.connect(func(node: Node) -> void:
		if node is Window:
			node.theme = shared_ui_theme
			node.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR)
	_build_discovery_dialog()
	death_dialog = AcceptDialog.new()
	death_dialog.title = "Fi de l’expedició"
	death_dialog.ok_button_text = "COMENÇA UN MÓN NOU"
	death_dialog.exclusive = true
	death_dialog.dialog_autowrap = true
	add_child(death_dialog)
	death_dialog.confirmed.connect(_restart_after_death)
	victory_dialog = AcceptDialog.new()
	victory_dialog.title = "Expedició completada"
	victory_dialog.dialog_text = "Has completat la investigació del Nucli a l’estrat −20."
	victory_dialog.dialog_autowrap = true
	victory_dialog.ok_button_text = "TANCA"
	victory_dialog.exclusive = true
	add_child(victory_dialog)
	death_dialog.canceled.connect(_restart_after_death)
	ui_root = Control.new()
	# Text must not inherit the nearest-neighbour filtering used by world sprites.
	ui_root.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	ui_root.theme = shared_ui_theme
	ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_root.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(ui_root)
	var left := _panel(Rect2(0, 8, 280, 350))
	left.get_child(0).hide()
	left.draw.connect(func() -> void: _draw_register_panel_frame(left))
	left.scale = Vector2.ONE * SIDE_PANEL_SCALE
	ui_root.add_child(left)
	_add_label(left, "SUBTERRA: MARS", 16, Color("e4f1f1"), Vector2(16, 12), Vector2(174, 26))
	var profiles_button := _button("PARTIDA", Vector2(190, 12), Vector2(74, 25), true)
	profiles_button.pressed.connect(_open_profiles)
	left.add_child(profiles_button)
	_build_profiles_dialog()
	mode_heading_label = _add_label(left, "MAPA DE RECERCA   /   ESTRAT -1", 10, MUTED, Vector2(16, 42), Vector2(248, 18))
	seed_edit = LineEdit.new()
	seed_edit.position = Vector2(16, 76)
	seed_edit.size = Vector2(145, 34)
	seed_edit.text = str(seed_value)
	seed_edit.placeholder_text = "Llavor"
	left.add_child(seed_edit)
	new_game_button = _button("NOVA PARTIDA", Vector2(168, 76), Vector2(96, 34))
	new_game_button.pressed.connect(_on_new_pressed)
	left.add_child(new_game_button)
	map_return_button = _button("MAPA", Vector2(16, 62), Vector2(80, 26), true)
	map_return_button.visible = false
	map_return_button.tooltip_text = "Torna a la vista general del mapa."
	map_return_button.pressed.connect(_exit_inspection)
	descend_button = _button("BAIXA A L’ESTRAT -1", Vector2(16, 62), Vector2(248, 26))
	descend_button.visible = false
	descend_button.tooltip_text = "Entra pel forat d'accés fins a la xarxa de coves de l’estrat -1."
	descend_button.pressed.connect(func() -> void: _confirm_depth_action(1, _descend_to_level_one))
	left.add_child(descend_button)
	base_return_button = _button("TORNA A LA BASE", Vector2(16, 62), Vector2(248, 26))
	base_return_button.visible = false
	base_return_button.tooltip_text = "Cal tornar a la sala d'entrada de l’estrat -1 per pujar a la superfície."
	base_return_button.pressed.connect(func() -> void: _confirm_depth_action(current_level - 1, _start_return_to_base))
	left.add_child(base_return_button)
	biome_base_return_button = _button("BASE DEL BIOMA", Vector2.ZERO, Vector2(172, 30), true)
	biome_base_return_button.pressed.connect(func() -> void: _request_depth_trip(_current_biome_base_depth()))
	left.add_child(biome_base_return_button)
	descend_navigation_button = _button("", Vector2(144, 130), Vector2(120, 30))
	descend_navigation_button.hide()
	descend_navigation_button.pressed.connect(func() -> void: _confirm_depth_action(current_level + 1, _start_descent_navigation))
	left.add_child(descend_navigation_button)
	catalogs_panel = _panel(Rect2(0, 0, 280, 136))
	ui_root.add_child(catalogs_panel)
	_add_label(catalogs_panel, "INVENTARI I CATÀLEGS", 11, MUTED, Vector2(12, 8), Vector2(196, 18))
	base_catalog_button = _button("CATÀLEG BIOLÒGIC", Vector2(12, 64), Vector2(256, 27), true)
	base_catalog_button.pressed.connect(_open_flora_catalog)
	catalogs_panel.add_child(base_catalog_button)
	craft_beacon_button = _button("FABRICA BALISA · 2 MATERIALS", Vector2(16, 234), Vector2(248, 32))
	craft_beacon_button.pressed.connect(_craft_equipment.bind(true))
	craft_oxygen_button = _button("FABRICA RESERVA D’OXIGEN · 1 MATERIAL", Vector2(16, 274), Vector2(248, 32))
	craft_oxygen_button.tooltip_text = "Afegeix una reserva portàtil d’oxigen."
	craft_oxygen_button.pressed.connect(_craft_equipment.bind(false))
	craft_suit_button = _button("VESTIT ESPACIAL REFORÇAT · 3 MATERIALS", Vector2(16, 314), Vector2(248, 32))
	craft_suit_button.pressed.connect(_craft_reinforced_suit)
	status_label = _add_label(left, "GENERADOR P0B · %s" % Generator.GENERATOR_VERSION, 10, Color("89b0bb"), Vector2(16, 100), Vector2(248, 30))
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_add_label(left, "PROFUNDITAT", 11, MUTED, Vector2(16, 138), Vector2(248, 18))
	var rewards_button := _button("★ FITES", Vector2(180, 132), Vector2(84, 25), true)
	rewards_button.add_theme_color_override("font_color", Color("ffd48a"))
	rewards_button.pressed.connect(_show_depth_rewards)
	left.add_child(rewards_button)
	rewards_dialog = AcceptDialog.new()
	rewards_dialog.title = "Fites de profunditat"
	rewards_dialog.ok_button_text = "TANCA"
	rewards_dialog.dialog_autowrap = true
	rewards_dialog.exclusive = true
	add_child(rewards_dialog)
	_build_depth_selector(left)
	var inventory_button := _button("INVENTARI", Vector2(12, 30), Vector2(256, 27), true)
	inventory_button.pressed.connect(_open_inventory.bind(false))
	catalogs_panel.add_child(inventory_button)
	var equipment_catalog_button := _button("EQUIP I MILLORES", Vector2(12, 98), Vector2(256, 27), true)
	equipment_catalog_button.pressed.connect(_open_inventory.bind(true))
	catalogs_panel.add_child(equipment_catalog_button)
	_build_inventory_and_workshop()

	level_panel = _panel(Rect2(0, 18, 280, 132))
	level_panel.position = Vector2(1142, 18)
	ui_root.add_child(level_panel)
	level_panel.get_child(0).hide()
	_add_section_frame(level_panel, Rect2(0, 0, 280, 54))
	_add_label(level_panel, "SALES ESCANEJADES", 10, MUTED, Vector2(16, 9), Vector2(115, 18))
	cave_count_label = _add_label(level_panel, "01", 19, Color("dcecf0"), Vector2(16, 23), Vector2(95, 28))
	_add_label(level_panel, "SORTIDES", 10, ACCESSIBLE_GALLERY_COLOR, Vector2(121, 9), Vector2(65, 18))
	exit_count_label = _add_label(level_panel, "0", 19, ACCESSIBLE_GALLERY_COLOR, Vector2(121, 23), Vector2(65, 28))
	_add_label(level_panel, "BLOQUEJADES", 10, BLOCKED_GALLERY_COLOR, Vector2(185, 9), Vector2(85, 18))
	blocked_exit_count_label = _add_label(level_panel, "0", 19, BLOCKED_GALLERY_COLOR, Vector2(185, 23), Vector2(85, 28))
	map_options_window = AcceptDialog.new()
	map_options_window.title = "Opcions del mapa"
	add_child(map_options_window)
	var map_options_content := Control.new()
	map_options_content.custom_minimum_size = Vector2(310, 486)
	map_options_window.add_child(map_options_content)
	seed_edit.reparent(map_options_content, false)
	seed_edit.position = Vector2(16, 20)
	new_game_button.reparent(map_options_content, false)
	new_game_button.position = Vector2(174, 20)
	_add_label(map_options_content, "LLAVOR DE LA PARTIDA", 10, MUTED, Vector2(16, 2), Vector2(248, 17))
	_add_label(map_options_content, "VISOR DE DESENVOLUPAMENT", 11, MUTED, Vector2(16, 67), Vector2(248, 18))
	var toggles := [ ["Graf", "graph"], ["Contorns", "contours"], ["Aparició", "spawn"] ]
	for i in range(toggles.size()):
		var check := CheckButton.new()
		check.text = toggles[i][0]
		check.position = Vector2(12 + (i % 2) * 126, 88 + (i / 2) * 34)
		check.button_pressed = true
		check.add_theme_color_override("font_color", Color("b4ccd2"))
		check.toggled.connect(_on_overlay_toggled.bind(toggles[i][1]))
		map_options_content.add_child(check)
	dev_toggle = CheckButton.new()
	dev_toggle.text = "MAPA COMPLET (DEV)"
	dev_toggle.position = Vector2(12, 160)
	dev_toggle.size = Vector2(248, 28)
	dev_toggle.button_pressed = false
	dev_toggle.tooltip_text = "Mostra tota la xarxa generada per inspeccionar llavors."
	dev_toggle.add_theme_font_size_override("font_size", 10)
	dev_toggle.add_theme_color_override("font_color", Color("b4ccd2"))
	dev_toggle.toggled.connect(_on_dev_mode_toggled)
	map_options_content.add_child(dev_toggle)
	var ring_toggle := CheckButton.new()
	ring_toggle.text = "Cercles fixos de cobertura"
	ring_toggle.position = Vector2(12, 198)
	ring_toggle.button_pressed = show_signal_rings
	ring_toggle.toggled.connect(_on_overlay_toggled.bind("signal_rings"))
	map_options_content.add_child(ring_toggle)
	var findings_toggle := CheckButton.new()
	findings_toggle.text = "Marcadors de flora i fauna"
	findings_toggle.position = Vector2(12, 232)
	findings_toggle.button_pressed = show_findings
	findings_toggle.toggled.connect(_on_overlay_toggled.bind("findings"))
	map_options_content.add_child(findings_toggle)
	beacon_waves_toggle = CheckButton.new()
	beacon_waves_toggle.text = "Ones en moviment"
	beacon_waves_toggle.tooltip_text = "Mostra l’animació de les ones de la base i les balises. Els cercles fixos tenen el seu propi control."
	beacon_waves_toggle.position = Vector2(12, 266)
	beacon_waves_toggle.button_pressed = show_beacon_waves
	beacon_waves_toggle.toggled.connect(_on_overlay_toggled.bind("beacon_waves"))
	map_options_content.add_child(beacon_waves_toggle)
	var sound_toggle := CheckButton.new()
	sound_toggle.text = "Efectes de so"
	sound_toggle.position = Vector2(12, 300)
	sound_toggle.button_pressed = game_audio.enabled
	sound_toggle.toggled.connect(game_audio.set_enabled)
	map_options_content.add_child(sound_toggle)
	var music_toggle := CheckButton.new()
	music_toggle.text="Música de fons"
	music_toggle.position=Vector2(12,334)
	music_toggle.button_pressed=game_audio.music_enabled
	music_toggle.toggled.connect(game_audio.set_music_enabled)
	map_options_content.add_child(music_toggle)
	var music_caption := _add_label(map_options_content,"Volum de música · %d%%" % roundi(game_audio.music_volume*100),12,CYAN,Vector2(16,376),Vector2(260,20))
	var music_slider := HSlider.new()
	music_slider.position=Vector2(16,402)
	music_slider.size=Vector2(266,24)
	music_slider.min_value=0
	music_slider.max_value=100
	music_slider.step=1
	music_slider.value=game_audio.music_volume*100
	music_slider.value_changed.connect(func(value: float) -> void:
		game_audio.set_music_volume(value/100.0)
		music_caption.text="Volum de música · %d%%" % roundi(value))
	map_options_content.add_child(music_slider)
	var recover_button := _button("DESENCALLA L’EXPLORADOR · F8",Vector2(12,440),Vector2(286,30))
	recover_button.tooltip_text="Cancel·la les ordres i busca un punt lliure proper sense canviar de sala ni recuperar reserves."
	recover_button.pressed.connect(_recover_stuck_explorer)
	map_options_content.add_child(recover_button)
	inspect_room_button = _button("INSPECCIONA", Vector2(16, 94), Vector2(120, 30))
	inspect_room_button.pressed.connect(_focus_selected_cave)
	inspect_room_button.tooltip_text = "Obre la sala on és l’explorador en vista isomètrica."
	fit_map_button = _button("ENQUADRA EL MAPA", Vector2.ZERO, Vector2(172, 30), true)
	fit_map_button.pressed.connect(_fit_discovered_map)
	map_legend_panel = _panel(Rect2(0, 0, 280, 414))
	ui_root.add_child(map_legend_panel)
	_add_label(map_legend_panel, "LLEGENDA DEL MAPA", 12, CYAN, Vector2(16, 8), Vector2(248, 20))
	var legend_content := Control.new()
	legend_content.position.y = 24
	legend_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	map_legend_panel.add_child(legend_content)
	map_options_section = _panel(Rect2(0, 64, 280, 68))
	level_panel.add_child(map_options_section)
	_add_label(map_options_section, "MAPA", 11, MUTED, Vector2(16, 8), Vector2(248, 18))
	var options_button := _button("OPCIONS", Vector2(16, 28), Vector2(248, 30), true)
	options_button.pressed.connect(func() -> void: map_options_window.popup_centered())
	map_options_section.add_child(options_button)
	var legend_icons := Control.new()
	legend_icons.position = Vector2(16, 12)
	legend_icons.size = Vector2(20, 380)
	legend_icons.mouse_filter = Control.MOUSE_FILTER_IGNORE
	legend_icons.draw.connect(func() -> void:
		var rows := [9, 32, 55, 78, 101, 136, 159, 194, 217, 240, 263, 286, 321, 344, 367]
		for i in range(rows.size()):
			legend_icons.draw_set_transform(Vector2.ZERO)
			var center := Vector2(9, rows[i])
			match i:
				0:
					legend_icons.draw_circle(center, 5, ORANGE)
					legend_icons.draw_circle(center, 8, Color("ffe2ba"), false, 1.4, true)
				1: _draw_room_state_badge(center, 1.0, true, legend_icons)
				2: _draw_room_complete_badge(legend_icons, center, 1.0)
				3: legend_icons.draw_circle(center, 7, ORANGE)
				4:
					_draw_elevator_icon(legend_icons, center - Vector2(4,0), false, 0.65)
					_draw_elevator_icon(legend_icons, center + Vector2(8,0), true, 0.65)
				5: _draw_room_state_badge(center, 0.9, false, legend_icons)
				6: _draw_blocked_exit_badge(legend_icons, center, 0.68)
				7: legend_icons.draw_texture_rect(preload("res://assets/ui/icona_flora_generica.svg"), Rect2(center - Vector2(10,10), Vector2(20,20)), false)
				8: legend_icons.draw_texture_rect(preload("res://assets/ui/icona_fauna_generica.svg"), Rect2(center - Vector2(10,10), Vector2(20,20)), false)
				9: _draw_mineral_badge(legend_icons, center)
				10: _draw_biological_trace(legend_icons, center, false)
				11: _draw_biological_trace(legend_icons, center, true)
				12: legend_icons.draw_rect(Rect2(center - Vector2(8,5), Vector2(17,10)), Color("285571"))
				13: legend_icons.draw_colored_polygon(PackedVector2Array([center+Vector2(0,-6), center+Vector2(6,0), center+Vector2(0,6), center+Vector2(-6,0)]), Color("abbeff"))
				14: _draw_workshop_badge(legend_icons, center)
		legend_icons.draw_set_transform(Vector2.ZERO))
	legend_content.add_child(legend_icons)
	var legend_labels := [
		"Explorador", "Sala escanejada", "Sala completa · 100%", "Sala d’entrada · accés a la base", "Ascensor · pujada o baixada",
		"Sortida accessible pendent de recórrer", "Sortida fora d’abast",
		"Flora · ! pendent d’analitzar", "Fauna · ! pendent d’observar", "Veta de mineral · ! pendent de minar",
		"Rastres de flora · cal un filtre", "Rastres de fauna · cal un filtre",
		"Galeria amb cobertura", "Balisa instal·lada", "Base del bioma",
	]
	var legend_row_centers := [9, 32, 55, 78, 101, 136, 159, 194, 217, 240, 263, 286, 321, 344, 367]
	for index in range(legend_labels.size()):
		_add_label(legend_content, legend_labels[index], 12, Color("dcecf0"), Vector2(43, legend_row_centers[index] + 2), Vector2(221, 20))
	_build_level_progress_strip()

	equipment_bar = PanelContainer.new()
	equipment_bar.custom_minimum_size = Vector2(1660, 150)
	equipment_bar.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	ui_root.add_child(equipment_bar)
	var groups := HBoxContainer.new()
	groups.add_theme_constant_override("separation", 16)
	equipment_bar.add_child(groups)
	inventory_strip_values.resize(21)
	_add_inventory_strip_group(groups, "RECURSOS", [0, STRIP_QUARTZ_SLOT, STRIP_MAGNETITE_SLOT, 6])
	_add_inventory_strip_group(groups, "EQUIP", [STRIP_HEALTH_SLOT,20,19, STRIP_OXYGEN_SLOT, 4, 9, 5, 3, STRIP_BIO_SCANNER_SLOT, 1, STRIP_LADDER_SLOT, 10, STRIP_MEDKIT_SLOT])
	_add_inventory_strip_group(groups, "RECERCA", [7, 8])

	navigation_panel = _panel(Rect2(0, 0, 620, 48))
	ui_root.add_child(navigation_panel)
	navigation_panel.add_child(inspect_room_button)
	navigation_panel.add_child(fit_map_button)
	var navigation_heading := _add_label(navigation_panel, "NAVEGACIÓ", 11, MUTED, Vector2(12, 0), Vector2(82, 48))
	navigation_heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	navigation_panel.add_child(map_return_button)
	map_return_button.text = "VES AL MAPA"
	map_return_button.position.x = 12.0
	map_return_button.size = Vector2(196, 30)
	center_explorer_button = _button("CENTRA L’EXPLORADOR", Vector2(12, 0), Vector2(196, 30), true)
	center_explorer_button.pressed.connect(_center_isometric_explorer)
	navigation_panel.add_child(center_explorer_button)
	level_title_label = _add_label(ui_root, "", 21, CYAN, Vector2.ZERO, Vector2(480, 32))
	level_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	room_progress_label = _add_label(ui_root, "", 17, CYAN, Vector2.ZERO, Vector2(380, 38))
	room_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	room_progress_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	room_progress_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	room_progress_label.draw.connect(_draw_isometric_room_badges)
	room_progress_label.hide()
	room_details_panel = _panel(Rect2(0, 0, 280, 292))
	ui_root.add_child(room_details_panel)
	room_details_panel.get_child(0).hide()
	room_details_panel.draw.connect(func() -> void:
		_draw_room_register_frame())
	room_details_title = _add_label(room_details_panel, "REGISTRE D’EXPEDICIÓ", 16, Color("e4f1f1"), Vector2(16, 12), Vector2(248, 24))
	room_details_status = _add_label(room_details_panel, "", 12, CYAN, Vector2(16, 42), Vector2(248, 22))
	room_details_meter = _new_resource_meter(100.0, CYAN)
	room_details_meter.position = Vector2(16, 68)
	room_details_meter.size = Vector2(248, 7)
	room_details_panel.add_child(room_details_meter)
	room_details_label = _add_label(room_details_panel, "", 12, Color("dcecf0"), Vector2(16, 88), Vector2(248, 192))
	room_details_label.add_theme_constant_override("line_spacing", 5)
	room_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	room_details_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	room_details_rows = VBoxContainer.new()
	room_details_rows.position = Vector2(16, 88)
	room_details_rows.size = Vector2(248, 192)
	room_details_rows.add_theme_constant_override("separation", 3)
	room_details_rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	room_details_panel.add_child(room_details_rows)
	room_details_label.hide()
	room_details_panel.hide()
	light_warning_label = _add_label(ui_root, "", 16, Color("ffd48a"), Vector2.ZERO, Vector2(280, 44))
	light_warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	light_warning_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	light_warning_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	light_warning_label.add_theme_color_override("font_outline_color", BG)
	light_warning_label.add_theme_constant_override("outline_size", 8)
	light_warning_label.hide()
	low_supply_label = _add_label(ui_root, "", 14, Color("ffd48a"), Vector2.ZERO, Vector2(440, 26))
	low_supply_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	low_supply_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	low_supply_label.add_theme_color_override("font_outline_color", BG)
	low_supply_label.add_theme_constant_override("outline_size", 8)
	low_supply_label.hide()
	field_camera_button = _new_equipment_icon_button("camera")
	bio_action_bar.add_child(field_camera_button)
	field_camera_button.pressed.connect(_photograph_subject)
	collect_flora_button = _new_equipment_icon_button("sample")
	bio_action_bar.add_child(collect_flora_button)
	collect_flora_button.pressed.connect(_collect_flora_sample)
	lower_level_button = _button("BAIXA A L’ESTRAT -2", Vector2(12, 382), Vector2(196, 30))
	lower_level_button.pressed.connect(func() -> void:
		if _is_final_room(selected_cave):
			_complete_final_research()
			return
		var destination: int = current_level - 1 if selected_cave == world.entry else current_level + 1
		_confirm_depth_action(destination, _use_selected_level_access))
	navigation_panel.add_child(lower_level_button)
	unstuck_navigation_button=_button("DESENCALLA · F8",Vector2.ZERO,Vector2(172,30))
	unstuck_navigation_button.tooltip_text="Recupera l’explorador en un punt lliure proper sense canviar de sala ni recarregar recursos."
	unstuck_navigation_button.pressed.connect(_recover_stuck_explorer)
	navigation_panel.add_child(unstuck_navigation_button)
	place_marker_button=_button("POSA MARCADOR",Vector2.ZERO,Vector2(140,30))
	place_marker_button.pressed.connect(_place_navigation_marker)
	navigation_panel.add_child(place_marker_button)
	return_marker_button=_button("TORNA AL MARCADOR",Vector2.ZERO,Vector2(140,30))
	return_marker_button.pressed.connect(_return_to_navigation_marker)
	navigation_panel.add_child(return_marker_button)
	var navigation_idle := StyleBoxFlat.new()
	navigation_idle.bg_color = Color("173244")
	navigation_idle.set_corner_radius_all(4)
	var navigation_hover := navigation_idle.duplicate() as StyleBoxFlat
	navigation_hover.bg_color = CYAN
	for button in [map_return_button, inspect_room_button, fit_map_button, center_explorer_button, biome_base_return_button, base_return_button, descend_navigation_button, lower_level_button, place_marker_button, return_marker_button, unstuck_navigation_button]:
		button.add_theme_stylebox_override("normal", navigation_idle)
		button.add_theme_stylebox_override("hover", navigation_hover)
		button.add_theme_stylebox_override("pressed", navigation_hover)
		button.add_theme_color_override("font_color", Color("dcecf0"))
		button.add_theme_color_override("font_hover_color", Color("06212a"))
		button.add_theme_color_override("font_pressed_color", Color("06212a"))
	lower_level_button.hide()
	use_repair_kit_button = _add_inventory_card_action(resource_gain_cards[10], _open_field_repair_menu)
	use_repair_kit_button.tooltip_text = "Obre la caixa d’eines"
	field_repair_menu = PopupMenu.new()
	field_repair_menu.add_item("Repara el vestit espacial", FieldRepair.SUIT)
	field_repair_menu.add_item("Repara les botes", FieldRepair.BOOTS)
	field_repair_menu.add_item("Repara l’eina de mineria", FieldRepair.MINING_TOOL)
	field_repair_menu.add_item("Repara l’escàner biològic", FieldRepair.BIO_SCANNER)
	field_repair_menu.id_pressed.connect(_apply_field_repair)
	add_child(field_repair_menu)
	flora_catalog = AcceptDialog.new()
	flora_catalog.title = "CATÀLEG DE L’EXPEDICIÓ"
	add_child(flora_catalog)
	var catalog_content := VBoxContainer.new()
	flora_catalog.add_child(catalog_content)
	flora_catalog_text = Label.new()
	catalog_content.add_child(flora_catalog_text)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(480, 380)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	catalog_content.add_child(scroll)
	catalog_grid = GridContainer.new()
	catalog_grid.columns = 2
	catalog_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	catalog_grid.add_theme_constant_override("h_separation", 8)
	catalog_grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(catalog_grid)
	navigation_panel.hide()
	equipment_action_buttons.assign([field_camera_button, collect_flora_button, oxygen_reserve_card_button,
		helmet_battery_card_button, medkit_button, beacon_card_button])
	for button in equipment_action_buttons:
		button.draw.connect(_draw_equipment_action_pulse.bind(button))

func _update_equipment_action_pulses() -> void:
	for button in equipment_action_buttons:
		var available := button.is_visible_in_tree() and not button.disabled
		if button == beacon_card_button and beacon_signal_meter.value > 0.0:
			available = false
		if button == medkit_button and health > 65.0:
			available = false
		if button == oxygen_reserve_card_button and oxygen_seconds > _oxygen_capacity() * LOW_SUPPLY_PERCENT / 100.0:
			available = false
		if available:
			pulsing_equipment_actions[button] = true
			button.queue_redraw()
		elif pulsing_equipment_actions.erase(button):
			button.queue_redraw()

func _draw_equipment_action_pulse(button: Button) -> void:
	if not pulsing_equipment_actions.has(button):
		return
	var bounds := Rect2(Vector2.ONE, button.size - Vector2.ONE * 2.0)
	if button == beacon_card_button:
		bounds = Rect2(Vector2((button.size.x - 32.0) * 0.5, button.size.y - EQUIPMENT_ICON_HEIGHT),
			Vector2(32.0, EQUIPMENT_ICON_HEIGHT - 1.0))
	var pulse := 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) * TAU / 1400.0)
	button.draw_rect(bounds, Color(CYAN, 0.10 * pulse))
	button.draw_rect(bounds, Color(CYAN, lerpf(0.20, 0.90, pulse)), false, 1.5, true)

func _new_equipment_icon_button(icon: String) -> Button:
	var button := _button("", Vector2.ZERO, Vector2(30, EQUIPMENT_ICON_HEIGHT), true)
	button.custom_minimum_size = Vector2(30, EQUIPMENT_ICON_HEIGHT)
	button.size_flags_vertical = Control.SIZE_SHRINK_END
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.draw.connect(func() -> void:
		button.draw_set_transform(button.size * 0.5, 0.0, Vector2.ONE * 0.75)
		var center := Vector2.ZERO
		var ink := MUTED if button.disabled else Color("baf8f7")
		if icon == "sample":
			var tube := PackedVector2Array([center + Vector2(-4, -6), center + Vector2(-4, 6),
				center + Vector2(-1, 9), center + Vector2(2, 9), center + Vector2(5, 6), center + Vector2(5, -6)])
			button.draw_polyline(tube, ink, 1.7, true)
			button.draw_line(center + Vector2(-6, -6), center + Vector2(7, -6), ink, 1.7, true)
			button.draw_line(center + Vector2(-3, 3), center + Vector2(4, 3), ink, 1.5, true)
		elif icon == "camera":
			button.draw_rect(Rect2(center - Vector2(11, 6), Vector2(22, 14)), ink, false, 1.7, true)
			button.draw_rect(Rect2(center - Vector2(5, 9), Vector2(8, 3)), ink)
			button.draw_circle(center + Vector2(0, 1), 3.7, ink, false, 1.5, true)
		button.draw_set_transform(Vector2.ZERO))
	return button


func _build_inventory_and_workshop() -> void:
	inventory_window = AcceptDialog.new()
	inventory_window.title = "EQUIP DE L’EXPEDICIÓ"
	inventory_window.ok_button_text = "TANCA"
	add_child(inventory_window)
	inventory_tabs = TabContainer.new()
	inventory_tabs.use_hidden_tabs_for_min_size = false
	inventory_window.add_child(inventory_tabs)
	inventory_tabs.tab_changed.connect(_resize_inventory_tab)
	var pack := MarginContainer.new()
	pack.name = "Inventari"
	for side in ["left", "right", "top", "bottom"]:
		pack.add_theme_constant_override("margin_" + side, 18)
	inventory_tabs.add_child(pack)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	var inventory_scroll := ScrollContainer.new()
	inventory_scroll.custom_minimum_size=Vector2(420,260)
	inventory_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	pack.add_child(inventory_scroll)
	inventory_scroll.add_child(grid)
	for title in ["Botes", "Escàner biològic", "Vestit espacial", "Eina de mineria"]:
		_add_inventory_item(grid, title)
	for supply_id: String in SUPPLY_UPGRADES:
		_add_inventory_item(grid, SUPPLY_UPGRADES[supply_id][0])
	var workshop_view := ScrollContainer.new()
	workshop_view.name = "Equip i millores"
	workshop_view.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	inventory_tabs.add_child(workshop_view)
	var workshop := HBoxContainer.new()
	workshop.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	workshop.size_flags_vertical = Control.SIZE_EXPAND_FILL
	workshop.add_theme_constant_override("separation", 16)
	workshop_view.add_child(workshop)
	workshop_materials_balance = Label.new()
	var materials := _add_workshop_section(workshop, "Materials", workshop_materials_balance, 4.0, ORANGE)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 12)
	materials.add_child(columns)
	var supplies := _add_workshop_column(columns, "Subministraments", 2)
	var repairs := _add_workshop_column(columns, "Reparacions")
	var upgrades := _add_workshop_column(columns, "Millores d’equipament")
	upgrades.get_parent().size_flags_stretch_ratio=2.0
	refill_oxygen_button = _button("RECARREGA · %d DE FERRO" % OXYGEN_REFILL_COST, Vector2.ZERO, Vector2.ZERO)
	refill_oxygen_button.pressed.connect(_refill_oxygen_at_base)
	_add_supply_offer(supplies, "oxygen_tank", refill_oxygen_button)
	repair_suit_button = _button("REPARA · %d DE FERRO" % SUIT_REPAIR_COST, Vector2.ZERO, Vector2.ZERO)
	repair_suit_button.pressed.connect(_repair_suit_at_base)
	_add_workshop_offer(repairs, "Reparació del vestit", "Restaura la integritat al 100%.", repair_suit_button)
	repair_mining_tool_button = _button("REPARA · %d DE FERRO" % MINING_REPAIR_COST, Vector2.ZERO, Vector2.ZERO)
	repair_mining_tool_button.pressed.connect(_repair_mining_tool_at_base)
	_add_workshop_offer(repairs, "Reparació d’eina de mineria", "Restaura l’estat de l’eina al 100%.", repair_mining_tool_button)
	buy_helmet_battery_button = _button("COMPRA · %d DE FERRO" % HELMET_BATTERY_COST, Vector2.ZERO, Vector2.ZERO)
	buy_helmet_battery_button.pressed.connect(_buy_helmet_battery)
	_add_supply_offer(supplies, "helmet_light", buy_helmet_battery_button)
	mining_tool_button = _button("", Vector2.ZERO, Vector2.ZERO)
	mining_tool_button.pressed.connect(_buy_mining_tool)
	_add_supply_offer(supplies, "beacon", craft_beacon_button)
	_add_supply_offer(supplies, "oxygen_reserve", craft_oxygen_button)
	suit_upgrade_offer = _add_workshop_offer(upgrades, "Vestit espacial", "", craft_suit_button)
	mining_offer = _add_workshop_offer(upgrades, "Eina de mineria", "", mining_tool_button)
	boots_button = _button("", Vector2.ZERO, Vector2.ZERO)
	boots_button.pressed.connect(_buy_boots)
	boots_offer = _add_workshop_offer(upgrades, "Botes d’exploració", "", boots_button)
	repair_boots_button = _button("REPARA · %d DE FERRO" % BOOT_REPAIR_COST, Vector2.ZERO, Vector2.ZERO)
	repair_boots_button.pressed.connect(_repair_boots_at_base)
	_add_workshop_offer(repairs, "Reparació de les botes", "Recupera l’estat i la velocitat.", repair_boots_button)
	buy_repair_kit_button = _button("REPOSA 1 ÚS · %d DE FERRO" % REPAIR_KIT_COST, Vector2.ZERO, Vector2.ZERO)
	buy_repair_kit_button.pressed.connect(_buy_repair_kit)
	_add_supply_offer(supplies, "repair_kit", buy_repair_kit_button)
	buy_medkit_button = _button("COMPRA · %d DE FERRO" % MEDKIT_COST, Vector2.ZERO, Vector2.ZERO)
	buy_medkit_button.pressed.connect(_buy_medkit)
	_add_supply_offer(supplies, "medkit", buy_medkit_button)
	repair_folding_ladder_button = _button("REPOSA USOS · %d DE FERRO" % FOLDING_LADDER_REPAIR_COST, Vector2.ZERO, Vector2.ZERO)
	repair_folding_ladder_button.pressed.connect(_repair_folding_ladder)
	_add_supply_offer(supplies, "ladder", repair_folding_ladder_button)
	upgrade_bio_scanner_button = _button("", Vector2.ZERO, Vector2.ZERO)
	upgrade_bio_scanner_button.pressed.connect(_upgrade_bio_scanner)
	scanner_upgrade_offer = _add_workshop_offer(upgrades, "Escàner biològic", "", upgrade_bio_scanner_button)
	repair_bio_scanner_button = _button("REPARA · %d DE FERRO" % BIO_SCANNER_REPAIR_COST, Vector2.ZERO, Vector2.ZERO)
	repair_bio_scanner_button.pressed.connect(_repair_bio_scanner)
	_add_workshop_offer(repairs, "Reparació de l’escàner", "Restaura l’estat al 100%.", repair_bio_scanner_button)
	_add_equipment_modifiers(boots_offer, "botes")
	_add_equipment_modifiers(suit_upgrade_offer, "vestit")
	_add_equipment_modifiers(mining_offer, "mineria")
	_add_equipment_modifiers(scanner_upgrade_offer, "escaner")
	defence_system.build_ui(self,grid,upgrades)

func _add_equipment_modifiers(offer: Label, slot: String) -> void:
	var contents := offer.get_parent() as VBoxContainer
	var original := contents.get_children()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation",12)
	contents.add_child(row)
	var equipment := VBoxContainer.new()
	equipment.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	equipment.custom_minimum_size.x=170
	row.add_child(equipment)
	for child in original: child.reparent(equipment)
	row.add_child(VSeparator.new())
	var modifiers := VBoxContainer.new()
	modifiers.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	modifiers.custom_minimum_size.x=210
	modifiers.add_theme_constant_override("separation",6)
	row.add_child(modifiers)
	_add_equipment_label(modifiers, "MODIFICADORS", 12, CYAN)
	for id: String in EQUIPMENT_MODIFIERS:
		var data: Array = EQUIPMENT_MODIFIERS[id]
		if data[0] != slot:
			continue
		var button := _button("", Vector2.ZERO, Vector2.ZERO, true)
		button.custom_minimum_size.y = 36.0
		button.pressed.connect(_apply_equipment_modifier.bind(id))
		modifier_buttons[id] = button
		modifiers.add_child(button)

func _apply_equipment_modifier(id: String) -> void:
	if not EQUIPMENT_MODIFIERS.has(id): return
	if not owned_modifiers.has(id):
		if not _can_use_workshop(): return
		if not _can_upgrade_equipment(MODIFIER_MATERIAL_COST, MODIFIER_RESEARCH_COST):
			return
		materials_in_pack -= MODIFIER_MATERIAL_COST
		equipment_research_spent += MODIFIER_RESEARCH_COST
		owned_modifiers[id] = true
		_record_expedition_milestone("Modificador: %s" % EQUIPMENT_MODIFIERS[id][1])
	var slot: String = EQUIPMENT_MODIFIERS[id][0]
	if equipped_modifiers.get(slot, "") == id:
		equipped_modifiers.erase(slot)
	else:
		equipped_modifiers[slot] = id
	_detect_fauna_near_unit()
	_update_research_panel()
	_update_flora_button()
	_save_active_profile()
	queue_redraw()

func _modifier_protects(slot: String, condition: String) -> bool:
	if not equipped_modifiers.has(slot):
		return false
	return EQUIPMENT_MODIFIERS[equipped_modifiers[slot]][3] == condition

func _room_environment(cave_id: int) -> String:
	if current_level < 2 or cave_id < 0 or cave_id == world.entry or cave_id == descent_access:
		return ""
	var roll := posmod(hash([seed_value, current_level, cave_id, "oxidized_environment_v1"]), 12)
	match _biome_at_depth(current_level):
		7: return "gel" if roll<9 else ""
		10: return "aigua" if roll<8 else ""
		13: return "calent" if roll<9 else ""
	if roll < 2:
		return "aigua"
	if roll < 4:
		return "gel"
	return "calent" if current_level == 3 and roll < 6 else ""

func _boots_wear_per_unit() -> float:
	var terrain := _room_environment(_cave_at_position(unit_position))
	if _modifier_protects("botes", terrain):
		return BOOT_WEAR_PER_UNIT
	return BOOT_WEAR_PER_UNIT * (1.8 if terrain == "calent" else (1.4 if terrain == "gel" else 1.0))

func _mineral_type(cave_id: int) -> String:
	return mineral_types.get(cave_id, "ferro")

func _assign_mineral_types(level: int) -> void:
	mineral_types.clear()
	if level < 2:
		return
	var candidates: Array[int] = []
	for cave_id: int in material_sites:
		if cave_id != world.entry and cave_id != descent_access:
			candidates.append(cave_id)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([seed_value, "oxidized_minerals_v2"])
	for mineral in ["quars", "magnetita"]:
		for index in range(2):
			if candidates.is_empty():
				return
			var chosen := rng.randi_range(0, candidates.size() - 1)
			mineral_types[candidates[chosen]] = mineral
			candidates.remove_at(chosen)

func _can_detect_species(species: String) -> bool:
	return species.get_slice("~", 0) not in ["molsa_ferrica", "escarabat_ferric"] or _modifier_protects("escaner", "ferric")

func _room_needs_ferric_filter(cave_id: int) -> bool:
	return _has_undetectable_trace(cave_id, false) or _has_undetectable_trace(cave_id, true)

func _has_undetectable_trace(cave_id: int, fauna: bool) -> bool:
	if fauna:
		var corpse := defence_system.predator(self,cave_id)
		if not corpse.is_empty() and (float(corpse.hp)<=0 or bool(corpse.alert)): return false
	var sites := fauna_sites if fauna else flora_sites
	var analyzed := analyzed_fauna if fauna else analyzed_flora
	var species := fauna_species_by_room if fauna else flora_species_by_room
	return sites.has(cave_id) and not analyzed.has(cave_id) and not _can_detect_species(species.get(cave_id, ""))

func _add_supply_offer(grid: GridContainer, supply_id: String, replenish: Button) -> void:
	var detail := _add_workshop_offer(grid, SUPPLY_UPGRADES[supply_id][0], "", replenish)
	var action := _button("", Vector2.ZERO, Vector2.ZERO)
	action.custom_minimum_size.y = 28
	action.pressed.connect(_upgrade_supply.bind(supply_id))
	detail.get_parent().add_child(action)
	supply_upgrade_buttons[supply_id] = action
	supply_upgrade_offers[supply_id] = detail

func _add_workshop_section(parent: HBoxContainer, title: String, balance: Label, width_ratio: float, accent: Color) -> VBoxContainer:
	var section := PanelContainer.new()
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.size_flags_stretch_ratio = width_ratio
	var style := _section_style()
	style.set_content_margin_all(12)
	section.add_theme_stylebox_override("panel", style)
	parent.add_child(section)
	var contents := VBoxContainer.new()
	contents.add_theme_constant_override("separation", 10)
	section.add_child(contents)
	var heading := _add_equipment_label(contents, title, 20, accent)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	balance.add_theme_color_override("font_color", Color("b4ccd2"))
	contents.add_child(balance)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size.y = 300.0
	scroll.custom_minimum_size.x = 860.0 if width_ratio > 1.0 else 216.0
	contents.add_child(scroll)
	var sections := VBoxContainer.new()
	sections.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sections.add_theme_constant_override("separation", 10)
	scroll.add_child(sections)
	return sections

func _add_workshop_column(parent: HBoxContainer, title: String, columns: int = 1) -> GridContainer:
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 10)
	parent.add_child(column)
	return _add_workshop_grid(column, title, columns)

func _add_workshop_grid(parent: VBoxContainer, title: String, columns: int) -> GridContainer:
	if not title.is_empty():
		var heading := _add_equipment_label(parent, title, 15, Color("dcecf0"))
		heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var grid := GridContainer.new()
	grid.columns = columns
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	parent.add_child(grid)
	return grid

func _add_inventory_strip_group(groups: HBoxContainer, title: String, slots: Array[int]) -> void:
	var section := PanelContainer.new()
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style := _section_style()
	style.set_content_margin_all(7)
	style.draw_center = false
	style.set_border_width_all(0)
	section.add_theme_stylebox_override("panel", style)
	_install_inventory_frame(section, true)
	groups.add_child(section)
	var group := VBoxContainer.new()
	section.add_child(group)
	var heading := _add_equipment_label(group, title, 12, CYAN)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var cards := GridContainer.new()
	cards.columns = slots.size()
	cards.add_theme_constant_override("h_separation", 6)
	group.add_child(cards)
	var meter_colors := {1: Color("abbeff"), STRIP_HEALTH_SLOT: Color("f07779"), STRIP_OXYGEN_SLOT: CYAN, 4: Color("abbeff"), 5: Color("ffd48a"), 3: Color("b6d79a"), 9: Color("d7affe"), STRIP_BIO_SCANNER_SLOT: CYAN,19:ORANGE,20:CYAN}
	for index in slots:
		var caption: String = INVENTORY_TITLES[index] if index < INVENTORY_TITLES.size() else {STRIP_HEALTH_SLOT: "Vida", STRIP_OXYGEN_SLOT: "Dipòsit d’oxigen", STRIP_QUARTZ_SLOT: "Quars", STRIP_MAGNETITE_SLOT: "Magnetita", STRIP_MEDKIT_SLOT: "Farmaciola",19:"Projector de polsos",20:"Escut personal"}[index]
		var meter: ProgressBar
		if meter_colors.has(index):
			meter = _new_resource_meter(100.0, meter_colors[index])
			meter.fill_mode = ProgressBar.FILL_BOTTOM_TO_TOP
			meter.custom_minimum_size = Vector2(8, 0)
			meter.size_flags_vertical = Control.SIZE_FILL
			meter.draw.connect(_draw_meter_dividers.bind(meter))
			inventory_strip_meters[index] = meter
		inventory_strip_values[index] = _add_inventory_slot(cards, caption, meter, 116.0)
		var contents := inventory_strip_values[index].get_parent() as VBoxContainer
		var card := (contents.get_parent() if meter == null else meter.get_parent().get_parent()) as PanelContainer
		if meter != null or index == 10:
			card.draw.connect(_draw_low_supply_card.bind(card, index))
		var footer := _add_inventory_strip_footer(contents)
		if index in [19,20]: defence_system.attach_footer(self,footer,index)
		var modifier_slots := {9: "botes", 4: "vestit", STRIP_MINING_SLOT: "mineria", STRIP_BIO_SCANNER_SLOT: "escaner",19:"arma",20:"escut"}
		if title=="EQUIP":
			var body := contents.get_child(0) as VBoxContainer
			body.get_child(0).hide()
			var equipment_heading := HBoxContainer.new()
			equipment_heading.alignment=BoxContainer.ALIGNMENT_CENTER
			body.add_child(equipment_heading)
			body.move_child(equipment_heading,0)
			var cells := {STRIP_HEALTH_SLOT:0,20:1,19:2,STRIP_OXYGEN_SLOT:3,4:4,9:5,5:6,STRIP_MINING_SLOT:7,STRIP_BIO_SCANNER_SLOT:8,1:9,STRIP_LADDER_SLOT:10,10:11,STRIP_MEDKIT_SLOT:12}
			var sheet: Texture2D=load("res://assets/ui/equip_pixel_art_detall.png")
			var cell: Vector2=sheet.get_size()/4.0
			var cell_id: int=cells.get(index,11)
			var texture := AtlasTexture.new()
			texture.atlas=sheet
			texture.region=Rect2(Vector2(cell_id%4,cell_id/4)*cell,cell)
			texture.filter_clip=true
			var icon := TextureRect.new()
			icon.texture=texture
			icon.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
			icon.custom_minimum_size=Vector2(48,48)
			icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.tooltip_text=caption
			icon.mouse_filter=Control.MOUSE_FILTER_STOP
			card.tooltip_text=caption
			equipment_heading.add_child(icon)
			if modifier_slots.has(index): _add_modifier_menu(equipment_heading,modifier_slots[index])
		if index in [0, STRIP_QUARTZ_SLOT, STRIP_MAGNETITE_SLOT, 6]:
			footer.hide()
			var body := contents.get_child(0) as VBoxContainer
			var illustration := Control.new()
			illustration.custom_minimum_size = Vector2(48, 56)
			illustration.mouse_filter = Control.MOUSE_FILTER_IGNORE
			illustration.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			body.add_child(illustration)
			body.move_child(illustration, 0)
			illustration.draw.connect(_draw_resource_card_art.bind(illustration, index))
		if index == 10:
			repair_kit_footer = footer
			footer.draw.connect(_draw_repair_kit_icon.bind(footer))
		if index == STRIP_LADDER_SLOT:
			folding_ladder_icon = footer
			footer.draw.connect(_draw_folding_ladder_icon.bind(footer))
		if index == 5:
			_bind_helmet_light_card(card)
			helmet_battery_card_button = _new_reserve_button(_replace_low_helmet_battery, true)
			helmet_light_card_button.add_child(helmet_battery_card_button)
			helmet_battery_card_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
			helmet_battery_card_button.offset_top = -EQUIPMENT_ICON_HEIGHT
			helmet_battery_card_button.offset_right = -12.0
			helmet_battery_card_button.tooltip_text = "Canvia la bateria del casc quan quedi un 10% o menys"
			_register_resource_gain_card(STRIP_BATTERY_SLOT, card)
		elif index == STRIP_MEDKIT_SLOT:
			medkit_button = _button("", Vector2.ZERO, Vector2(66, EQUIPMENT_ICON_HEIGHT), true)
			medkit_button.custom_minimum_size = Vector2(48, EQUIPMENT_ICON_HEIGHT)
			medkit_button.size_flags_vertical = Control.SIZE_SHRINK_END
			medkit_button.pressed.connect(_use_medkit)
			medkit_button.draw.connect(_draw_medkit_button)
			footer.add_child(medkit_button)
		elif index == STRIP_OXYGEN_SLOT:
			oxygen_reserve_card_button = _new_reserve_button(_use_oxygen_cartridge, false)
			footer.add_child(oxygen_reserve_card_button)
			oxygen_reserve_card_button.tooltip_text = "Utilitza una reserva d’oxigen"
			_register_resource_gain_card(2, card)
		elif index == STRIP_MINING_SLOT or index == STRIP_BIO_SCANNER_SLOT:
			field_action_cards[index] = card
			card.draw.connect(_draw_field_action_card.bind(card, index))
			if index == STRIP_BIO_SCANNER_SLOT:
				bio_action_bar = footer
			else:
				rockfall_tool_countdown = _add_equipment_label(footer, "", 12, ORANGE)
				rockfall_tool_countdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				rockfall_tool_countdown.hide()
		if meter == null or index == 1:
			_register_resource_gain_card(index, card)
			if index == 1:
				beacon_card_button = _add_inventory_card_action(card, _deploy_beacon)
				beacon_signal_meter = meter
				beacon_footer = footer
				footer.draw.connect(_draw_beacon_footer)

func _draw_resource_card_art(canvas: Control, index: int) -> void:
	if index == 6:
		if research_hud_texture == null:
			var image := RESEARCH_MICROSCOPE.get_image()
			image = image.get_region(image.get_used_rect())
			# Prefilter the detailed source once instead of skipping source pixels at HUD size.
			var extent := Vector2(image.get_size())
			extent *= 52.0 / extent.y
			image.resize(maxi(1, roundi(extent.x)), 52, Image.INTERPOLATE_LANCZOS)
			research_hud_texture = ImageTexture.create_from_image(image)
		var lab_extent := Vector2(research_hud_texture.get_size())
		var lab_destination := Rect2(((Vector2(canvas.size.x, 56) - lab_extent) * 0.5).floor(), lab_extent)
		canvas.draw_texture_rect(research_hud_texture, lab_destination, false)
		return
	var column := 0 if index == 0 else (1 if index == STRIP_QUARTZ_SLOT else 2)
	var cell := Vector2(MINERAL_ROCK_SPRITES.get_size()) / Vector2(4, 1)
	if not resource_card_regions.has(column):
		var image := MINERAL_ROCK_SPRITES.get_image()
		var low := Vector2i(cell)
		var high := Vector2i.ZERO
		# Ignore almost invisible alpha specks in the atlas padding when fitting UI art.
		for y in range(int(cell.y)):
			for x in range(int(cell.x)):
				if image.get_pixel(column * int(cell.x) + x, y).a >= 0.15:
					low = Vector2i(mini(low.x, x), mini(low.y, y))
					high = Vector2i(maxi(high.x, x + 1), maxi(high.y, y + 1))
		resource_card_regions[column] = Rect2(Vector2(column * cell.x, 0) + Vector2(low), Vector2(high - low))
	var source: Rect2 = resource_card_regions[column]
	var extent := source.size * minf((canvas.size.x - 8.0) / source.size.x, 52.0 / source.size.y)
	var destination := Rect2(((Vector2(canvas.size.x, 56) - extent) * 0.5).floor(), extent)
	canvas.draw_texture_rect_region(MINERAL_ROCK_SPRITES, destination, source)

func _draw_beacon_footer() -> void:
	var width := beacon_footer.size.x
	var center := Vector2(width * 0.5, beacon_footer.size.y * 0.55)
	var ink := MUTED if beacon_card_button.disabled else Color("abbeff")
	var font := ThemeDB.fallback_font
	beacon_footer.draw_string(font, Vector2(0, -4), "Senyal", HORIZONTAL_ALIGNMENT_CENTER, width, 11, Color("abbeff"))
	beacon_footer.draw_polyline(PackedVector2Array([center + Vector2(0, -6), center + Vector2(6, 0),
		center + Vector2(0, 6), center + Vector2(-6, 0), center + Vector2(0, -6)]), ink, 1.5, true)
	beacon_footer.draw_arc(center, 10.0, -PI * 0.9, -PI * 0.1, 12, ink, 1.3, true)
	beacon_footer.draw_string(font, center + Vector2(10, 4), str(_beacons_remaining()), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, ink)

func _draw_repair_kit_icon(footer: HBoxContainer) -> void:
	var center := Vector2(footer.size.x * 0.5 - 22.0, footer.size.y * 0.55)
	var ink := CYAN if _repair_kit_uses_left() > 0 else MUTED
	if repair_kit_urgent:
		ink = Color("ff676a")
	footer.draw_rect(Rect2(center - Vector2(8, 5), Vector2(16, 11)), ink, false, 1.5)
	footer.draw_rect(Rect2(center - Vector2(3, 8), Vector2(6, 3)), ink, false, 1.2)
	footer.draw_string(ThemeDB.fallback_font, center + Vector2(12, 4), "%d/%d usos" % [repair_kit_uses_spent, _repair_kit_capacity()], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, ink)

func _draw_folding_ladder_icon(footer: HBoxContainer) -> void:
	var center := Vector2(footer.size.x * 0.5 - 8.0, footer.size.y * 0.55)
	var ink := CYAN if _ladder_uses_left() > 0 else MUTED
	for side in [-1.0, 1.0]:
		var rail := center + Vector2(side * 5.0, 0)
		footer.draw_line(rail + Vector2(0, -8), rail + Vector2(0, 8), ink, 1.5, true)
	for step in [-5.0, 0.0, 5.0]:
		footer.draw_line(center + Vector2(-5, step), center + Vector2(5, step), ink, 1.5, true)
	footer.draw_string(ThemeDB.fallback_font, center + Vector2(10, 4), "%d/%d usos" % [ladder_uses_spent, _ladder_capacity()], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, ink)

func _add_inventory_strip_footer(contents: VBoxContainer) -> HBoxContainer:
	var labels := contents.get_children()
	contents.alignment = BoxContainer.ALIGNMENT_BEGIN
	var body := VBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.alignment = BoxContainer.ALIGNMENT_CENTER
	contents.add_child(body)
	for label in labels:
		label.reparent(body, false)
	var footer := HBoxContainer.new()
	footer.custom_minimum_size.y = EQUIPMENT_FOOTER_HEIGHT
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 4)
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer.draw.connect(func() -> void:
		footer.draw_line(Vector2(0, 0), Vector2(footer.size.x, 0), Color("285262"), 1.0))
	contents.add_child(footer)
	return footer

func _new_reserve_button(action: Callable, battery: bool) -> Button:
	var button := _button("", Vector2.ZERO, Vector2.ZERO, true)
	button.custom_minimum_size = Vector2(48, EQUIPMENT_ICON_HEIGHT)
	button.size_flags_vertical = Control.SIZE_SHRINK_END
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(action)
	button.draw.connect(func() -> void:
		var caption := str(flashlight_spares if battery else oxygen_cartridges)
		var font := ThemeDB.fallback_font
		var width := font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
		var center := button.size * 0.5
		var icon := center - Vector2((width + 6.0) * 0.5, 0)
		var color := Color("89a7b4") if button.disabled else Color("dcecf0")
		if battery:
			button.draw_rect(Rect2(icon - Vector2(6, 4), Vector2(12, 8)), color, false, 1.2, true)
			button.draw_rect(Rect2(icon + Vector2(6, -2), Vector2(2, 4)), color)
			button.draw_line(icon - Vector2(3, 0), icon + Vector2(3, 0), color, 1.0, true)
		else:
			button.draw_rect(Rect2(icon - Vector2(4, 4), Vector2(8, 10)), color, false, 1.2, true)
			button.draw_line(icon + Vector2(0, -4), icon + Vector2(0, -7), color, 1.2, true)
			button.draw_line(icon + Vector2(-3, 2), icon + Vector2(3, 2), color, 1.0, true)
		button.draw_string(font, icon + Vector2(12, 4), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, color))
	return button

func _register_resource_gain_card(index: int, card: PanelContainer) -> void:
	resource_gain_cards[index] = card
	card.draw.connect(_draw_resource_gain.bind(card, index))

func _record_resource_gains() -> void:
	var now := Time.get_ticks_msec()
	for index in resource_gain_cards:
		var count := oxygen_cartridges if index == 2 else (flashlight_spares if index == STRIP_BATTERY_SLOT else inventory_strip_values[index].text.to_int())
		if index == 1:
			count = _beacons_remaining()
		elif index == STRIP_LADDER_SLOT:
			count = _ladder_uses_left()
		elif index == 10:
			count = _repair_kit_uses_left()
		elif index == STRIP_MEDKIT_SLOT:
			count = medkits
		var delta: int = count - resource_previous_counts.get(index, count)
		resource_previous_counts[index] = count
		if delta <= 0:
			continue
		var previous: Vector2i = resource_gains.get(index, Vector2i.ZERO)
		var amount := delta + previous.x if previous.y > now else delta
		resource_gains[index] = Vector2i(amount, now + RESOURCE_GAIN_DURATION_MS)
		resource_gain_cards[index].queue_redraw()

func _update_resource_gain_cards() -> void:
	var now := Time.get_ticks_msec()
	for index in resource_gains.keys():
		if resource_gains[index].y <= now:
			resource_gains.erase(index)
		resource_gain_cards[index].queue_redraw()

func _draw_resource_gain(card: PanelContainer, index: int) -> void:
	var gain: Vector2i = resource_gains.get(index, Vector2i.ZERO)
	if gain.x <= 0:
		return
	var opacity := clampf(float(gain.y - Time.get_ticks_msec()) / 350.0, 0.0, 1.0)
	var accent := Color("ffe3a0") if index == 0 else Color("a5ffd8")
	var caption := "+%d" % gain.x
	var inner := Rect2(Vector2(2, 2), card.size - Vector2(4, 4))
	card.draw_rect(inner, Color(accent, opacity * 0.17))
	card.draw_rect(inner, Color(accent, opacity * 0.85), false, 1.5, true)
	var font := ThemeDB.fallback_font
	var width := font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
	var origin := Vector2(card.size.x - width - 8, 19)
	card.draw_string_outline(font, origin, caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, 4, Color(BG, opacity))
	card.draw_string(font, origin, caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(accent, opacity))

func _rockfall_clear_percent() -> int:
	return floori(100.0 * rockfall_clear_remaining / ROCKFALL_CLEAR_SECONDS)

func _update_field_action_cards() -> void:
	var now := Time.get_ticks_msec()
	var mining_progress: float = 1.0 - mining_remaining / _mining_duration(mining_tool) if mining_cave >= 0 else -1.0
	rockfall_tool_countdown.visible = rockfall_clear_remaining > 0.0
	if rockfall_tool_countdown.visible:
		rockfall_tool_countdown.text = "Neteja · %d%%" % _rockfall_clear_percent()
		mining_progress = 1.0 - rockfall_clear_remaining / ROCKFALL_CLEAR_SECONDS
	var scan_progress: float = bio_scan_elapsed / _bio_scan_duration(bio_scanner_tier) if bio_scan_room >= 0 else -1.0
	for index in field_action_cards:
		if index==STRIP_BIO_SCANNER_SLOT:
			var pending := _has_pending_biology_action()
			if pending or bool(field_action_cards[index].get_meta("biology_pending",false)):
				field_action_cards[index].queue_redraw()
			field_action_cards[index].set_meta("biology_pending",pending)
		var progress := mining_progress if index == STRIP_MINING_SLOT else scan_progress
		if progress < 0.0 and now < field_action_completed_until.get(index, 0):
			progress = 1.0
		if progress != field_action_progress.get(index, -1.0):
			field_action_progress[index] = progress
			field_action_cards[index].queue_redraw()

func _has_pending_biology_action() -> bool:
	if not analysis_mode or surface_mode or selected_cave<0 or bio_scan_room>=0: return false
	var scanned := analyzed_fauna.has(selected_cave) if selected_fauna==selected_cave else (selected_flora==selected_cave and analyzed_flora.has(selected_cave))
	if not scanned: return false
	var species := _camera_species_id()
	return _can_collect_flora_sample() or (not species.is_empty() and not field_photos.has(species) and _can_photograph_subject())

func _draw_field_action_card(card: PanelContainer, index: int) -> void:
	if index==STRIP_BIO_SCANNER_SLOT and _has_pending_biology_action():
		var pulse := 0.5+0.5*sin(float(Time.get_ticks_msec())*TAU/1400.0)
		var area := Rect2(Vector2(2,2),card.size-Vector2(4,4))
		card.draw_rect(area,Color(CYAN,0.14+0.10*pulse))
		card.draw_rect(area,Color(CYAN,0.65+0.35*pulse),false,2.0,false)
	var progress := float(field_action_progress.get(index, -1.0))
	if progress < 0.0:
		return
	var accent := Color("f6cb75") if index == STRIP_MINING_SLOT else CYAN
	var inset := Vector2(3, 3)
	var inside := card.size - inset * 2.0
	var height := maxf(2.0, inside.y * clampf(progress, 0.0, 1.0))
	var area := Rect2(Vector2(inset.x, inset.y + inside.y - height), Vector2(inside.x, height))
	card.draw_rect(Rect2(inset, inside), Color(accent, 0.07))
	card.draw_rect(area, Color(accent, 0.24))
	card.draw_line(area.position, area.position + Vector2(area.size.x, 0), Color(accent, 0.85), 1.5)
	card.draw_rect(Rect2(Vector2.ONE, card.size - Vector2.ONE * 2), Color(accent, 0.65), false, 1.0, true)

func _bind_helmet_light_card(card: PanelContainer) -> void:
	helmet_light_card = card
	helmet_light_card_idle = card.get_theme_stylebox("panel")
	helmet_light_card_glow = helmet_light_card_idle.duplicate() as StyleBoxFlat
	helmet_light_card_glow.bg_color = Color("493820")
	helmet_light_card_glow.border_color = Color("ffd48a")
	helmet_light_card_glow.shadow_color = Color("ffc462", 0.35)
	helmet_light_card_glow.shadow_size = 5
	helmet_light_card_button = _add_inventory_card_action(card, _toggle_flashlight)
	card.draw.connect(_draw_helmet_light_warning)

func _draw_helmet_light_warning() -> void:
	if light_warning_strength <= 0.0:
		return
	var pulse := 0.5 + 0.5 * cos(float(Time.get_ticks_msec()) * TAU / 620.0)
	var strength := light_warning_strength * lerpf(0.55, 1.0, pulse)
	var bounds := Rect2(Vector2(2, 2), helmet_light_card.size - Vector2(4, 4))
	helmet_light_card.draw_rect(bounds, Color(ORANGE, 0.32 * strength))
	helmet_light_card.draw_rect(bounds, Color("ffd48a", strength), false, 3.0, true)

func _add_inventory_card_action(card: PanelContainer, action: Callable) -> Button:
	var button := Button.new()
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var empty := StyleBoxEmpty.new()
	for state in ["normal", "hover", "pressed", "disabled"]:
		button.add_theme_stylebox_override(state, empty)
	var focus := StyleBoxFlat.new()
	focus.draw_center = false
	focus.border_color = Color("ffd48a")
	focus.set_border_width_all(1)
	focus.set_corner_radius_all(4)
	button.add_theme_stylebox_override("focus", focus)
	button.pressed.connect(action)
	card.add_child(button)
	return button

func _show_light_warning(screen_position: Vector2, reason: String) -> void:
	var action := "ENCÉN LA LLUM DEL CASC"
	if flashlight_charge <= 0.0:
		action = "CANVIA LA BATERIA DEL CASC" if flashlight_spares > 0 else "SENSE BATERIES DEL CASC"
	status_label.text = "%s · %s" % [reason, action]
	light_warning_label.text = "%s\n%s" % [reason, action]
	var view := _view_rect()
	var extent := light_warning_label.size
	light_warning_label.position = Vector2(
		clampf(screen_position.x - extent.x * 0.5, view.position.x, maxf(view.position.x, view.end.x - extent.x)),
		clampf(screen_position.y - extent.y - 12.0, 64.0, maxf(64.0, equipment_bar.position.y - extent.y - 8.0)))
	if light_warning_tween and light_warning_tween.is_valid():
		light_warning_tween.kill()
	light_warning_label.modulate.a = 1.0
	light_warning_label.show()
	_set_light_warning_strength(1.0)
	light_warning_tween = create_tween().set_parallel(true)
	light_warning_tween.tween_property(light_warning_label, "modulate:a", 0.0, 0.4).set_delay(2.8)
	light_warning_tween.tween_method(_set_light_warning_strength, 1.0, 0.0, 3.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	light_warning_tween.chain().tween_callback(light_warning_label.hide)

func _set_light_warning_strength(strength: float) -> void:
	light_warning_strength = strength
	helmet_light_card.queue_redraw()

func _draw_meter_dividers(meter: ProgressBar) -> void:
	const SEGMENTS := 8
	for segment in range(1, SEGMENTS):
		var fraction := float(segment) / SEGMENTS
		if meter.fill_mode == ProgressBar.FILL_BOTTOM_TO_TOP:
			var y := roundf(meter.size.y * fraction)
			meter.draw_rect(Rect2(0, y - 1, meter.size.x, 2), Color("102735"))
		else:
			var x := roundf(meter.size.x * fraction)
			meter.draw_rect(Rect2(x - 1, 0, 2, meter.size.y), Color("102735"))

func _add_inventory_slot(grid: GridContainer, title: String, meter: ProgressBar = null, minimum_height: float = 88.0) -> Label:
	var contents := _add_equipment_card(grid, Vector2(126, minimum_height), meter)
	contents.alignment = BoxContainer.ALIGNMENT_CENTER
	_add_equipment_label(contents, title, 11, Color("b4ccd2"))
	return _add_equipment_label(contents, "", 15, CYAN)

func _add_equipment_card(grid: GridContainer, minimum_size: Vector2, meter: ProgressBar = null) -> VBoxContainer:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = minimum_size
	slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var frame := StyleBoxFlat.new()
	frame.bg_color = Color("102735")
	frame.border_color = Color("285262")
	frame.set_border_width_all(1)
	frame.set_corner_radius_all(5)
	frame.draw_center = false
	frame.set_border_width_all(0)
	frame.content_margin_left = 6
	frame.content_margin_right = 6
	frame.content_margin_top = 6
	frame.content_margin_bottom = 6
	slot.add_theme_stylebox_override("panel", frame)
	_install_inventory_frame(slot)
	grid.add_child(slot)
	var contents := VBoxContainer.new()
	if meter == null:
		slot.add_child(contents)
	else:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		slot.add_child(row)
		contents.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(contents)
		row.add_child(meter)
	return contents


func _inventory_frame_outline(area: Rect2, cut: float) -> PackedVector2Array:
	var a := area.position.round()
	var b := area.end.round()
	var c := minf(cut, minf(area.size.x, area.size.y) * 0.25)
	# Two-pixel steps give the cut corners a crisp sprite-like silhouette.
	var result := PackedVector2Array([Vector2(a.x + c, a.y), Vector2(b.x - c, a.y)])
	for i in range(0, int(c), 2):
		result.append(Vector2(b.x - c + i + 2, a.y + i))
		result.append(Vector2(b.x - c + i + 2, a.y + i + 2))
	result.append(Vector2(b.x, b.y - c))
	for i in range(0, int(c), 2):
		result.append(Vector2(b.x - i, b.y - c + i + 2))
		result.append(Vector2(b.x - i - 2, b.y - c + i + 2))
	result.append(Vector2(a.x + c, b.y))
	for i in range(0, int(c), 2):
		result.append(Vector2(a.x + c - i - 2, b.y - i))
		result.append(Vector2(a.x + c - i - 2, b.y - i - 2))
	result.append(Vector2(a.x, a.y + c))
	for i in range(0, int(c), 2):
		result.append(Vector2(a.x + i, a.y + c - i - 2))
		result.append(Vector2(a.x + i + 2, a.y + c - i - 2))
	return result

func _install_inventory_frame(panel: PanelContainer, outer: bool = false) -> void:
	var art := Control.new()
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.show_behind_parent = true
	panel.add_child(art)
	panel.draw.connect(func() -> void: art.queue_redraw())
	art.draw.connect(func() -> void:
		art.draw_set_transform(-art.position)
		var active := panel == helmet_light_card and (flashlight_on or light_warning_strength > 0.0)
		for slot in field_action_cards:
			if field_action_cards[slot] == panel and float(field_action_progress.get(slot, -1.0)) >= 0.0:
				active = true
		var bounds := Rect2(Vector2.ONE, (panel.size - Vector2(2, 2)).floor())
		if bounds.size.x < 20 or bounds.size.y < 20:
			return
		var accent := Color("ff7a23") if active else Color("698c97")
		if outer:
			accent = Color("7d4835")
		for inset in range(4):
			var polygon := _inventory_frame_outline(bounds.grow(-inset), 8.0)
			var colors := [Color("02070a"), accent.darkened(0.55), accent, Color("101c22")]
			art.draw_colored_polygon(polygon, colors[inset])
		var face := _inventory_frame_outline(bounds.grow(-4), 6.0)
		art.draw_colored_polygon(face, Color("070e13"))
		art.draw_rect(Rect2(11, 4, maxf(0, panel.size.x - 22), 1), Color("b7d9dc") if not outer else Color("ee793c"))
		art.draw_rect(Rect2(4, 11, 1, minf(19, panel.size.y - 22)), Color("b7d9dc") if not outer else Color("ee793c"))
		if active:
			art.draw_rect(Rect2(10, panel.size.y - 5, panel.size.x - 20, 2), Color("ff9a35"))
			art.draw_rect(Rect2(12, panel.size.y - 7, panel.size.x - 24, 2), Color("8d3319"))
		art.draw_set_transform(Vector2.ZERO))

func _add_equipment_label(contents: BoxContainer, title: String, font_size: int, color: Color) -> Label:
	var caption := Label.new()
	caption.text = title
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size", font_size)
	caption.add_theme_color_override("font_color", color)
	contents.add_child(caption)
	return caption

func _add_workshop_offer(grid: GridContainer, title: String, description: String, action: Button) -> Label:
	var contents := _add_equipment_card(grid, Vector2(204, 121))
	var caption := _add_equipment_label(contents, title, 15, CYAN)
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var detail := _add_equipment_label(contents, description, 12, Color("b4ccd2"))
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	action.custom_minimum_size.y = 28
	contents.add_child(action)
	return detail

func _is_biome_workshop(cave_id: int) -> bool:
	return _depth_has_workshop(current_level) and cave_id >= 0 and cave_id == world.get("entry", -1)

func _depth_has_workshop(depth: int) -> bool:
	return depth > 0 and depth < CAMPAIGN_DEPTH and DEPTH_ZONE_NAMES.has(depth)

func _biome_base_name(depth: int) -> String:
	return "Base – %s" % _profile_biome_name(depth)

func _can_use_workshop() -> bool:
	return surface_mode or (not moving and not world.is_empty() and _is_biome_workshop(_cave_at_position(unit_position)))

func _open_inventory(workshop: bool) -> void:
	_update_research_panel()
	inventory_tabs.current_tab = 1 if workshop else 0
	inventory_window.popup_centered(_inventory_tab_size(inventory_tabs.current_tab))
	_resize_inventory_tab(inventory_tabs.current_tab)
	# Wrapped labels need their final column widths before the window can shrink.
	var resize := _resize_inventory_tab.bind(inventory_tabs.current_tab)
	if not get_tree().process_frame.is_connected(resize):
		get_tree().process_frame.connect(resize, CONNECT_ONE_SHOT)

func _inventory_tab_size(tab: int) -> Vector2i:
	var viewport_size := Vector2i(get_viewport_rect().size)
	var available_height := maxi(1, floori(equipment_bar.position.y) - 52)
	return Vector2i(viewport_size.x - 36, available_height)

func _resize_inventory_tab(tab: int) -> void:
	if not inventory_window.visible:
		return
	inventory_window.size = _inventory_tab_size(tab)
	var viewport_size := Vector2i(get_viewport_rect().size)
	var top := maxi(40, (floori(equipment_bar.position.y) - inventory_window.size.y) / 2)
	inventory_window.position = Vector2i((viewport_size.x - inventory_window.size.x) / 2, top)

func _add_inventory_item(grid: GridContainer, title: String) -> void:
	var level_label := _add_inventory_slot(grid, title)
	level_label.get_parent().get_parent().custom_minimum_size.y=150
	inventory_values.append(level_label)
	var detail := _add_equipment_label(level_label.get_parent(), "", 11, MUTED)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_details.append(detail)
	var level_meter := _new_resource_meter(MAX_EQUIPMENT_LEVEL,CYAN)
	level_meter.custom_minimum_size=Vector2(0,10)
	level_label.get_parent().add_child(level_meter)
	inventory_level_meters.append(level_meter)
	var condition_meter := _new_resource_meter(100,Color("b7d787"))
	condition_meter.custom_minimum_size=Vector2(0,12)
	level_label.get_parent().add_child(condition_meter)
	inventory_condition_meters.append(condition_meter)
	var slots := ["botes", "escaner", "vestit", "mineria"]
	if inventory_details.size() <= slots.size():
		_add_modifier_menu(level_label.get_parent(), slots[inventory_details.size() - 1])

func _update_inventory_screen() -> void:
	if not is_instance_valid(inventory_tabs):
		return
	if inventory_strip_meters.has(STRIP_OXYGEN_SLOT) and resource_gain_cards.has(10):
		_update_low_supply_warning(0.0)
	folding_ladder_icon.queue_redraw()
	var charge := _flashlight_charge_percent()
	var samples := _sample_totals()
	var values := [
		str(materials_in_pack), "Nv. %d · %d%%" % [_supply_tier("beacon") + 1, int(beacon_signal_meter.value)], str(oxygen_cartridges),
		"Nv. %d · %d%%" % [mining_tool + 1, ceili(mining_tool_integrity)],
		_inventory_suit_text(),
		"Nv. %d · %d%%" % [_supply_tier("helmet_light") + 1, charge], str(_research_points()),
		str(samples.x + samples.y), str(_earned_research_record_points()),
		_boots_summary(), "Nv. %d" % (_supply_tier("repair_kit") + 1), "Nv. %d · %d%%" % [bio_scanner_tier + 1, ceili(bio_scanner_integrity)], "Nv. %d" % (_supply_tier("ladder") + 1)]
	for index in range(values.size()):
		if is_instance_valid(inventory_strip_values[index]):
			inventory_strip_values[index].text = values[index]
	inventory_strip_values[STRIP_QUARTZ_SLOT].text = str(quartz_in_pack)
	inventory_strip_values[STRIP_MAGNETITE_SLOT].text = str(magnetite_in_pack)
	repair_kit_footer.queue_redraw()
	var tiers := [equipped_boots, bio_scanner_tier, suit_tier, mining_tool]
	for supply_id: String in SUPPLY_UPGRADES:
		tiers.append(_supply_tier(supply_id))
	var details := [
		"Velocitat base: %d u/s" % roundi(_boots_speed(equipped_boots)),
		"%.1f s per escaneig" % _bio_scan_duration(bio_scanner_tier),
		"%d%% menys de desgast per pressió" % (suit_tier * 4) if suit_tier > 0 else "Protecció estàndard",
		"%d materials per jaciment en %.1f s" % [_mining_yield(mining_tool), _mining_duration(mining_tool)],
		"%d min de capacitat" % int(_oxygen_capacity() / 60.0),
		"%d s d’oxigen per reserva" % int(OXYGEN_CARTRIDGE_SECONDS + _supply_bonus("oxygen_reserve")),
		"%d s de llum per bateria" % int(_helmet_battery_duration()),
		"%d unitats d’abast" % roundi(_beacon_range()),
		"Recupera %d punts de vida" % int(35.0 + _supply_bonus("medkit")),
		"%d/%d usos gastats · repara %d punts" % [repair_kit_uses_spent, _repair_kit_capacity(), int(FIELD_REPAIR_AMOUNT + _supply_bonus("repair_kit"))],
		"%d de %d usos gastats" % [ladder_uses_spent, _ladder_capacity()]]
	for index in range(tiers.size()):
		inventory_values[index].text = "Nivell %d" % (int(tiers[index]) + 1)
		inventory_details[index].text = details[index]
		inventory_level_meters[index].value=int(tiers[index])+1
		inventory_level_meters[index].tooltip_text="Nivell %d / %d" % [int(tiers[index])+1,MAX_EQUIPMENT_LEVEL]
	var conditions := [boots_integrity,bio_scanner_integrity,suit_integrity,mining_tool_integrity,oxygen_seconds*100.0/_oxygen_capacity(),100.0 if oxygen_cartridges>0 else 0.0,float(charge),beacon_signal_meter.value,100.0 if medkits>0 else 0.0,_repair_kit_uses_percent(),100.0*_ladder_uses_left()/maxi(1,_ladder_capacity())]
	for index in range(inventory_condition_meters.size()):
		inventory_condition_meters[index].value=conditions[index]
		inventory_condition_meters[index].tooltip_text="Estat / reserves · %d%%" % roundi(conditions[index])
	var equipment_slots := ["botes", "escaner", "vestit", "mineria"]
	for index in range(equipment_slots.size()):
		var equipped_id: String = equipped_modifiers.get(equipment_slots[index], "")
		if not equipped_id.is_empty():
			inventory_details[index].text += "\nACTIU · " + EQUIPMENT_MODIFIERS[equipped_id][1]
	_update_modifier_menus()
	_update_boots_display()
	var helmet_color := ORANGE if charge <= LOW_SUPPLY_PERCENT else (Color("ffd48a") if flashlight_on else CYAN)
	inventory_strip_values[5].add_theme_color_override("font_color", helmet_color)
	helmet_light_card.add_theme_stylebox_override("panel", helmet_light_card_glow if flashlight_on else helmet_light_card_idle)
	helmet_light_card_button.disabled = surface_mode or (flashlight_charge <= 0.0 and flashlight_spares <= 0)
	helmet_light_card_button.tooltip_text = "Apaga la llum del casc" if flashlight_on else "Encén la llum del casc"
	if flashlight_charge <= 0.0:
		helmet_light_card_button.tooltip_text = "Canvia la bateria del casc" if flashlight_spares > 0 else "Sense bateries del casc"
	oxygen_reserve_card_button.queue_redraw()
	helmet_battery_card_button.queue_redraw()
	beacon_footer.queue_redraw()
	_record_resource_gains()
	inventory_strip_meters[3].value = mining_tool_integrity
	inventory_strip_meters[5].value = charge
	inventory_strip_meters[STRIP_BIO_SCANNER_SLOT].value = bio_scanner_integrity
	workshop_materials_balance.text = "Ferro: %d   Quars: %d   Magnetita: %d   ·   Punts d’investigació: %d" % [materials_in_pack, quartz_in_pack, magnetite_in_pack, _research_points()]
	var workshop_available := _can_use_workshop()
	buy_medkit_button.disabled = not workshop_available or materials_in_pack < MEDKIT_COST
	_update_health_display()
	repair_folding_ladder_button.disabled = not workshop_available or materials_in_pack < FOLDING_LADDER_REPAIR_COST or ladder_uses_spent == 0
	if workshop_available:
		workshop_materials_balance.text += " · Base de superfície" if surface_mode else " · " + _biome_base_name(current_level)
	else:
		workshop_materials_balance.text += " · Ves al taller de superfície o a l’entrada d’un bioma"
	refill_oxygen_button.disabled = not workshop_available or materials_in_pack < OXYGEN_REFILL_COST or oxygen_seconds >= _oxygen_capacity()
	repair_suit_button.disabled = not workshop_available or materials_in_pack < SUIT_REPAIR_COST or suit_integrity >= 100.0
	repair_mining_tool_button.disabled = not workshop_available or materials_in_pack < MINING_REPAIR_COST or mining_tool_integrity >= 100.0
	buy_helmet_battery_button.disabled = not workshop_available or materials_in_pack < HELMET_BATTERY_COST
	for id in modifier_buttons:
		var action := modifier_buttons[id]
		var slot: String = EQUIPMENT_MODIFIERS[id][0]
		var equipped: bool = equipped_modifiers.get(slot, "") == id
		action.disabled = not owned_modifiers.has(id) and (not workshop_available or not _can_upgrade_equipment(MODIFIER_MATERIAL_COST, MODIFIER_RESEARCH_COST))
		var caption := "ACTIU · DESACTIVA" if equipped else ("ACTIVA" if owned_modifiers.has(id) else "COMPRA I ACTIVA · %d FERRO + %d PUNT" % [MODIFIER_MATERIAL_COST, MODIFIER_RESEARCH_COST])
		action.text = "%s\n%s" % [EQUIPMENT_MODIFIERS[id][1], caption]
		action.tooltip_text = EQUIPMENT_MODIFIERS[id][2]
	var next_tool := mini(mining_tool + 1, MAX_EQUIPMENT_LEVEL - 1)
	mining_offer.text = "%s · %s\n%d materials en %.1f s" % [_tier_caption(mining_tool), _mining_model(next_tool), _mining_yield(next_tool), _mining_duration(next_tool)]
	_update_upgrade_button(mining_tool_button, mining_tool)
	var next_boots := mini(equipped_boots + 1, MAX_EQUIPMENT_LEVEL - 1)
	boots_offer.text = "%s · %s\nVelocitat base: %d u/s" % [_tier_caption(equipped_boots), _boots_model(next_boots), roundi(_boots_speed(next_boots))]
	_update_upgrade_button(boots_button, equipped_boots)
	repair_boots_button.disabled = not workshop_available or materials_in_pack < BOOT_REPAIR_COST or boots_integrity >= 100.0
	buy_repair_kit_button.disabled = not workshop_available or materials_in_pack < REPAIR_KIT_COST or repair_kit_uses_spent <= 0
	_update_upgrade_button(upgrade_bio_scanner_button, bio_scanner_tier)
	_update_upgrade_button(craft_suit_button, suit_tier)
	var next_scanner := mini(bio_scanner_tier + 1, MAX_EQUIPMENT_LEVEL - 1)
	var next_suit := mini(suit_tier + 1, MAX_EQUIPMENT_LEVEL - 1)
	scanner_upgrade_offer.text = "%s\nEscaneig en %.1f s · −%.1f d’estat" % [_tier_caption(bio_scanner_tier), _bio_scan_duration(next_scanner), _bio_scan_wear(next_scanner)]
	suit_upgrade_offer.text = "%s\n%d%% menys de desgast per pressió" % [_tier_caption(suit_tier), next_suit * 4]
	repair_bio_scanner_button.disabled = not workshop_available or bio_scanner_integrity >= 100.0 or materials_in_pack < BIO_SCANNER_REPAIR_COST
	for supply_id in supply_upgrade_buttons:
		var tier := _supply_tier(supply_id)
		_update_upgrade_button(supply_upgrade_buttons[supply_id], tier)
		var effect: String = SUPPLY_UPGRADES[supply_id][1]
		if supply_id == "beacon":
			var range_now := roundi(_beacon_range())
			effect = "Abast: %d → %d u" % [range_now, range_now + 50] if tier < MAX_EQUIPMENT_LEVEL - 1 else "Abast: %d u" % range_now
		if supply_id == "repair_kit":
			effect = "%d/%d usos gastats · +1 ús per nivell" % [repair_kit_uses_spent, _repair_kit_capacity()]
		if supply_id == "ladder":
			effect = "%d de %d usos gastats" % [ladder_uses_spent, _ladder_capacity()]
			if tier < MAX_EQUIPMENT_LEVEL - 1:
				effect += " · +1 ús al nivell següent"
		supply_upgrade_offers[supply_id].text = "%s\n%s" % [_tier_caption(tier), effect]

func _tier_caption(tier: int) -> String:
	return "Nivell %d → %d" % [tier + 1, tier + 2] if tier < MAX_EQUIPMENT_LEVEL - 1 else "Nivell %d" % MAX_EQUIPMENT_LEVEL

func _equipment_cost(tier: int) -> Vector2i:
	return Vector2i(2 + tier, 1 + floori(float(tier) / 3.0))

func _upgrade_mineral(tier: int) -> String:
	if tier < 3 or tier % 3 != 0:
		return ""
	return "quars" if tier % 6 == 3 else "magnetita"

func _has_upgrade_mineral(mineral: String) -> bool:
	match mineral:
		"quars": return quartz_in_pack > 0
		"magnetita": return magnetite_in_pack > 0
		_: return true

func _update_upgrade_button(button: Button, tier: int) -> void:
	var cost := _equipment_cost(tier)
	var mineral := _upgrade_mineral(tier)
	button.disabled = tier >= MAX_EQUIPMENT_LEVEL - 1 or not _can_upgrade_equipment(cost.x, cost.y) or not _has_upgrade_mineral(mineral)
	if tier >= MAX_EQUIPMENT_LEVEL - 1:
		button.text = "NIVELL MÀXIM"
		button.tooltip_text = ""
		return
	button.text = _equipment_upgrade_caption(cost.x, cost.y)
	if not mineral.is_empty():
		button.text += "\n+ 1 DE %s" % mineral.to_upper()
	button.tooltip_text = button.text.replace("\n", " ")

func _pay_equipment_upgrade(tier: int, equipment_name: String) -> bool:
	var cost := _equipment_cost(tier)
	var mineral := _upgrade_mineral(tier)
	if tier >= MAX_EQUIPMENT_LEVEL - 1 or not _can_upgrade_equipment(cost.x, cost.y) or not _has_upgrade_mineral(mineral):
		return false
	materials_in_pack -= cost.x
	equipment_research_spent += cost.y
	match mineral:
		"quars": quartz_in_pack -= 1
		"magnetita": magnetite_in_pack -= 1
	_record_expedition_milestone("%s · nivell %d" % [equipment_name, tier + 2])
	return true

func _can_upgrade_equipment(material_cost: int, research_cost: int) -> bool:
	return _can_use_workshop() and materials_in_pack >= material_cost and _research_points() >= research_cost

func _equipment_upgrade_caption(material_cost: int, research_cost: int) -> String:
	return "MILLORA · %d FERRO + %d %s" % [material_cost, research_cost, "PUNT" if research_cost == 1 else "PUNTS"]

func _supply_tier(supply_id: String) -> int:
	return supply_tiers.get(supply_id, 0)

func _supply_bonus(supply_id: String) -> float:
	return float(SUPPLY_UPGRADES[supply_id][2]) * _supply_tier(supply_id)

func _upgrade_supply(supply_id: String) -> void:
	var tier := _supply_tier(supply_id)
	if not _pay_equipment_upgrade(tier, SUPPLY_UPGRADES[supply_id][0]):
		return
	supply_tiers[supply_id] = tier + 1
	_update_oxygen_display()
	_update_research_panel()
	_update_beacon_status()

func _bio_scan_duration(tier: int) -> float:
	return lerpf(6.0, 1.5, float(tier) / (MAX_EQUIPMENT_LEVEL - 1))

func _bio_scan_wear(tier: int) -> float:
	return lerpf(8.0, 2.0, float(tier) / (MAX_EQUIPMENT_LEVEL - 1))

func _upgrade_bio_scanner() -> void:
	if not _pay_equipment_upgrade(bio_scanner_tier, "Escàner biològic"):
		return
	bio_scanner_tier += 1
	bio_scanner_integrity = 100.0
	_update_research_panel()

func _repair_bio_scanner() -> void:
	if not _can_use_workshop() or bio_scanner_integrity >= 100.0 or materials_in_pack < BIO_SCANNER_REPAIR_COST:
		return
	materials_in_pack -= BIO_SCANNER_REPAIR_COST
	bio_scanner_integrity = 100.0
	_update_research_panel()

func _repair_kit_capacity() -> int:
	return 1 + _supply_tier("repair_kit") + int(starting_rewards_depth >= 10)

func _repair_kit_uses_left() -> int:
	return _repair_kit_capacity() - repair_kit_uses_spent

func _repair_kit_uses_percent() -> float:
	return 100.0 * _repair_kit_uses_left() / _repair_kit_capacity()

func _buy_repair_kit() -> void:
	if not _can_use_workshop() or materials_in_pack < REPAIR_KIT_COST or repair_kit_uses_spent <= 0:
		return
	materials_in_pack -= REPAIR_KIT_COST
	repair_kit_uses_spent -= 1
	_update_research_panel()
	status_label.text = "CAIXA D’EINES COMPRADA"

func _can_use_repair_kit() -> bool:
	return not death_dialog.visible and not victory_dialog.visible and _repair_kit_uses_left() > 0 and mining_cave < 0 and bio_scan_room < 0

func _open_field_repair_menu() -> void:
	if not _can_use_repair_kit():
		_action_notice("CAIXA D’EINES ESGOTADA · Reposa usos a Equip i millores" if _repair_kit_uses_left()<=0 else "ACABA L’ACCIÓ EN CURS ABANS DE REPARAR")
		return
	field_repair_menu.set_item_disabled(0, suit_integrity >= 100.0)
	field_repair_menu.set_item_disabled(1, boots_integrity >= 100.0)
	field_repair_menu.set_item_disabled(2, mining_tool_integrity >= 100.0)
	field_repair_menu.set_item_disabled(3, bio_scanner_integrity >= 100.0)
	field_repair_menu.popup_centered()

func _apply_field_repair(target: int) -> void:
	if not _can_use_repair_kit():
		return
	match target:
		FieldRepair.SUIT:
			if suit_integrity >= 100.0:
				return
			suit_integrity = minf(100.0, suit_integrity + FIELD_REPAIR_AMOUNT + _supply_bonus("repair_kit"))
		FieldRepair.BOOTS:
			if boots_integrity >= 100.0:
				return
			boots_integrity = minf(100.0, boots_integrity + FIELD_REPAIR_AMOUNT + _supply_bonus("repair_kit"))
		FieldRepair.MINING_TOOL:
			if mining_tool_integrity >= 100.0:
				return
			mining_tool_integrity = minf(100.0, mining_tool_integrity + FIELD_REPAIR_AMOUNT + _supply_bonus("repair_kit"))
		FieldRepair.BIO_SCANNER:
			if bio_scanner_integrity >= 100.0:
				return
			bio_scanner_integrity = minf(100.0, bio_scanner_integrity + FIELD_REPAIR_AMOUNT + _supply_bonus("repair_kit"))
		_:
			return
	repair_kit_uses_spent += 1
	_update_equipment_display()
	status_label.text = "REPARACIÓ DE CAMP COMPLETADA"
	_update_inventory_screen()
	_save_active_profile()

func _buy_boots() -> void:
	if not _pay_equipment_upgrade(equipped_boots, "Botes"):
		return
	equipped_boots += 1
	boots_integrity = 100.0
	_update_research_panel()

func _boots_model(tier: int) -> String:
	return BOOT_MODELS[mini(tier, BOOT_MODELS.size() - 1)]

func _boots_speed(tier: int) -> float:
	return BOOT_SPEEDS[mini(tier, BOOT_SPEEDS.size() - 1)] + maxf(0.0, tier - 2) * 9.0

func _movement_speed() -> float:
	var terrain := _room_environment(_cave_at_position(unit_position))
	var traction := 1.0 if _modifier_protects("botes", terrain) else (0.75 if terrain == "aigua" or terrain == "gel" else 1.0)
	return _boots_speed(equipped_boots) * lerpf(0.7, 1.0, boots_integrity / 100.0) * traction

func _boots_summary() -> String:
	return "Nv. %d · %d%%" % [equipped_boots + 1, ceili(boots_integrity)]

func _update_boots_display() -> void:
	if not inventory_strip_meters.has(9):
		return
	inventory_strip_meters[9].value = boots_integrity
	var summary := _boots_summary()
	if inventory_strip_values[9].text != summary:
		inventory_strip_values[9].text = summary

func _repair_boots_at_base() -> void:
	if not _can_use_workshop() or materials_in_pack < BOOT_REPAIR_COST or boots_integrity >= 100.0:
		return
	materials_in_pack -= BOOT_REPAIR_COST
	boots_integrity = 100.0
	_update_research_panel()
	status_label.text = "BOTES REPARADES"

func _refill_oxygen_at_base() -> void:
	if not _can_use_workshop() or materials_in_pack < OXYGEN_REFILL_COST or oxygen_seconds >= _oxygen_capacity():
		return
	materials_in_pack -= OXYGEN_REFILL_COST
	oxygen_seconds = _oxygen_capacity()
	_update_oxygen_display()
	_update_research_panel()
	status_label.text = "DIPÒSIT D’OXIGEN RECARREGAT"

func _repair_suit_at_base() -> void:
	if not _can_use_workshop() or materials_in_pack < SUIT_REPAIR_COST or suit_integrity >= 100.0:
		return
	materials_in_pack -= SUIT_REPAIR_COST
	suit_integrity = 100.0
	_update_research_panel()
	status_label.text = "VESTIT ESPACIAL REPARAT"

func _buy_helmet_battery() -> void:
	if not _can_use_workshop() or materials_in_pack < HELMET_BATTERY_COST:
		return
	materials_in_pack -= HELMET_BATTERY_COST
	if flashlight_charge <= 0.0:
		flashlight_charge = _helmet_battery_duration()
	else:
		flashlight_spares += 1
	_update_research_panel()
	status_label.text = "BATERIA DEL CASC COMPRADA"

func _draw_medkit_button() -> void:
	var center := medkit_button.size * 0.5 - Vector2(8, 0)
	var ink := MUTED if medkit_button.disabled else Color("f6a2a4")
	medkit_button.draw_rect(Rect2(center - Vector2(8, 5), Vector2(16, 12)), ink, false, 1.4)
	medkit_button.draw_rect(Rect2(center - Vector2(3, 8), Vector2(6, 3)), ink, false, 1.2)
	medkit_button.draw_line(center + Vector2(-3, 1), center + Vector2(3, 1), ink, 1.5, true)
	medkit_button.draw_line(center + Vector2(0, -2), center + Vector2(0, 4), ink, 1.5, true)
	medkit_button.draw_string(ThemeDB.fallback_font, center + Vector2(13, 5), str(medkits), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, ink)

func _update_health_display() -> void:
	inventory_strip_meters[STRIP_HEALTH_SLOT].value = health
	inventory_strip_values[STRIP_HEALTH_SLOT].text = "%d%%" % ceili(health)
	inventory_strip_values[STRIP_MEDKIT_SLOT].text = "Nv. %d" % (_supply_tier("medkit") + 1)
	medkit_button.tooltip_text = "Utilitza una farmaciola · recupera %d punts de vida" % int(35.0 + _supply_bonus("medkit"))
	medkit_button.disabled = medkits <= 0 or health >= 100.0 or health <= 0.0
	medkit_button.queue_redraw()

func _buy_medkit() -> void:
	if not _can_use_workshop() or materials_in_pack < MEDKIT_COST:
		return
	materials_in_pack -= MEDKIT_COST
	medkits += 1
	_update_equipment_display()

func _use_medkit() -> void:
	if medkits <= 0 or health >= 100.0 or health <= 0.0:
		return
	medkits -= 1
	health = minf(100.0, health + 35.0 + _supply_bonus("medkit"))
	_update_equipment_display()
	status_label.text = "FARMACIOLA UTILITZADA"
	_save_active_profile()

func _ladder_capacity() -> int:
	return 1 + _supply_tier("ladder") + int(starting_rewards_depth >= 19)

func _ladder_uses_left() -> int:
	return _ladder_capacity() - ladder_uses_spent

func _repair_folding_ladder() -> void:
	if not _can_use_workshop() or materials_in_pack < FOLDING_LADDER_REPAIR_COST or ladder_uses_spent == 0:
		return
	materials_in_pack -= FOLDING_LADDER_REPAIR_COST
	ladder_uses_spent = 0
	_update_equipment_display()
	status_label.text = "USOS DE L’ESCALA REPOSATS"

func _mining_model(tier: int) -> String:
	return MINING_TOOLS[mini(tier, MINING_TOOLS.size() - 1)]

func _mining_duration(tier: int) -> float:
	return MINING_SECONDS[mini(tier, MINING_SECONDS.size() - 1)] - maxf(0.0, tier - 2) * (1.45 / (MAX_EQUIPMENT_LEVEL - 3))

func _mining_yield(tier: int) -> int:
	return tier + 1

func _mining_wear(tier: int) -> float:
	return MINING_WEAR_PER_DEPOSIT[mini(tier, MINING_WEAR_PER_DEPOSIT.size() - 1)] - maxf(0.0, tier - 2) * (3.0 / (MAX_EQUIPMENT_LEVEL - 3))

func _buy_mining_tool() -> void:
	if not _pay_equipment_upgrade(mining_tool, "Eina de mineria"):
		return
	mining_tool += 1
	mining_tool_integrity = 100.0
	_update_research_panel()

func _repair_mining_tool_at_base() -> void:
	if not _can_use_workshop() or materials_in_pack < MINING_REPAIR_COST or mining_tool_integrity >= 100.0:
		return
	materials_in_pack -= MINING_REPAIR_COST
	mining_tool_integrity = 100.0
	_update_research_panel()
	status_label.text = "EINA DE MINERIA REPARADA"

func _build_depth_selector(parent: Control) -> void:
	depth_diagram = ScrollContainer.new()
	depth_diagram.position = Vector2(16, 156)
	depth_diagram.size = Vector2(248, 112)
	depth_diagram.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(depth_diagram)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 2)
	depth_diagram.add_child(list)
	for level in range(CAMPAIGN_DEPTH + 1):
		if DEPTH_ZONE_NAMES.has(level):
			if level > 1:
				list.add_child(HSeparator.new())
			var heading := _add_equipment_label(list, _profile_biome_name(level), 11, Color("abbeff"))
			heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			depth_zone_headings[level] = heading
		var caption := "Superfície · 0" if level == 0 else "Estrat −%d" % level
		var row := _button(caption, Vector2.ZERO, Vector2.ZERO, true)
		row.alignment = HORIZONTAL_ALIGNMENT_LEFT
		row.custom_minimum_size.y = 24
		row.pressed.connect(_request_depth_trip.bind(level))
		list.add_child(row)
		depth_rows.append(row)
		var percent := Label.new()
		percent.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		percent.add_theme_font_size_override("font_size", 11)
		percent.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(percent)
		percent.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		percent.offset_right = -8
		depth_percentages.append(percent)
	depth_trip_dialog = ConfirmationDialog.new()
	depth_trip_dialog.title = "Confirma el trajecte"
	depth_trip_dialog.ok_button_text = "CONTINUA"
	depth_trip_dialog.cancel_button_text = "CANCEL·LA"
	depth_trip_dialog.exclusive = true
	depth_trip_dialog.dialog_autowrap = true
	depth_trip_dialog.confirmed.connect(func() -> void:
		var action := pending_depth_action
		pending_depth_action = Callable()
		action.call())
	depth_trip_dialog.canceled.connect(func() -> void: pending_depth_action = Callable())
	add_child(depth_trip_dialog)

func _depth_state(level: int) -> Dictionary:
	if level > 0 and level == maxi(1, current_level):
		return _level_snapshot()
	return inactive_levels.get(level, {})

func _show_depth_rewards() -> void:
	var lines := PackedStringArray(["Millor profunditat: %d" % -deepest_reached,
		"Els desbloquejos s’acumulen i s’apliquen a la pròxima expedició."])
	for depth in DEPTH_REWARDS:
		var state := "Activa" if starting_rewards_depth >= depth else ("Desbloquejada" if deepest_reached >= depth else "Pendent")
		lines.append("%s −%d · %s · %s" % ["★" if deepest_reached >= depth else "☆", depth, DEPTH_REWARDS[depth], state])
	rewards_dialog.dialog_text = "\n\n".join(lines)
	rewards_dialog.popup_centered(Vector2i(480, 0))

func _refresh_depth_selector() -> void:
	for depth in depth_zone_headings:
		depth_zone_headings[depth].text = _profile_biome_name(depth)
	if depth_rows.is_empty() or world.is_empty():
		return
	for level in range(CAMPAIGN_DEPTH + 1):
		var row := depth_rows[level]
		var state := _depth_state(level)
		var discovered: bool = level == 0 or (not state.is_empty() and not state.visited_caves.is_empty())
		var active := level == current_level
		var caption := "Superfície · 0" if level == 0 else "Estrat −%d" % level
		if DEPTH_REWARDS.has(level):
			caption += " ★" if deepest_reached >= level else " ☆"
		if active:
			caption += " · ETS AQUÍ"
		elif not discovered:
			caption += " · PER DESCOBRIR"
		if discovered and _depth_has_workshop(level):
			caption += " · Base"
		row.text = ("%s  " % ("●" if active else "○")) + caption
		row.add_theme_color_override("font_color", CYAN if active else (Color("dcecf0") if discovered else MUTED))
		depth_percentages[level].text = "—"
		if level == 0:
			row.tooltip_text = "Base de superfície"
		elif not discovered:
			row.tooltip_text = "Estrat encara per descobrir"
		else:
			var counts := _depth_discovery_counts(state)
			depth_percentages[level].text = "%d%%" % floori(_overall_discovery(counts))
			var detail := PackedStringArray()
			for index in range(DEPTH_CATEGORIES.size()):
				detail.append("%s · %s" % [DEPTH_CATEGORIES[index], _discovery_percentage(counts[index])])
			row.tooltip_text = "\n".join(detail)
		if DEPTH_REWARDS.has(level):
			row.tooltip_text += "\n%s · %s" % [DEPTH_REWARDS[level], "Desbloquejada" if deepest_reached >= level else "Pendent"]
		if _depth_has_workshop(level):
			row.tooltip_text += "\n" + _biome_base_name(level)

func _depth_discovery_counts(state: Dictionary) -> Array[Vector2i]:
	var saved_world: Dictionary = state.world
	var minerals := Vector2i(0, state.material_sites.size())
	var size: Vector2i = saved_world.grid_size
	for cave_id in state.material_sites:
		var point: Vector2 = state.material_sites[cave_id]
		var cell := Vector2i((point / saved_world.cell_size).floor())
		var revealed: bool = state.revealed_mask[cell.y * size.x + cell.x] == 1
		if state.collected_materials.has(cave_id) or state.explored_caves.has(cave_id) or revealed:
			minerals.x += 1
	return [
		Vector2i(state.explored_caves.size(), saved_world.caves.size()),
		Vector2i(state.completed_gallery_traces.size(), saved_world.corridors.size()),
		Vector2i(state.analyzed_flora.size(), state.flora_sites.size()),
		Vector2i(state.analyzed_fauna.size(), state.fauna_sites.size()),
		minerals,
	]

func _overall_discovery(counts: Array[Vector2i]) -> float:
	var total := 0.0
	var categories := 0
	for count in counts:
		if count.y > 0:
			total += float(count.x) / float(count.y)
			categories += 1
	return 100.0 * total / maxf(1.0, categories)

func _fit_discovered_map() -> void:
	if surface_mode or world.is_empty():
		return
	center_map_during_move = false
	var bounds := Rect2(unit_position, Vector2.ZERO)
	for cave in world.caves:
		if _should_draw_cave(cave.id) or _can_inspect_cave(cave.id) or (analysis_mode and cave.id == selected_cave):
			for point in cave.contour:
				bounds = bounds.expand(cave.position + point)
		if _can_inspect_cave(cave.id):
			for exit_info in _visible_exits_for_cave(cave.id):
				bounds = bounds.expand(exit_info.position + exit_info.direction * 12.0)
				if analysis_mode:
					var gallery := _corridor_by_id(exit_info.corridor_id)
					for point in _isometric_exit_stub(exit_info, gallery, cave):
						bounds = bounds.expand(point - Vector2.ONE * float(gallery.width) * 0.5)
						bounds = bounds.expand(point + Vector2.ONE * float(gallery.width) * 0.5)
	for corridor in world.corridors:
		var half_width := Vector2.ONE * float(corridor.width) * 0.5
		var spans := _map_gallery_spans(corridor)
		if analysis_mode:
			spans = [corridor.points] if _gallery_has_lamps(corridor) or corridor.id in [inspection_corridor_id, isometric_passage_id] else _drawn_gallery_spans(corridor)
		for span: PackedVector2Array in spans:
			for point in (span if analysis_mode else _map_gallery_span_at_mouths(span, corridor)):
				bounds = bounds.expand(point - half_width).expand(point + half_width)
	var view := _view_rect()
	var left_panel := depth_diagram.get_parent() as Control
	var left := maxf(view.position.x, left_panel.get_global_rect().end.x + 12.0)
	var right := minf(view.end.x, minf(map_legend_panel.position.x, level_panel.position.x) - 12.0)
	var top := room_progress_label.position.y + 82.0
	if low_supply_label.visible:
		top = low_supply_label.get_global_rect().end.y
	var bottom := navigation_panel.position.y
	var area := Rect2(left, top, maxf(1.0, right - left), maxf(1.0, bottom - top))
	var available := (area.size - Vector2(88, 40)).max(Vector2.ONE)
	var projected_height := bounds.size.y * (ISO_VERTICAL_RATIO if analysis_mode else 1.0)
	var fit := minf(available.x / maxf(bounds.size.x, 1.0), available.y / maxf(projected_height, 1.0))
	zoom_level = minf(fit, ANALYSIS_MAX_ZOOM if analysis_mode else MAP_ENTRY_ZOOM)
	var center_offset := area.get_center() - view.get_center()
	var projected_center := _iso_project_relative(bounds.get_center(), world.caves[selected_cave].position) if analysis_mode else bounds.get_center() - Generator.WORLD_RECT.size * 0.5
	camera_offset = center_offset - projected_center * zoom_level
	queue_redraw()

func _build_level_progress_strip() -> void:
	level_progress_strip = HBoxContainer.new()
	level_progress_strip.add_theme_constant_override("separation", 8)
	ui_root.add_child(level_progress_strip)
	var cards := GridContainer.new()
	cards.columns = 6
	cards.add_theme_constant_override("h_separation", 8)
	level_progress_strip.add_child(cards)
	for title in ["Estrat descobert", "Sales escanejades", "Galeries recorregudes", "Flora analitzada", "Fauna observada", "Vetes descobertes"]:
		var card := _add_equipment_card(cards, Vector2(128, 66))
		card.alignment = BoxContainer.ALIGNMENT_CENTER
		_add_equipment_label(card, title, 11, Color("b4ccd2"))
		level_progress_values.append(_add_equipment_label(card, "", 15, CYAN))
		var meter := _new_resource_meter(100.0, CYAN)
		meter.custom_minimum_size.y = 7.0
		meter.draw.connect(_draw_meter_dividers.bind(meter))
		card.add_child(meter)
		level_progress_meters.append(meter)

func _layout_panels() -> void:
	var extent := get_viewport_rect().size
	var lateral_space := 2.0 * (280.0 * SIDE_PANEL_SCALE + 12.0)
	var available_width := maxf(extent.x * 0.55, extent.x - lateral_space)
	var progress_scale := minf(1.0, available_width / maxf(1.0, level_progress_strip.size.x))
	level_progress_strip.scale = Vector2.ONE * progress_scale
	var progress_extent := level_progress_strip.size * progress_scale
	level_progress_strip.position = Vector2((extent.x - progress_extent.x) * 0.5, 62.0)
	level_title_label.position = Vector2((extent.x - level_title_label.size.x) * 0.5, 22.0)
	room_progress_label.position = Vector2((extent.x - room_progress_label.size.x) * 0.5, level_progress_strip.position.y + progress_extent.y + 4.0)
	low_supply_label.position = Vector2((extent.x - low_supply_label.size.x) * 0.5, room_progress_label.position.y + 82.0)
	level_panel.scale = Vector2.ONE * SIDE_PANEL_SCALE
	level_panel.position = Vector2(maxf(0.0, extent.x - level_panel.size.x * SIDE_PANEL_SCALE), 8.0)
	var bar_scale := minf(1.0, (extent.x - 16.0) / equipment_bar.size.x)
	equipment_bar.scale = Vector2.ONE * bar_scale
	var bar_extent := equipment_bar.size * bar_scale
	equipment_bar.position = Vector2((extent.x - bar_extent.x) * 0.5, extent.y - bar_extent.y - 8.0)
	var left := depth_diagram.get_parent() as Control
	left.size.y = maxf(290.0, (equipment_bar.position.y - left.position.y - 8.0) / SIDE_PANEL_SCALE)
	depth_diagram.size.y = maxf(55.0, left.size.y - depth_diagram.position.y - 12.0)
	_layout_room_controls()
	_layout_catalogs_panel()

	queue_redraw()

func _layout_catalogs_panel() -> void:
	var width := get_viewport_rect().size.x
	var panels: Array[Control] = [map_legend_panel, catalogs_panel]
	if level_panel.visible:
		panels.append(level_panel)
	if is_instance_valid(room_details_panel) and room_details_panel.visible:
		panels.append(room_details_panel)
	var total_height := 0.0
	for panel in panels:
		total_height += panel.size.y
	var panel_scale := clampf((equipment_bar.position.y - 8.0 * (panels.size() + 1)) / total_height, 0.35, SIDE_PANEL_SCALE)
	var y := 8.0
	for panel in panels:
		panel.scale = Vector2.ONE * panel_scale
		panel.position = Vector2(maxf(0.0, width - panel.size.x * panel_scale - 8.0), y)
		y += panel.size.y * panel_scale + 8.0

func _new_resource_meter(capacity: float, color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	var track := StyleBoxFlat.new()
	track.bg_color = Color("142d3b")
	track.set_corner_radius_all(4)
	var fill := track.duplicate() as StyleBoxFlat
	fill.bg_color = color
	bar.add_theme_stylebox_override("background", track)
	bar.add_theme_stylebox_override("fill", fill)
	bar.max_value = capacity
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return bar


func _panel(rect: Rect2) -> Control:
	var panel := Control.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background := Panel.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.add_theme_stylebox_override("panel", preload("res://scripts/interface_theme.gd").frame())
	panel.add_child(background)
	return panel


func _section_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL
	style.bg_color = Color("050e12")
	style.border_color = Color("527f89")
	style.set_border_width_all(1)
	style.set_corner_radius_all(0)
	return style


func _add_section_frame(parent: Control, bounds: Rect2) -> Panel:
	var frame := Panel.new()
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.position = bounds.position
	frame.size = bounds.size
	frame.add_theme_stylebox_override("panel", _section_style())
	parent.add_child(frame)
	parent.move_child(frame, 0)
	return frame


func _add_label(parent: Control, value: String, font_size: int, color: Color, pos: Vector2, extent: Vector2) -> Label:
	var label := Label.new()
	label.text = value
	label.position = pos
	label.size = extent
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _button(value: String, pos: Vector2, extent: Vector2, secondary: bool = false) -> Button:
	var button := Button.new()
	button.text = value
	button.add_theme_font_size_override("font_size", 10)
	var text_color := Color("dcecf0") if secondary else Color("06212a")
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_hover_color", text_color)
	button.add_theme_color_override("font_pressed_color", text_color)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("173244") if secondary else CYAN
	style.set_corner_radius_all(4)
	button.add_theme_stylebox_override("normal", style)
	var hover := style.duplicate() as StyleBoxFlat
	hover.bg_color = style.bg_color.lightened(0.12)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	var disabled := style.duplicate() as StyleBoxFlat
	disabled.bg_color = Color("142330")
	button.add_theme_stylebox_override("disabled", disabled)
	button.position = pos
	button.size = extent
	return button


func _on_new_pressed() -> void:
	map_options_window.hide()
	var parsed := seed_edit.text.strip_edges().to_int()
	if seed_edit.text.strip_edges().is_empty():
		parsed = int(Time.get_unix_time_from_system())
	_new_world(parsed)
	_save_active_profile()

func _pick_biome_species(species: Dictionary, depth: int, rng: RandomNumberGenerator, basic_scanner_only: bool = false) -> String:
	var biome := _biome_at_depth(depth)
	var native: Array[String] = []
	for id in species:
		if species[id].get("predator",false): continue
		if basic_scanner_only and id in ["molsa_ferrica", "escarabat_ferric"]:
			continue
		if int(species[id].get("biome", 1)) == biome:
			native.append(id)
	return native[rng.randi_range(0, native.size() - 1)]

func _sample_room_site(cave: Dictionary, rng: RandomNumberGenerator, clearance: float, reserved: Array[Vector2]) -> Vector2:
	var contour: PackedVector2Array = cave.contour
	var bounds := Rect2(contour[0], Vector2.ZERO)
	for vertex in contour:
		bounds = bounds.expand(vertex)
	for attempt in range(64):
		var offset := Vector2(rng.randf_range(bounds.position.x, bounds.end.x), rng.randf_range(bounds.position.y, bounds.end.y))
		var point: Vector2 = cave.position + offset
		if not _point_inside_cave_id(point, cave.id) or _distance_to_cave_boundary(point, cave) < clearance:
			continue
		var overlaps := false
		for occupied in reserved:
			if point.distance_to(occupied) < clearance + 8.0:
				overlaps = true
				break
		if not overlaps and _segment_is_walkable(cave.position, point, true):
			return point
	return Vector2.INF

func _room_site_reservations(cave_id: int) -> Array[Vector2]:
	var reserved: Array[Vector2] = []
	if cave_id == world.entry or cave_id == descent_access:
		reserved.append(_level_access_position(cave_id))
	for sites in [flora_sites, fauna_sites, material_sites]:
		if sites.has(cave_id):
			reserved.append(sites[cave_id])
	return reserved

func _place_flora_sites(depth: int = 1) -> void:
	flora_sites.clear()
	flora_species_by_room.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([seed_value, "flora_mix_v2"])
	var first_neighbor := -1
	for corridor in world.corridors:
		if (corridor.a == world.entry or corridor.b == world.entry) and _gallery_has_continuous_signal(corridor, -1, true):
			first_neighbor = corridor.b if corridor.a == world.entry else corridor.a
			break
	for cave in world.caves:
		if cave.id == world.entry or (cave.id != first_neighbor and rng.randf() >= 0.25):
			continue
		var point := _sample_room_site(cave, rng, 8.0, _room_site_reservations(cave.id))
		if point.is_finite():
			flora_sites[cave.id] = point
		if cave.id == first_neighbor and not flora_sites.has(cave.id):
			flora_sites[cave.id] = cave.position
	# Separate the species draw from placement so changes to one do not reroll the other.
	var species_rng := RandomNumberGenerator.new()
	for cave_id in flora_sites:
		species_rng.seed = hash([seed_value, "flora_species_mix_v2", cave_id])
		var family := _pick_biome_species(FLORA_SPECIES, depth, species_rng, cave_id == first_neighbor)
		flora_species_by_room[cave_id] = OrganismTraits.roll(family, OrganismTraits.PLANT, species_rng)

func _flora_is_visible() -> bool:
	return analysis_mode and _flora_is_visible_in_room(selected_cave)

func _flora_is_visible_in_room(cave_id: int) -> bool:
	if not flora_sites.has(cave_id) or not _can_detect_species(flora_species_by_room.get(cave_id, "")):
		return false
	var plant: Vector2 = flora_sites[cave_id]
	return analyzed_flora.has(cave_id) or _room_is_fully_lit(cave_id) or (_is_revealed(plant) and _can_use_tools_at(plant, cave_id))

func _room_is_fully_lit(cave_id: int) -> bool:
	return cave_id >= 0 and (cave_id == world.get("entry", -1) or explored_caves.has(cave_id))

func _has_ambient_light(point: Vector2) -> bool:
	var cave_id := _cave_at_position(point)
	if cave_id >= 0:
		return _room_is_fully_lit(cave_id)
	return _point_in_lit_gallery(point)

func _update_automatic_helmet_light(point: Vector2) -> void:
	var zone_lit := surface_mode or _has_ambient_light(point)
	if zone_lit == helmet_light_zone_lit:
		return
	helmet_light_zone_lit = zone_lit
	_set_helmet_light(not zone_lit and flashlight_charge > 0.0)

func _flashlight_radius() -> float:
	return float(world.cell_size) * (4.0 + _supply_tier("helmet_light") * 0.18)

func _can_use_tools_at(point: Vector2, cave_id: int) -> bool:
	if surface_mode or not analysis_mode or current_cave_id != cave_id or _cave_at_position(unit_position) != cave_id:
		return false
	if _room_is_fully_lit(cave_id):
		return true
	if not flashlight_on:
		return false
	var offset := point - unit_position
	if offset.is_zero_approx():
		return true
	if offset.length() > _flashlight_radius() * 1.4 or explorer_facing.dot(offset.normalized()) < FLASHLIGHT_USABLE_DOT:
		return false
	var cell_size: float = world.cell_size
	return _has_line_of_sight(Vector2i((unit_position / cell_size).floor()), Vector2i((point / cell_size).floor()))

func _place_fauna_sites(depth: int = 1) -> void:
	fauna_sites.clear()
	fauna_species_by_room.clear()
	fauna_patrol_ends.clear()
	fauna_time = 0.0
	fauna_pause.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([seed_value, "fauna_mix_v2"])
	var population := rng.randi_range(2, maxi(3, ceili(world.caves.size() * 0.4)))
	var candidates: Array = world.caves.duplicate()
	for index in range(candidates.size() - 1, 0, -1):
		var other := rng.randi_range(0, index)
		var swap: Dictionary = candidates[index]
		candidates[index] = candidates[other]
		candidates[other] = swap
	for cave in candidates:
		if cave.id == world.entry:
			continue
		var reserved := _room_site_reservations(cave.id)
		var spawn := _sample_room_site(cave, rng, 8.0, reserved)
		if not spawn.is_finite():
			continue
		fauna_sites[cave.id] = spawn
		for attempt in range(12):
			var target := _sample_room_site(cave, rng, 8.0, reserved)
			if target.is_finite() and spawn.distance_to(target) >= 14.0 and not _path_prefix_inside_cave([target], spawn, cave.id).is_empty() and _segment_is_walkable(spawn, target, true):
				fauna_patrol_ends[cave.id] = target
				break
		if fauna_sites.size() == population:
			break
	var species_rng := RandomNumberGenerator.new()
	for cave_id in fauna_sites:
		species_rng.seed = hash([seed_value, "fauna_species_mix_v2", cave_id])
		var family := _pick_biome_species(FAUNA_SPECIES, depth, species_rng)
		var id := _roll_fauna_variant(family, species_rng)
		for retry in range(12):
			if not fauna_species_by_room.values().has(id):
				break
			id = _roll_fauna_variant(family, species_rng)
		fauna_species_by_room[cave_id] = id

func _roll_fauna_variant(family: String, rng: RandomNumberGenerator) -> String:
	return OrganismTraits.roll(family, OrganismTraits.ANIMAL, rng)

func _fauna_variant(species_id: String) -> Dictionary:
	return OrganismPixelArt.animal_recipe(species_id)

func _fauna_ground_is_clear(point: Vector2, cave_id: int) -> bool:
	for offset in [Vector2.ZERO, Vector2(-7, 0), Vector2(7, 0), Vector2(0, -7), Vector2(0, 7)]:
		var sample: Vector2 = point + offset
		if not _point_inside_cave_id(sample, cave_id) or not _segment_is_walkable(sample, sample, true):
			return false
	for obstacle in world.obstacles:
		if point.distance_to(obstacle.position) < float(obstacle.radius) + 7.0:
			return false
	if material_sites.has(cave_id) and point.distance_to(material_sites[cave_id]) < 16.0:
		return false
	return true

func _fauna_safe_patrol(cave_id: int) -> PackedVector2Array:
	if not is_same(fauna_path_world, world):
		fauna_path_world = world
		fauna_safe_paths.clear()
	var start: Vector2 = fauna_sites[cave_id]
	var finish: Vector2 = fauna_patrol_ends.get(cave_id, start)
	var key := hash([cave_id, start, finish, world.get("rock_ground_footprints_v1", false)])
	if fauna_safe_paths.has(key):
		return fauna_safe_paths[key]
	var cave: Dictionary = world.caves[cave_id]
	var bounds := Rect2(cave.position + cave.contour[0], Vector2.ZERO)
	for corner in cave.contour:
		bounds = bounds.expand(cave.position + corner)
	var cell_size: float = world.cell_size
	var low := Vector2i((bounds.position / cell_size).floor()).max(Vector2i.ZERO)
	var high := Vector2i((bounds.end / cell_size).ceil()).min(Vector2i(world.grid_size) - Vector2i.ONE)
	var grid := AStarGrid2D.new()
	grid.region = Rect2i(low, high - low + Vector2i.ONE)
	grid.cell_size = Vector2.ONE * cell_size
	grid.offset = Vector2.ONE * cell_size * 0.5
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.update()
	var first := Vector2i(-1, -1)
	var last := Vector2i(-1, -1)
	var start_distance := INF
	var finish_distance := INF
	for y in range(low.y, high.y + 1):
		for x in range(low.x, high.x + 1):
			var cell := Vector2i(x, y)
			var point := (Vector2(cell) + Vector2.ONE * 0.5) * cell_size
			var clear := _fauna_ground_is_clear(point, cave_id)
			grid.set_point_solid(cell, not clear)
			if not clear: continue
			if point.distance_squared_to(start) < start_distance:
				first = cell
				start_distance = point.distance_squared_to(start)
			if point.distance_squared_to(finish) < finish_distance:
				last = cell
				finish_distance = point.distance_squared_to(finish)
	var route := PackedVector2Array()
	if first.x >= 0:
		# Explore only edges that also fit the body between their endpoints.
		# A blocked original destination must not collapse an entire patrol.
		var queue: Array[Vector2i] = [first]
		var parents: Dictionary = {first: first}
		var best := first
		var farthest := first
		var cursor := 0
		while cursor < queue.size() and cursor < 4096:
			var cell: Vector2i = queue[cursor]
			cursor += 1
			var point := grid.get_point_position(cell)
			if point.distance_squared_to(finish) < grid.get_point_position(best).distance_squared_to(finish): best = cell
			if point.distance_squared_to(grid.get_point_position(first)) > grid.get_point_position(farthest).distance_squared_to(grid.get_point_position(first)): farthest = cell
			for direction in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var next: Vector2i = cell + direction
				if not grid.region.has_point(next) or parents.has(next) or grid.is_point_solid(next): continue
				var clear_edge := true
				for step in range(1, 5):
					if not _fauna_ground_is_clear(point.lerp(grid.get_point_position(next), float(step) / 4), cave_id): clear_edge = false
				if clear_edge:
					parents[next] = cell
					queue.append(next)
		if grid.get_point_position(best).distance_to(grid.get_point_position(first)) < 14.0: best = farthest
		var cell := best
		while cell != first:
			route.append(grid.get_point_position(cell))
			cell = parents[cell]
		route.append(grid.get_point_position(first))
		route.reverse()
	fauna_safe_paths[key] = route
	return route

func _fauna_position(cave_id: int, time_offset: float = 0.0) -> Vector2:
	var hostile := defence_system.predator(self,cave_id)
	if not hostile.is_empty(): return hostile.position
	var route := _fauna_safe_patrol(cave_id)
	if route.size() < 2:
		return route[0] if not route.is_empty() else Vector2(fauna_sites[cave_id])
	var distance := 0.0
	for i in range(route.size() - 1): distance += route[i].distance_to(route[i + 1])
	var id: String = fauna_species_by_room.get(cave_id, "escarabat")
	var speed := 8.0 if _fauna_is_segmented(id) else 13.0
	var recipe := _fauna_variant(id)
	var movement := int(recipe.get("movement", -1))
	if movement == 0:
		speed *= 0.7
	elif movement == 1:
		speed *= 1.35
	var travel_time := distance / speed
	var pause := 1.2
	var phase := fposmod(fauna_time - float(fauna_pause.get(cave_id, 0.0)) + time_offset + cave_id * 0.41, (travel_time + pause) * 2.0)
	if movement == 2:
		phase = (phase + sin(phase * 7.0) * 0.09)
	var along := clampf(phase * speed, 0.0, distance)
	if phase >= travel_time + pause:
		along = distance - clampf((phase - travel_time - pause) * speed, 0.0, distance)
	for i in range(route.size() - 1):
		var length := route[i].distance_to(route[i + 1])
		if along <= length: return route[i].lerp(route[i + 1], along / length)
		along -= length
	return route[-1]

func _fauna_is_visible() -> bool:
	return analysis_mode and _fauna_is_visible_in_room(selected_cave)

func _fauna_is_visible_in_room(cave_id: int) -> bool:
	var corpse := defence_system.predator(self,cave_id)
	if not corpse.is_empty() and bool(corpse.alert) and _cave_at_position(unit_position)==cave_id: return true
	if not corpse.is_empty() and float(corpse.hp)<=0:
		return _room_is_fully_lit(cave_id) or _is_revealed(corpse.position)
	return fauna_sites.has(cave_id) and _can_detect_species(fauna_species_by_room.get(cave_id, "")) and (seen_fauna.has(cave_id) or _room_is_fully_lit(cave_id) or (_is_revealed(_fauna_position(cave_id)) and _can_use_tools_at(_fauna_position(cave_id), cave_id)))

func _detect_fauna_near_unit() -> void:
	if not analysis_mode or current_cave_id != selected_cave or seen_fauna.has(selected_cave) or not fauna_sites.has(selected_cave):
		return
	if not _can_detect_species(fauna_species_by_room.get(selected_cave, "")):
		return
	var creature := _fauna_position(selected_cave)
	if _can_use_tools_at(creature, selected_cave) and (_room_is_fully_lit(selected_cave) or _is_revealed(creature)):
		seen_fauna[selected_cave] = true
		queue_redraw()

func _action_notice(message: String) -> void:
	status_label.text = message.get_slice(" · ", 0) + " · CONSULTA L’AVÍS"
	status_label.tooltip_text = message
	if is_instance_valid(game_audio): game_audio.play("denied")
	if not is_instance_valid(action_notice_label):
		action_notice_label = Label.new()
		action_notice_label.custom_minimum_size=Vector2(460,100)
		action_notice_label.size=Vector2(460,100)
		action_notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		action_notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		action_notice_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		action_notice_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		action_notice_label.add_theme_font_size_override("font_size", 16)
		action_notice_label.add_theme_color_override("font_color", Color("ffd18b"))
		action_notice_label.add_theme_stylebox_override("normal", preload("res://scripts/interface_theme.gd").frame())
		ui_root.add_child(action_notice_label)
	action_notice_label.text = message
	action_notice_label.size = Vector2(460, 100)
	action_notice_label.set_deferred("size",Vector2(460,100))
	action_notice_label.position = Vector2((get_viewport_rect().size.x - 460) * 0.5, 175)
	action_notice_label.modulate.a = 1.0
	action_notice_label.show()
	if action_notice_tween and action_notice_tween.is_valid(): action_notice_tween.kill()
	action_notice_tween = create_tween()
	action_notice_tween.tween_interval(5.0)
	action_notice_tween.tween_property(action_notice_label, "modulate:a", 0.0, 0.3)

func _scanner_requirement_notice() -> void:
	_action_notice("RASTRE BIOLÒGIC · Requereix escàner Nv. 1 + Filtre espectral fèrric. Compra i activa el filtre a Base → Equip i millores.")

func _select_flora(screen_position: Vector2) -> void:
	for animal in [false, true]:
		var sites := fauna_sites if animal else flora_sites
		if _has_undetectable_trace(selected_cave, animal) and (_room_is_fully_lit(selected_cave) or _is_revealed(sites[selected_cave])):
			var point: Vector2 = _fauna_position(selected_cave) if animal else sites[selected_cave]
			var size := Vector2(26, 34) * _isometric_organism_scale()
			if Rect2(_world_to_screen(point) - size * Vector2(0.5,0.9), size).has_point(screen_position):
				_scanner_requirement_notice()
				return
	if bio_scan_room >= 0:
		return
	selected_flora = -1
	selected_fauna = -1
	var fauna_distance := screen_position.distance_to(_world_to_screen(_fauna_position(selected_cave))) if _fauna_is_visible() else INF
	var flora_distance := screen_position.distance_to(_world_to_screen(flora_sites[selected_cave])) if _flora_is_visible() else INF
	var hostile := defence_system.predator(self,selected_cave)
	if _fauna_is_visible() and not hostile.is_empty() and defence_system.sprite_rect(self,hostile.position).has_point(screen_position): fauna_distance=0.0
	if _fauna_is_visible():
		var animal_id: String = fauna_species_by_room[selected_cave]
		if not _fauna_variant(animal_id).is_empty() and OrganismPixelArt.animal_hit_rect(
				_world_to_screen(_fauna_position(selected_cave)), _isometric_organism_scale(),
				_fauna_variant(animal_id)).has_point(screen_position):
			fauna_distance = 0.0
	if _flora_is_visible():
		var plant_id: String = flora_species_by_room[selected_cave]
		if OrganismPixelArt.supports_plant(plant_id) and OrganismPixelArt.plant_hit_rect(
				_world_to_screen(flora_sites[selected_cave]), 1.4 * _isometric_organism_scale(),
				OrganismPixelArt.plant_recipe(plant_id)).has_point(screen_position):
			flora_distance = 0.0
	var animal_hit_radius := clampf(zoom_level * 4.2, 10.0, 20.0)
	if fauna_distance <= animal_hit_radius or (fauna_distance <= 22.0 and fauna_distance <= flora_distance):
		selected_fauna = selected_cave
		if not hostile.is_empty() and float(hostile.hp)<=0 and not fauna_samples.has(selected_cave):
			if unit_position.distance_to(hostile.position)<=38.0:
				moving=false
				move_path.clear()
				selected_route.clear()
				move_target=unit_position
				level_navigation_target=-1
				depth_trip_target=-1
				chained_cave_id=-1
			if _can_collect_flora_sample():
				_collect_flora_sample()
			else:
				_action_notice("MOSTRA DE DEPREDADOR · Acosta’t al cos (menys de 38 unitats) i atura’t per recollir-la")
	elif flora_distance <= 22.0:
		selected_flora = selected_cave
	_update_flora_button()
	if (selected_fauna >= 0 and not analyzed_fauna.has(selected_fauna)) or (selected_flora >= 0 and not analyzed_flora.has(selected_flora)):
		_interact_with_flora()
	_layout_room_controls()
	queue_redraw()

func _update_flora_button() -> void:
	if is_instance_valid(field_camera_button):
		var species_id := _camera_species_id()
		var has_photo := field_photos.has(species_id)
		field_camera_button.disabled = taking_field_photo or has_photo or not _can_photograph_subject()
		field_camera_button.tooltip_text = "Foto al catàleg" if has_photo else "Fes una fotografia"
		if species_id.is_empty():
			field_camera_button.tooltip_text = "Completa l’escaneig per fer una fotografia"
	if is_instance_valid(collect_flora_button):
		collect_flora_button.disabled = not _can_collect_flora_sample()
		if selected_fauna >= 0 and selected_fauna == selected_cave:
			collect_flora_button.tooltip_text = "Mostra recollida" if fauna_samples.has(selected_cave) else "Recull una mostra del depredador abatut"
		elif _has_selected_scanned_flora():
			collect_flora_button.tooltip_text = "Mostra recollida" if flora_samples.has(selected_cave) else "Recull una mostra de flora"
		else:
			collect_flora_button.tooltip_text = "Escaneja una planta per recollir-ne una mostra"
func _interact_with_flora() -> void:
	var fauna := selected_fauna == selected_cave and _fauna_is_visible()
	var flora := selected_flora == selected_cave and _flora_is_visible()
	if bio_scanner_integrity <= 0.0:
		_action_notice("ESCÀNER AVARIAT · Repara l’escàner Nv. %d al taller o amb la caixa d’eines." % (bio_scanner_tier + 1))
		return
	if moving or mining_cave >= 0 or bio_scan_room >= 0:
		_action_notice("ATURA’T I ACABA L’ACCIÓ EN CURS PER ESCANEJAR")
		return
	if not (fauna or flora):
		return
	var scanned := analyzed_fauna.has(selected_cave) if fauna else analyzed_flora.has(selected_cave)
	if scanned: return
	if not _can_use_tools_at(_bio_scan_target(selected_cave, fauna), selected_cave):
		_action_notice("IL·LUMINA L’ORGANISME AMB EL CASC I ENTRA A LA SEVA SALA PER ESCANEJAR · Escàner Nv. 1 o superior")
		return
	bio_scan_room = selected_cave
	bio_scan_fauna = fauna
	bio_scan_elapsed = 0.0
	_update_flora_button()
	queue_redraw()

func _has_selected_scanned_flora() -> bool:
	return selected_cave >= 0 and selected_flora == selected_cave and selected_fauna != selected_cave and analyzed_flora.has(selected_cave) and flora_sites.has(selected_cave)

func _can_collect_flora_sample() -> bool:
	if selected_fauna==selected_cave and selected_cave>=0:
		var enemy := defence_system.predator(self,selected_cave)
		return not enemy.is_empty() and float(enemy.hp)<=0 and not fauna_samples.has(selected_cave) and not moving and mining_cave<0 and bio_scan_room<0 and unit_position.distance_to(enemy.position)<=38.0 and _can_use_tools_at(enemy.position,selected_cave)
	return _has_selected_scanned_flora() and not flora_samples.has(selected_cave) and mining_cave < 0 and bio_scan_room < 0 and _can_use_tools_at(flora_sites[selected_cave], selected_cave)

func _collect_flora_sample() -> void:
	if not _can_collect_flora_sample():
		return
	var animal := selected_fauna==selected_cave
	if animal: fauna_samples[selected_cave]=false
	else: flora_samples[selected_cave] = false
	_update_inventory_screen()
	status_label.text = "RESTES DEL DEPREDADOR RECOLLIDES · +1 MOSTRA BIOLÒGICA · +1 PUNT" if animal else "MOSTRA DE FLORA RECOLLIDA · +1 PUNT"
	_update_flora_button()
	_layout_room_controls()
	_save_active_profile()

func _bio_scan_target(cave_id: int, fauna: bool) -> Vector2:
	return _fauna_position(cave_id) if fauna else flora_sites[cave_id]

func _build_discovery_dialog() -> void:
	discovery_dialog = AcceptDialog.new()
	discovery_dialog.ok_button_text = "CONTINUA"
	discovery_dialog.exclusive = true
	add_child(discovery_dialog)
	discovery_portrait = Control.new()
	discovery_portrait.custom_minimum_size = Vector2(460, 300)
	discovery_dialog.add_child(discovery_portrait)
	discovery_portrait.draw.connect(func() -> void:
		var center := discovery_portrait.size * 0.5
		discovery_portrait.draw_rect(Rect2(Vector2.ZERO, discovery_portrait.size), BG)
		if discovery_photo.texture != null:
			return
		if discovery_is_fauna:
			_draw_fauna_map_badge(discovery_portrait, center, discovery_species, 10.0, false)
		else:
			_draw_flora_symbol(discovery_portrait, center + Vector2(0, 65), 11.0, discovery_species))
	discovery_photo = TextureRect.new()
	discovery_photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	discovery_photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	discovery_photo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	discovery_portrait.add_child(discovery_photo)
	discovery_photo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _show_new_discovery(species_id: String, fauna: bool, point: Vector2) -> void:
	if discovery_capture_pending:
		return
	discovery_species = species_id
	discovery_is_fauna = fauna
	var species := FAUNA_SPECIES if fauna else FLORA_SPECIES
	var family: Dictionary = species.get(species_id.get_slice("~", 0), {})
	var family_name: String = family.get("name", species_id)
	var traits := OrganismTraits.ANIMAL if fauna else OrganismTraits.PLANT
	var display_name := family_name if OrganismTraits.decode(species_id, traits).is_empty() else OrganismTraits.display_name(species_id, family_name, int(family.get("biome", 1)))
	discovery_dialog.title = ("Fauna nova" if fauna else "Flora nova") + " · " + display_name
	discovery_photo.texture = null
	# Capture a fresh frame with the scanner percentage and signal rings hidden.
	if DisplayServer.get_name() != "headless":
		var previous_photo_state := taking_field_photo
		discovery_capture_pending = true
		taking_field_photo = true
		queue_redraw()
		await RenderingServer.frame_post_draw
		taking_field_photo = previous_photo_state
		discovery_capture_pending = false
		queue_redraw()
	var viewport := get_viewport()
	var visible_rect := viewport.get_visible_rect()
	var center := _world_to_screen(point)
	var frame := _organism_photo_frame(species_id, fauna, center)
	if DisplayServer.get_name() != "headless" and visible_rect.encloses(frame) and not _over_ui(center):
		var image := viewport.get_texture().get_image()
		if image != null and not image.is_empty():
			var pixel_scale := Vector2(image.get_size()) / visible_rect.size
			var crop := Rect2i((frame.position - visible_rect.position) * pixel_scale, frame.size * pixel_scale)
			if crop.size.x > 0 and crop.size.y > 0:
				discovery_photo.texture = ImageTexture.create_from_image(image.get_region(crop))
	discovery_portrait.queue_redraw()
	discovery_dialog.popup_centered(Vector2i(540, 0))

func _update_bio_scan(delta: float) -> void:
	if bio_scan_room < 0:
		return
	var cave_id := bio_scan_room
	var species: String = (fauna_species_by_room if bio_scan_fauna else flora_species_by_room).get(cave_id, "")
	var corpse := defence_system.predator(self,cave_id) if bio_scan_fauna else {}
	var dead_predator := not corpse.is_empty() and float(corpse.hp)<=0
	if not dead_predator and not _can_detect_species(species):
		_cancel_bio_scan()
		_scanner_requirement_notice()
		return
	if moving or selected_cave != cave_id or not _can_use_tools_at(_bio_scan_target(cave_id, bio_scan_fauna), cave_id):
		_cancel_bio_scan()
		status_label.text = "ESCANEIG ATURAT · IL·LUMINA LA TROBALLA"
		return
	var duration: float = _bio_scan_duration(bio_scanner_tier)
	var elapsed := minf(delta, duration - bio_scan_elapsed)
	var previous_integrity := ceili(bio_scanner_integrity)
	var wear: float = elapsed * _bio_scan_wear(bio_scanner_tier) / duration
	var can_finish_step := wear <= bio_scanner_integrity or is_equal_approx(wear, bio_scanner_integrity)
	bio_scanner_integrity = maxf(0.0, bio_scanner_integrity - wear)
	bio_scan_elapsed += elapsed
	if not can_finish_step or (bio_scanner_integrity <= 0.0 and bio_scan_elapsed < duration):
		_cancel_bio_scan()
		_update_inventory_screen()
		status_label.text = "ESCÀNER AVARIAT · REPARA’L PER CONTINUAR"
		return
	if bio_scan_elapsed >= duration:
		field_action_completed_until[STRIP_BIO_SCANNER_SLOT] = Time.get_ticks_msec() + 450
		if bio_scan_fauna:
			analyzed_fauna[cave_id] = true
		else:
			analyzed_flora[cave_id] = true
		var species_by_room := fauna_species_by_room if bio_scan_fauna else flora_species_by_room
		var species_id: String = species_by_room[cave_id]
		var first_discovery := not biological_register.has(species_id)
		var subject := _bio_scan_target(cave_id, bio_scan_fauna)
		var is_fauna := bio_scan_fauna
		biological_register[species_id] = true
		_cancel_bio_scan()
		_update_inventory_screen()
		_update_level_progress()
		_update_flora_button()
		_layout_room_controls()
		status_label.text = "ESCANEIG 100% · FOTO DISPONIBLE" if bio_scan_fauna else "ESCANEIG 100% · MOSTRA I FOTO DISPONIBLES"
		_save_active_profile()
		if first_discovery:
			_show_new_discovery(species_id, is_fauna, subject)
	elif previous_integrity != ceili(bio_scanner_integrity):
		_update_inventory_screen()
	queue_redraw()

func _cancel_bio_scan() -> void:
	if bio_scan_room < 0:
		return
	bio_scan_room = -1
	queue_redraw()
func _camera_species_id() -> String:
	if not analysis_mode or current_cave_id != selected_cave or bio_scan_room >= 0:
		return ""
	if _camera_targets_fauna():
		return fauna_species_by_room[selected_cave]
	if selected_flora == selected_cave and analyzed_flora.has(selected_cave):
		return flora_species_by_room[selected_cave]
	return ""

func _camera_subject_position() -> Vector2:
	if _camera_targets_fauna():
		return _fauna_position(selected_cave)
	return flora_sites.get(selected_cave, Vector2.ZERO)

func _can_photograph_subject() -> bool:
	return not _camera_species_id().is_empty() and _can_use_tools_at(_camera_subject_position(), selected_cave)

func _camera_targets_fauna() -> bool:
	return selected_fauna == selected_cave and analyzed_fauna.has(selected_cave)

func _photograph_subject() -> void:
	if taking_field_photo or not _can_photograph_subject():
		return
	var species_id := _camera_species_id()
	if field_photos.has(species_id):
		return
	var center := _world_to_screen(_camera_subject_position())
	var frame := _organism_photo_frame(species_id, selected_fauna == selected_cave, center)
	var viewport := get_viewport()
	var visible_rect := viewport.get_visible_rect()
	if not visible_rect.encloses(frame):
		status_label.text = "CENTRA L’ANIMAL PER FER LA FOTO"
		return
	for panel in ui_root.get_children():
		if panel is Control and panel.is_visible_in_tree() and frame.intersects(panel.get_global_rect()):
			status_label.text = "CENTRA L’ANIMAL PER FER LA FOTO"
			return
	taking_field_photo = true
	_update_flora_button()
	queue_redraw()
	await RenderingServer.frame_post_draw
	var image := viewport.get_texture().get_image()
	taking_field_photo = false
	queue_redraw()
	_update_flora_button()
	if _camera_species_id() != species_id:
		return
	if image == null or image.is_empty():
		status_label.text = "NO S’HA POGUT CAPTURAR LA FOTO"
		return
	var pixel_scale := Vector2(image.get_size()) / visible_rect.size
	var crop := Rect2i((frame.position - visible_rect.position) * pixel_scale, frame.size * pixel_scale)
	if crop.size.x < 1 or crop.size.y < 1:
		return
	var photo := image.get_region(crop)
	field_photos[species_id] = ImageTexture.create_from_image(photo)
	saved_photo_bytes[species_id] = photo.save_png_to_buffer()
	biological_register[species_id] = true
	biological_photos[species_id] = saved_photo_bytes[species_id]
	_update_inventory_screen()
	status_label.text = "FOTO DESADA AL CATÀLEG"
	_update_flora_button()
	_save_active_profile()

func _catalog_rooms(species_id: String, fauna: bool) -> PackedStringArray:
	var rooms := PackedStringArray()
	var states := inactive_levels.duplicate()
	states[maxi(1, current_level)] = _level_snapshot()
	var levels := states.keys()
	levels.sort()
	for level in levels:
		var state: Dictionary = states[level]
		var observations: Dictionary = state.analyzed_fauna if fauna else state.analyzed_flora
		var species_by_room: Dictionary = state.fauna_species_by_room if fauna else state.flora_species_by_room
		var ids := observations.keys()
		ids.sort()
		for id in ids:
			if species_by_room.get(id) == species_id:
				rooms.append("Estrat %d · sala %02d" % [-int(level), int(id) + 1])
	return rooms

func _remember_current_biology() -> void:
	var levels := inactive_levels.values()
	levels.append(_level_snapshot())
	for state in levels:
		for id in state.analyzed_flora:
			biological_register[state.flora_species_by_room[id]] = true
		for id in state.analyzed_fauna:
			biological_register[state.fauna_species_by_room[id]] = true
	for species in saved_photo_bytes:
		biological_register[species] = true
		if not biological_photos.has(species):
			biological_photos[species] = saved_photo_bytes[species]

func _open_flora_catalog() -> void:
	_remember_current_biology()
	for entry in catalog_grid.get_children():
		catalog_grid.remove_child(entry)
		entry.queue_free()
	var registered := biological_register.keys()
	registered.sort()
	for species_id: String in registered:
		var family := species_id.get_slice("~", 0)
		if FLORA_SPECIES.has(family):
			var flora_entry: Dictionary = FLORA_SPECIES[family]
			var plant := OrganismTraits.decode(species_id, OrganismTraits.PLANT)
			if not plant.is_empty():
				flora_entry = {"name": OrganismTraits.display_name(species_id, flora_entry.name, int(flora_entry.get("biome", 1))),
					"description": OrganismTraits.describe(plant, OrganismTraits.PLANT)}
			_add_catalog_card(species_id, flora_entry, _catalog_rooms(species_id, false), false)
			continue
		if not FAUNA_SPECIES.has(family):
			continue
		var entry: Dictionary = FAUNA_SPECIES[family]
		var variant := _fauna_variant(species_id)
		var animal := OrganismTraits.decode(species_id, OrganismTraits.ANIMAL)
		if not animal.is_empty():
			entry = {"name": OrganismTraits.display_name(species_id, entry.name, int(entry.get("biome", 1))),
				"description": OrganismTraits.describe(animal, OrganismTraits.ANIMAL)}
		elif not variant.is_empty():
			entry = {"name": "%s · %s" % [entry.name, FAUNA_VARIANT_COLOR_NAMES[variant.color]],
				"description": "%d %s · %s · %s · patró: %s" % [variant.legs, "pota" if variant.legs == 1 else "potes",
					"amb pèl" if variant.fur else "sense pèl", FAUNA_VARIANT_SIZES[variant.size], FAUNA_VARIANT_PATTERNS[variant.pattern]]}
		_add_catalog_card(species_id, entry, _catalog_rooms(species_id, true), true)
	if catalog_grid.get_child_count() == 0:
		var empty := _add_equipment_card(catalog_grid, Vector2(226, 80))
		_add_equipment_label(empty, "Cap espècie registrada", 14, MUTED)
	var samples := _sample_totals()
	flora_catalog_text.text = "Mostres a sobre: %d   ·   Lliurades: %d   ·   Punts de recerca: %d" % [samples.x, samples.y, _research_points()]
	flora_catalog.popup_centered(Vector2i(520, 530))

func _add_catalog_card(species_id: String, species: Dictionary, rooms: PackedStringArray, fauna: bool) -> void:
	var card := _add_equipment_card(catalog_grid, Vector2(226, 170))
	_add_equipment_label(card, species.name, 15, CYAN)
	var photo: Texture2D = field_photos.get(species_id)
	if photo == null and biological_photos.has(species_id):
		var picture := Image.new()
		if picture.load_png_from_buffer(biological_photos[species_id]) == OK:
			photo = ImageTexture.create_from_image(picture)
	if photo != null:
		var preview := TextureRect.new()
		preview.texture = photo
		preview.custom_minimum_size.y = 76
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		card.add_child(preview)
	else:
		var icon := Control.new()
		icon.custom_minimum_size.y = 76
		card.add_child(icon)
		icon.draw.connect(func() -> void:
			var center := icon.size * 0.5
			if fauna:
				_draw_fauna_map_badge(icon, center, species_id, 2.0)
			else:
				_draw_flora_symbol(icon, center + Vector2(0, 10), 1.8, species_id))
	_add_equipment_label(card, "Fauna observada" if fauna else "Flora analitzada", 11, CYAN)
	var detail := _add_equipment_label(card, species.description, 12, Color("b4ccd2"))
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var locations := _add_equipment_label(card, "Expedicions anteriors" if rooms.is_empty() else ", ".join(rooms), 11, MUTED)
	locations.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _research_points() -> int:
	var samples := _sample_totals()
	return samples.x + samples.y + _earned_research_record_points() - equipment_research_spent

func _sample_totals() -> Vector2i:
	var totals := _count_samples(flora_samples) + _count_samples(fauna_samples)
	for state in inactive_levels.values():
		totals += _count_samples(state.flora_samples) + _count_samples(state.get("fauna_samples", {}))
	return totals

func _count_samples(samples: Dictionary) -> Vector2i:
	var delivered := samples.values().count(true)
	return Vector2i(samples.size() - delivered, delivered)

func _earned_research_record_points() -> int:
	var species_seen: Dictionary = {}
	for cave_id in analyzed_flora:
		species_seen[flora_species_by_room[cave_id]] = true
	for cave_id in analyzed_fauna:
		species_seen[fauna_species_by_room[cave_id]] = true
	for state in inactive_levels.values():
		for cave_id in state.analyzed_flora:
			species_seen[state.flora_species_by_room[cave_id]] = true
		for cave_id in state.analyzed_fauna:
			species_seen[state.fauna_species_by_room[cave_id]] = true
	return species_seen.size() + field_photos.size()

func _update_research_panel() -> void:
	craft_beacon_button.disabled = not _can_use_workshop() or materials_in_pack < BEACON_CRAFT_COST
	craft_oxygen_button.disabled = not _can_use_workshop() or materials_in_pack < OXYGEN_CRAFT_COST
	craft_beacon_button.text = "REPOSA · %d DE FERRO" % BEACON_CRAFT_COST
	craft_oxygen_button.text = "COMPRA · %d DE FERRO" % OXYGEN_CRAFT_COST
	_update_equipment_display()

func _update_equipment_display() -> void:
	_update_suit_display()
	_update_field_equipment_buttons()
	_update_inventory_screen()
	defence_system.refresh_ui(self)

func _update_field_equipment_buttons() -> void:
	if not is_instance_valid(oxygen_reserve_card_button):
		return
	oxygen_reserve_card_button.disabled = surface_mode or oxygen_cartridges <= 0 or oxygen_seconds >= _oxygen_capacity() - 1.0
	use_repair_kit_button.disabled = not _can_use_repair_kit() or (suit_integrity >= 100.0 and boots_integrity >= 100.0 and mining_tool_integrity >= 100.0 and bio_scanner_integrity >= 100.0)
	helmet_battery_card_button.disabled = not _can_replace_low_helmet_battery()
	_update_beacon_action()
	_layout_room_controls()

func _layout_room_controls() -> void:
	if is_instance_valid(return_marker_button): return_marker_button.disabled=navigation_marker.is_empty() or int(navigation_marker.get("seed",-1))!=seed_value
	if not is_instance_valid(navigation_panel):
		return
	navigation_panel.visible = not surface_mode
	inspect_room_button.visible = not analysis_mode
	fit_map_button.visible = not surface_mode
	center_explorer_button.visible = analysis_mode
	if not navigation_panel.visible:
		return
	var x := 94.0
	for button in [map_return_button, inspect_room_button, fit_map_button, center_explorer_button, biome_base_return_button, base_return_button, descend_navigation_button, lower_level_button, place_marker_button, return_marker_button, unstuck_navigation_button]:
		if not button.visible:
			continue
		button.position = Vector2(x, 9)
		var font: Font = button.get_theme_font("font")
		var text_width: float = font.get_string_size(button.text,HORIZONTAL_ALIGNMENT_LEFT,-1,button.get_theme_font_size("font_size")).x
		button.size = Vector2(maxf(92.0,ceilf(text_width)+20.0),30)
		x += button.size.x + 4.0
	navigation_panel.size.x = x + 6.0
	var view := _view_rect()
	var scale := minf(1.0, (view.size.x - 16.0) / navigation_panel.size.x)
	navigation_panel.scale = Vector2.ONE * scale
	navigation_panel.position = Vector2(view.position.x+(view.size.x - navigation_panel.size.x * scale) * 0.5,
		equipment_bar.position.y - navigation_panel.size.y * scale - 8.0)

func _place_material_sites(include_ladder_reserve: bool = false) -> void:
	material_sites.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([seed_value, "materials_v1"])
	for cave in world.caves:
		if cave.id == world.entry:
			continue
		var point := _sample_room_site(cave, rng, 12.0, _room_site_reservations(cave.id))
		if point.is_finite():
			material_sites[cave.id] = point
	if not include_ladder_reserve:
		return
	var nearby_deposits := 0
	for corridor in world.corridors:
		if corridor.a != world.entry and corridor.b != world.entry:
			continue
		var room: int = corridor.b if corridor.a == world.entry else corridor.a
		if material_sites.has(room) and _gallery_has_continuous_signal(corridor, -1, true):
			nearby_deposits += 1
	if nearby_deposits >= FOLDING_LADDER_REPAIR_COST:
		return
	var entry: Dictionary = world.caves[world.entry]
	for index in range(16):
		var point: Vector2 = entry.position + Vector2.from_angle(TAU * index / 16.0) * minf(48.0, float(entry.radius) * 0.6)
		if _point_inside_cave_id(point, entry.id) and _segment_is_walkable(point, point, true):
			material_sites[entry.id] = point
			return

func _material_rock_is_visible(cave_id: int) -> bool:
	return analysis_mode and _mineral_site_discovered(cave_id)

func _mineral_site_discovered(cave_id: int) -> bool:
	return material_sites.has(cave_id) and (collected_materials.has(cave_id) or explored_caves.has(cave_id) or _is_revealed(material_sites[cave_id]))

func _material_is_visible(cave_id: int) -> bool:
	return _material_rock_is_visible(cave_id) and not collected_materials.has(cave_id)

func _material_marker_position(cave_id: int) -> Vector2:
	return _world_to_screen(material_sites[cave_id]) - Vector2(0, 6.0 * zoom_level * 0.28)

func _try_click_biome_base(screen_point: Vector2) -> bool:
	if not analysis_mode or not _depth_has_workshop(current_level): return false
	var cave: Dictionary = world.caves[world.entry]
	if not _can_inspect_cave(cave.id): return false
	var footprint := _biome_base_footprint(cave)
	if footprint.size() != 4: return false
	var anchor := Vector2.ZERO
	for point in footprint: anchor += point
	anchor /= 4.0
	var texture := _biome_module_texture(_biome_at_depth(current_level))
	var size := Vector2(texture.get_size()) * zoom_level * float(OXIDIZED_BASE_TEXTURE.get_width()) / float(texture.get_width()) * 0.034 * footprint[0].distance_to(footprint[1]) / 52.0
	var atlas := _biome_at_depth(current_level) in OTHER_BIOME_PROFILES
	if atlas: size *= 0.62
	var area := Rect2(_world_to_screen(anchor) - size * Vector2(0.5, 0.96 if atlas else 0.88), size)
	if not area.has_point(screen_point): return false
	var local := (screen_point - area.position) / area.size
	# Exclude the generous transparent margins of standalone sprites.
	if not atlas and (local.x < 0.23 or local.x > 0.77 or local.y < 0.04 or local.y > 0.9): return false
	if not _can_use_workshop():
		status_label.text = "TORNA A LA SALA DE LA BASE PER OBRIR EQUIP I MILLORES"
		return true
	_open_inventory(true)
	return true

func _try_click_mineral(screen_point: Vector2) -> bool:
	if not analysis_mode:
		return false
	var gallery := _inspection_gallery()
	if gallery.is_empty() and isometric_passage_id >= 0:
		gallery = _corridor_by_id(isometric_passage_id)
	# Reverse the room painter order: the visible rock on top gets the click.
	for i in range(world.caves.size() - 1, -1, -1):
		var cave: Dictionary = world.caves[i]
		if cave.id != selected_cave and not _can_inspect_cave(cave.id) and (gallery.is_empty() or (cave.id != gallery.a and cave.id != gallery.b)):
			continue
		if not _mineral_hit_test(cave.id, screen_point):
			continue
		if current_cave_id != cave.id or _cave_at_position(unit_position) != cave.id:
			_action_notice("ENTRA A LA SALA %02d PER EXTREURE AQUESTA VETA" % (cave.id + 1))
			return true
		if selected_cave != cave.id:
			var anchor_before := _world_to_screen(material_sites[cave.id])
			selected_cave = cave.id
			_update_view_mode_ui()
			camera_offset += anchor_before - _world_to_screen(material_sites[cave.id])
		_collect_material()
		return true
	return false

func _collect_material() -> void:
	if mining_cave >= 0:
		_action_notice("EXTRACCIÓ EN CURS")
		return
	if bio_scan_room >= 0 or rockfall_clear_remaining > 0.0:
		_action_notice("ACABA L’ACCIÓ EN CURS ABANS D’EXTREURE EL MINERAL")
		return
	if current_cave_id != selected_cave or _cave_at_position(unit_position) != selected_cave:
		_action_notice("ENTRA A LA SALA DE LA VETA PER EXTREURE-LA")
		return
	if not _material_is_visible(selected_cave):
		return
	if mining_tool_integrity <= 0.0:
		_action_notice("EINA AVARIADA · REPARA-LA AL TALLER")
		return
	if not _can_use_tools_at(material_sites[selected_cave], selected_cave):
		_action_notice("IL·LUMINA LA VETA PER EXTREURE EL MINERAL")
		return
	if moving:
		_action_notice("ATURA’T PER EXTREURE EL MINERAL")
		return
	var mineral := _mineral_type(selected_cave)
	if mineral != "ferro" and not _modifier_protects("mineria", mineral):
		var head := "Capçal de precisió" if mineral == "quars" else "Capçal reforçat"
		_action_notice("VETA DE %s · Requereix eina de mineria Nv. 1 + %s. Millora l’eina a Base → Equip i millores i activa el capçal." % [mineral.to_upper(), head])
		return
	mining_cave = selected_cave
	mining_remaining = _mining_duration(mining_tool)
	_update_mining(0.0)
	_update_field_equipment_buttons()

func _cancel_mining() -> void:
	if mining_cave < 0:
		return
	mining_cave = -1
	_update_field_equipment_buttons()
	queue_redraw()

func _update_mining(delta: float) -> void:
	if mining_cave < 0:
		return
	if surface_mode or moving or selected_cave != mining_cave or current_cave_id != mining_cave or not _material_is_visible(mining_cave):
		_cancel_mining()
		return
	if not _can_use_tools_at(material_sites[mining_cave], mining_cave):
		_cancel_mining()
		status_label.text = "EXTRACCIÓ ATURADA · IL·LUMINA LA VETA"
		return
	var elapsed := minf(delta, mining_remaining)
	var previous_integrity := ceili(mining_tool_integrity)
	var wear_per_second: float = _mining_wear(mining_tool) / _mining_duration(mining_tool)
	var wear := elapsed * wear_per_second
	if wear > mining_tool_integrity and not is_equal_approx(wear, mining_tool_integrity):
		mining_tool_integrity = 0.0
		_cancel_mining()
		_update_inventory_screen()
		status_label.text = "EINA AVARIADA · REPARA-LA AL TALLER"
		return
	mining_tool_integrity = maxf(0.0, mining_tool_integrity - wear)
	mining_remaining -= elapsed
	if mining_remaining > 0.0:
		if mining_tool_integrity <= 0.0:
			_cancel_mining()
			status_label.text = "EINA AVARIADA · REPARA-LA AL TALLER"
		if previous_integrity != ceili(mining_tool_integrity):
			_update_inventory_screen()
		queue_redraw()
		return
	var mineral := _mineral_type(mining_cave)
	collected_materials[mining_cave] = true
	field_action_completed_until[STRIP_MINING_SLOT] = Time.get_ticks_msec() + 450
	mining_cave = -1
	var yield_amount := _mining_yield(mining_tool) + (1 if mineral != "ferro" else 0)
	status_label.text = "+%d DE %s" % [yield_amount, mineral.to_upper()]
	match mineral:
		"quars": quartz_in_pack += yield_amount
		"magnetita": magnetite_in_pack += yield_amount
		_: materials_in_pack += yield_amount
	_update_equipment_display()
	_save_active_profile()
	queue_redraw()

func _craft_equipment(beacon: bool) -> void:
	var cost := BEACON_CRAFT_COST if beacon else OXYGEN_CRAFT_COST
	if not _can_use_workshop() or materials_in_pack < cost:
		return
	materials_in_pack -= cost
	if beacon:
		crafted_beacons += 1
	else:
		oxygen_cartridges += 1
	_update_research_panel()
	_update_beacon_status()
	status_label.text = "BALISA FABRICADA" if beacon else "RESERVA D’OXIGEN FABRICADA"

func _craft_reinforced_suit() -> void:
	if not _pay_equipment_upgrade(suit_tier, "Vestit espacial"):
		return
	suit_tier += 1
	suit_integrity = 100.0
	_update_research_panel()
	status_label.text = "VESTIT ESPACIAL MILLORAT"

func _update_suit_display() -> void:
	if not inventory_strip_values.is_empty():
		inventory_strip_meters[4].value = suit_integrity
		var text := _inventory_suit_text()
		if inventory_strip_values[4].text != text:
			inventory_strip_values[4].text = text
			inventory_strip_values[4].add_theme_color_override("font_color", ORANGE if suit_integrity <= LOW_SUPPLY_PERCENT else CYAN)

func _inventory_suit_text() -> String:
	return "%s · %d%%" % ["Nv. %d" % (suit_tier + 1), ceili(suit_integrity)]

func _toggle_flashlight() -> void:
	if surface_mode:
		return
	var replaced_battery := flashlight_charge <= 0.0
	if flashlight_charge <= 0.0:
		if flashlight_spares <= 0:
			return
		flashlight_spares -= 1
		flashlight_charge = _helmet_battery_duration()
	_set_helmet_light(not flashlight_on)
	if replaced_battery:
		_save_active_profile()

func _set_helmet_light(enabled: bool) -> void:
	if flashlight_on == enabled:
		return
	flashlight_on = enabled
	if flashlight_on:
		if light_warning_tween and light_warning_tween.is_valid():
			light_warning_tween.kill()
		light_warning_label.hide()
		_set_light_warning_strength(0.0)
	if flashlight_on and _cave_at_position(unit_position) >= 0:
		_reveal_around(unit_position, 4 + floori(float(_supply_tier("helmet_light")) / 3.0))
	_update_field_equipment_buttons()
	_update_inventory_screen()
	queue_redraw()

func _oxygen_capacity() -> float:
	return OXYGEN_CAPACITY + _supply_bonus("oxygen_tank")

func _helmet_battery_duration() -> float:
	return FLASHLIGHT_BATTERY_SECONDS + _supply_bonus("helmet_light")

func _flashlight_charge_percent() -> int:
	return ceili(flashlight_charge * 100.0 / _helmet_battery_duration())

func _draw_low_supply_card(card: PanelContainer, slot: int) -> void:
	var active := repair_kit_urgent if slot == 10 else warned_low_supplies.has(slot)
	if not active:
		return
	var pulse := 0.5 + 0.5 * cos(float(Time.get_ticks_msec()) * TAU / 900.0)
	var bounds := Rect2(Vector2(2, 2), card.size - Vector2(4, 4))
	card.draw_rect(bounds, Color(1.0, 0.13, 0.16, 0.20 * pulse))
	card.draw_rect(bounds, Color(1.0, 0.24, 0.26, lerpf(0.20, 1.0, pulse)), false, 2.0, true)

func _update_low_supply_warning(delta: float) -> void:
	if not is_instance_valid(low_supply_label):
		return
	var repair := "Fes servir la caixa d’eines" if _repair_kit_uses_left() > 0 else "Repara-ho al taller"
	var supplies := [
		["Oxigen", oxygen_seconds * 100.0 / _oxygen_capacity(), "Clica Reserves dins del dipòsit" if oxygen_cartridges > 0 else "Torna a la base a recarregar"],
		["Bateria del casc", flashlight_charge * 100.0 / _helmet_battery_duration(), "Clica Bateries dins de Llum del casc" if flashlight_spares > 0 else "Sense recanvi"],
		["Vestit espacial", suit_integrity, repair],
		["Botes", boots_integrity, repair],
		["Eina de mineria", mining_tool_integrity, repair],
		["Escàner biològic", bio_scanner_integrity, repair],
		["Caixa d’eines", _repair_kit_uses_percent(), "Reposa els usos al taller"]]
	var lines := PackedStringArray()
	var new_warning := false
	var equipment_low := false
	var slots := [STRIP_OXYGEN_SLOT, 5, 4, 9, STRIP_MINING_SLOT, STRIP_BIO_SCANNER_SLOT, 10]
	for index in range(supplies.size()):
		var supply: Array = supplies[index]
		var slot: int = slots[index]
		var title: String = supply[0]
		var remaining := float(supply[1])
		var was_low := warned_low_supplies.has(slot)
		var is_low := remaining < LOW_SUPPLY_PERCENT
		if slot in [4, 9, STRIP_MINING_SLOT, STRIP_BIO_SCANNER_SLOT]:
			equipment_low = equipment_low or is_low
		if was_low or is_low:
			if slot != 10:
				inventory_strip_meters[slot].get_parent().get_parent().queue_redraw()
		if not is_low:
			warned_low_supplies.erase(slot)
			if resource_gain_cards.has(slot): resource_gain_cards[slot].queue_redraw()
			continue
		if not was_low:
			warned_low_supplies[slot] = true
			new_warning = true
		lines.append("%s · %d%% · %s" % [title, floori(remaining), supply[2]])
	var kit_should_pulse := equipment_low and _repair_kit_uses_left() > 0
	if kit_should_pulse or repair_kit_urgent != kit_should_pulse:
		resource_gain_cards[10].queue_redraw()
		repair_kit_footer.queue_redraw()
	repair_kit_urgent = kit_should_pulse
	low_supply_warning_time = 5.0 if new_warning else maxf(0.0, low_supply_warning_time - delta)
	low_supply_label.visible = low_supply_warning_time > 0.0 and not lines.is_empty()
	if low_supply_label.visible:
		var notification := "\n".join(lines)
		if low_supply_label.text != notification:
			low_supply_label.text = notification

func _can_replace_low_helmet_battery() -> bool:
	return not surface_mode and flashlight_spares > 0 and _flashlight_charge_percent() <= LOW_SUPPLY_PERCENT

func _replace_low_helmet_battery() -> void:
	if not _can_replace_low_helmet_battery():
		return
	if flashlight_charge <= 0.0:
		_toggle_flashlight()
	else:
		flashlight_spares -= 1
		flashlight_charge = _helmet_battery_duration()
		_update_equipment_display()
		_save_active_profile()
	status_label.text = "BATERIA DEL CASC SUBSTITUÏDA"

func _update_flashlight_charge(delta: float) -> void:
	if not flashlight_on:
		return
	var previous_percent := _flashlight_charge_percent()
	flashlight_charge = maxf(0.0, flashlight_charge - delta)
	if flashlight_charge <= 0.0:
		flashlight_on = false
		status_label.text = "BATERIA DEL CASC ESGOTADA · %d DE RECANVI" % flashlight_spares
		queue_redraw()
	if previous_percent != _flashlight_charge_percent():
		_update_inventory_screen()

func _use_oxygen_cartridge() -> void:
	if surface_mode or oxygen_cartridges <= 0 or oxygen_seconds >= _oxygen_capacity() - 1.0:
		return
	oxygen_cartridges -= 1
	oxygen_seconds = minf(_oxygen_capacity(), oxygen_seconds + OXYGEN_CARTRIDGE_SECONDS + _supply_bonus("oxygen_reserve"))
	_update_oxygen_display()
	_update_equipment_display()
	status_label.text = "RESERVA D’OXIGEN UTILITZADA"
	_save_active_profile()

func _beacon_range() -> float:
	return BEACON_RANGE + _supply_bonus("beacon")

func _signal_sources(excluded_beacon: int = -1) -> PackedVector2Array:
	var sources := PackedVector2Array([world.caves[world.entry].position])
	for cave_id in deployed_beacons:
		if cave_id != excluded_beacon:
			sources.append(world.caves[cave_id].position)
	return sources

func _covered_segment_intervals(start: Vector2, finish: Vector2, sources: PackedVector2Array, range_override: float = -1.0) -> Array[Vector2]:
	var intervals: Array[Vector2] = []
	var segment := finish - start
	var length_squared := segment.length_squared()
	var radius := _beacon_range() if range_override < 0.0 else range_override
	var radius_squared := radius * radius
	for center in sources:
		var offset := center - start
		if length_squared < 0.000001:
			if offset.length_squared() <= radius_squared:
				return [Vector2(0, 1)]
			continue
		var projection := offset.dot(segment) / length_squared
		var remaining := radius_squared - (offset - projection * segment).length_squared()
		if remaining < 0.0:
			continue
		var half_span := sqrt(remaining / length_squared)
		var first := maxf(0.0, projection - half_span)
		var last := minf(1.0, projection + half_span)
		if first <= last:
			intervals.append(Vector2(first, last))
	intervals.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)
	var merged: Array[Vector2] = []
	for interval in intervals:
		if not merged.is_empty() and interval.x <= merged[-1].y + 0.00001:
			merged[-1] = Vector2(merged[-1].x, maxf(merged[-1].y, interval.y))
		else:
			merged.append(interval)
	return merged

func _gallery_has_continuous_signal(corridor: Dictionary, excluded_beacon: int = -1, initial_coverage_only: bool = false) -> bool:
	var points: PackedVector2Array = corridor.points
	var start := _project_to_polyline(corridor.exit_a, points)
	var finish := _project_to_polyline(corridor.exit_b, points)
	# Projection can place the exits in reverse order on a winding route.
	if float(start.segment) + float(start.t) > float(finish.segment) + float(finish.t):
		var swap := start
		start = finish
		finish = swap
	var span := PackedVector2Array([start.point])
	if int(start.segment) < int(finish.segment):
		span.append_array(points.slice(int(start.segment) + 1, int(finish.segment) + 1))
	span.append(finish.point)
	var sources := PackedVector2Array([world.caves[world.entry].position]) if initial_coverage_only else _signal_sources(excluded_beacon)
	var range_override := BEACON_RANGE if initial_coverage_only else -1.0
	for index in range(span.size() - 1):
		var intervals := _covered_segment_intervals(span[index], span[index + 1], sources, range_override)
		if intervals.size() != 1 or intervals[0].x > 0.00001 or intervals[0].y < 0.99999:
			return false
	return true

func _can_enter_room_with_signal(destination: int, corridor_id: int = -1, source: int = -1, allow_dev_override: bool = true, excluded_beacon: int = -1) -> bool:
	if (dev_mode and allow_dev_override) or visited_caves.has(destination) or explored_caves.has(destination):
		return true
	var source_room := current_cave_id if source < 0 else source
	for corridor in world.corridors:
		if corridor_id >= 0 and corridor.id != corridor_id:
			continue
		var connects: bool = (corridor.a == source_room and corridor.b == destination) or (corridor.b == source_room and corridor.a == destination)
		if connects and _gallery_has_continuous_signal(corridor, excluded_beacon):
			return true
	return false

func _beacon_action_room() -> int:
	if surface_mode or world.is_empty() or (analysis_mode and selected_cave != current_cave_id):
		return -1
	return _cave_at_position(unit_position)

func _can_deploy_beacon() -> bool:
	var cave_id := _beacon_action_room()
	return cave_id >= 0 and cave_id != world.entry and not deployed_beacons.has(cave_id) and _beacons_remaining() > 0

func _beacons_remaining() -> int:
	var installed := deployed_beacons.size()
	for state in inactive_levels.values():
		installed += state.deployed_beacons.size()
	return BEACON_STOCK + crafted_beacons - installed + int(starting_rewards_depth >= 4)

func _can_recover_beacon() -> bool:
	var cave_id := _beacon_action_room()
	return cave_id >= 0 and deployed_beacons.has(cave_id) and not used_beacons.has(cave_id)

func _register_beacon_use(destination: int) -> void:
	if dev_mode or deployed_beacons.is_empty() or _can_inspect_cave(destination):
		return
	for cave_id in deployed_beacons:
		if not used_beacons.has(cave_id) and not _can_enter_room_with_signal(destination, -1, current_cave_id, false, cave_id):
			used_beacons[cave_id] = true

func _is_gallery_exit_accessible(corridor: Dictionary, room_id: int) -> bool:
	var destination: int = corridor.b if corridor.a == room_id else corridor.a
	return _can_enter_room_with_signal(destination, corridor.id, room_id, false)

func _update_beacon_status() -> void:
	if not is_instance_valid(beacon_signal_meter) or world.is_empty():
		return
	var distance := INF
	for center in _signal_sources():
		distance = minf(distance, unit_position.distance_to(center))
	var strength := 100 if surface_mode else ceili(clampf(1.0 - distance / _beacon_range(), 0.0, 1.0) * 100.0)
	beacon_signal_meter.value = strength
	inventory_strip_values[1].text = "Nv. %d · %d%%" % [_supply_tier("beacon") + 1, strength]
	if level_panel.visible:
		var room_id := selected_cave if analysis_mode else current_cave_id
		var exits := _visible_exits_for_cave(room_id)
		var accessible := 0
		for exit_info in exits:
			var gallery := _corridor_by_id(exit_info.corridor_id)
			if _is_gallery_exit_accessible(gallery, room_id):
				accessible += 1
		exit_count_label.text = str(accessible)
		blocked_exit_count_label.text = str(exits.size() - accessible)
	_update_beacon_action()

func _update_beacon_action() -> void:
	var cave_id := _beacon_action_room()
	var was_disabled := beacon_card_button.disabled
	beacon_card_button.disabled = not (_can_deploy_beacon() or _can_recover_beacon())
	if was_disabled != beacon_card_button.disabled:
		beacon_footer.queue_redraw()
	var action_label := "COL·LOCA BALISA"
	if deployed_beacons.has(cave_id):
		action_label = "BALISA EN ÚS" if used_beacons.has(cave_id) else "RECULL BALISA"
	beacon_card_button.tooltip_text = action_label.capitalize()
	if beacon_card_button.disabled and not deployed_beacons.has(cave_id):
		beacon_card_button.tooltip_text = "Cal una sala fora de l’entrada i una balisa disponible."

func _deploy_beacon() -> void:
	var cave_id := _beacon_action_room()
	if _can_recover_beacon():
		deployed_beacons.erase(cave_id)
		_update_beacon_status()
		_update_inventory_screen()
		status_label.text = "BALISA RECUPERADA"
		_save_active_profile()
		queue_redraw()
		return
	if not _can_deploy_beacon():
		return
	deployed_beacons[cave_id] = true
	_update_beacon_status()
	_update_inventory_screen()
	status_label.text = "BALISA INSTAL·LADA"
	_save_active_profile()
	queue_redraw()

func _draw_flora_symbol(canvas: CanvasItem, base: Vector2, scale: float, species_id: String = "falguera") -> void:
	var recipe := OrganismPixelArt.plant_recipe(species_id)
	if OrganismPixelArt.supports_plant(species_id):
		var clock := fauna_time if canvas == self and analysis_mode and not taking_field_photo else 0.0
		OrganismPixelArt.draw_plant(canvas, base, scale, recipe, clock, hash(species_id) & 0x7fffffff)
		return
	if not recipe.is_empty():
		_draw_plant_variant(canvas, base, scale, recipe)
		return
	var species: Dictionary = FLORA_SPECIES.get(species_id, {})
	var is_coral: bool = species_id == "coral" or species.get("form") == "coral"
	var glow := Color("dea6ff") if is_coral else Color("a1f8b0")
	var stem := Color("9362c9") if is_coral else Color("4ec584")
	var tips := [Vector2(-10, -7), Vector2(-6, -12), Vector2(5, -12), Vector2(10, -7)] if is_coral else [Vector2(-7, -9), Vector2(0, -15), Vector2(7, -11)]
	if species_id == "molsa_ferrica" or species.get("form") == "molsa":
		glow = Color("ffd09a")
		stem = Color("bd6947")
		tips = [Vector2(-9, -4), Vector2(-4, -7), Vector2(2, -5), Vector2(8, -7)]
	if species.has("color"):
		glow = Color(species.color)
		stem = glow.darkened(0.28)
	for tip in tips:
		var end: Vector2 = base + tip * scale
		canvas.draw_line(base, end, stem, 1.7, true)
		canvas.draw_circle(end, 4.0 * scale, Color(glow, 0.2), true, -1.0, true)
		canvas.draw_circle(end, 2.1 * scale, glow, true, -1.0, true)

func _draw_plant_variant(canvas: CanvasItem, base: Vector2, scale: float, recipe: Dictionary) -> void:
	var tint := Color(OrganismTraits.PLANT_COLORS[recipe.color])
	var height := 9.0 + 4.0 * int(recipe.size)
	var count := int(recipe.stems) + 1
	for index in range(count):
		var spread := 0.0 if count == 1 else float(index) / float(count - 1) * 2.0 - 1.0
		var tip := Vector2(spread * 9.0, -height * (1.0 - absf(spread) * 0.32))
		match int(recipe.form):
			1:
				tip = Vector2(spread * 12.0, -height * 0.6 - absf(spread) * 3.0)
			2:
				tip.x *= 0.68
				tip.y *= 1.15
			3:
				tip = Vector2(spread * 11.0, -height * 0.42 - (index % 2) * 2.0)
		var end := base + tip * scale
		var leaf := base.lerp(end, 0.65)
		canvas.draw_line(base, end, tint.darkened(0.35), 1.5 * scale, true)
		match int(recipe.leaf):
			0:
				canvas.draw_circle(leaf, 2.0 * scale, tint.darkened(0.18), true, -1.0, true)
			1:
				canvas.draw_colored_polygon(PackedVector2Array([leaf, leaf + Vector2(-4, -3) * scale,
					leaf + Vector2(2, -2) * scale]), tint)
			2:
				canvas.draw_line(leaf - Vector2(3, 0) * scale, leaf + Vector2(2, -2) * scale, tint, 2.4 * scale, true)
		if recipe.texture == 1:
			canvas.draw_line(leaf, end, tint.lightened(0.32), 0.75 * scale, true)
		elif recipe.texture == 2:
			canvas.draw_circle(leaf, 0.75 * scale, tint.lightened(0.4))
		if recipe.glow > 0:
			canvas.draw_circle(end, (3.0 + recipe.glow * 1.6) * scale, Color(tint, 0.13 * recipe.glow), true, -1.0, true)
		match int(recipe.tip):
			0:
				canvas.draw_circle(end, 1.8 * scale, tint, true, -1.0, true)
			1:
				for petal in range(4):
					canvas.draw_circle(end + Vector2.from_angle(TAU * petal / 4.0) * 1.7 * scale, 1.15 * scale, tint.lightened(0.25))
				canvas.draw_circle(end, scale, tint.darkened(0.25))
			2:
				for spore in [Vector2(-2, -1), Vector2(0, -3), Vector2(2, 0)]:
					canvas.draw_circle(end + spore * scale, 0.8 * scale, tint.lightened(0.34))

func _fauna_is_segmented(species_id: String) -> bool:
	var family := species_id.get_slice("~", 0)
	return family == "isopode" or FAUNA_SPECIES.get(family, {}).get("segmented", false)

func _fauna_color(species_id: String) -> Color:
	var fallback := "7f9cbe" if species_id == "isopode" else ("e56d58" if species_id == "escarabat_ferric" else "ffac62")
	return Color(FAUNA_SPECIES.get(species_id, {}).get("color", fallback))

func _draw_fauna_map_badge(canvas: CanvasItem, center: Vector2, species_id: String = "escarabat", icon_scale: float = 1.0, _show_ring: bool = false, normalize_size: bool = false) -> void:
	if species_id.begins_with("depredador_"):
		defence_system.draw_badge(canvas,center,species_id,icon_scale)
		return
	var variant := _fauna_variant(species_id)
	if not variant.is_empty():
		if normalize_size:
			variant.size = 4
		_draw_fauna_variant(canvas, center, species_id, variant, icon_scale * 0.85)
		return
	var color := _fauna_color(species_id)
	if _fauna_is_segmented(species_id):
		for index in range(-1, 2):
			canvas.draw_circle(center + Vector2(0, index * 3) * icon_scale, 3.2 * icon_scale, color.lightened(0.24) if index % 2 == 0 else color, true, -1.0, true)
	else:
		_draw_fauna_symbol(canvas, center, 0.65 * icon_scale, color)

func _draw_fauna_variant(canvas: CanvasItem, center: Vector2, species_id: String, variant: Dictionary, icon_scale: float) -> void:
	if OrganismPixelArt.supports_animal(species_id):
		OrganismPixelArt.draw_animal(canvas, center, icon_scale, variant,
			Vector2(1, 0.5), 0.0, false, FAUNA_VARIANT_COLORS)
		return
	var scale := icon_scale * (0.78 + 0.11 * int(variant.size))
	var tint := Color(FAUNA_VARIANT_COLORS[variant.color])
	var segmented := _fauna_is_segmented(species_id)
	var length := 7.0 if segmented else 5.0
	var tail := int(variant.get("tail", 0))
	if tail > 0:
		var tail_base := center + Vector2(0, length - 1.0) * scale
		var tail_tip := tail_base + Vector2(0, 4) * scale
		canvas.draw_line(tail_base, tail_tip, tint.darkened(0.25), 1.4 * scale, true)
		if tail == 2:
			for side in [-1.0, 1.0]:
				canvas.draw_line(tail_tip, tail_tip + Vector2(side * 2.5, 2.2) * scale, tint, scale, true)
	var antennae := int(variant.get("antennae", 0))
	if antennae > 0:
		for side in [-1.0, 1.0]:
			canvas.draw_line(center + Vector2(side * 1.5, -length + 1) * scale,
				center + Vector2(side * (2 + antennae), -length - antennae * 2.0) * scale, tint.lightened(0.25), scale, true)
	for leg in range(variant.legs):
		var side := -1.0 if leg % 2 == 0 else 1.0
		var y := -3.0 if leg < 2 else 3.0
		var joint := center + Vector2(side * 3.0, y) * scale
		var foot := center + Vector2(side * 8.0, y + 2.0) * scale
		canvas.draw_line(joint, foot, tint.darkened(0.22), 1.2 * scale, true)
	if variant.fur:
		for tuft in range(12):
			var outward := Vector2.from_angle(TAU * float(tuft) / 12.0)
			var edge := center + outward * Vector2(4.0, length) * scale
			canvas.draw_line(edge, edge + outward * 2.2 * scale, tint.lightened(0.3), 1.1 * scale, true)
	var outline := PackedVector2Array()
	for vertex in range(16):
		var direction := Vector2.from_angle(TAU * float(vertex) / 16.0)
		outline.append(center + direction * Vector2(4.5, length) * scale)
	canvas.draw_colored_polygon(outline, tint)
	if segmented or variant.get("armor") == 1:
		for y in [-3.0, 0.0, 3.0]:
			canvas.draw_line(center + Vector2(-3.2, y) * scale, center + Vector2(3.2, y) * scale, tint.darkened(0.33), scale, true)
	if variant.get("armor") == 2:
		for y in [-3.0, 0.0, 3.0]:
			for side in [-1.0, 1.0]:
				var spike := center + Vector2(side * 3.0, y) * scale
				canvas.draw_colored_polygon(PackedVector2Array([spike, spike + Vector2(side * 3, -1) * scale,
					spike + Vector2(0, 2) * scale]), tint.lightened(0.38))
	var marking := tint.lightened(0.46)
	match int(variant.pattern):
		1, 2:
			canvas.draw_line(center + Vector2(0, -3.5) * scale, center + Vector2(0, 3.5) * scale, marking, scale, true)
			if variant.pattern == 2:
				canvas.draw_line(center + Vector2(2, -3.0) * scale, center + Vector2(2, 3.0) * scale, marking, scale, true)
		3:
			for spot in [Vector2(-2, -2), Vector2(2, 1), Vector2(-1, 3)]:
				canvas.draw_circle(center + spot * scale, 0.9 * scale, marking)

func _draw_fauna_symbol(canvas: CanvasItem, center: Vector2, scale: float, shell_color: Color) -> void:
	for row in [-5.0, 0.0, 5.0]:
		for side in [-1.0, 1.0]:
			canvas.draw_line(center + Vector2(side * 3.0, row) * scale, center + Vector2(side * 9.0, row + 2.0) * scale, Color("ce9454"), 1.5, true)
	canvas.draw_circle(center + Vector2(0, -5) * scale, 4.5 * scale, Color("b67642"), true, -1.0, true)
	canvas.draw_circle(center + Vector2(0, 2) * scale, 6.0 * scale, shell_color, true, -1.0, true)
	canvas.draw_line(center + Vector2(0, -2) * scale, center + Vector2(0, 7) * scale, Color("945632"), 1.2, true)

func _pick_descent_access() -> int:
	var result := -1
	var greatest_distance := -1.0
	for corridor in world.corridors:
		if corridor.a != world.entry and corridor.b != world.entry:
			continue
		var cave_id: int = corridor.b if corridor.a == world.entry else corridor.a
		var distance: float = world.caves[world.entry].position.distance_to(world.caves[cave_id].position)
		if distance > greatest_distance and _gallery_has_continuous_signal(corridor, -1, true):
			result = cave_id
			greatest_distance = distance
	return result

func _level_access_position(cave_id: int) -> Vector2:
	if cave_id == descent_access:
		return world.get("descent_position", world.caves[cave_id].position)
	return world.caves[cave_id].position

func _place_descent_position() -> void:
	if descent_access < 0:
		return
	var cave: Dictionary = world.caves[descent_access]
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([seed_value, "descent_position_v1", descent_access])
	var point := _sample_room_site(cave, rng, 18.0, [cave.position])
	world["descent_position"] = point if point.is_finite() else cave.position

func _level_snapshot() -> Dictionary:
	var state := {}
	for field in LEVEL_STATE_FIELDS:
		state[field] = get(field)
	return state

func _change_underground_level(destination: int, arrival: int) -> void:
	rockfall_clear_remaining = 0.0
	isometric_passage_id = -1
	use_elevator_on_arrival = false
	_cancel_mining()
	_cancel_bio_scan()
	inactive_levels[current_level] = _level_snapshot()
	if inactive_levels.has(destination):
		var state: Dictionary = inactive_levels[destination]
		inactive_levels.erase(destination)
		for field in LEVEL_STATE_FIELDS:
			set(field, state[field])
	else:
		rockfall_remaining = 0.0
		rockfall_corridor_id = -1
		rockfall_hit = false
		var original_seed := seed_value
		seed_value = hash([original_seed, "subterra_level_v1", destination]) & 0x7fffffff
		world = Generator.generate(seed_value, destination >= 19, _biome_at_depth(destination))
		world["biome_profile"] = _biome_at_depth(destination)
		world["campaign_order_version"] = 1
		for field in LEVEL_STATE_FIELDS:
			if get(field) is Dictionary and field != "world":
				set(field, {})
		revealed_mask = PackedByteArray()
		revealed_mask.resize(world.terrain_mask.size())
		descent_access = int(world.objective) if destination == 19 else (_pick_descent_access() if destination < CAMPAIGN_DEPTH else -1)
		_place_descent_position()
		_place_flora_sites(destination)
		_place_fauna_sites(destination)
		_place_material_sites()
		_assign_mineral_types(destination)
		seed_value = original_seed
	current_level = destination
	discovered_biomes[_biome_at_depth(destination)] = true
	expedition_record.depth = maxi(int(expedition_record.depth), destination)
	var unlocked_reward := destination > deepest_reached and DEPTH_REWARDS.has(destination)
	deepest_reached = maxi(deepest_reached, destination)
	if current_level == 3 and descent_access < 0:
		descent_access = _pick_descent_access()
	current_cave_id = world.entry if arrival < 0 else arrival
	selected_cave = current_cave_id
	visited_caves[current_cave_id] = true
	analysis_mode = true
	unit_position = _level_access_position(current_cave_id)
	selected_cave_focus = unit_position
	move_target = unit_position
	moving = false
	level_navigation_target = -1
	move_path.clear()
	selected_route.clear()
	chained_cave_id = -1
	inspection_corridor_id = -1
	inspection_destination_cave_id = -1
	inspect_on_cave_arrival = false
	selected_flora = -1
	selected_fauna = -1
	last_revealed_cell = Vector2i(-1, -1)
	if not explored_caves.has(current_cave_id):
		_reveal_around(unit_position, 5)
		_scan_current_cave()
	zoom_level = _analysis_zoom_for_cave(current_cave_id)
	_focus_world_position(unit_position, zoom_level)
	_update_map_stats()
	_update_view_mode_ui()
	if unlocked_reward:
		_record_expedition_milestone("Fita: %s" % DEPTH_REWARDS[destination])
		status_label.text = "★ FITA DESBLOQUEJADA\n%s a la pròxima expedició" % DEPTH_REWARDS[destination]
	queue_redraw()
	_save_active_profile()

func _descend_to_lower_level() -> void:
	if not _at_lower_level_access():
		return
	if not _biome_exit_is_ready():
		_notice_biome_exit_requirement()
		return
	if _is_unopened_shaft(descent_access):
		if _ladder_uses_left() <= 0:
			status_label.text = "ESCALA ESGOTADA · REPARA-LA A LA BASE"
			return
		ladder_uses_spent += 1
	_change_underground_level(current_level + 1, -1)

func _can_descend_to_lower_level() -> bool:
	return _at_lower_level_access() and _biome_exit_is_ready()

func _at_lower_level_access() -> bool:
	if mining_cave >= 0 or bio_scan_room >= 0:
		return false
	return _has_descent_elevator(descent_access) and analysis_mode and selected_cave == descent_access and current_cave_id == descent_access and not moving and _cave_at_position(unit_position) == descent_access and unit_position.distance_to(_level_access_position(descent_access)) <= 42.0

func _new_world(value: int) -> void:
	navigation_marker.clear()
	marker_return_pending=false
	defence_state=ExpeditionDefence.defaults()
	defence_system.reset()
	campaign_biome_order = CampaignRules.order_for_seed(value)
	if not expedition_record.is_empty():
		_remember_current_biology()
		if expedition_record.outcome == "En curs":
			_finish_expedition_record("Reiniciada")
		expedition_history.append(expedition_record)
	expedition_record = _new_expedition_record(value)
	starting_rewards_depth = deepest_reached
	expedition_completed = false
	depth_trip_target = -1
	owned_modifiers.clear()
	equipped_modifiers.clear()
	equipment_research_spent = 0
	supply_tiers.clear()
	ladder_uses_spent = 0
	rockfall_clear_remaining = 0.0
	health = 100.0
	medkits = 1 + int(starting_rewards_depth >= 16)
	rockfall_remaining = 0.0
	rockfall_cooldown = 0.0
	rockfall_corridor_id = -1
	for card in resource_gain_cards.values():
		card.queue_redraw()
	resource_gains.clear()
	resource_previous_counts.clear()
	isometric_passage_id = -1
	field_action_completed_until.clear()
	use_elevator_on_arrival = false
	inspect_on_cave_arrival = false
	center_map_during_move = false
	dragging = false
	_cancel_mining()
	_cancel_bio_scan()
	inactive_levels.clear()
	level_navigation_target = -1
	oxygen_seconds = _oxygen_capacity()
	walked_gallery_spans.clear()
	completed_gallery_traces.clear()
	deployed_beacons.clear()
	used_beacons.clear()
	seed_value = value
	var start_time := Time.get_ticks_msec()
	world = Generator.generate(seed_value)
	world["biome_profile"] = 1
	world["campaign_order_version"] = 1
	descent_access = _pick_descent_access()
	_place_descent_position()
	fauna_sites.clear()
	material_sites.clear()
	_place_flora_sites()
	_place_fauna_sites()
	_place_material_sites(true)
	_assign_mineral_types(1)
	collected_materials.clear()
	materials_in_pack = 0
	quartz_in_pack = 0
	magnetite_in_pack = 0
	crafted_beacons = 0
	oxygen_cartridges = int(starting_rewards_depth >= 13)
	flashlight_on = false
	flashlight_charge = _helmet_battery_duration()
	flashlight_spares = FLASHLIGHT_SPARE_BATTERIES + int(starting_rewards_depth >= 7)
	suit_integrity = 100.0
	suit_tier = 0
	mining_tool = 0
	mining_tool_integrity = 100.0
	equipped_boots = 0
	repair_kit_uses_spent = 0
	boots_integrity = 100.0
	analyzed_flora.clear()
	analyzed_fauna.clear()
	field_photos.clear()
	saved_photo_bytes.clear()
	seen_fauna.clear()
	selected_fauna = -1
	flora_samples.clear()
	fauna_samples.clear()
	bio_scanner_tier = 0
	bio_scanner_integrity = 100.0
	selected_flora = -1
	var elapsed := Time.get_ticks_msec() - start_time
	selected_cave = -1
	selected_cave_focus = Vector2.ZERO
	analysis_mode = false
	surface_mode = true
	current_level = 0
	unit_position = world.caves[world.entry].position
	move_target = unit_position
	moving = false
	move_path.clear()
	selected_route.clear()
	inspection_corridor_id = -1
	chained_cave_id = -1
	inspection_destination_cave_id = -1
	current_cave_id = world.entry
	discovered_exits.clear()
	cave_floor_textures.clear()
	explored_caves.clear()
	visited_caves.clear()
	detected_caves.clear()
	revealed_mask.resize(world.terrain_mask.size())
	revealed_mask.fill(0)
	last_revealed_cell = Vector2i(-1, -1)
	camera_offset = Vector2.ZERO
	if is_instance_valid(status_label):
		status_label.text = "LLAVOR %d · %d ms · %s" % [seed_value, elapsed, "RESERVA" if world.fallback else "P0B"]
	_update_map_stats()
	_update_view_mode_ui()
	camera_offset = -(unit_position - Generator.WORLD_RECT.size * 0.5) * zoom_level
	queue_redraw()

func _descend_to_level_one() -> void:
	if not surface_mode or world.is_empty() or death_dialog.visible:
		return
	surface_mode = false
	current_level = 1
	expedition_record.depth = maxi(int(expedition_record.depth), 1)
	analysis_mode = true
	selected_cave = world.entry
	current_cave_id = world.entry
	visited_caves[current_cave_id] = true
	unit_position = world.caves[world.entry].position
	selected_cave_focus = unit_position
	move_target = unit_position
	moving = false
	move_path.clear()
	selected_route.clear()
	zoom_level = _analysis_zoom_for_cave(selected_cave)
	if not explored_caves.has(current_cave_id):
		_reveal_around(unit_position, 5)
		_scan_current_cave()
	else:
		_update_map_stats()
	_focus_world_position(unit_position, zoom_level)
	_update_view_mode_ui()
	queue_redraw()
	_save_active_profile()

func _on_overlay_toggled(value: bool, overlay: String) -> void:
	match overlay:
		"graph": show_graph = value
		"contours": show_contours = value
		"spawn": show_spawn = value
		"signal_rings": show_signal_rings = value
		"beacon_waves": show_beacon_waves = value
		"findings": show_findings = value
	queue_redraw()

func _on_dev_mode_toggled(value: bool) -> void:
	dev_mode = value
	_update_map_stats()
	queue_redraw()

func _update_map_stats() -> void:
	if not is_instance_valid(cave_count_label) or world.is_empty():
		return
	var scanned_count := explored_caves.size()
	cave_count_label.text = "%d / %d" % [scanned_count, world.caves.size()] if dev_mode else str(scanned_count)
	_update_level_progress()
	_update_beacon_status()

func _update_level_progress() -> void:
	if not is_instance_valid(level_progress_strip) or world.is_empty():
		return
	var counts := _depth_discovery_counts(_level_snapshot())
	var overall := _overall_discovery(counts)
	level_progress_values[0].text = "%d%%" % floori(overall)
	level_progress_meters[0].value = overall
	_refresh_depth_selector()
	for index in range(counts.size()):
		var count: Vector2i = counts[index]
		level_progress_values[index + 1].text = _discovery_percentage(count)
		level_progress_meters[index + 1].value = 100.0 * count.x / maxi(1, count.y)

func _discovery_percentage(count: Vector2i) -> String:
	if count.y <= 0:
		return "—"
	return "%d%%" % floori(100.0 * float(count.x) / float(count.y))

func _input(event: InputEvent) -> void:
	_ensure_solid_room_rocks()
	if event is InputEventMouseMotion and not surface_mode:
		queue_redraw()
		_refresh_room_progress()
		if not dragging and not _over_ui(event.position):
			var hovered := _hovered_room(event.position)
			if hovered >= 0:
				room_details_panel.show()
				room_details_label.show()
				_update_room_details_card(hovered)
				_layout_catalogs_panel.call_deferred()
	if discovery_dialog.visible or delete_profile_dialog.visible:
		return
	if death_dialog.visible or victory_dialog.visible or profiles_dialog.visible or depth_trip_dialog.visible or restart_run_dialog.visible or rewards_dialog.visible or history_dialog.visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var focus := get_viewport().gui_get_focus_owner()
		if not focus is LineEdit and not focus is TextEdit:
			if event.keycode==KEY_F:
				defence_system.fire(self)
				return
			if event.keycode==KEY_F8:
				_recover_stuck_explorer()
				return
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT and event.ctrl_pressed and not _over_ui(event.position):
		var hostile := defence_system.predator(self,_cave_at_position(unit_position))
		if not hostile.is_empty() and defence_system.sprite_rect(self,hostile.position).has_point(event.position): defence_system.fire(self)
		return
	if surface_mode:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not _over_ui(event.position):
			if Geometry2D.is_point_in_polygon(event.position, _elevator_outline(_surface_hatch_center(), _surface_elevator_extent())):
				_descend_to_level_one()
			else:
				var action: String = surface_base_art.module_action_at(event.position, _surface_hatch_center(), _surface_art_scale())
				match action:
					"inventory": _open_inventory(false)
					"catalog": _open_flora_catalog()
					"workshop": _open_inventory(true)
				if not action.is_empty() and is_instance_valid(game_audio): game_audio.play("ui")
		elif event is InputEventKey and event.pressed and (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER):
			_descend_to_level_one()
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_at(event.position, 1.16)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_at(event.position, 1.0 / 1.16)
		elif event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			center_map_during_move = false
			dragging = true
			drag_origin = event.position
		elif event.button_index == MOUSE_BUTTON_MIDDLE and not event.pressed:
			dragging = false
		elif event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
			dragging=false
		elif event.pressed and not _over_ui(event.position) and (event.button_index==MOUSE_BUTTON_RIGHT or (event.button_index==MOUSE_BUTTON_LEFT and analysis_mode and not _exit_marker_order(_screen_to_world(event.position)).is_empty())):
			var ground := _screen_to_world(event.position)
			var empty := _cave_at_position(ground)<0
			if analysis_mode and not _exit_marker_order(ground).is_empty(): empty=false
			if empty:
				for corridor in world.get("corridors",[]):
					if _distance_to_polyline(ground,corridor.points)<=float(corridor.width)*0.5: empty=false; break
			if empty:
				center_map_during_move=false
				dragging=true
				drag_origin=event.position
				return
			if rockfall_clear_remaining > 0.0:
				return
			if analysis_mode and moving and inspection_corridor_id >= 0 and _cave_at_position(unit_position) < 0:
				return
			if mining_cave >= 0:
				status_label.text = "EXTRACCIÓ EN CURS · ESPERA QUE ACABI"
				return
			if bio_scan_room >= 0:
				status_label.text = "ESCANEIG EN CURS · ESPERA QUE ACABI"
				return
			var clicked_point := _screen_to_world(event.position)
			var order := _resolve_order_target(clicked_point)
			if not order.is_empty():
				var destination := int(order.get("inspection_cave_id", -1))
				var corridor_id := int(order.get("corridor_id", -1))
				if corridor_id < 0 and int(order.cave_id) >= 0:
					corridor_id = _known_exit_corridor(_screen_to_world(event.position))
				var can_light_gallery := flashlight_on or (helmet_light_zone_lit and flashlight_charge > 0.0)
				if corridor_id >= 0 and not can_light_gallery and not _gallery_has_lamps(_corridor_by_id(corridor_id)):
					_show_light_warning(event.position, "GALERIA A LES FOSQUES")
					return
				if order.has("explore_room") and not flashlight_on and not _room_is_fully_lit(selected_cave) and not _is_revealed(clicked_point):
					_show_light_warning(event.position, "TERRENY DESCONEGUT")
				if destination >= 0 and destination != current_cave_id and not _can_enter_room_with_signal(destination, corridor_id):
					status_label.text = "FORA D’ABAST · CAL UNA BALISA"
					return
				var path := _path_for_order(order)
				if not path.is_empty():
					var rockfall_warned := not moving and _warn_of_rockfall(corridor_id)
					if rockfall_warned and not analysis_mode:
						return
					use_elevator_on_arrival = false
					level_navigation_target = -1
					depth_trip_target = -1
					inspection_destination_cave_id = int(order.get("inspection_cave_id", -1))
					inspect_on_cave_arrival = inspection_destination_cave_id >= 0 and (not analysis_mode or bool(order.get("room_click", false)))
					inspection_corridor_id = int(order.get("corridor_id", -1)) if analysis_mode else -1
					if analysis_mode and bool(order.get("room_click", false)):
						isometric_passage_id = -1
						if selected_cave != current_cave_id:
							selected_cave = current_cave_id
							_update_view_mode_ui()
					chained_cave_id = int(order.cave_id)
					chained_arrival = world.caves[chained_cave_id].position if chained_cave_id >= 0 else Vector2.ZERO
					move_path = path
					selected_route = path.duplicate()
					move_target = move_path.back()
					moving = true
					warned_dark_movement = false
					if corridor_id >= 0 and not rockfall_warned:
						status_label.text = "TRAVESSANT LA GALERIA"
				elif bool(order.get("room_click", false)):
					status_label.text = "CAP RUTA PER GALERIES RECORREGUDES"
				elif order.has("corridor_id"):
					status_label.text = "CAP PAS TRANSITABLE PER AQUESTA GALERIA"
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not _over_ui(event.position):
			if defence_system.recover_click(self,event.position): return
			if _try_click_biome_base(event.position):
				return
			if _try_click_mineral(event.position):
				return
			if _clear_rockfall_at(event.position):
				return
			if rockfall_clear_remaining > 0.0:
				return
			if analysis_mode:
				if _has_level_elevator(selected_cave) and (Geometry2D.is_point_in_polygon(
						event.position, _elevator_outline(_world_to_screen(_level_access_position(selected_cave)), _underground_elevator_extent())) or _descent_shaft_hit(event.position,selected_cave)):
					_approach_level_access(true)
					return
				_select_flora(event.position)
			else:
				_select_cave(event.position)
	elif event is InputEventMouseMotion and dragging:
		camera_offset += event.relative
		queue_redraw()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		center_map_during_move = false
		dragging = true
	elif event is InputEventKey and not event.pressed and event.keycode == KEY_SPACE:
		dragging = false
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and analysis_mode:
		_exit_inspection()

func _zoom_at(screen_position: Vector2, factor: float) -> void:
	center_map_during_move = false
	var before := _screen_to_world(screen_position)
	zoom_level = clampf(zoom_level * factor, 0.28 if analysis_mode else minf(zoom_level, MAP_MIN_ZOOM), 8.0)
	var projected_after := _world_to_screen(before)
	camera_offset += screen_position - projected_after
	queue_redraw()

func _select_cave(screen_position: Vector2) -> void:
	var point := _screen_to_world(screen_position)
	var occupied_cave := _cave_at_position(unit_position)
	if occupied_cave >= 0 and screen_position.distance_to(_world_to_screen(unit_position)) <= 14.0:
		_inspect_map_room(occupied_cave, unit_position)
		return
	var clicked_cave := _cave_at_position(point)
	if clicked_cave >= 0 and _can_inspect_cave(clicked_cave) and (_should_draw_cave(clicked_cave) or _is_revealed(point)):
		var focus: Vector2 = world.caves[clicked_cave].position if _should_draw_cave(clicked_cave) else point
		_inspect_map_room(clicked_cave, focus)
		return
	var nearest := -1
	var nearest_focus := Vector2.ZERO
	var distance := 95.0 / zoom_level
	for cave in world.caves:
		if not _can_inspect_cave(cave.id):
			continue
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
		_inspect_map_room(nearest, nearest_focus)

func _inspect_map_room(cave_id: int, focus: Vector2, zoom_factor: float = 1.0) -> void:
	selected_cave = cave_id
	selected_cave_focus = focus
	center_map_during_move = false
	analysis_mode = true
	selected_route.clear()
	zoom_level = _analysis_zoom_for_cave(cave_id) * zoom_factor
	_update_view_mode_ui()
	_focus_world_position(focus, zoom_level)

func _can_inspect_cave(cave_id: int) -> bool:
	return visited_caves.has(cave_id) or explored_caves.has(cave_id)

func _focus_selected_cave() -> void:
	var occupied_cave := _cave_at_position(unit_position)
	if occupied_cave >= 0:
		_inspect_map_room(occupied_cave, unit_position, 0.8)
		return
	status_label.text = "ARRIBA A UNA SALA PER INSPECCIONAR-LA"

func _focus_cave(cave_id: int, requested_zoom: float) -> void:
	if cave_id < 0 or cave_id >= world.caves.size():
		return
	_focus_world_position(world.caves[cave_id].position, requested_zoom)

func _center_isometric_explorer() -> void:
	if not analysis_mode or current_cave_id < 0 or current_cave_id >= world.caves.size():
		return
	dragging = false
	if selected_cave != current_cave_id:
		_inspect_map_room(current_cave_id, unit_position)
	else:
		_focus_world_position(unit_position, zoom_level)

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
	var available_size := _view_rect().size * Vector2(0.72, 0.76)
	var horizontal_fit := available_size.x / maxf(bounds.size.x, 1.0)
	var vertical_fit := available_size.y / maxf(bounds.size.y, 1.0)
	return clampf(minf(horizontal_fit, vertical_fit), ANALYSIS_MIN_ZOOM, ANALYSIS_MAX_ZOOM) * ANALYSIS_ENTRY_ZOOM_FACTOR

func _update_view_mode_ui() -> void:
	if not is_instance_valid(mode_heading_label):
		return
	_update_oxygen_display()
	base_catalog_button.show()
	_update_research_panel()
	if surface_mode:
		mode_heading_label.text = "BASE MARCIANA · SUPERFÍCIE 0"
		seed_edit.visible = false
		new_game_button.visible = false
		map_return_button.visible = false
		descend_button.visible = true
		status_label.text = "SUPERFÍCIE · ACCÉS A COVES DISPONIBLE"
	elif analysis_mode and selected_cave >= 0 and selected_cave < world.caves.size():
		mode_heading_label.text = "%s · %d · Sala %02d" % [_profile_biome_name(current_level), -current_level, selected_cave + 1]
		seed_edit.visible = false
		new_game_button.visible = false
		map_return_button.visible = true
		descend_button.visible = false
		if selected_cave == current_cave_id and not explored_caves.has(selected_cave):
			status_label.text = "SALA EN EXPLORACIÓ"
		elif not explored_caves.has(selected_cave):
			status_label.text = "SENYAL DE COVA · EXPLORACIÓ PENDENT" if detected_caves.has(selected_cave) else "FRAGMENT VISIBLE · SALA NO ESCANEJADA"
		elif selected_cave == current_cave_id:
			status_label.text = "SALA ACTUAL · EXPLORADA"
		else:
			status_label.text = "SALA EXPLORADA · VISUALITZACIÓ"
	else:
		analysis_mode = false
		mode_heading_label.text = "MAPA DE RECERCA   /   ESTRAT %d" % -current_level
		seed_edit.visible = true
		new_game_button.visible = true
		map_return_button.visible = false
		descend_button.visible = false
	if is_instance_valid(level_panel):
		level_panel.visible = not surface_mode
		level_progress_strip.visible = not surface_mode
	_update_beacon_status()
	level_title_label.visible = not surface_mode
	_layout_panels.call_deferred()
	if not surface_mode:
		var zone := _profile_biome_name(current_level)
		level_title_label.text = "%s · Estrat −%d" % [zone, current_level]
	_update_flora_button()
	_layout_catalogs_panel()
	_refresh_depth_selector()
	_refresh_room_progress()
	if is_instance_valid(base_return_button):
		base_return_button.visible = not surface_mode and current_level > 0
		_update_base_return_availability()

func _hud_room_id() -> int:
	return selected_cave if analysis_mode else _cave_at_position(unit_position)

func _refresh_room_progress() -> void:
	if not is_instance_valid(room_progress_label):
		return
	var cave_id := -1 if surface_mode or world.is_empty() else _hud_room_id()
	room_progress_label.visible = not surface_mode and (cave_id >= 0 or moving)
	var details_were_visible := room_details_panel.visible
	room_details_label.visible = room_progress_label.visible and cave_id >= 0
	room_details_panel.visible = room_details_label.visible
	if details_were_visible != room_details_panel.visible:
		_layout_catalogs_panel.call_deferred()
	room_details_label.text = ""
	room_progress_label.queue_redraw()
	if not room_progress_label.visible:
		return
	if cave_id < 0 or (analysis_mode and moving and _cave_at_position(unit_position) < 0):
		room_progress_label.text = "GALERIA"
		room_details_label.hide()
		room_details_panel.hide()
		_layout_catalogs_panel.call_deferred()
		return
	var environment := _room_environment(cave_id)
	var title := "SALA"
	match environment:
		"aigua": title = "SALA INUNDADA"
		"gel": title = "SALA GELADA"
		"calent": title = "SALA CALENTA"
	var explored_percent := 100 if explored_caves.has(cave_id) else floori(_room_reveal_ratio(world.caves[cave_id]) * 100.0)
	room_progress_label.text = "%s %02d · %d%% ESCANEJAT" % [title, cave_id + 1, explored_percent]
	if _is_biome_workshop(cave_id):
		room_progress_label.text += " · BASE"
	if room_details_label.visible:
		_update_room_details_card(cave_id)

func _update_room_details_card(cave_id: int) -> void:
	var scanned := explored_caves.has(cave_id)
	var progress := _room_tasks(cave_id)
	var percent := floori(100.0 * progress.x / maxi(1, progress.y)) if scanned else floori(_room_reveal_ratio(world.caves[cave_id]) * 100.0)
	var complete := _room_is_complete(cave_id)
	room_details_status.text = "SALA %02d · %s · %d%%" % [cave_id + 1, "Completa" if complete else ("Tasques" if scanned else "Escaneig"), percent]
	room_details_status.add_theme_color_override("font_color", Color("ffd17e") if complete else CYAN)
	room_details_meter.value = percent
	var lines := _room_detail_lines(cave_id)
	var signature := str([cave_id, lines])
	if signature == room_details_signature:
		return
	room_details_signature = signature
	room_details_label.text = ""
	for child in room_details_rows.get_children():
		room_details_rows.remove_child(child)
		child.queue_free()
	for line in lines:
		var done := line in ["Escaneig complet", "Flora analitzada", "Fauna observada", "Veta extreta"] or line.begins_with("Equip preparat")
		if line.begins_with("Galeries recorregudes"):
			var galleries := _room_gallery_progress(cave_id)
			done = galleries.x == galleries.y
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		room_details_rows.add_child(row)
		var icon := Control.new()
		icon.custom_minimum_size = Vector2(17, 18)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(icon)
		icon.draw.connect(_draw_room_register_indicator.bind(icon, done))
		var label := _add_equipment_label(row, line, 12, Color("c6dadd"))
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _draw_room_register_indicator(icon: Control, done: bool) -> void:
	var color := Color("32f36a") if done else Color("526e79")
	var edge := PackedVector2Array([Vector2(5, 2), Vector2(12, 2), Vector2(15, 5), Vector2(15, 12), Vector2(12, 15), Vector2(5, 15), Vector2(2, 12), Vector2(2, 5), Vector2(5, 2)])
	icon.draw_polyline(edge, color, 2.0, false)
	if done:
		icon.draw_polyline(PackedVector2Array([Vector2(5, 8), Vector2(8, 11), Vector2(16, 3)]), color, 2.0, false)

func _draw_room_register_frame() -> void:
	_draw_register_panel_frame(room_details_panel)

func _draw_register_panel_frame(panel: Control) -> void:
	var edge := _inventory_frame_outline(Rect2(Vector2.ONE, panel.size - Vector2(2, 2)), 8)
	panel.draw_colored_polygon(edge, Color("050e12"))
	edge.append(edge[0])
	panel.draw_polyline(edge, Color("527f89"), 2.0, false)
	panel.draw_rect(Rect2(16, 38, panel.size.x - 32, 1), Color("16404a"))
	panel.draw_rect(Rect2(16, 38, 82, 1), CYAN)

func _return_to_map(requested_zoom: float = 0.62) -> void:
	isometric_passage_id = -1
	center_map_during_move = false
	use_elevator_on_arrival = false
	analysis_mode = false
	inspect_on_cave_arrival = false
	inspection_corridor_id = -1
	selected_cave = -1
	selected_cave_focus = Vector2.ZERO
	selected_route.clear()
	zoom_level = requested_zoom
	_focus_world_position(unit_position, requested_zoom)
	_update_view_mode_ui()
	queue_redraw()

func _return_to_surface_base() -> void:
	if not _can_return_to_base():
		return
	for samples in [flora_samples, fauna_samples]:
		for cave_id in samples:
			samples[cave_id] = true
	for state in inactive_levels.values():
		for samples in [state.flora_samples, state.get("fauna_samples", {})]:
			for cave_id in samples:
				samples[cave_id] = true
	_enter_surface_base()

func _expedition_emergency() -> String:
	if health <= 0.0:
		return "FERIDES MORTALS"
	if suit_integrity <= 0.0:
		return "VESTIT ESPACIAL MALMÈS"
	if flashlight_charge <= 0.0 and flashlight_spares <= 0 and not _room_is_fully_lit(_cave_at_position(unit_position)) and not _point_in_lit_gallery(unit_position):
		return "SENSE BATERIES DEL CASC"
	return ""

func _death_summary(reason: String) -> String:
	return "%s\n\nL’expedició s’ha acabat. Els materials que portaves es perden i no es poden recuperar. La pròxima sortida començarà en un món nou. Conserves el catàleg i les descobertes del perfil. L’equip torna al nivell 1, sense modificadors de l’expedició anterior." % reason

func _end_expedition(reason: String) -> void:
	if death_dialog.visible:
		return
	_finish_expedition_record("Mort", reason)
	_cancel_mining()
	_cancel_bio_scan()
	death_dialog.dialog_text = _death_summary(reason)
	materials_in_pack = 0
	quartz_in_pack = 0
	magnetite_in_pack = 0
	death_dialog.popup_centered(Vector2i(440, 0))
	_save_active_profile()

func _restart_after_death() -> void:
	if expedition_record.get("outcome","")!="Mort": return
	death_dialog.hide()
	_start_run_with_new_seed()
	_enter_surface_base()
	_save_active_profile()

func _start_run_with_new_seed() -> void:
	var next_seed := randi_range(0, 0x7fffffff)
	if next_seed == seed_value:
		next_seed = (seed_value + 1) & 0x7fffffff
	seed_edit.text = str(next_seed)
	_new_world(next_seed)

func _enter_surface_base() -> void:
	rockfall_clear_remaining = 0.0
	flashlight_on = false
	helmet_light_zone_lit = true
	surface_mode = true
	current_level = 0
	analysis_mode = false
	selected_cave = -1
	selected_cave_focus = Vector2.ZERO
	moving = false
	move_path.clear()
	selected_route.clear()
	chained_cave_id = -1
	_update_view_mode_ui()
	_update_equipment_display()
	queue_redraw()
	_save_active_profile()

func _update_oxygen_display() -> void:
	if not inventory_strip_meters.has(STRIP_OXYGEN_SLOT):
		return
	var ratio := oxygen_seconds / _oxygen_capacity()
	inventory_strip_meters[STRIP_OXYGEN_SLOT].value = ratio * 100.0
	var label := inventory_strip_values[STRIP_OXYGEN_SLOT]
	var percent := ceili(ratio * 100.0)
	var caption := "Nv. %d · %d%%" % [_supply_tier("oxygen_tank") + 1, percent]
	if label.text != caption:
		label.text = caption
		label.add_theme_color_override("font_color", ORANGE if percent <= LOW_SUPPLY_PERCENT else CYAN)
func _request_depth_trip(destination: int) -> void:
	var workshop_trip := _depth_has_workshop(destination)
	if destination == current_level and not workshop_trip:
		return
	if destination > CAMPAIGN_DEPTH:
		status_label.text = "ESTRAT −%d ENCARA NO DISPONIBLE" % destination
		return
	if mining_cave >= 0 or bio_scan_room >= 0 or rockfall_clear_remaining > 0.0 or level_navigation_target >= 0:
		status_label.text = "ACABA L’ACCIÓ EN CURS ABANS DE CANVIAR D’ESTRAT"
		return
	var going_down := destination > current_level
	var depth := maxi(1, current_level)
	var origin := current_cave_id if current_level > 0 else int(world.entry)
	var distance := 0.0
	var suit_wear := 0.0
	var ladders_needed := 0
	var rockfall_on_route := false
	while depth != destination and depth > 0:
		var state := _depth_state(depth)
		var target: int = state.descent_access if going_down else state.world.entry
		if going_down and not state.explored_caves.has(target):
			status_label.text = "PRIMER HAS DE DESCOBRIR L’ACCÉS A L’ESTRAT −%d" % (depth + 1)
			return
		var leg := _known_depth_leg(state, origin, target)
		if leg.is_empty():
			status_label.text = "CAP RUTA PER GALERIES RECORREGUDES FINS A L’ACCÉS"
			return
		var leg_distance: float = leg.distance
		if depth == current_level:
			leg_distance += unit_position.distance_to(state.world.caves[origin].position)
		distance += leg_distance
		var seconds := leg_distance / maxf(1.0, _boots_speed(equipped_boots) * 0.7 * 0.75)
		var pressure: float = [0.0, 0.03, 0.10, 0.15][mini(depth, 3)]
		suit_wear += seconds * (pressure * (1.0 - float(suit_tier) * 0.04) + (0.06 if depth >= 2 else 0.0))
		rockfall_on_route = rockfall_on_route or bool(leg.blocked)
		depth += 1 if going_down else -1
		if depth <= 0:
			break
		var next := _depth_state(depth)
		if next.is_empty():
			ladders_needed += 1
			if depth != destination:
				status_label.text = "PRIMER HAS D’EXPLORAR L’ESTRAT −%d" % depth
				return
			break
		origin = int(next.world.entry if going_down else next.descent_access)
	var destination_state := _depth_state(destination)
	if workshop_trip and not destination_state.is_empty() and origin != destination_state.world.entry:
		var leg := _known_depth_leg(destination_state, origin, int(destination_state.world.entry))
		if leg.is_empty():
			status_label.text = "CAP RUTA PER GALERIES RECORREGUDES FINS A LA BASE"
			return
		var workshop_distance: float = leg.distance
		if current_level == destination:
			workshop_distance += unit_position.distance_to(destination_state.world.caves[origin].position)
		distance += workshop_distance
		var pressure: float = [0.0, 0.03, 0.10, 0.15][mini(destination, 3)]
		suit_wear += workshop_distance / maxf(1.0, _boots_speed(equipped_boots) * 0.7 * 0.75) * (pressure + 0.06)
		rockfall_on_route = rockfall_on_route or bool(leg.blocked)
	if ladders_needed > _ladder_uses_left():
		status_label.text = "ESCALA ESGOTADA · REPARA-LA A LA BASE"
		return
	var warnings := PackedStringArray()
	var travel_seconds := distance / maxf(1.0, _boots_speed(equipped_boots) * 0.7 * 0.75)
	var available_oxygen := oxygen_seconds + oxygen_cartridges * (OXYGEN_CARTRIDGE_SECONDS + _supply_bonus("oxygen_reserve"))
	if travel_seconds > 0.0 and travel_seconds + 15.0 >= available_oxygen:
		warnings.append("L’oxigen i les reserves podrien esgotar-se durant el trajecte.")
	if distance > 0.0 and distance * BOOT_WEAR_PER_UNIT * 1.8 >= boots_integrity:
		warnings.append("Les botes es podrien trencar abans d’arribar.")
	if suit_wear > 0.0 and suit_wear >= suit_integrity:
		warnings.append("El vestit podria esgotar-se abans d’arribar.")
	if not surface_mode and flashlight_charge <= 0.0 and flashlight_spares <= 0 and not _room_is_fully_lit(_cave_at_position(unit_position)) and not _point_in_lit_gallery(unit_position):
		warnings.append("Ets en una zona fosca i no tens bateria ni recanvis per al llum del casc.")
	if rockfall_on_route:
		warnings.append("Hi ha un despreniment pel camí. Hauràs de retirar les roques.")
	_confirm_depth_action(destination, _begin_depth_trip.bind(destination), warnings, workshop_trip)

func _confirm_depth_action(destination: int, action: Callable, warnings: PackedStringArray = PackedStringArray(), workshop_trip: bool = false) -> void:
	var message := "Vols tornar a la base?"
	if workshop_trip:
		message = "Vols anar a «%s» (estrat −%d)?" % [_biome_base_name(destination), destination]
	elif destination > 0:
		var direction := "pujar" if destination < current_level else "baixar"
		message = "Vols %s a l’estrat −%d?" % [direction, destination]
	if not warnings.is_empty():
		message += "\n\n" + "\n\n".join(warnings)
	pending_depth_action = action
	depth_trip_dialog.dialog_text = message
	depth_trip_dialog.popup_centered(Vector2i(450, 0))

func _known_depth_leg(state: Dictionary, source: int, target: int) -> Dictionary:
	var caves: Array = state.world.caves
	if source < 0 or target < 0 or source >= caves.size() or target >= caves.size():
		return {}
	var distances := {source: 0.0}
	var blocked := {source: false}
	var frontier: Array[int] = [source]
	while not frontier.is_empty():
		var nearest := 0
		for index in range(1, frontier.size()):
			if distances[frontier[index]] < distances[frontier[nearest]]:
				nearest = index
		var room: int = frontier.pop_at(nearest)
		if room == target:
			return {"distance": distances[room], "blocked": blocked[room]}
		for corridor in state.world.corridors:
			if not state.completed_gallery_traces.has(corridor.id) or (corridor.a != room and corridor.b != room):
				continue
			var neighbor: int = corridor.b if corridor.a == room else corridor.a
			var points: PackedVector2Array = corridor.points
			var length := 0.0
			for index in range(1, points.size()):
				length += points[index - 1].distance_to(points[index])
			var candidate: float = distances[room] + maxf(length, caves[room].position.distance_to(caves[neighbor].position)) * 1.2
			if candidate >= float(distances.get(neighbor, INF)):
				continue
			distances[neighbor] = candidate
			blocked[neighbor] = blocked[room] or corridor.id == state.rockfall_corridor_id
			if not frontier.has(neighbor):
				frontier.append(neighbor)
	return {}

func _begin_depth_trip(destination: int) -> void:
	depth_trip_target = destination
	_continue_depth_trip()

func _continue_depth_trip() -> void:
	if depth_trip_target < 0:
		return
	if current_level == depth_trip_target:
		if marker_return_pending and int(navigation_marker.get("level",-1))==current_level:
			depth_trip_target=-1
			marker_return_pending=false
			_return_to_navigation_marker()
			return
		if _depth_has_workshop(current_level):
			_start_level_navigation(int(world.entry))
			if moving:
				return
		depth_trip_target = -1
		return
	if surface_mode:
		_descend_to_level_one()
		_continue_depth_trip.call_deferred()
		return
	var previous_depth := current_level
	var access := descent_access if depth_trip_target > current_level else int(world.entry)
	_start_level_navigation(access)
	if not moving and current_level == previous_depth:
		depth_trip_target = -1
		marker_return_pending=false

func _start_return_to_base() -> void:
	depth_trip_target = -1
	if not world.is_empty():
		_start_level_navigation(world.entry)

func _start_descent_navigation() -> void:
	depth_trip_target = -1
	if _has_descent_elevator(descent_access):
		_start_level_navigation(descent_access)

func _start_level_navigation(target: int) -> void:
	if surface_mode or level_navigation_target >= 0 or mining_cave >= 0 or bio_scan_room >= 0 or rockfall_clear_remaining > 0.0:
		return
	var going_up: bool = target == world.entry
	if not going_up and not _biome_exit_is_ready():
		_notice_biome_exit_requirement()
		return
	if not going_up and _is_unopened_shaft(target) and _ladder_uses_left() <= 0:
		status_label.text = "ESCALA ESGOTADA · REPARA-LA A LA BASE"
		return
	var access_position := _level_access_position(target)
	if _cave_at_position(unit_position) == target and unit_position.distance_to(access_position) <= 42.0:
		moving = false
		move_path.clear()
		_finish_level_navigation(target)
		return
	var reachable := _reachable_revealed_cells(unit_position, true, true)
	var cell := _nearest_revealed_walkable_in_cave(target, access_position, reachable)
	var path: Array[Vector2] = []
	if cell.x >= 0:
		var arrival := (Vector2(cell) + Vector2.ONE * 0.5) * float(world.cell_size)
		if arrival.distance_to(access_position) <= 42.0:
			path = _find_path(unit_position, arrival, {}, true, -1, true)
	if path.is_empty():
		status_label.text = "CAP CAMÍ CONEGUT FINS A L’ACCÉS"
		return
	_return_to_map(MAP_ENTRY_ZOOM)
	chained_cave_id = -1
	move_path = path
	move_target = path.back()
	level_navigation_target = target
	center_map_during_move = true
	moving = true
	status_label.text = "CAMINANT CAP A LA BASE DEL BIOMA" if going_up and depth_trip_target == current_level else ("CAMINANT CAP A LA PUJADA" if going_up else "CAMINANT CAP A LA BAIXADA")
	_update_base_return_availability()

func _finish_level_navigation(target: int) -> void:
	if _cave_at_position(unit_position) != target:
		depth_trip_target = -1
		return
	if target == world.entry:
		if depth_trip_target == current_level and _depth_has_workshop(current_level):
			depth_trip_target = -1
			_inspect_map_room(target, unit_position)
			status_label.text = _biome_base_name(current_level) + " · Obre Equip i millores"
			_save_active_profile()
			return
		_finish_return_to_entry()
	elif _has_descent_elevator(target):
		_inspect_map_room(target, unit_position)
		_descend_to_lower_level()
	if depth_trip_target >= 0:
		_continue_depth_trip.call_deferred()

func _finish_return_to_entry() -> void:
	if current_level > 1 and _cave_at_position(unit_position) == world.entry:
		var upper: Dictionary = inactive_levels[current_level - 1]
		_change_underground_level(current_level - 1, int(upper.descent_access))
	elif current_level == 1:
		_return_to_surface_base()

func _can_return_to_base() -> bool:
	return not surface_mode and current_level == 1 and current_cave_id == world.entry and _cave_at_position(unit_position) == world.entry and not moving

func _current_biome_base_depth() -> int:
	# The final core has no workshop: its return base remains the Threshold.
	return 19 if current_level >= 19 else CampaignRules.block_start(current_level)

func _update_base_return_availability() -> void:
	if not is_instance_valid(base_return_button):
		return
	var busy := surface_mode or level_navigation_target >= 0 or mining_cave >= 0 or bio_scan_room >= 0 or rockfall_clear_remaining > 0.0
	base_return_button.disabled = busy
	biome_base_return_button.disabled = busy
	biome_base_return_button.visible = not surface_mode and current_level > 0
	biome_base_return_button.tooltip_text = "Torna a la base de %s per una ruta coneguda." % _profile_biome_name(_current_biome_base_depth())
	descend_navigation_button.disabled = busy
	for button in [base_return_button, descend_navigation_button, biome_base_return_button]:
		if button.get_parent() != navigation_panel:
			button.reparent(navigation_panel, false)
	var has_descent := not surface_mode and _has_descent_elevator(descent_access)
	base_return_button.text = "PUJA A L’ESTRAT %d" % -(current_level - 1) if current_level > 1 else "TORNA A LA BASE"
	base_return_button.tooltip_text = "Camina fins a l’accés superior i puja."
	descend_navigation_button.visible = has_descent
	descend_navigation_button.text = "BAIXA A L’ESTRAT %d" % -(current_level + 1)
	descend_navigation_button.tooltip_text = "Camina fins a l’accés inferior descobert i baixa."
	var final_research := _can_complete_final_research()
	lower_level_button.visible = final_research or _can_use_selected_level_access()
	base_return_button.visible = not surface_mode and current_level > 0 and not (
		lower_level_button.visible and selected_cave == world.entry)
	if lower_level_button.visible:
		if selected_cave != world.entry:
			descend_navigation_button.hide()
		lower_level_button.text = ("VEURE EL FINAL" if expedition_completed else "INVESTIGA EL NUCLI") if final_research else (("↑ " if selected_cave == world.entry else "↓ ") + _level_access_label(selected_cave))
		lower_level_button.tooltip_text = ""
		if not final_research and selected_cave!=world.entry and not _biome_exit_is_ready():
			lower_level_button.text = "↓ EQUIP PENDENT"
			lower_level_button.tooltip_text = _biome_exit_requirement()
	_layout_room_controls()

func _can_complete_final_research() -> bool:
	return analysis_mode and not moving and mining_cave < 0 and bio_scan_room < 0 and rockfall_clear_remaining <= 0.0 and _is_final_room(selected_cave) and explored_caves.has(selected_cave) and _cave_at_position(unit_position) == selected_cave

func _complete_final_research() -> void:
	if not _can_complete_final_research():
		return
	expedition_completed = true
	_finish_expedition_record("Completada")
	_update_base_return_availability()
	_save_active_profile()
	victory_dialog.popup_centered(Vector2i(460, 0))

func _can_use_selected_level_access() -> bool:
	if surface_mode or not analysis_mode or moving or mining_cave >= 0 or bio_scan_room >= 0 or not _has_level_elevator(selected_cave):
		return false
	if selected_cave != world.entry:
		return _at_lower_level_access()
	return current_cave_id == selected_cave and _cave_at_position(unit_position) == selected_cave and unit_position.distance_to(world.caves[selected_cave].position) <= 42.0

func _use_selected_level_access() -> void:
	if not _can_use_selected_level_access():
		return
	if selected_cave == world.entry:
		_finish_return_to_entry()
	else:
		_descend_to_lower_level()

func _approach_level_access(use_on_arrival: bool = false) -> void:
	if current_cave_id != selected_cave or mining_cave >= 0 or bio_scan_room >= 0:
		return
	if _can_use_selected_level_access():
		if use_on_arrival:
			_use_selected_level_access()
		else:
			lower_level_button.grab_focus()
		return
	var hatch := _level_access_position(selected_cave)
	var path := _find_path(unit_position, hatch, {}, false, selected_cave)
	if path.is_empty() or path.back().distance_to(hatch) > 42.0:
		status_label.text = "CAP CAMÍ TRANSITABLE FINS A L’ACCÉS"
		return
	level_navigation_target = -1
	use_elevator_on_arrival = use_on_arrival
	chained_cave_id = -1
	inspection_corridor_id = -1
	inspection_destination_cave_id = -1
	inspect_on_cave_arrival = false
	move_path = path
	selected_route = path.duplicate()
	move_target = path.back()
	moving = true
	status_label.text = "CAMINANT CAP A L’ACCÉS"
	_update_base_return_availability()

func _exit_inspection() -> void:
	if not analysis_mode:
		return
	_return_to_map(MAP_ENTRY_ZOOM)
	dragging = false
	center_map_during_move = moving

func _path_prefix_inside_cave(path: Array[Vector2], from: Vector2, cave_id: int) -> Array[Vector2]:
	var safe_path: Array[Vector2] = []
	if cave_id < 0 or cave_id >= world.caves.size():
		return safe_path
	var previous := from
	for destination in path:
		var distance: float = previous.distance_to(destination)
		var steps: int = maxi(1, ceili(distance / maxf(1.0, world.cell_size * 0.25)))
		var segment_is_inside := true
		for step in range(1, steps + 1):
			var point := previous.lerp(destination, float(step) / float(steps))
			if not _point_inside_cave_id(point, cave_id):
				segment_is_inside = false
				break
		if not segment_is_inside:
			break
		safe_path.append(destination)
		previous = destination
	return safe_path

func _point_inside_cave_id(point: Vector2, cave_id: int) -> bool:
	var cave: Dictionary = world.caves[cave_id]
	return Geometry2D.is_point_in_polygon(point - cave.position, cave.contour)

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

func _place_navigation_marker() -> void:
	if surface_mode or death_dialog.visible: return
	navigation_marker={"seed":seed_value,"level":current_level,"position":unit_position}
	marker_return_pending=false
	_layout_room_controls()
	_action_notice("MARCADOR GUARDAT · Estrat −%d" % current_level)
	_save_active_profile()
	queue_redraw()

func _return_to_navigation_marker() -> void:
	if navigation_marker.is_empty() or int(navigation_marker.get("seed",-1))!=seed_value: return
	if death_dialog.visible or mining_cave>=0 or bio_scan_room>=0: return
	moving=false
	move_path.clear()
	selected_route.clear()
	level_navigation_target=-1
	chained_cave_id=-1
	if current_level!=int(navigation_marker.level) or surface_mode:
		marker_return_pending=true
		_begin_depth_trip(int(navigation_marker.level))
		return
	marker_return_pending=false
	var target: Vector2=navigation_marker.position
	if unit_position.distance_to(target)<1.0:
		_action_notice("JA ETS AL MARCADOR")
		return
	var path := _find_path(unit_position,target,{},true)
	var last: Vector2=path.back() if not path.is_empty() else unit_position
	if path.is_empty() or not _segment_is_walkable(last,target):
		_action_notice("NO HI HA CAP CAMÍ CONEGUT FINS AL MARCADOR")
		return
	path.append(target)
	var previous := unit_position
	for point in path:
		var steps := maxi(1,ceili(previous.distance_to(point)/2.0))
		for step in range(steps+1):
			var sample: Vector2=previous.lerp(point,float(step)/steps)
			if not _segment_is_walkable(sample,sample) or not _is_known_room_route_point(sample):
				_action_notice("NO HI HA CAP CAMÍ DESCOBERT FINS AL MARCADOR")
				return
		previous=point
	_return_to_map(zoom_level if not analysis_mode else MAP_ENTRY_ZOOM)
	level_navigation_target=-1
	depth_trip_target=-1
	chained_cave_id=-1
	move_path=path
	selected_route=path.duplicate()
	move_target=target
	moving=true
	status_label.text="TORNANT AL MARCADOR PELS CAMINS CONEGUTS"
	_save_active_profile()

func _draw_navigation_marker(canvas: CanvasItem) -> void:
	if navigation_marker.is_empty() or surface_mode or taking_field_photo: return
	if int(navigation_marker.get("seed",-1))!=seed_value or int(navigation_marker.get("level",-1))!=current_level: return
	var point := _world_to_screen(navigation_marker.position)
	if navigation_marker_texture==null: navigation_marker_texture=load("res://assets/sprites/marcador_retorn.png")
	var width := clampf(12.0*zoom_level,22.0,64.0)
	var size := Vector2(width,width*navigation_marker_texture.get_height()/navigation_marker_texture.get_width())
	canvas.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	canvas.draw_texture_rect(navigation_marker_texture,Rect2((point-size*Vector2(0.44,0.96)).round(),size),false)
	canvas.draw_string(ThemeDB.fallback_font,point+Vector2(5,7),"MARCADOR",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("ffdfa0"))

func _recover_stuck_explorer() -> void:
	if death_dialog.visible or discovery_dialog.visible or world.is_empty(): return
	var origin := unit_position
	var room := _cave_at_position(origin)
	var gallery := {}
	if room<0:
		var nearest := INF
		for corridor in world.corridors:
			var distance := _distance_to_polyline(origin,corridor.points)
			if _point_inside_corridor(origin,corridor) and distance<nearest:
				gallery=corridor
				nearest=distance
	_cancel_mining()
	_cancel_bio_scan()
	moving=false
	dragging=false
	center_map_during_move=false
	move_path.clear()
	selected_route.clear()
	chained_cave_id=-1
	level_navigation_target=-1
	depth_trip_target=-1
	use_elevator_on_arrival=false
	inspect_on_cave_arrival=false
	inspection_corridor_id=-1
	inspection_destination_cave_id=-1
	rockfall_clear_remaining=0.0
	var destination := origin
	if not surface_mode:
		var start_cell := Vector2i((origin/float(world.cell_size)).floor())
		for radius in [10.0,20.0,30.0]:
			for index in range(16):
				var candidate: Vector2 = origin+Vector2.from_angle(float(index)*TAU/16.0)*float(radius)
				if room>=0 and not _point_inside_cave_id(candidate,room): continue
				if room<0 and (gallery.is_empty() or not _point_inside_corridor(candidate,gallery)): continue
				if not _is_revealed(candidate): continue
				var clear := true
				for offset in [Vector2.ZERO,Vector2(4,0),Vector2(-4,0),Vector2(0,4),Vector2(0,-4)]:
					if not _segment_is_walkable(candidate+offset,candidate+offset): clear=false
				var steps := maxi(1,ceili(radius/2.0))
				for step in range(1,steps+1):
					var point := origin.lerp(candidate,float(step)/steps)
					# A legacy blocked starting cell may be exited, never another obstacle.
					if Vector2i((point/float(world.cell_size)).floor())==start_cell: continue
					if not _segment_is_walkable(point,point): clear=false
				if fauna_sites.has(room) and candidate.distance_to(_fauna_position(room))<22.0: clear=false
				if clear: destination=candidate; break
			if destination!=origin: break
	unit_position=destination
	move_target=destination
	map_options_window.hide()
	_update_view_mode_ui()
	_action_notice("EXPLORADOR RECUPERAT · Ordres cancel·lades, punt lliure proper" if destination!=origin else "ORDRES REINICIADES · Tria un altre punt de moviment")
	queue_redraw()
	_save_active_profile()

func _find_path(from: Vector2, to: Vector2, gallery: Dictionary = {}, known_galleries_only: bool = false, explore_room: int = -1, completed_only: bool = false) -> Array[Vector2]:
	if gallery.is_empty() and explore_room<0 and _cave_at_position(from)>=0 and _cave_at_position(to)>=0 and _cave_at_position(from)!=_cave_at_position(to):
		return _find_graph_gallery_route(from,to,known_galleries_only,completed_only)
	var path: Array[Vector2] = []
	var grid_size: Vector2i = world.grid_size
	var cell_size: float = world.cell_size
	var mask: PackedByteArray = world.walkable_mask
	var explore_unknown := explore_room >= 0 and (flashlight_on or _room_is_fully_lit(explore_room))
	var start := _nearest_walkable_cell(Vector2i(floori(from.x / cell_size), floori(from.y / cell_size)), 3)
	var goal := _nearest_walkable_cell(Vector2i(floori(to.x / cell_size), floori(to.y / cell_size)), 0)
	if start.x < 0 or (goal.x < 0 and explore_room < 0):
		return path
	var start_index := start.y * grid_size.x + start.x
	var goal_index := goal.y * grid_size.x + goal.x if goal.x >= 0 else -1
	if explore_room >= 0 and goal_index >= 0 and not _point_inside_cave_id((Vector2(goal) + Vector2.ONE * 0.5) * cell_size, explore_room):
		goal_index = -1
	var previous := PackedInt32Array()
	previous.resize(grid_size.x * grid_size.y)
	previous.fill(-2)
	previous[start_index] = -1
	var queue: Array[int] = [start_index]
	var queue_head := 0
	var directions: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]
	while queue_head < queue.size() and (goal_index < 0 or previous[goal_index] == -2):
		var current: int = queue[queue_head]
		queue_head += 1
		var cell := Vector2i(current % grid_size.x, current / grid_size.x)
		for direction in directions:
			var next := cell + direction
			if next.x < 0 or next.x >= grid_size.x or next.y < 0 or next.y >= grid_size.y:
				continue
			var next_index := next.y * grid_size.x + next.x
			if mask[next_index] == 0 or (explore_room < 0 and not dev_mode and revealed_mask[next_index] == 0) or previous[next_index] != -2:
				continue
			if explore_room >= 0 and not explore_unknown and revealed_mask[next_index] == 0:
				continue
			if explore_room >= 0 and not _point_inside_cave_id((Vector2(next) + Vector2.ONE * 0.5) * cell_size, explore_room):
				continue
			if known_galleries_only:
				var center := Vector2(next) * cell_size + Vector2.ONE * cell_size * 0.5
				if not _is_known_room_route_point(center, completed_only):
					continue
			if not gallery.is_empty():
				var center := Vector2(next) * cell_size + Vector2.ONE * cell_size * 0.5
				if not _point_inside_corridor(center, gallery) and not _point_inside_cave_id(center, gallery.a) and not _point_inside_cave_id(center, gallery.b):
					continue
			previous[next_index] = current
			queue.append(next_index)
	if goal_index < 0 or previous[goal_index] == -2:
		if gallery.is_empty() and explore_room < 0:
			return path
		var destination := explore_room if explore_room >= 0 else _cave_at_position(to)
		if destination < 0:
			return path
		var closest := INF
		for index in queue:
			if index == start_index:
				continue
			var center := (Vector2(index % grid_size.x, index / grid_size.x) + Vector2.ONE * 0.5) * cell_size
			var distance := center.distance_squared_to(to)
			if distance < closest and _point_inside_cave_id(center, destination):
				closest = distance
				goal_index = index
		if goal_index < 0 or previous[goal_index] == -2:
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
	if completed_only:
		# Automatic returns retain the validated cell route. Replacing portions
		# with nearby corridor centerlines can introduce shortcuts at crossings.
		var last := from
		for point in path:
			if not _segment_is_walkable(last,point) or not _is_known_room_route_point(point,true): return []
			last=point
		return path
	if explore_room >= 0:
		return _smooth_room_path(from, path, explore_unknown)
	var corridor_path := _follow_corridor_centerlines(path, int(gallery.get("id", -1)))
	corridor_path = _smooth_gallery_steps(from, corridor_path)
	var smoothed := _smooth_room_path(from, corridor_path)
	if known_galleries_only:
		var previous_point := from
		for point in smoothed:
			var steps := maxi(1, ceili(previous_point.distance_to(point) / (cell_size * 0.25)))
			for step in range(1, steps + 1):
				if not _is_known_room_route_point(previous_point.lerp(point, float(step) / float(steps)), completed_only):
					return path
			previous_point = point
	return smoothed

func _find_graph_gallery_route(from: Vector2, to: Vector2, known_only: bool, completed_only: bool) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var start := _cave_at_position(from)
	var goal := _cave_at_position(to)
	var parents := {start:start}
	var links := {}
	var queue: Array[int] = [start]
	var head := 0
	while head<queue.size() and not parents.has(goal):
		var room := queue[head]
		head+=1
		for corridor in world.corridors:
			if corridor.a!=room and corridor.b!=room: continue
			if completed_only and not completed_gallery_traces.has(corridor.id): continue
			if known_only and not completed_gallery_traces.has(corridor.id): continue
			var next: int = corridor.b if corridor.a==room else corridor.a
			if parents.has(next): continue
			parents[next]=room
			links[next]=corridor
			queue.append(next)
	if not parents.has(goal): return result
	var rooms: Array[int] = []
	var room := goal
	while room!=start:
		rooms.push_front(room)
		room=parents[room]
	var cursor := from
	room=start
	for next in rooms:
		var corridor: Dictionary = links[next]
		var mouth: Vector2 = corridor.exit_a if corridor.a==room else corridor.exit_b
		var other: Vector2 = corridor.exit_b if corridor.a==room else corridor.exit_a
		var approach := _find_path(cursor,mouth,{},false,room)
		if approach.is_empty() and cursor.distance_to(mouth)>float(world.cell_size)*1.5: return []
		result.append_array(approach)
		var last: Vector2 = result.back() if not result.is_empty() else cursor
		if not _segment_is_walkable(last,mouth): return []
		result.append(mouth)
		var span := _route_span_on_corridor(mouth,other,corridor)
		if span.is_empty(): return []
		for point in span:
			if not _segment_is_walkable(result.back(),point): return []
			result.append(point)
		if not _segment_is_walkable(result.back(),other): return []
		result.append(other)
		cursor=other
		room=next
	var final_path := _find_path(cursor,to,{},false,goal)
	if final_path.is_empty() and cursor.distance_to(to)>float(world.cell_size)*1.5: return []
	result.append_array(final_path)
	return result

func _is_known_room_route_point(point: Vector2, completed_only: bool = false) -> bool:
	var room := _cave_at_position(point)
	if room >= 0 and _can_inspect_cave(room):
		return true
	for corridor_id in completed_gallery_traces:
		var completed := _corridor_by_id(corridor_id)
		if not completed.is_empty() and _point_inside_corridor(point,completed): return true
	if completed_only:
		return false
	for corridor_id in walked_gallery_spans:
		var corridor := _corridor_by_id(corridor_id)
		if corridor.is_empty():
			continue
		if completed_gallery_traces.has(corridor_id) and _point_inside_corridor(point, corridor):
			return true
		for span in walked_gallery_spans[corridor_id]:
			if _distance_to_polyline(point, span) <= world.cell_size:
				return true
	return false

func _smooth_gallery_steps(from: Vector2, path: Array[Vector2]) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var anchor := from
	var index := 0
	var max_step: float = world.cell_size * 3.0
	while index < path.size():
		var next_index := index
		# Only remove short grid steps. Keep the longer segments of the curve.
		for candidate in range(index + 1, mini(index + 6, path.size())):
			if anchor.distance_to(path[candidate]) > max_step:
				break
			if _cave_at_position(anchor) >= 0 or _cave_at_position(path[candidate]) >= 0:
				break
			var skipped_point := path[candidate - 1]
			var cell_center: Vector2 = (skipped_point / world.cell_size).floor() * world.cell_size + Vector2.ONE * world.cell_size * 0.5
			if skipped_point.distance_squared_to(cell_center) > 0.001:
				break
			if _segment_is_walkable(anchor, path[candidate]):
				next_index = candidate
		anchor = path[next_index]
		result.append(anchor)
		index = next_index + 1
	return result

func _smooth_room_path(from: Vector2, path: Array[Vector2], ignore_fog: bool = false) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var anchor := from
	var index := 0
	while index < path.size():
		var room := _cave_at_position(anchor)
		var next_index := index
		if room >= 0:
			var run_end := index
			while run_end < path.size() and _point_inside_cave_id(path[run_end], room):
				run_end += 1
			for candidate in range(run_end - 1, index, -1):
				if _segment_is_walkable(anchor, path[candidate], ignore_fog) and not _path_prefix_inside_cave([path[candidate]], anchor, room).is_empty():
					next_index = candidate
					break
		anchor = path[next_index]
		result.append(anchor)
		index = next_index + 1
	return result

func _follow_corridor_centerlines(path: Array[Vector2], only_corridor_id: int = -1) -> Array[Vector2]:
	if path.size() < 3 or world.is_empty():
		return path
	var corridor_at := PackedInt32Array()
	corridor_at.resize(path.size())
	corridor_at.fill(-1)
	var distance_at := PackedFloat32Array()
	distance_at.resize(path.size())
	distance_at.fill(INF)
	var room_cells := PackedByteArray()
	for point in path:
		room_cells.append(1 if _cave_at_position(point) >= 0 else 0)
	for corridor in world.corridors:
		if only_corridor_id >= 0 and corridor.id != only_corridor_id:
			continue
		var route: PackedVector2Array = corridor.points
		var capture_distance: float = ceilf(float(corridor.width) * 0.5 / world.cell_size) * world.cell_size + world.cell_size
		for path_index in range(path.size()):
			if room_cells[path_index] == 1:
				continue
			var distance := _distance_to_polyline(path[path_index], route)
			if distance <= capture_distance and distance < distance_at[path_index]:
				distance_at[path_index] = distance
				corridor_at[path_index] = int(corridor.id)
	var result: Array[Vector2] = []
	var index := 0
	while index < path.size():
		var corridor_id: int = corridor_at[index]
		if corridor_id < 0:
			_append_path_point(result, path[index])
			index += 1
			continue
		var run_end := index
		while run_end + 1 < path.size() and corridor_at[run_end + 1] == corridor_id:
			run_end += 1
		var corridor: Dictionary = _corridor_by_id(corridor_id)
		var replacement: Array[Vector2] = []
		var span_end := run_end
		# A hidden cell near a mouth should not discard the visible centerline.
		while span_end > index:
			replacement = _route_span_on_corridor(path[index], path[span_end], corridor)
			if not replacement.is_empty():
				break
			span_end -= 1
		if replacement.is_empty():
			_append_path_point(result, path[index])
		else:
			for point in replacement:
				_append_path_point(result, point)
		index = span_end + 1
	return result

func _route_span_on_corridor(start: Vector2, finish: Vector2, corridor: Dictionary) -> Array[Vector2]:
	if corridor.is_empty():
		return []
	var route: PackedVector2Array = corridor.points
	var from_projection := _project_to_polyline(start, route)
	var to_projection := _project_to_polyline(finish, route)
	var max_projection_distance: float = float(corridor.width) * 0.5 + world.cell_size
	if float(from_projection.distance) > max_projection_distance or float(to_projection.distance) > max_projection_distance:
		return []
	var forward: bool = int(from_projection.segment) < int(to_projection.segment) or (int(from_projection.segment) == int(to_projection.segment) and float(from_projection.t) <= float(to_projection.t))
	var oriented := route
	var from_segment: int = int(from_projection.segment)
	var to_segment: int = int(to_projection.segment)
	var from_point: Vector2 = from_projection.point
	var to_point: Vector2 = to_projection.point
	if not forward:
		oriented = PackedVector2Array()
		for point_index in range(route.size() - 1, -1, -1):
			oriented.append(route[point_index])
		from_projection = _project_to_polyline(start, oriented)
		to_projection = _project_to_polyline(finish, oriented)
		from_segment = int(from_projection.segment)
		to_segment = int(to_projection.segment)
		from_point = from_projection.point
		to_point = to_projection.point
	if from_segment > to_segment:
		return []
	var replacement: Array[Vector2] = [start]
	if not _segment_is_walkable(start, from_point):
		return []
	_append_path_point(replacement, from_point)
	for route_index in range(from_segment + 1, to_segment + 1):
		if not _segment_is_walkable(replacement.back(), oriented[route_index]):
			return []
		_append_path_point(replacement, oriented[route_index])
	if not _segment_is_walkable(replacement.back(), to_point) or not _segment_is_walkable(to_point, finish):
		return []
	_append_path_point(replacement, to_point)
	_append_path_point(replacement, finish)
	return replacement

func _project_to_polyline(point: Vector2, route: PackedVector2Array) -> Dictionary:
	var nearest_point := Vector2.ZERO
	var nearest_segment := 0
	var nearest_t := 0.0
	var nearest_distance := INF
	for segment in range(route.size() - 1):
		var start: Vector2 = route[segment]
		var difference: Vector2 = route[segment + 1] - start
		var weight := clampf((point - start).dot(difference) / maxf(difference.length_squared(), 0.001), 0.0, 1.0)
		var candidate := start + difference * weight
		var distance := point.distance_to(candidate)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_point = candidate
			nearest_segment = segment
			nearest_t = weight
	return {"point": nearest_point, "segment": nearest_segment, "t": nearest_t, "distance": nearest_distance}

func _distance_to_polyline(point: Vector2, route: PackedVector2Array) -> float:
	var distance := INF
	for segment in range(route.size() - 1):
		distance = minf(distance, Geometry2D.get_closest_point_to_segment(point, route[segment], route[segment + 1]).distance_to(point))
	return distance

func _corridor_by_id(corridor_id: int) -> Dictionary:
	for corridor in world.corridors:
		if int(corridor.id) == corridor_id:
			return corridor
	return {}

func _append_path_point(path: Array[Vector2], point: Vector2) -> void:
	if path.is_empty() or path.back().distance_squared_to(point) > 0.01:
		path.append(point)

func _path_for_order(order: Dictionary) -> Array[Vector2]:
	var target: Vector2 = order.position
	if analysis_mode and bool(order.get("room_click", false)):
		return _find_path(unit_position, target, {}, true, -1, true)
	if order.has("explore_room"):
		return _find_path(unit_position, target, {}, false, int(order.explore_room))
	var corridor_id: int = int(order.get("corridor_id", -1))
	if not analysis_mode or corridor_id < 0:
		var known_only := not dev_mode and not analysis_mode and bool(order.get("room_click", false))
		if corridor_id >= 0:
			return _find_path(unit_position, target, _corridor_by_id(corridor_id))
		return _find_path(unit_position, target, {}, known_only)
	for exit_info in _visible_exits_for_cave(selected_cave):
		if int(exit_info.corridor_id) != corridor_id:
			continue
		var gallery := _corridor_by_id(corridor_id)
		if gallery.is_empty():
			return []
		if not _point_inside_cave_id(unit_position, selected_cave):
			if _point_inside_corridor(unit_position, gallery):
				return _find_path(unit_position, target, gallery)
			return []
		var inside: Vector2 = exit_info.position - exit_info.direction * 10.0
		var approach := _path_prefix_inside_cave(_find_path(unit_position, inside), unit_position, selected_cave)
		var approach_start: Vector2 = approach.back() if not approach.is_empty() else unit_position
		if _path_prefix_inside_cave([inside], approach_start, selected_cave).is_empty() or not _segment_is_walkable(approach_start, inside):
			return _find_path(unit_position, target, gallery)
		approach.append(inside)
		var stub := _isometric_exit_stub(exit_info, gallery, world.caves[selected_cave])
		if stub.size() < 3:
			return []
		for index in range(1, stub.size()):
			if not _segment_is_walkable(stub[index - 1], stub[index]):
				return _find_path(unit_position, target, gallery)
			approach.append(stub[index])
		var stub_end := stub[stub.size() - 1]
		var continuation := _find_path(stub_end, target, gallery)
		if continuation.is_empty():
			return _find_path(unit_position, target, gallery)
		approach.append_array(continuation)
		return approach
	return []

func _is_discovered_move_segment(start: Vector2, finish: Vector2) -> bool:
	var steps := maxi(1, ceili(start.distance_to(finish) / (world.cell_size * 0.25)))
	for step in range(1, steps + 1):
		var point := start.lerp(finish, float(step) / float(steps))
		var cave_id := _cave_at_position(point)
		if cave_id < 0:
			if not _point_in_lit_gallery(point):
				return false
		elif not _is_revealed(point) and not _room_is_fully_lit(cave_id):
			return false
	return true

func _segment_is_walkable(start: Vector2, finish: Vector2, ignore_fog: bool = false) -> bool:
	var steps := maxi(1, ceili(start.distance_to(finish) / maxf(1.0, world.cell_size * 0.25)))
	for step in range(steps + 1):
		var point := start.lerp(finish, float(step) / float(steps))
		var cell := Vector2i(floori(point.x / world.cell_size), floori(point.y / world.cell_size))
		if cell.x < 0 or cell.x >= world.grid_size.x or cell.y < 0 or cell.y >= world.grid_size.y:
			return false
		var index: int = cell.y * world.grid_size.x + cell.x
		if world.walkable_mask[index] == 0 or (not ignore_fog and not dev_mode and revealed_mask[index] == 0):
			return false
	return true

func _exit_marker_order(point: Vector2) -> Dictionary:
	if not analysis_mode or selected_cave<0 or selected_cave!=current_cave_id: return {}
	var screen := _world_to_screen(point)
	var nearest := INF
	var selected := {}
	var radius := 14.0*clampf(zoom_level/3.5,1.35,1.8)
	for exit_info in _visible_exits_for_cave(selected_cave):
		var corridor := _corridor_by_id(exit_info.corridor_id)
		if corridor.is_empty(): continue
		if _is_gallery_exit_accessible(corridor,selected_cave) and _gallery_was_crossed(corridor): continue
		var marker := _world_to_screen(exit_info.position+exit_info.direction*8.0)
		var distance := screen.distance_to(marker)
		if distance>radius or distance>=nearest: continue
		nearest=distance
		var destination: int=corridor.b if corridor.a==selected_cave else corridor.a
		selected={"position":_arrival_point(destination,corridor.id),"cave_id":-1,"corridor_id":corridor.id,"inspection_cave_id":destination}
	return selected

func _resolve_order_target(point: Vector2) -> Dictionary:
	var marked := _exit_marker_order(point)
	if not marked.is_empty(): return marked
	if analysis_mode:
		var clicked_room := _cave_at_position(point)
		if clicked_room >= 0 and clicked_room != current_cave_id and _can_inspect_cave(clicked_room):
			var reachable := _reachable_revealed_cells(unit_position, true, true)
			var cell := _nearest_revealed_walkable_in_cave(clicked_room, point, reachable)
			var target := (Vector2(cell) + Vector2.ONE * 0.5) * float(world.cell_size) if cell.x >= 0 else point
			return {"position": target, "cave_id": -1, "inspection_cave_id": clicked_room, "room_click": true}
		if selected_cave != current_cave_id:
			return {}
		var gallery := _visible_gallery_at(point)
		if not gallery.is_empty():
			var destination: int = gallery.b if gallery.a == current_cave_id else gallery.a
			var arrival := _arrival_point(destination, gallery.id)
			return {"position": arrival, "cave_id": -1, "corridor_id": gallery.id, "inspection_cave_id": destination}
		return {"position": point, "cave_id": -1, "explore_room": selected_cave}
	# A click inside a revealed neighboring room is a room movement order,
	# even when the small room lies close to its connecting mouth.
	var containing_cave := -1
	for cave in world.caves:
		if Geometry2D.is_point_in_polygon(point - cave.position, cave.contour):
			containing_cave = cave.id
			break
	var mouth_id := _known_exit_corridor(point)
	if containing_cave >= 0 and containing_cave != current_cave_id and (mouth_id < 0 or _can_inspect_cave(containing_cave)):
		var reachable_room := _reachable_revealed_cells(unit_position, not dev_mode and _can_inspect_cave(containing_cave))
		var room_target := _nearest_revealed_walkable_in_cave(containing_cave, point, reachable_room)
		if room_target.x >= 0:
			return {"position": Vector2((float(room_target.x) + 0.5) * world.cell_size, (float(room_target.y) + 0.5) * world.cell_size), "cave_id": -1, "inspection_cave_id": containing_cave, "room_click": true}
		if _can_inspect_cave(containing_cave):
			return {"position": point, "cave_id": -1, "inspection_cave_id": containing_cave, "room_click": true}
	var exit_cave := _known_exit_cave(point)
	if exit_cave >= 0 and not analysis_mode:
		var arrival := _arrival_point(exit_cave, mouth_id)
		return {"position": arrival, "cave_id": exit_cave, "inspection_cave_id": exit_cave, "corridor_id": mouth_id}
	if exit_cave >= 0:
		var reachable_for_exit := _reachable_revealed_cells(unit_position)
		var exit_target := _nearest_revealed_walkable_in_cave(exit_cave, point, reachable_for_exit)
		if exit_target.x >= 0:
			return {"position": Vector2((float(exit_target.x) + 0.5) * world.cell_size, (float(exit_target.y) + 0.5) * world.cell_size), "cave_id": exit_cave, "inspection_cave_id": exit_cave, "corridor_id": mouth_id}
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

func _reachable_revealed_cells(from: Vector2, known_only: bool = false, completed_only: bool = false) -> PackedByteArray:
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
			if known_only and not _is_known_room_route_point((Vector2(next) + Vector2.ONE * 0.5) * world.cell_size, completed_only):
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
	last_revealed_cell = center_cell
	var reveal_cave_id := _cave_at_position(center)
	if not flashlight_on and reveal_cave_id >= 0 and not _room_is_fully_lit(reveal_cave_id):
		return
	var radius_squared := radius_cells * radius_cells
	for y in range(maxi(0, center_cell.y - radius_cells), mini(size.y, center_cell.y + radius_cells + 1)):
		for x in range(maxi(0, center_cell.x - radius_cells), mini(size.x, center_cell.x + radius_cells + 1)):
			var offset := Vector2i(x, y) - center_cell
			var index := y * size.x + x
			if offset.length_squared() <= radius_squared and terrain[index] == 1 and _has_line_of_sight(center_cell, Vector2i(x, y)):
				if not flashlight_on and revealed_mask[index] == 0:
					var cell_cave_id := _cave_at_position((Vector2(x, y) + Vector2.ONE * 0.5) * cell_size)
					if cell_cave_id >= 0 and not _room_is_fully_lit(cell_cave_id):
						continue
				revealed_mask[index] = 1
	if analysis_mode and reveal_cave_id == selected_cave and reveal_cave_id >= 0:
		var cave: Dictionary = world.caves[reveal_cave_id]
		if not explored_caves.has(reveal_cave_id) and _room_reveal_ratio(cave) >= 0.90:
			for node in get_children():
				if node.get_script()==preload("res://scripts/cave_lighting.gd"): node.begin_room_reveal(cave)
			_reveal_entire_room(cave)
			_scan_current_cave()
			if is_instance_valid(status_label):
				status_label.text = "SALA %02d DESCOBERTA · SORTIDES %d" % [reveal_cave_id + 1, _exit_count(reveal_cave_id)]
	_update_level_progress()
	_refresh_room_progress()
	queue_redraw()

func _reveal_entire_room(cave: Dictionary) -> void:
	var contour: PackedVector2Array = cave.contour
	if contour.is_empty():
		return
	var bounds := Rect2(contour[0] + cave.position, Vector2.ZERO)
	for point in contour:
		bounds = bounds.expand(point + cave.position)
	var min_x := maxi(0, floori(bounds.position.x / world.cell_size))
	var max_x := mini(world.grid_size.x - 1, ceili(bounds.end.x / world.cell_size))
	var min_y := maxi(0, floori(bounds.position.y / world.cell_size))
	var max_y := mini(world.grid_size.y - 1, ceili(bounds.end.y / world.cell_size))
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var index: int = y * world.grid_size.x + x
			if world.terrain_mask[index] == 0:
				continue
			var center := Vector2((float(x) + 0.5) * world.cell_size, (float(y) + 0.5) * world.cell_size)
			if Geometry2D.is_point_in_polygon(center - cave.position, contour):
				revealed_mask[index] = 1

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
	_refresh_room_progress()
	queue_redraw()

func _update_current_cave(allow_intermediate_stop: bool = false) -> void:
	for cave in world.caves:
		if Geometry2D.is_point_in_polygon(unit_position - cave.position, cave.contour):
			if allow_intermediate_stop and current_cave_id != cave.id:
				_register_beacon_use(cave.id)
			visited_caves[cave.id] = true
			if current_cave_id != cave.id:
				if allow_intermediate_stop:
					for corridor in world.corridors:
						var connects_rooms: bool = (corridor.a == current_cave_id and corridor.b == cave.id) or (corridor.b == current_cave_id and corridor.a == cave.id)
						if connects_rooms and _gallery_was_crossed(corridor):
							completed_gallery_traces[corridor.id] = true
				current_cave_id = cave.id
				var gallery_arrival: bool = analysis_mode and inspection_corridor_id >= 0 and cave.id == inspection_destination_cave_id
				var is_destination: bool = (inspect_on_cave_arrival or gallery_arrival) and cave.id == inspection_destination_cave_id
				var needs_inspection: bool = allow_intermediate_stop and level_navigation_target < 0 and not explored_caves.has(cave.id)
				if analysis_mode and inspect_on_cave_arrival:
					selected_cave = cave.id
					selected_cave_focus = unit_position
					if needs_inspection and not is_destination:
						move_target = unit_position
						move_path.clear()
					_update_view_mode_ui()
					_focus_world_position(unit_position, zoom_level)
				if gallery_arrival or (not analysis_mode and (is_destination or needs_inspection)):
					if needs_inspection and not is_destination:
						move_target = unit_position
						move_path.clear()
						chained_cave_id = -1
					if gallery_arrival:
						isometric_passage_id = inspection_corridor_id
					selected_cave = cave.id
					selected_cave_focus = unit_position if gallery_arrival else cave.position
					analysis_mode = true
					inspect_on_cave_arrival = false
					inspection_destination_cave_id = -1
					inspection_corridor_id = -1
					if not gallery_arrival:
						zoom_level = _analysis_zoom_for_cave(cave.id)
					_update_view_mode_ui()
					_focus_world_position(selected_cave_focus, zoom_level)
				if is_instance_valid(status_label):
					status_label.text = "EXPLORANT LA SALA %02d" % (current_cave_id + 1)
				_update_map_stats()
			return

func _cave_at_position(position: Vector2) -> int:
	for cave in world.caves:
		if Geometry2D.is_point_in_polygon(position - cave.position, cave.contour):
			return cave.id
	return -1

func _detect_caves_near_unit() -> void:
	if world.is_empty():
		return
	var newly_detected := false
	for cave in world.caves:
		if explored_caves.has(cave.id) or detected_caves.has(cave.id):
			continue
		var unit_inside_cave: bool = Geometry2D.is_point_in_polygon(unit_position - cave.position, cave.contour)
		if not unit_inside_cave and _distance_to_cave_boundary(unit_position, cave) > CAVE_DETECTION_MARGIN:
			continue
		detected_caves[cave.id] = true
		newly_detected = true
	if newly_detected:
		if is_instance_valid(status_label):
			status_label.text = "SENYAL DE COVA DETECTADA · APROPA'T PER EXPLORAR"
		queue_redraw()

func _distance_to_cave_boundary(point: Vector2, cave: Dictionary) -> float:
	var nearest_distance := INF
	var contour: PackedVector2Array = cave.contour
	for index in range(contour.size()):
		var start: Vector2 = cave.position + contour[index]
		var finish: Vector2 = cave.position + contour[(index + 1) % contour.size()]
		var closest := Geometry2D.get_closest_point_to_segment(point, start, finish)
		nearest_distance = minf(nearest_distance, point.distance_to(closest))
	return nearest_distance

func _discover_exit_near_unit() -> void:
	if current_cave_id < 0 or current_cave_id >= world.caves.size():
		return
	if not flashlight_on and not _room_is_fully_lit(current_cave_id):
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
	var corridor := _corridor_by_id(_known_exit_corridor(target))
	if corridor.is_empty():
		return -1
	return corridor.b if corridor.a == current_cave_id else corridor.a

func _known_exit_corridor(target: Vector2) -> int:
	var nearest := -1
	var nearest_distance := 42.0 / zoom_level
	for exit_info in _visible_exits_for_cave(current_cave_id):
		var mouth_center: Vector2 = exit_info.position + exit_info.direction * 12.0
		var distance := target.distance_to(mouth_center)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = exit_info.corridor_id
	return nearest

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
		if not visited_caves.has(cave.id):
			continue
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
		if child == light_warning_label or child == low_supply_label:
			continue
		if child is Control and child.is_visible() and child.get_global_rect().has_point(point):
			return true
	return false

func _view_rect() -> Rect2:
	var viewport_size := Vector2(1440, 900)
	if is_inside_tree():
		viewport_size = get_viewport_rect().size
	var left_margin := 280.0 * SIDE_PANEL_SCALE + 12.0
	var right_margin := (220.0 if analysis_mode else 280.0) * SIDE_PANEL_SCALE + 12.0
	if viewport_size.x <= left_margin + right_margin + 200.0:
		return Rect2(Vector2.ZERO, viewport_size)
	return Rect2(left_margin, 0, viewport_size.x - left_margin - right_margin, viewport_size.y)

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
		var iso_point := (point - view.get_center() - camera_offset) / zoom_level
		return cave.position + Vector2(iso_point.x, iso_point.y / ISO_VERTICAL_RATIO)
	return Generator.WORLD_RECT.size * 0.5 + (point - view.get_center() - camera_offset) / zoom_level

func _iso_project_relative(point: Vector2, origin: Vector2) -> Vector2:
	var delta := point - origin
	return Vector2(delta.x, delta.y * ISO_VERTICAL_RATIO)
