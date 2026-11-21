extends SceneTree
class TestAudio extends "res://scripts/game_audio.gd":
	func _settings_path() -> String:
		return "user://music_check_settings.cfg"
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var path := "user://music_check_settings.cfg"
	if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
	var player := TestAudio.new()
	root.add_child(player)
	player.set_process(false)
	assert(player.music_tracks.size()==2)
	for track in player.music_tracks: assert(track.get_length()>30 and not track.loop)
	assert(player.music_player.playing and player.music_index==0)
	await create_timer(0.15).timeout
	player.set_music_enabled(false)
	var position := player.music_player.get_playback_position()
	await create_timer(0.12).timeout
	assert(player.music_player.stream_paused and absf(player.music_player.get_playback_position()-position)<0.05)
	player.set_music_enabled(true)
	assert(not player.music_player.stream_paused and player.music_index==0)
	player.set_enabled(false)
	assert(player.music_player.playing)
	player.set_music_volume(0.37)
	assert(is_equal_approx(db_to_linear(player.music_player.volume_db),0.37))
	var settings := ConfigFile.new()
	assert(settings.load(path)==OK and is_equal_approx(float(settings.get_value("audio","music_volume")),0.37))
	player.music_player.seek(player.music_tracks[0].get_length()-0.07)
	await create_timer(0.5).timeout
	assert(player.music_index==1 and player.music_player.stream==player.music_tracks[1])
	player.music_player.seek(player.music_tracks[1].get_length()-0.07)
	await create_timer(0.5).timeout
	assert(player.music_index==0 and player.music_player.playing)
	player.set_music_enabled(false)
	var other := TestAudio.new()
	root.add_child(other)
	other.set_process(false)
	assert(not other.music_enabled and not other.enabled and is_equal_approx(other.music_volume,0.37))
	print("MUSIC_PLAYLIST_OK tracks=2 durations=%.1f_%.1f natural_finish=alternates_and_wraps mute=resumes effects=independent volume=persisted" % [player.music_tracks[0].get_length(),player.music_tracks[1].get_length()])
	player.music_player.stop()
	other.music_player.stop()
	player.queue_free()
	other.queue_free()
	await process_frame
	await process_frame
	DirAccess.remove_absolute(path)
	if DisplayServer.get_name()!="headless":
		root.size=Vector2i(1440,900)
		var game = preload("res://scripts/organism_preview.gd").PreviewGame.new()
		root.add_child(game)
		game.set_process(false)
		game._new_world(134027)
		game.map_options_window.popup_centered()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://reports/opcions_musica.png")
		game.queue_free()
		await process_frame
	quit()
