extends Node2D
class_name UnitManager

## 单位管理器
##
## 管理场景中所有单位，处理选中、框选、编队、批量命令。

const UnitScript = preload("res://scripts/Units/Unit.gd")

var all_units: Array = []
var selected_units: Array = []

var is_box_selecting: bool = false
var box_select_start: Vector2 = Vector2.ZERO
var box_select_end: Vector2 = Vector2.ZERO
var box_select_rect: ColorRect


func _ready() -> void:
	_create_box_select_rect()


func _create_box_select_rect() -> void:
	box_select_rect = ColorRect.new()
	box_select_rect.name = "BoxSelectRect"
	box_select_rect.color = Color(0.2, 1.0, 0.2, 0.15)
	box_select_rect.visible = false
	add_child(box_select_rect)


func _input(event: InputEvent) -> void:
	_handle_selection(event)
	_handle_commands(event)


func _handle_selection(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_box_select_start(event.position)
		else:
			_box_select_finish()


func _handle_commands(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var world_pos = _get_world_mouse_pos()
		_command_move(world_pos)


func _box_select_start(pos: Vector2) -> void:
	is_box_selecting = true
	box_select_start = pos
	box_select_rect.visible = true


func _box_select_update(pos: Vector2) -> void:
	box_select_end = pos
	var rect = _get_box_rect()
	box_select_rect.position = rect.position
	box_select_rect.size = rect.size


func _box_select_finish() -> void:
	is_box_selecting = false
	box_select_rect.visible = false
	
	var rect = _get_box_rect()
	_select_units_in_rect(rect)


func _get_box_rect() -> Rect2:
	var x = min(box_select_start.x, box_select_end.x)
	var y = min(box_select_start.y, box_select_end.y)
	var w = abs(box_select_end.x - box_select_start.x)
	var h = abs(box_select_end.y - box_select_start.y)
	return Rect2(x, y, w, h)


func _select_units_in_rect(rect: Rect2) -> void:
	_deselect_all()
	
	for unit in all_units:
		if not unit.is_alive:
			continue
		var screen_pos = _world_to_screen(unit.global_position)
		if rect.has_point(screen_pos):
			unit.select()
			selected_units.append(unit)


func _deselect_all() -> void:
	for unit in selected_units:
		if is_instance_valid(unit):
			unit.deselect()
	selected_units.clear()


func _command_move(target: Vector2) -> void:
	var world_target = _get_world_mouse_pos()
	for unit in selected_units:
		if is_instance_valid(unit) and unit.is_alive:
			unit.command_move(world_target)


func _get_world_mouse_pos() -> Vector2:
	var viewport = get_viewport()
	var camera = viewport.get_camera_2d()
	if camera:
		return camera.get_global_mouse_position()
	return viewport.get_mouse_position()


func _world_to_screen(world_pos: Vector2) -> Vector2:
	var viewport = get_viewport()
	var camera = viewport.get_camera_2d()
	if camera:
		return camera.get_screen_transform() * world_pos
	return world_pos


func register_unit(unit) -> void:
	all_units.append(unit)


func unregister_unit(unit) -> void:
	all_units.erase(unit)
	selected_units.erase(unit)


func spawn_unit(unit_scene: PackedScene, position: Vector2, faction: String = "allied"):
	var unit = unit_scene.instantiate()
	unit.global_position = position
	unit.faction = faction
	add_child(unit)
	register_unit(unit)
	return unit


func get_faction_units(faction: String) -> Array:
	var result = []
	for unit in all_units:
		if unit.faction == faction and unit.is_alive:
			result.append(unit)
	return result
