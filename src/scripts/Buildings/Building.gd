extends StaticBody2D

## 建筑基类 — 程序化可视化
## _draw 渲染建筑形状

enum BuildingType {
	CONSTRUCTION_YARD, POWER_PLANT, REFINERY,
	BARRACKS, WAR_FACTORY, AIR_COMMAND,
	BATTLE_LAB, SUPER_WEAPON, DEFENSE_TOWER,
}

@export var building_name: String = "建筑"
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
var occupied_tiles: Array = []
var production_queue: Array = []
var production_timer: float = 0.0
var is_producing: bool = false
var dying: bool = false
var death_timer: float = 0.0

const FACTION_COLORS = {
	"allied": Color(0.15, 0.4, 0.8),
	"soviet": Color(0.8, 0.15, 0.1),
	"china": Color(0.85, 0.5, 0.05),
}


func _ready() -> void:
	current_health = max_health


func _process(delta: float) -> void:
	if dying:
		death_timer += delta
		if death_timer > 0.6:
			queue_free()
		queue_redraw()
		return
	if not is_alive: return
	if is_producing:
		_process_production(delta)
	queue_redraw()


func _draw() -> void:
	if dying:
		var s = 1.0 - death_timer * 1.5
		draw_rect(Rect2(-32*s, -32*s, 64*s, 64*s), Color(1, 0.3, 0, 0.5))
		return
	if not is_alive: return
	
	var w = build_size.x * 64.0
	var h = build_size.y * 64.0
	var color = FACTION_COLORS.get(faction, Color(0.5, 0.5, 0.5))
	
	# 建筑主体
	draw_rect(Rect2(0, 0, w, h), color.darkened(0.2))
	draw_rect(Rect2(2, 2, w-4, h-4), color)
	
	# 类型标记线
	match building_type:
		BuildingType.POWER_PLANT:
			draw_rect(Rect2(w*0.3, h*0.3, w*0.4, h*0.4), Color.YELLOW)
		BuildingType.BARRACKS:
			draw_rect(Rect2(w*0.25, h*0.2, w*0.5, h*0.6), color.lightened(0.2))
		BuildingType.WAR_FACTORY:
			draw_line(Vector2(w*0.1, h*0.5), Vector2(w*0.9, h*0.5), color.lightened(0.2), 3)
		BuildingType.REFINERY:
			draw_circle(Vector2(w/2, h/2), min(w,h)*0.25, Color(1, 0.84, 0))
	
	# 选中发光
	if is_selected:
		draw_rect(Rect2(-2, -2, w+4, h+4), Color(0.2, 1.0, 0.2, 0.3), false, 3)
	
	# 生产进度条
	if is_producing and not production_queue.is_empty():
		var item = production_queue[0]
		var pct = item["progress"] / item["time"]
		draw_rect(Rect2(4, h-10, (w-8)*pct, 6), Color(0.3, 0.8, 1.0))
	
	# 血条
	if current_health < max_health:
		var bw = w - 8; var bh = 5; var by = -10
		draw_rect(Rect2(4, by, bw, bh), Color(0.2, 0.05, 0.05))
		draw_rect(Rect2(4, by, bw * current_health / max_health, bh), Color.RED)
	
	# 名称
	if is_selected:
		draw_string(ThemeDB.fallback_font, Vector2(4, -18), building_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)


func select() -> void: is_selected = true
func deselect() -> void: is_selected = false


func take_damage(amount: float) -> void:
	if dying: return
	current_health = max(0, current_health - amount)
	if current_health <= 0: _die()


func _die() -> void:
	is_alive = false; dying = true
	death_timer = 0.0; is_producing = false
	_spawn_death_fx()


func _spawn_death_fx() -> void:
	var tree = get_tree()
	if not tree: return
	var world = tree.get_first_node_in_group("game_world")
	if world and world.has_method("spawn_explosion"):
		world.spawn_explosion(global_position, 2.0)


func queue_production(unit_type: String, cost: int, time: float) -> void:
	production_queue.append({"unit_type": unit_type, "cost": cost, "time": time, "progress": 0.0})
	is_producing = true


func cancel_production(index: int) -> void:
	if index < production_queue.size(): production_queue.remove_at(index)


func _process_production(delta: float) -> void:
	if production_queue.is_empty(): is_producing = false; return
	var item = production_queue[0]
	item["progress"] += delta
	if item["progress"] >= item["time"]:
		production_queue.pop_front()
		_on_unit_produced(item["unit_type"])


func _on_unit_produced(_unit_type: String) -> void:
	pass


func get_occupied_tiles(base_tile: Vector2i) -> Array:
	var tiles = []
	for x in range(build_size.x):
		for y in range(build_size.y):
			tiles.append(Vector2i(base_tile.x + x, base_tile.y + y))
	return tiles
