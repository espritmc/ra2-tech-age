extends Node2D
class_name MapSystem

## 地图系统
##
## 管理地形数据、渲染地形、可行走区域判定。
## 地图大小: 128×128 tiles, 每个 tile 64×64px → 8192×8192px 世界
##
## MVP 阶段用程序化绘制的彩色方块代替 tilemap（无需外部资源）。

enum TerrainType {
	GRASS = 0,
	DESERT = 1,
	WATER = 2,
	MOUNTAIN = 3,
	ROAD = 4,
	ORE = 5,
}

const TILE_SIZE: int = 64
const MAP_WIDTH: int = 128
const MAP_HEIGHT: int = 128

# 可行走地形
const WALKABLE_TERRAIN: Array = [TerrainType.GRASS, TerrainType.DESERT, TerrainType.ROAD, TerrainType.ORE]

var tile_data: Array = []  # [x][y] → TerrainType
var map_rect: Rect2i

# 每格颜色（程序化地形，不需要外部素材）
const TERRAIN_COLORS = {
	TerrainType.GRASS: Color(0.25, 0.45, 0.15),
	TerrainType.DESERT: Color(0.65, 0.55, 0.3),
	TerrainType.WATER: Color(0.1, 0.2, 0.55),
	TerrainType.MOUNTAIN: Color(0.35, 0.3, 0.25),
	TerrainType.ROAD: Color(0.4, 0.35, 0.3),
	TerrainType.ORE: Color(0.8, 0.7, 0.2),
}


func _ready() -> void:
	print("[MapSystem] 初始化地图系统...")
	_generate_map()
	print("[MapSystem] 地图生成完成: %dx%d tiles (%.0f×%.0f px)" % [MAP_WIDTH, MAP_HEIGHT, MAP_WIDTH*TILE_SIZE, MAP_HEIGHT*TILE_SIZE])


func _generate_map() -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = 42
	
	# 初始化 tile_data 数组
	tile_data.clear()
	for x in range(MAP_WIDTH):
		tile_data.append([])
		for y in range(MAP_HEIGHT):
			var terrain = _pick_terrain(x, y, rng)
			tile_data[x].append(terrain)
	
	map_rect = Rect2i(0, 0, MAP_WIDTH, MAP_HEIGHT)


func _pick_terrain(x: int, y: int, rng: RandomNumberGenerator) -> int:
	if x <= 3 or x >= MAP_WIDTH - 4 or y <= 3 or y >= MAP_HEIGHT - 4:
		return TerrainType.WATER
	
	var cx = MAP_WIDTH / 2
	var cy = MAP_HEIGHT / 2
	var dist = sqrt(pow(x - cx, 2) + pow(y - cy, 2))
	
	if dist < 20:
		return TerrainType.GRASS
	
	var r = rng.randf()
	if r < 0.55:
		return TerrainType.GRASS
	elif r < 0.70:
		return TerrainType.DESERT
	elif r < 0.78:
		return TerrainType.WATER
	elif r < 0.85:
		return TerrainType.MOUNTAIN
	elif r < 0.90:
		return TerrainType.ROAD
	else:
		return TerrainType.ORE


## 绘制地形
func _draw() -> void:
	var viewport = get_viewport()
	if not viewport:
		return
	
	var camera = viewport.get_camera_2d()
	if not camera:
		return
	
	# 计算可见 tile 范围
	var view_rect = get_viewport().get_visible_rect()
	var cam_pos = camera.global_position
	var zoom = camera.zoom
	
	var visible_width = view_rect.size.x / zoom.x
	var visible_height = view_rect.size.y / zoom.y
	
	var start_x = max(0, int((cam_pos.x - visible_width/2) / TILE_SIZE) - 1)
	var end_x = min(MAP_WIDTH - 1, int((cam_pos.x + visible_width/2) / TILE_SIZE) + 1)
	var start_y = max(0, int((cam_pos.y - visible_height/2) / TILE_SIZE) - 1)
	var end_y = min(MAP_HEIGHT - 1, int((cam_pos.y + visible_height/2) / TILE_SIZE) + 1)
	
	# 只绘制可见的 tile
	for x in range(start_x, end_x + 1):
		for y in range(start_y, end_y + 1):
			var terrain = tile_data[x][y]
			var color = TERRAIN_COLORS.get(terrain, Color.MAGENTA)
			var rect = Rect2(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			draw_rect(rect, color)
			
			# 水域和山脉画网格线以区分
			if terrain == TerrainType.WATER or terrain == TerrainType.MOUNTAIN:
				draw_rect(rect, color.darkened(0.15), false, 1.0)


func _process(_delta: float) -> void:
	queue_redraw()


## 获取指定坐标的地形
func get_terrain_at(world_pos: Vector2) -> int:
	var tp = world_to_tile(world_pos)
	if tp.x < 0 or tp.x >= MAP_WIDTH or tp.y < 0 or tp.y >= MAP_HEIGHT:
		return TerrainType.WATER
	return tile_data[tp.x][tp.y]


func world_to_tile(world_pos: Vector2) -> Vector2i:
	return Vector2i(floor(world_pos.x / TILE_SIZE), floor(world_pos.y / TILE_SIZE))


func tile_to_world(tile_pos: Vector2i) -> Vector2:
	return Vector2(tile_pos.x * TILE_SIZE + TILE_SIZE / 2, tile_pos.y * TILE_SIZE + TILE_SIZE / 2)


func is_walkable(world_pos: Vector2) -> bool:
	return get_terrain_at(world_pos) in WALKABLE_TERRAIN


func is_tile_walkable(tile_pos: Vector2i) -> bool:
	if tile_pos.x < 0 or tile_pos.x >= MAP_WIDTH or tile_pos.y < 0 or tile_pos.y >= MAP_HEIGHT:
		return false
	return tile_data[tile_pos.x][tile_pos.y] in WALKABLE_TERRAIN


func is_buildable(tile_pos: Vector2i) -> bool:
	if tile_pos.x < 0 or tile_pos.x >= MAP_WIDTH or tile_pos.y < 0 or tile_pos.y >= MAP_HEIGHT:
		return false
	return tile_data[tile_pos.x][tile_pos.y] in [TerrainType.GRASS, TerrainType.DESERT, TerrainType.ROAD]


func get_map_bounds() -> Rect2:
	return Rect2(0, 0, MAP_WIDTH * TILE_SIZE, MAP_HEIGHT * TILE_SIZE)
