extends CharacterBody2D

## 载具单位 — 坦克/装甲车
## _draw 渲染坦克形状

var unit_name: String = "坦克"
var faction: String = "allied"
var max_health: float = 300.0
var current_health: float = 300.0
var speed: float = 220.0
var attack_range: float = 260.0
var attack_damage: float = 40.0
var attack_cooldown: float = 1.0
var build_cost: int = 700
var is_alive: bool = true
var is_selected: bool = false

var move_target: Vector2
var has_move_order: bool = false
var attack_target = null
var attack_timer: float = 0.0
var death_timer: float = 0.0
var dying: bool = false

const FACTION_COLORS = {
	"allied": Color(0.15, 0.45, 0.9),
	"soviet": Color(0.85, 0.15, 0.1),
	"china": Color(0.9, 0.55, 0.05),
	"neutral": Color(0.6, 0.6, 0.6),
}


func _ready() -> void:
	current_health = max_health
	add_to_group("vehicles")


func _process(delta: float) -> void:
	if dying:
		death_timer += delta
		if death_timer > 0.5:
			queue_free()
		queue_redraw()
		return
	
	if not is_alive:
		return
	
	attack_timer = max(0, attack_timer - delta)
	
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
		if dist < 10.0:
			has_move_order = false
			velocity = Vector2.ZERO
		else:
			velocity = dir.normalized() * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()


# ── 绘制坦克形状 ──

func _draw() -> void:
	if dying:
		var s = 1.0 - death_timer * 2.0
		draw_circle(Vector2.ZERO, 14 * s, Color(1, 0.3, 0, 0.7))
		return
	
	if not is_alive:
		return
	
	var color = FACTION_COLORS.get(faction, Color.GRAY)
	var dark = color.darkened(0.35)
	
	# 车身（矩形）
	draw_rect(Rect2(-14, -9, 28, 18), dark)
	draw_rect(Rect2(-12, -8, 24, 16), color)
	
	# 炮塔（圆）
	draw_circle(Vector2.ZERO, 8, dark)
	draw_circle(Vector2.ZERO, 6, color.lightened(0.15))
	
	# 炮管（指向移动方向或默认朝右）
	var gun_angle = 0.0
	if has_move_order and velocity.length() > 10:
		gun_angle = velocity.angle()
	var gun_end = Vector2(cos(gun_angle), sin(gun_angle)) * 18
	draw_line(Vector2.ZERO, gun_end, dark, 4)
	draw_line(Vector2.ZERO, gun_end * 0.9, color, 2)
	
	# 选中发光环
	if is_selected:
		draw_circle(Vector2.ZERO, 20, Color(0.2, 1.0, 0.2, 0.25))
		draw_arc(Vector2.ZERO, 20, 0, TAU, 32, Color(0.2, 1.0, 0.2, 0.7), 2.0)
	
	# 攻击范围
	if is_selected and attack_target:
		draw_circle(Vector2.ZERO, attack_range, Color(1, 0, 0, 0.06))
	
	# 血条
	if current_health < max_health:
		var bw = 30.0; var bh = 4.0; var by = -22.0
		draw_rect(Rect2(-bw/2, by, bw, bh), Color(0.2, 0.05, 0.05))
		draw_rect(Rect2(-bw/2, by, bw * current_health / max_health, bh), Color(1, 0.2, 0.2))
	
	# 标签
	if is_selected:
		draw_string(ThemeDB.fallback_font, Vector2(-22, -28), unit_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color.WHITE)


# ── 命令 ──

func command_move(target: Vector2) -> void:
	move_target = target; has_move_order = true; attack_target = null


func command_attack(target) -> void:
	attack_target = target; has_move_order = false


func command_stop() -> void:
	has_move_order = false; attack_target = null; move_target = Vector2.ZERO


func select() -> void: is_selected = true
func deselect() -> void: is_selected = false


func take_damage(amount: float) -> void:
	if dying: return
	current_health = max(0, current_health - amount)
	if current_health <= 0: _die()


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
		world.spawn_explosion(global_position, 1.5)


# ── 预设 ──

func setup_as_grizzly() -> void:
	unit_name = "灰熊坦克"; faction = "allied"
	max_health = 300; speed = 240; attack_range = 260
	attack_damage = 38; attack_cooldown = 1.0; build_cost = 700
	current_health = max_health


func setup_as_rhino() -> void:
	unit_name = "犀牛坦克"; faction = "soviet"
	max_health = 400; speed = 200; attack_range = 260
	attack_damage = 48; attack_cooldown = 1.1; build_cost = 900
	current_health = max_health


func setup_as_yanhuang() -> void:
	unit_name = "炎黄坦克"; faction = "china"
	max_health = 600; speed = 160; attack_range = 290
	attack_damage = 80; attack_cooldown = 1.3; build_cost = 1200
	current_health = max_health
