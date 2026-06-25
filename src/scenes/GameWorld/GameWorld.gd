extends Node2D
class_name GameWorld

var map_system; var resource_system; var unit_manager; var building_manager
var combat_system; var ai_controller; var hud; var minimap
var explosion_fx; var combat_visuals; var bgm_player; var sfx_player

var camera: Camera2D
var camera_speed: float = 800.0
var zoom_min: float = 0.3; var zoom_max: float = 2.0; var zoom_step: float = 0.1


func _ready() -> void:
	add_to_group("game_world")
	print("[GameWorld] ═══ RA2 科技时代 — 初始化 ═══")
	_setup_camera(); _setup_map(); _setup_resources(); _setup_combat()
	_setup_fx(); _setup_buildings(); _setup_units(); _setup_ai()
	_setup_audio(); _setup_hud(); _setup_minimap()
	_spawn_player_start()
	print("[GameWorld] ✅ 就绪！")


func _setup_camera() -> void:
	camera = Camera2D.new(); camera.position = Vector2(2500, 4096); camera.zoom = Vector2(0.6, 0.6)
	add_child(camera); camera.make_current()

func _setup_map() -> void:
	var S = load("res://scripts/Map/MapSystem.gd"); map_system = S.new(); map_system.name = "MapSystem"; add_child(map_system)

func _setup_resources() -> void:
	var S = load("res://scripts/Systems/ResourceSystem.gd"); resource_system = S.new(); resource_system.name = "ResourceSystem"
	resource_system.credits = 10000; add_child(resource_system)

func _setup_combat() -> void:
	var S = load("res://scripts/Systems/CombatSystem.gd"); combat_system = S.new(); combat_system.name = "CombatSystem"; add_child(combat_system)

func _setup_fx() -> void:
	var E = load("res://scripts/Systems/ExplosionEffect.gd"); explosion_fx = E.new(); explosion_fx.name = "ExplosionFX"; add_child(explosion_fx)
	var C = load("res://scripts/Systems/CombatVisuals.gd"); combat_visuals = C.new(); combat_visuals.name = "CombatVisuals"; add_child(combat_visuals)

func _setup_buildings() -> void:
	var S = load("res://scripts/Buildings/BuildingManager.gd"); building_manager = S.new(); building_manager.name = "BuildingManager"
	add_child(building_manager); building_manager.init(map_system)

func _setup_units() -> void:
	var S = load("res://scripts/Units/UnitManager.gd"); unit_manager = S.new(); unit_manager.name = "UnitManager"
	add_child(unit_manager)

func _setup_ai() -> void:
	var S = load("res://scripts/AI/AIController.gd"); ai_controller = S.new(); ai_controller.name = "AIController"
	ai_controller.faction = "soviet"; ai_controller.base_position = Vector2(5800, 5500)
	add_child(ai_controller); ai_controller.init(resource_system, building_manager, unit_manager, map_system)

func _setup_audio() -> void:
	var B = load("res://scripts/Systems/BgmPlayer.gd"); bgm_player = B.new(); bgm_player.name = "BGM"; add_child(bgm_player)
	var S = load("res://scripts/Systems/SfxPlayer.gd"); sfx_player = S.new(); sfx_player.name = "SFX"; add_child(sfx_player)

func _setup_hud() -> void:
	var scene = load("res://scripts/UI/Hud.tscn"); hud = scene.instantiate(); hud.name = "HUD"
	add_child(hud); hud.init(resource_system, building_manager, unit_manager)

func _setup_minimap() -> void:
	var S = load("res://scripts/UI/Minimap.gd"); minimap = S.new(); minimap.name = "Minimap"
	add_child(minimap); minimap.init(map_system, unit_manager, building_manager)


