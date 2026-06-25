extends Node2D
class_name BuildingManager

## 建筑管理器
##
## 管理场景中所有建筑，处理建筑放置验证、生产管理。

# 预加载脚本
const BuildingScript = preload("res://scripts/Buildings/Building.gd")

# 所有建筑
var all_buildings: Array = []
var selected_building  # Building

# 放置预览
var is_placing: bool = false
var placing_building_type: int = 0  # Building.BuildingType
var placing_preview: ColorRect
var map_system  # MapSystem


func _ready() -> void:
	_create_placing_preview()


func _create_placing_preview() -> void:
	placing_preview = ColorRect.new()
	placing_preview.name = "PlacingPreview"
	placing_preview.color = Color(0.2, 1.0, 0.2, 0.3)
	placing_preview.visible = false
	add_child(placing_preview)


func init(map) -> void:
	map_system = map


func _process(_delta: float) -> void:
	if is_placing:
		_update_placing_preview()


func _input(event: InputEvent) -> void:
	if not is_placing:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_try_place_building()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		cancel_placing()


func start_placing(type: int) -> void:
	is_placing = true
	placing_building_type = type
	placing_preview.visible = true
	var size = _get_building_tile_size(type)
	placing_preview.size = Vector2(size.x * 64, size.y * 64)


func cancel_placing() -> void:
	is_placing = false
	placing_preview.visible = false


func _update_placing_preview() -> void:
	var mouse_pos = _get_mouse_tile_pos()
	placing_preview.position = Vector2(mouse_pos.x * 64, mouse_pos.y * 64)
	
	if _can_place_at(mouse_pos):
		placing_preview.color = Color(0.2, 1.0, 0.2, 0.3)
	else:
		placing_preview.color = Color(1.0, 0.2, 0.2, 0.3)


func _try_place_building() -> void:
	var tile_pos = _get_mouse_tile_pos()
	
	if not _can_place_at(tile_pos):
		return
	
	var world_pos = map_system.tile_to_world(tile_pos)
	var building = _create_building(placing_building_type)
	building.global_position = world_pos
	building.is_placed = true
	building.occupied_tiles = building.get_occupied_tiles(tile_pos)
	
	add_child(building)
	all_buildings.append(building)
	
	cancel_placing()
	print("[BuildingManager] 建筑已放置: %s at %s" % [building.building_name, tile_pos])


func _can_place_at(tile_pos: Vector2i) -> bool:
	if not map_system:
		return true
	
	var size = _get_building_tile_size(placing_building_type)
	for x in range(size.x):
		for y in range(size.y):
			var check_tile = Vector2i(tile_pos.x + x, tile_pos.y + y)
			if not map_system.is_buildable(check_tile):
				return false
			
			for b in all_buildings:
				for ot in b.occupied_tiles:
					if ot == check_tile:
						return false
	
	return true


func _get_building_tile_size(type: int) -> Vector2i:
	var BT = BuildingScript.BuildingType
	match type:
		BT.CONSTRUCTION_YARD:
			return Vector2i(3, 3)
		BT.WAR_FACTORY:
			return Vector2i(3, 2)
		BT.REFINERY:
			return Vector2i(3, 2)
		BT.BARRACKS, BT.BATTLE_LAB:
			return Vector2i(2, 2)
		_:
			return Vector2i(2, 2)


func _get_mouse_tile_pos() -> Vector2i:
	var viewport = get_viewport()
	var camera = viewport.get_camera_2d()
	var mouse_pos = camera.get_global_mouse_position() if camera else viewport.get_mouse_position()
	return map_system.world_to_tile(mouse_pos) if map_system else Vector2i.ZERO


func _create_building(type: int):
	var building = BuildingScript.new()
	building.building_type = type
	
	var BT = BuildingScript.BuildingType
	match type:
		BT.CONSTRUCTION_YARD:
			building.building_name = "建造场"
			building.max_health = 2000.0
			building.build_cost = 0
			building.power_provided = 50
			building.build_size = Vector2i(3, 3)
		BT.POWER_PLANT:
			building.building_name = "发电厂"
			building.max_health = 750.0
			building.build_cost = 300
			building.power_provided = 100
			building.build_size = Vector2i(2, 2)
		BT.REFINERY:
			building.building_name = "矿场"
			building.max_health = 1000.0
			building.build_cost = 2000
			building.power_consumed = 30
			building.build_size = Vector2i(3, 2)
		BT.BARRACKS:
			building.building_name = "兵营"
			building.max_health = 800.0
			building.build_cost = 500
			building.power_consumed = 20
			building.build_size = Vector2i(2, 2)
		BT.WAR_FACTORY:
			building.building_name = "战车工厂"
			building.max_health = 1200.0
			building.build_cost = 2000
			building.power_consumed = 30
			building.build_size = Vector2i(3, 2)
		BT.AIR_COMMAND:
			building.building_name = "空指部"
			building.max_health = 1000.0
			building.build_cost = 1500
			building.power_consumed = 50
			building.build_size = Vector2i(2, 2)
		BT.BATTLE_LAB:
			building.building_name = "作战实验室"
			building.max_health = 600.0
			building.build_cost = 3000
			building.power_consumed = 100
			building.build_size = Vector2i(2, 2)
		BT.SUPER_WEAPON:
			building.building_name = "超级武器"
			building.max_health = 1200.0
			building.build_cost = 5000
			building.power_consumed = 200
			building.build_size = Vector2i(2, 2)
		BT.DEFENSE_TOWER:
			building.building_name = "防御塔"
			building.max_health = 500.0
			building.build_cost = 600
			building.power_consumed = 20
			building.build_size = Vector2i(1, 1)
	
	building.current_health = building.max_health
	return building
