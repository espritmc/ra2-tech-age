extends Node2D
class_name GameWorld

## RA2 科技时代 — 游戏世界核心枢纽
##
## 启动时按顺序初始化所有子系统：
##   MapSystem → ResourceSystem → BuildingManager → UnitManager → AIController → HUD
##
## 使用 preload 加载脚本，var 动态类型避免 Godot 解析期类型检查问题。

# === 子系统（延迟类型声明） ===
var map_system
var resource_system
var unit_manager
var building_manager
var combat_system
var ai_controller
var hud

# === 相机 ===
var camera: Camera2D
var camera_speed: float = 800.0
var zoom_min: float = 0.3
var zoom_max: float = 2.0
var zoom_step: float = 0.1


func _ready() -> void:
	print("[GameWorld] ═══ RA2 科技时代 — 游戏世界初始化 ═══")
	_setup_camera()
	_setup_map()
	_setup_resources()
	_setup_combat()
	_setup_buildings()
	_setup_units()
	_setup_ai()
	_setup_hud()
	print("[GameWorld] ✅ 所有系统就绪！")


func _setup_camera() -> void:
	camera = Camera2D.new()
	camera.position = Vector2(4096, 4096)
	camera.zoom = Vector2(0.8, 0.8)
	add_child(camera)
	camera.make_current()


func _setup_map() -> void:
	var MapSys = load("res://scripts/Map/MapSystem.gd")
	map_system = MapSys.new()
	map_system.name = "MapSystem"
	add_child(map_system)


func _setup_resources() -> void:
	var ResSys = load("res://scripts/Systems/ResourceSystem.gd")
	resource_system = ResSys.new()
	resource_system.name = "ResourceSystem"
	add_child(resource_system)
	resource_system.credits = 10000


func _setup_combat() -> void:
	var CombatSys = load("res://scripts/Systems/CombatSystem.gd")
	combat_system = CombatSys.new()
	combat_system.name = "CombatSystem"
	add_child(combat_system)


func _setup_buildings() -> void:
	var BldMgr = load("res://scripts/Buildings/BuildingManager.gd")
	building_manager = BldMgr.new()
	building_manager.name = "BuildingManager"
	add_child(building_manager)
	building_manager.init(map_system)


func _setup_units() -> void:
	var UnitMgr = load("res://scripts/Units/UnitManager.gd")
	unit_manager = UnitMgr.new()
	unit_manager.name = "UnitManager"
	add_child(unit_manager)


func _setup_ai() -> void:
	var AICtrl = load("res://scripts/AI/AIController.gd")
	ai_controller = AICtrl.new()
	ai_controller.name = "AIController"
	ai_controller.faction = "soviet"
	ai_controller.base_position = Vector2(9000, 5500)
	add_child(ai_controller)
	ai_controller.init(resource_system, building_manager, unit_manager, map_system)


func _setup_hud() -> void:
	var hud_scene = load("res://scripts/UI/Hud.tscn")
	hud = hud_scene.instantiate()
	hud.name = "HUD"
	add_child(hud)
	hud.init(resource_system, building_manager, unit_manager)


func _process(delta: float) -> void:
	_handle_camera_movement(delta)
	_update_camera_bounds()


func _handle_camera_movement(delta: float) -> void:
	var input_dir = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	if input_dir != Vector2.ZERO:
		camera.position += input_dir.normalized() * camera_speed * delta / camera.zoom
	
	if Input.is_action_just_pressed("camera_zoom_in"):
		camera.zoom = (camera.zoom - Vector2(zoom_step, zoom_step)).clamp(
			Vector2(zoom_min, zoom_min), Vector2(zoom_max, zoom_max))
	if Input.is_action_just_pressed("camera_zoom_out"):
		camera.zoom = (camera.zoom + Vector2(zoom_step, zoom_step)).clamp(
			Vector2(zoom_min, zoom_min), Vector2(zoom_max, zoom_max))


func _update_camera_bounds() -> void:
	var map_bounds = map_system.get_map_bounds()
	var view_size = get_viewport().get_visible_rect().size / camera.zoom
	var half_view = view_size / 2
	
	camera.position.x = clamp(camera.position.x, map_bounds.position.x + half_view.x, map_bounds.end.x - half_view.x)
	camera.position.y = clamp(camera.position.y, map_bounds.position.y + half_view.y, map_bounds.end.y - half_view.y)
