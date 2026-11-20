extends RefCounted

const DIRECTORY := "user://partides"
const FORMAT_VERSION := 1

static func profile_id(profile_name: String) -> String:
	return profile_name.strip_edges().to_lower().sha256_text()

static func read_profile(id: String, validate_game: Callable = Callable()) -> Dictionary:
	for suffix in [".sav", ".bak"]:
		var profile := read_profile_file(DIRECTORY.path_join(id + suffix))
		if not profile.is_empty() and (not validate_game.is_valid() or validate_game.call(profile.game)):
			return profile
	return {}

static func list_profiles() -> Dictionary[String, String]:
	var profiles: Dictionary[String, String] = {}
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(DIRECTORY)):
		return profiles
	for filename in DirAccess.get_files_at(DIRECTORY):
		if filename.get_extension() not in ["sav", "bak"]:
			continue
		var id := filename.get_basename()
		if profiles.has(id):
			continue
		var profile := read_profile(id)
		if not profile.is_empty():
			profiles[id] = profile.name
	return profiles

static func write_profile(id: String, profile_name: String, game: Dictionary) -> Error:
	var directory := ProjectSettings.globalize_path(DIRECTORY)
	var result := DirAccess.make_dir_recursive_absolute(directory)
	if result != OK and result != ERR_ALREADY_EXISTS:
		return result
	var destination := directory.path_join(id + ".sav")
	var backup := directory.path_join(id + ".bak")
	var temporary := directory.path_join("%s.%d.tmp" % [id, Time.get_ticks_usec()])
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_var({"version": FORMAT_VERSION, "name": profile_name, "game": game}, false)
	file.flush()
	result = file.get_error()
	file.close()
	if result != OK:
		DirAccess.remove_absolute(temporary)
		return result
	if FileAccess.file_exists(destination) and not read_profile_file(destination).is_empty():
		result = DirAccess.rename_absolute(destination, backup)
		if result != OK:
			DirAccess.remove_absolute(temporary)
			return result
	result = DirAccess.rename_absolute(temporary, destination)
	if result != OK:
		DirAccess.remove_absolute(temporary)
	return result

static func read_profile_file(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var value = file.get_var(false)
	if file.get_error() == OK and value is Dictionary and value.get("version") == FORMAT_VERSION and value.get("name") is String and value.get("game") is Dictionary:
		return value
	return {}
