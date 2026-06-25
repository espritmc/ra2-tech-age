extends CharacterBody2D
class_name Unit

## 单位基类
##
## 所有可移动游戏实体（步兵、载具、飞行器）的公共基类。
## 提供：选中、移动命令、攻击命令、生命值、归属阵营。

# 单位属性
@export var unit_name: String = "Unit"
@export var unit_type: String = "infantry"  # infantry, vehicle, aircraft
@export var faction: String = "allied"       # allied, soviet, china

@export var max_health: float = 100.0
@export var speed: float = 200.0
@export var attack_range: float = 150.0
@export var attack_damage: float = 15.0
@export var attack_cooldown: float = 1.0
@export var build_cost: int = 100
@export var build_time: float = 5.0  # 秒

# 状态
var current_health: float
var is_selected: bool = false
var is_alive: bool = true
var attack_timer: float = 0.0

# 命令
var move_target: Vector2 = Vector2.ZERO
var has_move_order: bool = false
var attack_target: Unit = null

# 节点引用
@onready var selection_indicator: Sprite2D = $SelectionIndicator
@onready var health_bar: ProgressBar = $HealthBar


func _ready() -> void:
	current_health = max_health
	_update_health_bar()
	
	# 创建选中指示器
	if not selection_indicator:
		_create_selection_indicator()
	if not health_bar:
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


## 创建选中指示器（绿色圆环）
func _create_selection_indicator() -> void:
	selection_indicator = Sprite2D.new()
	selection_indicator.name = "SelectionIndicator"
	selection_indicator.visible = false
	add_child(selection_indicator)


## 创建血条
func _create_health_bar() -> void:
	health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	health_bar.size = Vector2(40, 6)
	health_bar.position = Vector2(-20, -35)
	health_bar.max_value = max_health
	health_bar.value = current_health
	add_child(health_bar)


## 更新选中显示
func _update_selection_display() -> void:
	if selection_indicator:
		selection_indicator.visible = is_selected


## 更新血条
func _update_health_bar() -> void:
	if health_bar:
		health_bar.value = current_health
		health_bar.visible = current_health < max_health


## 发出移动命令
func command_move(target: Vector2) -> void:
	move_target = target
	has_move_order = true
	attack_target = null


## 发出攻击命令
func command_attack(target: Unit) -> void:
	attack_target = target
	has_move_order = false


## 发出停止命令
func command_stop() -> void:
	has_move_order = false
	attack_target = null
	move_target = Vector2.ZERO


## 选中
func select() -> void:
	is_selected = true


## 取消选中
func deselect() -> void:
	is_selected = false


## 受到伤害
func take_damage(amount: float) -> void:
	current_health = max(0, current_health - amount)
	
	if current_health <= 0:
		_die()


## 死亡
func _die() -> void:
	is_alive = false
	has_move_order = false
	attack_target = null
	queue_free()


## 攻击目标
func _try_attack_target(delta: float) -> void:
	if attack_target == null or not is_instance_valid(attack_target):
		attack_target = null
		return
	
	if not attack_target.is_alive:
		attack_target = null
		return
	
	var distance = global_position.distance_to(attack_target.global_position)
	
	if distance <= attack_range:
		if attack_timer <= 0:
			attack_target.take_damage(attack_damage)
			attack_timer = attack_cooldown
	else:
		# 移动到攻击范围内
		move_target = attack_target.global_position
		has_move_order = true


## 移动到目标
func _move_toward_target(delta: float) -> void:
	var direction = move_target - global_position
	var distance = direction.length()
	
	if distance < 5.0:
		has_move_order = false
		velocity = Vector2.ZERO
		return
	
	velocity = direction.normalized() * speed
	move_and_slide()
