extends CharacterBody2D

## 步兵单位
##
## 地面步兵，速度较慢，生命值低，可被运输。

const UnitBase = preload("res://scripts/Units/Unit.gd")

var unit_name: String = "Infantry"
var unit_type: String = "infantry"
var faction: String = "allied"
var max_health: float = 100.0
var speed: float = 200.0
var attack_range: float = 150.0
var attack_damage: float = 15.0
var attack_cooldown: float = 1.0
var build_cost: int = 100
var build_time: float = 5.0

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
	_update_health_bar()
	_create_selection_indicator()
	_create_health_bar()


func _process(delta: float) -> void:
	if not is_alive:
		return
	attack_timer = max(0, attack_timer - delta)
	_update_selection_display()
	_update_health_bar()


func _physics_process(delta: float) -> void:
	if not is_alive:
		return
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
	health_bar.size = Vector2(40, 6)
	health_bar.position = Vector2(-20, -35)
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


func command_move(target: Vector2) -> void:
	move_target = target
	has_move_order = true
	attack_target = null


func command_attack(target) -> void:
	attack_target = target
	has_move_order = false


func command_stop() -> void:
	has_move_order = false
	attack_target = null
	move_target = Vector2.ZERO


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
	has_move_order = false
	attack_target = null
	queue_free()


func _move_toward_target(delta: float) -> void:
	var direction = move_target - global_position
	var distance = direction.length()
	if distance < 5.0:
		has_move_order = false
		velocity = Vector2.ZERO
		return
	velocity = direction.normalized() * speed
	move_and_slide()


func setup_as_gi() -> void:
	unit_name = "GI 大兵"
	faction = "allied"
	max_health = 125.0; speed = 160.0; attack_range = 180.0
	attack_damage = 10.0; attack_cooldown = 0.5; build_cost = 200
	current_health = max_health


func setup_as_conscript() -> void:
	unit_name = "动员兵"
	faction = "soviet"
	max_health = 100.0; speed = 150.0; attack_range = 180.0
	attack_damage = 8.0; attack_cooldown = 0.6; build_cost = 100
	current_health = max_health


func setup_as_hacker() -> void:
	unit_name = "黑客"
	faction = "china"
	max_health = 80.0; speed = 200.0; attack_range = 120.0
	attack_damage = 0.0; attack_cooldown = 2.0; build_cost = 300
	current_health = max_health


func setup_as_engineer() -> void:
	unit_name = "工程师"
	faction = "neutral"
	max_health = 75.0; speed = 120.0; attack_range = 50.0
	attack_damage = 0.0; attack_cooldown = 0.0; build_cost = 500
	current_health = max_health
