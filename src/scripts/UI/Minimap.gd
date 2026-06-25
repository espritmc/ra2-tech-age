extends Node2D

## 小地图 — 右下角实时地图概览

var map_system
var unit_manager
var building_manager
var minimap_size: Vector2 = Vector2(200, 200)
var minimap_margin: Vector2 = Vector2(10, 10)
var map_scale: float = 1.0


func _ready() -> void:
	set_process(false)


func init(ms, um, bm) -> void:
	map_system = ms
	unit_manager = um
	building_manager = bm
	var map_w = ms.MAP_WIDTH * ms.TILE_SIZE
	var map_h = ms.MAP_HEIGHT * ms.TILE_SIZE
	map_scale = minimap_size.x / map_w
	set_process(true)


func _draw() -> void:
	if not map_system: return
	
	var viewport = get_viewport()
	var view_size = viewport.get_visible_rect().size
	var base_pos = Vector2(view_size.x - minimap_size.x - minimap_margin.x, view_size.y - minimap_size.y - minimap_margin.y)
	
	# 背景
	draw_rect(Rect2(base_pos, minimap_size), Color(0, 0, 0, 0.7))
	draw_rect(Rect2(base_pos, minimap_size), Color(1, 1, 1, 0.3), false, 1)
	
	# 地形
	var td = map_system.tile_data
	var ts = map_system.TILE_SIZE
	var step = max(1, int(ts * map_scale / 2))
	
	for x in range(0, map_system.MAP_WIDTH, step):
		for y in range(0, map_system.MAP_HEIGHT, step):
			var terrain = td[x][y]
			var color = map_system.TERRAIN_COLORS.get(terrain, Color.GRAY)
			var rx = base_pos.x + x * ts * map_scale
			var ry = base_pos.y + y * ts * map_scale
			var rs = ts * map_scale * step
			draw_rect(Rect2(rx, ry, rs, rs), color)
	
	# 单位（小点）
	if unit_manager:
		for u in unit_manager.all_units:
			if not u.is_alive: continue
			var up = base_pos + u.global_position * map_scale
			var uc = Color(0.2, 1.0, 0.2) if u.faction == "allied" else Color(1.0, 0.2, 0.2)
			draw_circle(up, 1.5, uc)
	
	# 建筑（小方块）
	if building_manager:
		for b in building_manager.all_buildings:
			if not b.is_alive: continue
			var bp = base_pos + b.global_position * map_scale
			var bc = Color(0.3, 0.7, 1.0) if b.faction == "allied" else Color(1.0, 0.3, 0.2)
			draw_rect(Rect2(bp - Vector2(2, 2), Vector2(4, 4)), bc)
	
	# 视口框
	var cam = viewport.get_camera_2d()
	if cam:
		var vs = viewport.get_visible_rect().size / cam.zoom
		var cam_tl = cam.global_position - vs / 2
		var vr = Rect2(base_pos + cam_tl * map_scale, vs * map_scale)
		draw_rect(vr, Color(1, 1, 1, 0.8), false, 1.5)