func _spawn_player_start() -> void:
	var Inf = load("res://scripts/Units/Infantry.gd"); var Veh = load("res://scripts/Units/Vehicle.gd")
	var Bld = load("res://scripts/Buildings/Building.gd"); var bx = 2500.0; var by = 5000.0
	
	var buildings_data = [
		{"name":"建造场","type":Bld.BuildingType.CONSTRUCTION_YARD,"hp":2000,"pow":50,"sz":Vector2i(3,3),"off":Vector2(0,0)},
		{"name":"发电厂","type":Bld.BuildingType.POWER_PLANT,"hp":750,"pow":100,"sz":Vector2i(2,2),"off":Vector2(-200,0)},
		{"name":"兵营","type":Bld.BuildingType.BARRACKS,"hp":800,"pow":-20,"sz":Vector2i(2,2),"off":Vector2(200,0)},
		{"name":"战车工厂","type":Bld.BuildingType.WAR_FACTORY,"hp":1200,"pow":-30,"sz":Vector2i(3,2),"off":Vector2(0,-200)},
	]
	for d in buildings_data:
		var b = Bld.new(); b.building_name = d["name"]; b.building_type = d["type"]; b.faction = "allied"
		b.max_health = d["hp"]; b.current_health = d["hp"]; b.build_size = d["sz"]; b.is_placed = true
		if d["pow"] > 0: b.power_provided = d["pow"]
		else: b.power_consumed = -d["pow"]
		b.global_position = Vector2(bx + d["off"].x, by + d["off"].y)
		add_child(b); building_manager.all_buildings.append(b)
	
	for i in range(4):
		var t = Veh.new(); t.setup_as_grizzly(); t.global_position = Vector2(bx + 100 + i*90, by - 250); add_child(t); unit_manager.register_unit(t)
	for i in range(8):
		var g = Inf.new(); g.setup_as_gi(); g.global_position = Vector2(bx - 150 + i*50, by - 200); add_child(g); unit_manager.register_unit(g)
	
	print("[GameWorld] 玩家初始部队: 4 灰熊 + 8 GI 大兵 + 4 建筑")


func _process(delta: float) -> void:
	_handle_camera_movement(delta); _update_camera_bounds()
	_check_combat_visuals(); _check_sfx()


func _handle_camera_movement(delta: float) -> void:
	var dir = Vector2(Input.get_axis("move_left","move_right"), Input.get_axis("move_up","move_down"))
	if dir != Vector2.ZERO: camera.position += dir.normalized() * camera_speed * delta / camera.zoom
	if Input.is_action_just_pressed("camera_zoom_in"): camera.zoom = (camera.zoom - Vector2(zoom_step,zoom_step)).clamp(Vector2(zoom_min,zoom_min), Vector2(zoom_max,zoom_max))
	if Input.is_action_just_pressed("camera_zoom_out"): camera.zoom = (camera.zoom + Vector2(zoom_step,zoom_step)).clamp(Vector2(zoom_min,zoom_min), Vector2(zoom_max,zoom_max))


func _update_camera_bounds() -> void:
	var mb = map_system.get_map_bounds(); var vs = get_viewport().get_visible_rect().size / camera.zoom; var hv = vs/2
	camera.position.x = clamp(camera.position.x, mb.position.x+hv.x, mb.end.x-hv.x)
	camera.position.y = clamp(camera.position.y, mb.position.y+hv.y, mb.end.y-hv.y)


func _check_combat_visuals() -> void:
	if Engine.get_process_frames() % 8 != 0: return
	for u in unit_manager.all_units:
		if not u.is_alive or not u.attack_target: continue
		var t = u.attack_target
		if not is_instance_valid(t) or not t.is_alive: continue
		var dist = u.global_position.distance_to(t.global_position)
		if dist <= u.attack_range + 30:
			var faction_color = {"allied": Color(0.3,0.6,1), "soviet": Color(1,0.3,0.2), "china": Color(1,0.7,0.1)}.get(u.faction, Color.WHITE)
			combat_visuals.add_shot(u.global_position, t.global_position, faction_color)


var _last_alive_count: int = 0

func _check_sfx() -> void:
	if Engine.get_process_frames() % 15 != 0: return
	var alive = 0
	var shooting = false
	for u in unit_manager.all_units:
		if u.is_alive:
			alive += 1
			if u.attack_target: shooting = true
	if alive < _last_alive_count and sfx_player:
		sfx_player.play_explosion()
	if shooting and sfx_player and Engine.get_process_frames() % 30 == 0:
		sfx_player.play_shoot()
	_last_alive_count = alive


func spawn_explosion(pos: Vector2, size: float = 1.0) -> void:
	if explosion_fx: explosion_fx.spawn_explosion(pos, size)
