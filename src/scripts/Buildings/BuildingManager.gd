extends Node2D

## 建筑管理器 — 放置预览、验证、建造、选中

const BuildingScript = preload("res://scripts/Buildings/Building.gd")

var all_buildings: Array = []
var selected_building = null
var map_system

var is_placing: bool = false
var placing_type: int = 0
var placing_size: Vector2i = Vector2i(2, 2)
var can_place: bool = false


func _ready() -> void:
	set_process_input(true)


func init(map) -> void:
	map_system = map


func _input(event: InputEvent) -> void:
	if not is_placing: return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and can_place:
			_place()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			cancel_placing()
	
	if event is InputEventMouseMotion:
		queue_redraw()


func start_placing(type: int) -> void:
	is_placing = true
	placing_type = type
	placing_size = _get_size(type)
	queue_redraw()


func cancel_placing() -> void:
	is_placing = false
	can_place = false
	queue_redraw()


func _get_tile_pos() -> Vector2i:
	var cam = get_viewport().get_camera_2d()
	if not cam or not map_system: return Vector2i.ZERO
	return map_system.world_to_tile(cam.get_global_mouse_position())


func _get_size(type: int) -> Vector2i:
	var BT = BuildingScript.BuildingType
	match type:
		BT.CONSTRUCTION_YARD: return Vector2i(3, 3)
		BT.WAR_FACTORY, BT.REFINERY: return Vector2i(3, 2)
		_: return Vector2i(2, 2)


func _can_place_at(tile: Vector2i) -> bool:
	if not map_system: return true
	for x in range(placing_size.x):
		for y in range(placing_size.y):
			var ct = Vector2i(tile.x + x, tile.y + y)
			if not map_system.is_buildable(ct): return false
			for b in all_buildings:
				for ot in b.occupied_tiles:
					if ot == ct: return false
	return true


func _place() -> void:
	var tile = _get_tile_pos()
	var world_pos = map_system.tile_to_world(tile) if map_system else Vector2.ZERO
	
	var building = _make_building(placing_type)
	building.global_position = world_pos
	building.is_placed = true
	building.occupied_tiles = building.get_occupied_tiles(tile)
	
	get_parent().add_child(building)
	all_buildings.append(building)
	cancel_placing()


func _make_building(type: int):
	var b = BuildingScript.new()
	b.building_type = type
	var BT = BuildingScript.BuildingType
	match type:
		BT.CONSTRUCTION_YARD:
			b.building_name = "建造场"; b.max_health = 2000; b.build_cost = 0; b.power_provided = 50; b.build_size = Vector2i(3, 3)
		BT.POWER_PLANT:
			b.building_name = "发电厂"; b.max_health = 750; b.build_cost = 300; b.power_provided = 100; b.build_size = Vector2i(2, 2)
		BT.REFINERY:
			b.building_name = "矿场"; b.max_health = 1000; b.build_cost = 2000; b.power_consumed = 30; b.build_size = Vector2i(3, 2)
		BT.BARRACKS:
			b.building_name = "兵营"; b.max_health = 800; b.build_cost = 500; b.power_consumed = 20; b.build_size = Vector2i(2, 2)
		BT.WAR_FACTORY:
			b.building_name = "战车工厂"; b.max_health = 1200; b.build_cost = 2000; b.power_consumed = 30; b.build_size = Vector2i(3, 2)
		BT.AIR_COMMAND:
			b.building_name = "空指部"; b.max_health = 1000; b.build_cost = 1500; b.power_consumed = 50; b.build_size = Vector2i(2, 2)
		BT.BATTLE_LAB:
			b.building_name = "作战实验室"; b.max_health = 600; b.build_cost = 3000; b.power_consumed = 100; b.build_size = Vector2i(2, 2)
		BT.SUPER_WEAPON:
			b.building_name = "超级武器"; b.max_health = 1200; b.build_cost = 5000; b.power_consumed = 200; b.build_size = Vector2i(2, 2)
		BT.DEFENSE_TOWER:
			b.building_name = "防御塔"; b.max_health = 500; b.build_cost = 600; b.power_consumed = 20; b.build_size = Vector2i(1, 1)
	b.current_health = b.max_health
	return b


func _draw() -> void:
	if not is_placing: return
	
	var tile = _get_tile_pos()
	can_place = _can_place_at(tile)
	
	var world_pos = Vector2(tile.x * 64, tile.y * 64)
	var w = placing_size.x * 64.0
	var h = placing_size.y * 64.0
	var color = Color(0.2, 1.0, 0.2, 0.35) if can_place else Color(1.0, 0.2, 0.2, 0.35)
	
	draw_rect(Rect2(world_pos, Vector2(w, h)), color)
	draw_rect(Rect2(world_pos, Vector2(w, h)), color.lightened(0.3), false, 2.0)
