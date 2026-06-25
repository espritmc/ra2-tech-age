extends Node2D

## 战斗视觉效果 — 子弹轨迹、激光线

var shots: Array = []


func add_shot(from: Vector2, to: Vector2, color: Color = Color(1, 0.8, 0.2)) -> void:
	shots.append({"from": from, "to": to, "color": color, "timer": 0.0, "duration": 0.15})
	set_process(true)


func _process(delta: float) -> void:
	var alive = []
	for s in shots:
		s["timer"] += delta
		if s["timer"] < s["duration"]:
			alive.append(s)
	shots = alive
	if shots.is_empty(): set_process(false)
	queue_redraw()


func _draw() -> void:
	for s in shots:
		var alpha = 1.0 - s["timer"] / s["duration"]
		draw_line(s["from"], s["to"], Color(s["color"], alpha), 2.0)
