extends Node2D

## 爆炸特效 — 单位/建筑死亡时的粒子动画

var particles: Array = []


func spawn_explosion(pos: Vector2, size: float = 1.0) -> void:
	var p = {
		"pos": pos,
		"timer": 0.0,
		"duration": 0.5,
		"size": size,
		"particles": _gen_particles(size)
	}
	particles.append(p)
	set_process(true)


func _gen_particles(size: float) -> Array:
	var arr = []
	for i in range(12):
		arr.append({
			"offset": Vector2(randf_range(-20, 20) * size, randf_range(-20, 20) * size),
			"vel": Vector2(randf_range(-80, 80), randf_range(-80, 80)) * size,
			"life": randf_range(0.3, 0.8)
		})
	return arr


func _process(delta: float) -> void:
	var alive = []
	for p in particles:
		p["timer"] += delta
		if p["timer"] < p["duration"]:
			alive.append(p)
	particles = alive
	
	if particles.is_empty():
		set_process(false)
	
	queue_redraw()


func _draw() -> void:
	for p in particles:
		var progress = p["timer"] / p["duration"]
		var alpha = 1.0 - progress
		var base_color = Color(1.0, 0.5, 0.0, alpha)
		
		# 中心闪光
		var flash_size = p["size"] * 30 * (1.0 - progress)
		draw_circle(p["pos"], flash_size, Color(1.0, 0.8, 0.2, alpha * 0.6))
		
		# 粒子碎片
		for pt in p["particles"]:
			var pt_progress = p["timer"] / pt["life"]
			if pt_progress > 1.0: continue
			var pt_pos = p["pos"] + pt["offset"] + pt["vel"] * p["timer"]
			var pt_alpha = 1.0 - pt_progress
			draw_circle(pt_pos, 2 * p["size"], Color(1.0, 0.3, 0.0, pt_alpha))
