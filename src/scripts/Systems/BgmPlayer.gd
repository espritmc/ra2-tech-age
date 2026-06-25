extends Node

## BGM 背景音乐系统 — 程序化生成军事风格音乐

var audio_player: AudioStreamPlayer
var current_track: String = "theme"
var tracks: Dictionary = {}


func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	_generate_tracks()
	play_track("theme")


func _generate_tracks() -> void:
	tracks["theme"] = _generate_theme()
	tracks["battle"] = _generate_battle()


func _generate_theme() -> AudioStream:
	# 使用 AudioStreamGenerator 生成简单军乐
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 2.0  # 循环 2 秒
	
	tracks["theme_data"] = generator
	return generator


func _generate_battle() -> AudioStream:
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	generator.buffer_length = 1.5
	return generator


func play_track(name: String) -> void:
	if not tracks.has(name):
		return
	
	current_track = name
	audio_player.stream = tracks[name]
	audio_player.play()
	audio_player.volume_db = -12  # 背景音量
	
	if name == "theme":
		_fill_theme_buffer()
	elif name == "battle":
		_fill_battle_buffer()


func _fill_theme_buffer() -> void:
	var generator = audio_player.stream as AudioStreamGenerator
	if not generator: return
	
	var playback = audio_player.get_stream_playback() as AudioStreamGeneratorPlayback
	if not playback: return
	
	# 简单的军事进行曲风格：低音鼓点 + 号角旋律
	var frames = generator.buffer_length * generator.mix_rate as int
	
	for i in range(int(frames)):
		var t = float(i) / generator.mix_rate
		var beat_t = fmod(t, 1.0)  # 1 秒节奏循环
		var bar_t = fmod(t, 4.0)    # 4 秒小节循环
		
		# 鼓点
		var drum = 0.0
		if fmod(t, 0.5) < 0.06:
			drum = 0.3 * (1.0 - fmod(t, 0.5) / 0.06)
		if fmod(t, 2.0) < 0.08:
			drum += 0.4 * (1.0 - fmod(t, 2.0) / 0.08)
		
		# 低音号角旋律
		var melody = sin(t * 220.0 * PI * 2) * 0.15  # A3
		melody += sin(t * 330.0 * PI * 2) * 0.1   # E4
		
		if bar_t > 2.0:
			melody = sin(t * 277.0 * PI * 2) * 0.15  # C#4
			melody += sin(t * 415.0 * PI * 2) * 0.1  # G#4
		
		# 混音
		var sample = (drum + melody) * 0.5
		playback.push_frame(Vector2(sample, sample))
	
	print("[BGM] 主题曲开始播放")


func _fill_battle_buffer() -> void:
	var generator = audio_player.stream as AudioStreamGenerator
	if not generator: return
	
	var playback = audio_player.get_stream_playback() as AudioStreamGeneratorPlayback
	if not playback: return
	
	var frames = generator.buffer_length * generator.mix_rate as int
	
	for i in range(int(frames)):
		var t = float(i) / generator.mix_rate
		
		# 战斗 — 更快节奏
		var drum = 0.0
		if fmod(t, 0.25) < 0.04:
			drum = 0.4 * (1.0 - fmod(t, 0.25) / 0.04)
		
		var bass = sin(t * 110.0 * PI * 2) * 0.2
		var high = sin(t * 440.0 * PI * 2) * 0.08
		
		var sample = (drum + bass + high) * 0.4
		playback.push_frame(Vector2(sample, sample))
	
	print("[BGM] 战斗音乐开始")


func switch_to_battle() -> void:
	if current_track != "battle":
		play_track("battle")


func switch_to_theme() -> void:
	if current_track != "theme":
		play_track("theme")
