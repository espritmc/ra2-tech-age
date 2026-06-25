extends Node2D

## RA2 科技时代 — 主入口
## 先加载主菜单，菜单选择"新游戏"后切换到 GameWorld

func _ready() -> void:
	print("=".repeat(40))
	print("  RA2 科技时代 v0.2.0")
	print("  引擎: ", Engine.get_version_info())
	print("=".repeat(40))
	
	get_tree().set_auto_accept_quit(false)
	
	# 延迟加载主菜单（等当前场景完全建立后）
	call_deferred("_load_menu")


func _load_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
