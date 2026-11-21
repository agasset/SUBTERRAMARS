extends Node
var enabled := true
var settings_enabled := true
const MUSIC_PATHS := ["res://assets/audio/music/subterranean_pulse.mp3","res://assets/audio/music/stone_echoes.mp3"]
var music_enabled := true
var music_volume := 0.25
var music_index := 0
var music_player: AudioStreamPlayer
var music_tracks: Array[AudioStreamMP3] = []
var clips: Dictionary = {}
var voices: Array[AudioStreamPlayer] = []
var cooldowns: Dictionary = {}
var scan_clock := 0.0
var tool_clock := 0.0
var alarm_clock := 0.0
var last_status := ""
var last_light := false
var last_photo := false
func _ready() -> void:
	var settings := ConfigFile.new()
	if settings.load(_settings_path())==OK:
		enabled=bool(settings.get_value("audio","effects_enabled",true))
		music_enabled=bool(settings.get_value("audio","music_enabled",true))
		music_volume=clampf(float(settings.get_value("audio","music_volume",0.25)),0,1)
	music_player=AudioStreamPlayer.new()
	add_child(music_player)
	music_player.finished.connect(_next_music_track)
	for path in MUSIC_PATHS:
		var track := load(path).duplicate() as AudioStreamMP3
		track.loop=false
		music_tracks.append(track)
	_apply_music_volume()
	if music_enabled: _play_music_track()
	for i in range(6):
		var voice := AudioStreamPlayer.new()
		add_child(voice)
		voices.append(voice)
	get_tree().node_added.connect(_node_added)
func _node_added(node: Node) -> void:
	if node is Button and get_parent().is_ancestor_of(node):
		node.pressed.connect(func() -> void: play("ui"))
func set_enabled(value: bool) -> void:
	enabled = value
	if not enabled:
		for voice in voices: voice.stop()
	_save_settings()

func _settings_path() -> String:
	return "user://audio_settings.cfg"

func _save_settings() -> void:
	if not settings_enabled: return
	var settings := ConfigFile.new()
	settings.set_value("audio","effects_enabled",enabled)
	settings.set_value("audio","music_enabled",music_enabled)
	settings.set_value("audio","music_volume",music_volume)
	settings.save(_settings_path())

func _apply_music_volume() -> void:
	music_player.volume_db=linear_to_db(music_volume) if music_volume>0 else -80.0

func _play_music_track() -> void:
	if music_tracks.is_empty(): return
	music_player.stream=music_tracks[music_index]
	music_player.play()

func _next_music_track() -> void:
	music_index=(music_index+1)%music_tracks.size()
	if music_enabled: _play_music_track()

func set_music_enabled(value: bool) -> void:
	music_enabled=value
	if value:
		if not music_player.playing: _play_music_track()
		music_player.stream_paused=false
	else:
		music_player.stream_paused=true
	_save_settings()

func set_music_volume(value: float) -> void:
	music_volume=clampf(value,0,1)
	_apply_music_volume()
	_save_settings()
func _clip(kind: String) -> AudioStreamWAV:
	if clips.has(kind): return clips[kind]
	var spec: Array = {"ui":[0.045,750.0,1050.0],"denied":[0.22,240.0,130.0],"scan":[0.12,950.0,1450.0],"tool":[0.1,110.0,65.0],"complete":[0.32,620.0,1250.0],"alarm":[0.45,550.0,880.0],"photo":[0.09,1700.0,250.0],"service":[0.18,360.0,760.0],"light":[0.06,420.0,620.0],"weapon":[0.16,1500.0,140.0],"shield":[0.20,320.0,1100.0],"predator":[0.34,140.0,65.0]}[kind]
	var count := int(float(spec[0]) * 22050)
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	var phase := 0.0
	for i in range(count):
		var t := float(i) / count
		var frequency := lerpf(float(spec[1]),float(spec[2]),t)
		if kind == "alarm": frequency = float(spec[1]) if t < 0.5 else float(spec[2])
		phase += TAU * frequency / 22050.0
		var value := sin(phase) * sin(PI * t) * exp(-t * 2.0)
		if kind == "tool" or kind == "photo": value += sin(phase * 7.31) * 0.25 * (1.0-t)
		bytes.encode_s16(i * 2, int(clampf(value,-1,1) * 15000))
	var clip := AudioStreamWAV.new()
	clip.format = AudioStreamWAV.FORMAT_16_BITS
	clip.mix_rate = 22050
	clip.data = bytes
	clips[kind] = clip
	return clip
func play(kind: String) -> void:
	if not enabled or voices.is_empty(): return
	var now := Time.get_ticks_msec()
	if now - int(cooldowns.get(kind, -10000)) < 100: return
	cooldowns[kind] = now
	for voice in voices:
		if not voice.playing:
			voice.stream = _clip(kind)
			voice.volume_db = -14.0 if kind == "alarm" else (-24.0 if kind == "ui" else -19.0)
			voice.play()
			break
func _process(delta: float) -> void:
	var game = get_parent()
	if not is_instance_valid(game.status_label): return
	if game.flashlight_on != last_light:
		last_light = game.flashlight_on
		play("light")
	if game.taking_field_photo and not last_photo: play("photo")
	last_photo = game.taking_field_photo
	scan_clock -= delta
	tool_clock -= delta
	alarm_clock -= delta
	if game.bio_scan_room >= 0 and scan_clock <= 0:
		play("scan")
		scan_clock = 0.55
	if (game.mining_cave >= 0 or game.rockfall_clear_remaining > 0) and tool_clock <= 0:
		play("tool")
		tool_clock = 0.32
	if not game.surface_mode and alarm_clock <= 0 and (game.health <= 15.0 or game.oxygen_seconds <= game.call("_oxygen_capacity") * 0.1 or (game.flashlight_on and game.call("_flashlight_charge_percent") <= 10.0)):
		play("alarm")
		alarm_clock = 6.0
	var status: String = game.status_label.text
	if status != last_status:
		last_status = status
		if status.contains("ESCANEIG 100%") or status.begins_with("+"): play("complete")
		elif status.contains("RECOLLIDA") or (status.contains("REPARADA") or status.contains("REPARAT")) or status.contains("REPOSAT") or (status.contains("BALISA INSTAL") or status.contains("BALISA DESPLEGADA")) or status.contains("OXIGEN RE"): play("service")
