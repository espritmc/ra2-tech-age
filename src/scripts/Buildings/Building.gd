extends StaticBody2D

## 建筑基类

enum BuildingType {
	CONSTRUCTION_YARD,
	POWER_PLANT,
	REFINERY,
	BARRACKS,
	WAR_FACTORY,
	AIR_COMMAND,
	BATTLE_LAB,
	SUPER_WEAPON,
	DEFENSE_TOWER,
}

@export var building_name: String = "Building"
@export var building_type: BuildingType = BuildingType.CONSTRUCTION_YARD
@export var faction: String = "allied"

@export var max_health: float = 1000.0
@export var build_cost: int = 500
@export var power_provided: int = 0
@export var power_consumed: int = 0
@export var build_size: Vector2i = Vector2i(2, 2)

var current_health: float
var is_placed: bool = false
var is_alive: bool = true
var is_selected: bool = false

var production_queue: Array = []
var production_timer: float = 0.0
var is_producing: bool = false
var occupied_tiles: Array = []

var selection_indicator: Sprite2D
var health_bar: ProgressBar


func _ready() -> void:
	current_health = max_health
	_create_indicators()


func _process(delta: float) -> void:
	if not is_alive:
		return
	
	_update_selection_display()
	_update_health_bar()
	
	if is_producing:
		_process_production(delta)


func _create_indicators() -> void:
	selection_indicator = Sprite2D.new()
	selection_indicator.name = "SelectionIndicator"
	selection_indicator.visible = false
	add_child(selection_indicator)
	
	health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	health_bar.size = Vector2(80, 8)
	health_bar.position = Vector2(-40, -60)
	health_bar.max_value = max_health
	health_bar.value = current_health
	add_child(health_bar)


func _update_selection_display() -> void:
	if selection_indicator:
		selection_indicator.visible = is_selected


func _update_health_bar() -> void:
	if health_bar:
		health_bar.value = current_health
		health_bar.visible = current_health < max_health


func select() -> void:
	is_selected = true


func deselect() -> void:
	is_selected = false


func take_damage(amount: float) -> void:
	current_health = max(0, current_health - amount)
	if current_health <= 0:
		_die()


func _die() -> void:
	is_alive = false
	queue_free()


func queue_production(unit_type: String, cost: int, time: float) -> void:
	production_queue.append({
		"unit_type": unit_type,
		"cost": cost,
		"time": time,
		"progress": 0.0
	})


func cancel_production(index: int) -> void:
	if index < production_queue.size():
		production_queue.remove_at(index)


func _process_production(delta: float) -> void:
	if production_queue.is_empty():
		is_producing = false
		return
	
	var item = production_queue[0]
	item["progress"] += delta
	
	if item["progress"] >= item["time"]:
		production_queue.pop_front()
		_on_unit_produced(item["unit_type"])


func _on_unit_produced(unit_type: String) -> void:
	pass


func get_occupied_tiles(base_tile: Vector2i) -> Array:
	var tiles = []
	for x in range(build_size.x):
		for y in range(build_size.y):
			tiles.append(Vector2i(base_tile.x + x, base_tile.y + y))
	return tiles
