extends Node2D
class_name GameWorld

## 游戏世界根节点
##
## 管理所有游戏实体的顶层容器：
## - MapSystem   (地形、地图)
## - UnitManager (所有单位)
## - BuildingManager (所有建筑)
## - 相机控制
##
## 是 RTS 游戏的核心枢纽。

# 子系统引用
var map_system: Node2D = null
var unit_manager: Node2D = null
var building_manager: Node2D = null

# 相机
var camera: Camera2D
var camera_speed: float = 600.0
var zoom_min: float = 0.3
var zoom_max: float = 2.0
var zoom_step: float = 0.1

func _ready() -> void:
	print("[GameWorld] 初始化游戏世界...")
	
	_setup_camera()
	_initialize_subsystems()
	
	print("[GameWorld] 游戏世界就绪")

func _setup_camera() -> void:
	camera = Camera2D.new()
	camera.position = Vector2(640, 360)  # 1280x720 居中
	camera.zoom = Vector2(1.0, 1.0)
	camera.make_current()
	add_child(camera)

func _initialize_subsystems() -> void:
	# 子系统占位 — 后续 feature 会逐个填充
	pass

func _process(delta: float) -> void:
	_handle_camera_movement(delta)

func _handle_camera_movement(delta: float) -> void:
	var input_dir = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	if input_dir != Vector2.ZERO:
		camera.position += input_dir.normalized() * camera_speed * delta / camera.zoom
	
	# 缩放
	if Input.is_action_just_pressed("camera_zoom_in"):
		camera.zoom = (camera.zoom - Vector2(zoom_step, zoom_step)).clamp(Vector2(zoom_min, zoom_min), Vector2(zoom_max, zoom_max))
	if Input.is_action_just_pressed("camera_zoom_out"):
		camera.zoom = (camera.zoom + Vector2(zoom_step, zoom_step)).clamp(Vector2(zoom_min, zoom_min), Vector2(zoom_max, zoom_max))
