extends Node

## AI 控制器 — 定时生产 + 进攻

enum AIState { BUILDING, PRODUCING, ATTACKING }

var state: int = AIState.BUILDING
var faction: String = "soviet"
var resource_system; var building_manager; var unit_manager; var map_system
var game_world  # GameWorld 引用

var state_timer: float = 0.0
var attack_interval: float = 16.0
var production_interval: float = 4.0
var production_timer: float = 0.0
var base_position: Vector2 = Vector2.ZERO
var InfantryScript = preload("res://scripts/Units/Infantry.gd")
var VehicleScript = preload("res://scripts/Units/Vehicle.gd")
var BuildingScript = preload("res://scripts/Buildings/Building.gd")

func _ready() -> void:
	print("[AIController] soviet AI 就绪")


func init(res, bm, um, ms) -> void:
	resource_system = res; building_manager = bm; unit_manager = um; map_system = ms


func _process(delta: float) -> void:
	state_timer += delta
	production_timer += delta
	match state:
		AIState.BUILDING: _do_building_phase()
		AIState.PRODUCING: _do_producing_phase()
		AIState.ATTACKING: _do_attacking_phase()


func _do_building_phase() -> void:
	var existing = 0
	for b in building_manager.all_buildings:
		if b.faction == faction:
			existing += 1
	
	if existing == 0:
		# 放置建造场
		var yard = BuildingScript.new()
		yard.building_name = "建造场"; yard.building_type = BuildingScript.BuildingType.CONSTRUCTION_YARD
		yard.faction = faction; yard.max_health = 2000; yard.current_health = 2000
		yard.build_size = Vector2i(3, 3); yard.is_placed = true; yard.power_provided = 50
		yard.global_position = base_position
		get_parent().add_child(yard)
		building_manager.all_buildings.append(yard)
	elif existing < 2 and state_timer > 3.0:
		# 放置兵营
		var br = BuildingScript.new()
		br.building_name = "兵营"; br.building_type = BuildingScript.BuildingType.BARRACKS
		br.faction = faction; br.max_health = 800; br.current_health = 800
		br.build_size = Vector2i(2, 2); br.is_placed = true; br.power_consumed = 20
		br.global_position = base_position + Vector2(200, 0)
		get_parent().add_child(br)
		building_manager.all_buildings.append(br)
	
	if state_timer > 4.0:
		state = AIState.PRODUCING


func _do_producing_phase() -> void:
	var my_units = 0
	for u in unit_manager.all_units:
		if u.faction == faction and u.is_alive:
			my_units += 1
	
	if production_timer >= production_interval and my_units < 40:
		production_timer = 0.0
		_spawn_unit()
	
	if state_timer > attack_interval and my_units > 5:
		state_timer = 0.0
		state = AIState.ATTACKING


func _do_attacking_phase() -> void:
	var target = Vector2(map_system.MAP_WIDTH / 2 * 64, map_system.MAP_HEIGHT / 2 * 64)
	for u in unit_manager.all_units:
		if u.faction == faction and u.is_alive:
			# 攻击移动：朝敌人基地方向移动
			var offset = Vector2(randf_range(-300, 300), randf_range(-300, 300))
			u.command_move(target + offset)
	
	state = AIState.PRODUCING


func _spawn_unit() -> void:
	var pos = base_position + Vector2(randf_range(-150, 150), randf_range(-150, 150))
	
	if randi() % 3 == 0:
		# 生产坦克
		var v = VehicleScript.new()
		v.setup_as_rhino()
		v.global_position = pos
		get_parent().add_child(v)
		unit_manager.register_unit(v)
	else:
		# 生产步兵
		var inf = InfantryScript.new()
		inf.setup_as_conscript()
		inf.global_position = pos
		get_parent().add_child(inf)
		unit_manager.register_unit(inf)
