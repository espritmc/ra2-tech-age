extends Node2D

## 地形精灵纹理 — 像素风程序化地面

const TILE = 64
const TERRAIN_COLORS = {
	0: Color(0.22, 0.42, 0.13),  # 草地
	1: Color(0.62, 0.52, 0.28),  # 沙漠
	2: Color(0.08, 0.18, 0.50),  # 水域
	3: Color(0.30, 0.27, 0.22),  # 山脉
	4: Color(0.38, 0.34, 0.28),  # 道路
	5: Color(0.75, 0.65, 0.15),  # 矿石
}


func draw_terrain(canvas: CanvasItem, x: int, y: int, terrain: int) -> void:
	var px = x * TILE
	var py = y * TILE
	var c = TERRAIN_COLORS.get(terrain, Color.MAGENTA)
	
	match terrain:
		0: _draw_grass(canvas, px, py, c)
		1: _draw_desert(canvas, px, py, c)
		2: _draw_water(canvas, px, py, c)
		3: _draw_mountain(canvas, px, py, c)
		4: _draw_road(canvas, px, py, c)
		5: _draw_ore(canvas, px, py, c)


func _draw_grass(c: CanvasItem, x: float, y: float, col: Color) -> void:
	c.draw_rect(Rect2(x, y, TILE, TILE), col)
	# 草纹细节
	var detail = col.lightened(0.08)
	for i in range(8):
		var dx = x + 8 + (i * 53) % 56
		var dy = y + 8 + (i * 37) % 56
		c.draw_rect(Rect2(dx, dy, 3, 6), detail)
		c.draw_rect(Rect2(dx + 1, dy - 2, 1, 3), detail.lightened(0.1))


func _draw_desert(c: CanvasItem, x: float, y: float, col: Color) -> void:
	c.draw_rect(Rect2(x, y, TILE, TILE), col)
	var d1 = col.lightened(0.1)
	var d2 = col.darkened(0.08)
	for i in range(5):
		c.draw_rect(Rect2(x + (i*79)%60, y + (i*43)%58, 4 + i%3, 4 + i%3), d1 if i%2==0 else d2)
	# 沙波纹
	for i in range(3):
		var py2 = y + 16 + i * 18
		c.draw_line(Vector2(x+4, py2), Vector2(x+60, py2), col.darkened(0.06), 1)


func _draw_water(c: CanvasItem, x: float, y: float, col: Color) -> void:
	c.draw_rect(Rect2(x, y, TILE, TILE), col)
	# 波纹
	var wave = col.lightened(0.15)
	for i in range(3):
		var wy = y + 16 + i * 18
		for j in range(4):
			var wx = x + 6 + j * 14
			c.draw_arc(Vector2(wx, wy), 5, 0, PI, 8, wave, 1.5)
	c.draw_rect(Rect2(x, y, TILE, TILE), Color(0, 0, 0, 0.15), false, 1)


func _draw_mountain(c: CanvasItem, x: float, y: float, col: Color) -> void:
	c.draw_rect(Rect2(x, y, TILE, TILE), col)
	# 岩石
	var rock1 = col.lightened(0.15)
	var rock2 = col.lightened(0.25)
	var points = PackedVector2Array([Vector2(x+10,y+50), Vector2(x+32,y+10), Vector2(x+54,y+50)])
	c.draw_colored_polygon(points, rock1)
	c.draw_polyline(points, rock2, 2)
	# 小碎石
	for i in range(4):
		var rx = x + 10 + (i*37)%50
		var ry = y + 45 + (i*19)%16
		c.draw_circle(Vector2(rx, ry), 3 + i%2, rock2)


func _draw_road(c: CanvasItem, x: float, y: float, col: Color) -> void:
	c.draw_rect(Rect2(x, y, TILE, TILE), col)
	# 道路标线
	c.draw_rect(Rect2(x, y+30, TILE, 4), col.lightened(0.2))
	# 路面纹理
	for i in range(6):
		var rx = x + 4 + (i*43)%60
		var ry = y + 4 + (i*37)%28
		c.draw_circle(Vector2(rx, ry), 1.5, col.darkened(0.08))


func _draw_ore(c: CanvasItem, x: float, y: float, col: Color) -> void:
	c.draw_rect(Rect2(x, y, TILE, TILE), col.darkened(0.3))
	# 矿石晶体
	var crystal = Color(1, 0.84, 0.1)
	for i in range(6):
		var cx = x + 10 + (i*47)%50
		var cy = y + 12 + (i*31)%46
		var size = 5 + i % 4
		var pts = PackedVector2Array([
			Vector2(cx, cy-size), Vector2(cx+size*0.7, cy+size*0.3),
			Vector2(cx, cy+size), Vector2(cx-size*0.7, cy+size*0.3)
		])
		c.draw_colored_polygon(pts, crystal)
		c.draw_polyline(pts, Color(1,1,1,0.6), 1)
