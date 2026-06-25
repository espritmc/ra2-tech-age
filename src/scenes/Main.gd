extends Node2D

## RA2 科技时代 — 主场景入口
##
## 负责：
## - 启动时加载游戏世界
## - 管理全局状态（主菜单 / 游戏中 / 暂停）
## - 处理退出确认

var game_world: Node2D
var current_state: String = "menu"  # menu, playing, paused

func _ready() -> void:
	print("=".repeat(40))
	print("  RA2 科技时代 v0.1.0")
	print("  引擎版本: ", Engine.get_version_info())
	print("=".repeat(40))
	
	get_tree().set_auto_accept_quit(false)
	
	# 直接进入游戏（MVP 阶段跳过主菜单）
	start_game()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_on_quit_request()

func start_game() -> void:
	print("[Main] 启动游戏世界...")
	current_state = "playing"
	
	var gw_scene = load("res://scenes/GameWorld/GameWorld.tscn")
	game_world = gw_scene.instantiate()
	add_child(game_world)
	print("[Main] GameWorld 已加载")

func _on_quit_request() -> void:
	print("[Main] 退出游戏")
	get_tree().quit()
