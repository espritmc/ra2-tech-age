extends Node

## 音效系统 — 射击 / 爆炸 / 选中 / 提示音

var players: Array = []
var max_players: int = 8


func play_shoot() -> void:
	_play_tone(800, 0.06, 0.15)
	_play_tone(400, 0.04, 0.1)


func play_explosion() -> void:
	_play_noise(0.2, 0.3)
	_play_tone(80, 0.15, 0.4)


func play_select() -> void:
	_play_tone(600, 0.05, 0.08)
	_play_tone(900, 0.03, 0.06)


func play_build() -> void:
	_play_tone(500, 0.08, 0.12)
	_play_tone(700, 0.06, 0.1)


func play_warning() -> void:
	for i in range(3):
		_play_tone(1000, 0.1, 0.2)


func _play_tone(freq: float, duration: float, volume: float) -> void:
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 22050
	generator.buffer_length = duration
	
	var player = AudioStreamPlayer.new()
	player.stream = generator
	player.volume_db = linear_to_db(volume) - 6
	player.finished.connect(_on_player_finished.bind(player))
	add_child(player)
	player.play()
	
	var playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
	if not playback: return
	
	var frames = int(generator.buffer_length * generator.mix_rate)
	for i in range(frames):
		var t = float(i) / generator.mix_rate
		var env = 1.0 - t / duration
		var s = sin(t * freq * PI * 2) * env * 0.5
		playback.push_frame(Vector2(s, s))
	
	players.append(player)
	if players.size() > max_players:
		var old = players.pop_front()
		if is_instance_valid(old):
			old.stop()
			old.queue_free()


func _play_noise(duration: float, volume: float) -> void:
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 22050
	generator.buffer_length = duration
	
	var player = AudioStreamPlayer.new()
	player.stream = generator
	player.volume_db = linear_to_db(volume) - 4
	player.finished.connect(_on_player_finished.bind(player))
	add_child(player)
	player.play()
	
	var playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
	if not playback: return
	
	var frames = int(generator.buffer_length * generator.mix_rate)
	for i in range(frames):
		var t = float(i) / generator.mix_rate
		var env = 1.0 - t / duration
		var s = (randf() * 2 - 1) * env * 0.6
		playback.push_frame(Vector2(s, s))
	
	players.append(player)
	if players.size() > max_players:
		var old = players.pop_front()
		if is_instance_valid(old): old.queue_free()


func _on_player_finished(player: AudioStreamPlayer) -> void:
	players.erase(player)
	player.queue_free()
