extends Control

## RA2 科技时代 — 主菜单
## 红色警戒风格：暗色背景、金属质感按钮、动画标题

var title_label: Label
var subtitle_label: Label
var menu_buttons: Array = []
var bg_color: Color = Color(0.05, 0.05, 0.08)
var anim_timer: float = 0.0

const GOLD = Color(0.95, 0.75, 0.1)
const RED = Color(0.85, 0.12, 0.08)


func _ready() -> void:
	_build_background()
	_build_title()
	_build_buttons()
	print("[MainMenu] 主菜单就绪")


func _build_background() -> void:
	var bg = ColorRect.new()
	bg.color = bg_color
	bg.size = Vector2(1280, 720)
	bg.position = Vector2.ZERO
	add_child(bg)
	
	# 装饰性条纹
	for i in range(5):
		var stripe = ColorRect.new()
		stripe.color = RED.darkened(0.3)
		stripe.position = Vector2(0, 140 + i * 120)
		stripe.size = Vector2(1280, 2)
		add_child(stripe)


func _build_title() -> void:
	# 主标题
	title_label = Label.new()
	title_label.text = "RA2 科技时代"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.position = Vector2(0, 160)
	title_label.size = Vector2(1280, 80)
	title_label.add_theme_color_override("font_color", RED)
	title_label.add_theme_font_size_override("font_size", 56)
	add_child(title_label)
	
	# 副标题
	subtitle_label = Label.new()
	subtitle_label.text = "— 红色警戒2 即时战略 —"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.position = Vector2(0, 240)
	subtitle_label.size = Vector2(1280, 30)
	subtitle_label.add_theme_color_override("font_color", GOLD)
	subtitle_label.add_theme_font_size_override("font_size", 18)
	add_child(subtitle_label)


func _build_buttons() -> void:
	var items = [
		{"text": "⚔ 新游戏", "action": "new_game"},
		{"text": "⚡ 遭遇战", "action": "skirmish"},
		{"text": "🌐 局域网对战", "action": "multiplayer"},
		{"text": "⚙ 设置", "action": "settings"},
		{"text": "✕ 退出", "action": "quit"},
	]
	
	for i in range(items.size()):
		var item = items[i]
		var btn = Button.new()
		btn.text = item["text"]
		btn.position = Vector2(500, 300 + i * 56)
		btn.size = Vector2(280, 46)
		btn.flat = true
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_font_size_override("font_size", 18)
		btn.self_modulate = Color(0.15, 0.13, 0.18)
		btn.pressed.connect(_on_menu_pressed.bind(item["action"]))
		add_child(btn)
		menu_buttons.append(btn)
	
	# 版本号
	var ver = Label.new()
	ver.text = "v0.2.0  |  macOS / Windows"
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ver.position = Vector2(0, 680)
	ver.size = Vector2(1280, 20)
	ver.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	ver.add_theme_font_size_override("font_size", 11)
	add_child(ver)


func _on_menu_pressed(action: String) -> void:
	match action:
		"new_game", "skirmish":
			_start_game()
		"multiplayer":
			pass  # TODO
		"settings":
			pass  # TODO
		"quit":
			get_tree().quit()


func _start_game() -> void:
	print("[MainMenu] 开始游戏...")
	get_tree().change_scene_to_file("res://scenes/GameWorld/GameWorld.tscn")


func _process(delta: float) -> void:
	anim_timer += delta
	# 标题呼吸动画
	var pulse = 1.0 + sin(anim_timer * 2.0) * 0.06
	title_label.scale = Vector2(pulse, pulse)
	
	# 按钮 hover 效果
	for btn in menu_buttons:
		var rect = Rect2(btn.position, btn.size)
		var mouse = get_global_mouse_position()
		if rect.has_point(mouse):
			btn.self_modulate = btn.self_modulate.lerp(Color(0.25, 0.2, 0.3), delta * 10)
		else:
			btn.self_modulate = btn.self_modulate.lerp(Color(0.15, 0.13, 0.18), delta * 10)
