extends CharacterBody2D

## 载具单位 — 坦克、装甲车

var unit_name: String = "Vehicle"
var unit_type: String = "vehicle"
var faction: String = "allied"
var max_health: float = 300.0
var speed: float = 200.0
var attack_range: float = 250.0
var attack_damage: float = 35.0
var attack_cooldown: float = 1.0
var build_cost: int = 700
var build_time: float = 10.0

var current_health: float
var is_selected: bool = false
var is_alive: bool = true
var attack_timer: float = 0.0

var move_target: Vector2 = Vector2.ZERO
var has_move_order: bool = false
var attack_target = null

var selection_indicator: Sprite2D
var health_bar: ProgressBar


func _ready() -> void:
	current_health = max_health
	_create_selection_indicator()
	_create_health_bar()


func _process(delta: float) -> void:
	if not is_alive: return
	attack_timer = max(0, attack_timer - delta)
	_update_selection_display()
	_update_health_bar()


func _physics_process(delta: float) -> void:
	if not is_alive: return
	if has_move_order:
		_move_toward_target(delta)


func _create_selection_indicator() -> void:
	selection_indicator = Sprite2D.new()
	selection_indicator.name = "SelectionIndicator"
	selection_indicator.visible = false
	add_child(selection_indicator)


func _create_health_bar() -> void:
	health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	health_bar.size = Vector2(48, 7)
	health_bar.position = Vector2(-24, -40)
	health_bar.max_value = max_health
	health_bar.value = current_health
	add_child(health_bar)


func _update_selection_display() -> void:
	if selection_indicator: selection_indicator.visible = is_selected


func _update_health_bar() -> void:
	if health_bar:
		health_bar.value = current_health
		health_bar.visible = current_health < max_health


func command_move(target: Vector2) -> void:
	move_target = target; has_move_order = true; attack_target = null


func command_attack(target) -> void:
	attack_target = target; has_move_order = false


func command_stop() -> void:
	has_move_order = false; attack_target = null; move_target = Vector2.ZERO


func select() -> void: is_selected = true
func deselect() -> void: is_selected = false


func take_damage(amount: float) -> void:
	current_health = max(0, current_health - amount)
	if current_health <= 0: _die()


func _die() -> void:
	is_alive = false; has_move_order = false; attack_target = null; queue_free()


func _move_toward_target(delta: float) -> void:
	var direction = move_target - global_position
	var distance = direction.length()
	if distance < 5.0: has_move_order = false; velocity = Vector2.ZERO; return
	velocity = direction.normalized() * speed
	move_and_slide()


func setup_as_grizzly() -> void:
	unit_name = "灰熊坦克"; faction = "allied"
	max_health = 300.0; speed = 250.0; attack_range = 250.0
	attack_damage = 35.0; attack_cooldown = 1.0; build_cost = 700
	current_health = max_health


func setup_as_rhino() -> void:
	unit_name = "犀牛坦克"; faction = "soviet"
	max_health = 400.0; speed = 200.0; attack_range = 250.0
	attack_damage = 45.0; attack_cooldown = 1.2; build_cost = 900
	current_health = max_health


func setup_as_yanhuang() -> void:
	unit_name = "炎黄坦克"; faction = "china"
	max_health = 600.0; speed = 170.0; attack_range = 280.0
	attack_damage = 75.0; attack_cooldown = 1.3; build_cost = 1200
	current_health = max_health
