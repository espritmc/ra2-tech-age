extends CharacterBody2D

## 步兵单位 — 程序化可视化
## 使用 _draw 渲染，无外部素材依赖

# ── 属性 ──
var unit_name: String = "步兵"
var faction: String = "allied"
var max_health: float = 100.0
var current_health: float = 100.0
var speed: float = 150.0
var attack_range: float = 180.0
var attack_damage: float = 10.0
var attack_cooldown: float = 0.6
var build_cost: int = 100
var is_alive: bool = true
var is_selected: bool = false

# ── 内部状态 ──
var move_target: Vector2
var has_move_order: bool = false
var attack_target = null
var attack_timer: float = 0.0
var death_timer: float = 0.0
var dying: bool = false

# ── 阵营颜色 ──
const FACTION_COLORS = {
	"allied": Color(0.2, 0.5, 1.0),    # 盟军蓝
	"soviet": Color(1.0, 0.2, 0.2),     # 苏联红
	"china": Color(1.0, 0.6, 0.1),      # 中国金
	"neutral": Color(0.7, 0.7, 0.7),     # 中立灰
}


func _ready() -> void:
	current_health = max_health


func _process(delta: float) -> void:
	if dying:
		death_timer += delta
		if death_timer > 0.4:
			queue_free()
		queue_redraw()
		return
	
	if not is_alive:
		return
	
	attack_timer = max(0, attack_timer - delta)
	
	# 攻击逻辑
	if attack_target and is_instance_valid(attack_target) and attack_target.is_alive:
		var dist = global_position.distance_to(attack_target.global_position)
		if dist <= attack_range:
			if attack_timer <= 0:
				attack_target.take_damage(attack_damage)
				attack_timer = attack_cooldown
		else:
			move_target = attack_target.global_position
			has_move_order = true
	else:
		attack_target = null
	
	queue_redraw()


func _physics_process(delta: float) -> void:
	if not is_alive or dying:
		return
	if has_move_order:
		var dir = move_target - global_position
		var dist = dir.length()
		if dist < 8.0:
			has_move_order = false
			velocity = Vector2.ZERO
		else:
			velocity = dir.normalized() * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()


# ── 绘制 ──

func _draw() -> void:
	if dying:
		# 死亡动画：缩小 + 变透明
		var s = 1.0 - death_timer * 2.0
		draw_circle(Vector2.ZERO, 8 * s, Color.RED, false, 2.0)
		return
	
	if not is_alive:
		return
	
	var color = FACTION_COLORS.get(faction, Color.GRAY)
	
	# 身体（圆形）
	draw_circle(Vector2.ZERO, 8, color)
	
	# 选中发光
	if is_selected:
		draw_circle(Vector2.ZERO, 14, Color(0.2, 1.0, 0.2, 0.3))
		draw_arc(Vector2.ZERO, 14, 0, TAU, 32, Color(0.2, 1.0, 0.2, 0.6), 2.0)
	
	# 攻击范围指示
	if is_selected and attack_target:
		draw_circle(Vector2.ZERO, attack_range, Color(1.0, 0.0, 0.0, 0.08))
	
	# 血条
	if current_health < max_health:
		var bar_w = 20.0
		var bar_h = 3.0
		var bar_y = -16.0
		draw_rect(Rect2(-bar_w/2, bar_y, bar_w, bar_h), Color(0.3, 0.1, 0.1))
		draw_rect(Rect2(-bar_w/2, bar_y, bar_w * current_health / max_health, bar_h), Color.RED)
	
	# 名称标签
	if is_selected:
		draw_string(ThemeDB.fallback_font, Vector2(-20, -22), unit_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.WHITE)


# ── 命令接口 ──

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
	if dying:
		return
	current_health = max(0, current_health - amount)
	if current_health <= 0:
		_die()


func _die() -> void:
	is_alive = false; dying = true; death_timer = 0.0
	has_move_order = false; attack_target = null
	collision_layer = 0; collision_mask = 0
	_spawn_death_fx()


func _spawn_death_fx() -> void:
	var tree = get_tree()
	if not tree: return
	var world = tree.get_first_node_in_group("game_world")
	if world and world.has_method("spawn_explosion"):
		world.spawn_explosion(global_position, 1.0)


# ── 预设配置 ──

func setup_as_gi() -> void:
	unit_name = "GI 大兵"; faction = "allied"
	max_health = 125; speed = 160; attack_range = 200
	attack_damage = 12; attack_cooldown = 0.5; build_cost = 200
	current_health = max_health


func setup_as_conscript() -> void:
	unit_name = "动员兵"; faction = "soviet"
	max_health = 100; speed = 140; attack_range = 190
	attack_damage = 10; attack_cooldown = 0.55; build_cost = 100
	current_health = max_health


func setup_as_hacker() -> void:
	unit_name = "黑客"; faction = "china"
	max_health = 80; speed = 190; attack_range = 130
	attack_damage = 0; attack_cooldown = 2.0; build_cost = 300
	current_health = max_health


func setup_as_engineer() -> void:
	unit_name = "工程师"; faction = "neutral"
	max_health = 75; speed = 110; attack_range = 60
	attack_damage = 0; attack_cooldown = 0; build_cost = 500
	current_health = max_health
