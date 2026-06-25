extends Node2D

## 单位管理器 — 选中、框选、命令、自动交战

var all_units: Array = []
var selected_units: Array = []

var is_box_selecting: bool = false
var box_start: Vector2
var box_end: Vector2


func _ready() -> void:
	set_process_input(true)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_box(event.position)
			else:
				_finish_box()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_issue_command()
	
	if event is InputEventMouseMotion and is_box_selecting:
		box_end = event.position
		queue_redraw()


func _start_box(pos: Vector2) -> void:
	is_box_selecting = true
	box_start = pos
	box_end = pos


func _finish_box() -> void:
	is_box_selecting = false
	var rect = _get_box_rect()
	
	if rect.size.length() < 8:
		# 单击 — 选中最前面的单位
		_click_select(box_start)
	else:
		_box_select(rect)
	
	queue_redraw()


func _click_select(screen_pos: Vector2) -> void:
	_deselect_all()
	var cam = get_viewport().get_camera_2d()
	if not cam: return
	var world_pos = cam.get_screen_transform().affine_inverse() * screen_pos
	
	# 优先选坦克
	var best = null
	var best_dist = 40.0
	for u in all_units:
		if not u.is_alive: continue
		var d = u.global_position.distance_to(world_pos)
		if d < best_dist:
			best = u
			best_dist = d
	
	if best:
		best.select()
		selected_units.append(best)


func _box_select(rect: Rect2) -> void:
	_deselect_all()
	var cam = get_viewport().get_camera_2d()
	if not cam: return
	
	for u in all_units:
		if not u.is_alive: continue
		var screen_pos = cam.get_canvas_transform() * u.global_position
		if rect.has_point(screen_pos):
			u.select()
			selected_units.append(u)


func _issue_command() -> void:
	if selected_units.is_empty(): return
	
	var cam = get_viewport().get_camera_2d()
	if not cam: return
	var target = cam.get_global_mouse_position()
	
	# 散开队形计算
	var count = selected_units.size()
	if count == 1:
		selected_units[0].command_move(target)
	elif count <= 8:
		var spacing = 50.0
		var cols = min(count, 4)
		for i in range(count):
			if selected_units[i].is_alive:
				var ox = (i % cols - cols/2.0) * spacing
				var oy = (i / cols - 1) * spacing
				selected_units[i].command_move(target + Vector2(ox, oy))
	else:
		# 大队形：双排
		var half = count / 2
		for i in range(count):
			if selected_units[i].is_alive:
				var row = 0 if i < half else 1
				var col = i if row == 0 else i - half
				var ox = (col - half/2.0) * 40
				var oy = row * 50 - 25
				selected_units[i].command_move(target + Vector2(ox, oy))


func _deselect_all() -> void:
	for u in selected_units:
		if is_instance_valid(u):
			u.deselect()
	selected_units.clear()


func _get_box_rect() -> Rect2:
	var x = min(box_start.x, box_end.x)
	var y = min(box_start.y, box_end.y)
	var w = abs(box_end.x - box_start.x)
	var h = abs(box_end.y - box_start.y)
	return Rect2(x, y, w, h)


# ── 绘制框选矩形 ──

func _draw() -> void:
	if is_box_selecting:
		var r = _get_box_rect()
		draw_rect(r, Color(0.2, 1.0, 0.2, 0.12))
		draw_rect(r, Color(0.2, 1.0, 0.2, 0.6), false, 1.5)


# ── 单位管理 ──

func register_unit(unit) -> void:
	all_units.append(unit)


func unregister_unit(unit) -> void:
	all_units.erase(unit)
	selected_units.erase(unit)


func get_faction_units(faction: String) -> Array:
	var r = []
	for u in all_units:
		if u.faction == faction and u.is_alive:
			r.append(u)
	return r


# ── 每帧自动交战检查 ──

func _process(_delta: float) -> void:
	if Engine.get_process_frames() % 30 != 0:
		return
	
	for u in all_units:
		if not u.is_alive or u.attack_target: continue
		# 单位自动索敌
		for other in all_units:
			if other == u or not other.is_alive or other.faction == u.faction: continue
			var dist = u.global_position.distance_to(other.global_position)
			if dist < u.attack_range * 1.2:
				u.command_attack(other)
				break
