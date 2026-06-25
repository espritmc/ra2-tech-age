extends Node
class_name AIController

## AI 控制器 — 简单敌方 AI
## 建造基地 → 生产单位 → 进攻玩家

const BuildingScript = preload("res://scripts/Buildings/Building.gd")
const InfantryScript = preload("res://scripts/Units/Infantry.gd")

enum AIState { BUILDING, PRODUCING, ATTACKING, DEFENDING }

var state: int = AIState.BUILDING
var faction: String = "soviet"
var enemy_faction: String = "allied"

var resource_system   # ResourceSystem
var building_manager  # BuildingManager
var unit_manager      # UnitManager
var map_system        # MapSystem

var state_timer: float = 0.0
var attack_interval: float = 20.0
var production_interval: float = 5.0
var production_timer: float = 0.0
var base_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	print("[AIController] AI 就绪 — 阵营: %s" % faction)


func init(res, bm, um, ms) -> void:
	resource_system = res
	building_manager = bm
	unit_manager = um
	map_system = ms


func _process(delta: float) -> void:
	state_timer += delta
	production_timer += delta
	
	match state:
		AIState.BUILDING:
			_do_building_phase()
		AIState.PRODUCING:
			_do_producing_phase()
		AIState.ATTACKING:
			_do_attacking_phase()
		AIState.DEFENDING:
			_do_defending_phase()


func _do_building_phase() -> void:
	if building_manager.all_buildings.is_empty():
		var yard = building_manager._create_building(BuildingScript.BuildingType.CONSTRUCTION_YARD)
		yard.global_position = base_position
		yard.is_placed = true
		building_manager.add_child(yard)
		building_manager.all_buildings.append(yard)
	
	if state_timer > 2.0:
		state = AIState.PRODUCING


func _do_producing_phase() -> void:
	if production_timer >= production_interval:
		production_timer = 0.0
		_spawn_infantry()
	
	if state_timer > attack_interval:
		state_timer = 0.0
		state = AIState.ATTACKING


func _do_attacking_phase() -> void:
	var attack_pos = Vector2(map_system.MAP_WIDTH / 2 * 64, map_system.MAP_HEIGHT / 2 * 64)
	
	for unit in unit_manager.get_faction_units(faction):
		unit.command_move(attack_pos + Vector2(randf_range(-200, 200), randf_range(-200, 200)))
	
	state = AIState.PRODUCING


func _do_defending_phase() -> void:
	for unit in unit_manager.get_faction_units(faction):
		unit.command_move(base_position + Vector2(randf_range(-100, 100), randf_range(-100, 100)))
	
	state = AIState.PRODUCING


func _spawn_infantry() -> void:
	if unit_manager.all_units.size() > 50:
		return
	
	var spawn_pos = base_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
	
	var infantry = InfantryScript.new()
	infantry.setup_as_conscript()
	infantry.global_position = spawn_pos
	unit_manager.add_child(infantry)
	unit_manager.register_unit(infantry)
