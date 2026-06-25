extends CanvasLayer
class_name Hud

## HUD 界面 — 资金、电力、建造菜单、选中信息

const BuildingScript = preload("res://scripts/Buildings/Building.gd")

var resource_system   # ResourceSystem
var building_manager  # BuildingManager
var unit_manager      # UnitManager

var credits_label: Label
var power_label: Label
var build_panel: Panel
var minimap: ColorRect
var selection_info: Label
var build_buttons: Array = []


func _ready() -> void:
	pass


func init(res, bm, um) -> void:
	resource_system = res
	building_manager = bm
	unit_manager = um
	
	resource_system.credits_changed.connect(_on_credits_changed)
	resource_system.power_changed.connect(_on_power_changed)
	
	_build_ui()


func _build_ui() -> void:
	var top_bar = Panel.new()
	top_bar.name = "TopBar"
	top_bar.position = Vector2(0, 0)
	top_bar.size = Vector2(1280, 40)
	add_child(top_bar)
	
	credits_label = Label.new()
	credits_label.name = "CreditsLabel"
	credits_label.position = Vector2(10, 10)
	credits_label.text = "$ " + str(int(resource_system.credits))
	credits_label.add_theme_font_size_override("font_size", 20)
	credits_label.add_theme_color_override("font_color", Color(1, 1, 0))
	top_bar.add_child(credits_label)
	
	power_label = Label.new()
	power_label.name = "PowerLabel"
	power_label.position = Vector2(200, 10)
	power_label.text = "⚡ 充足"
	power_label.add_theme_font_size_override("font_size", 16)
	power_label.add_theme_color_override("font_color", Color(0.3, 1, 0.3))
	top_bar.add_child(power_label)
	
	_build_construction_panel()
	
	selection_info = Label.new()
	selection_info.name = "SelectionInfo"
	selection_info.position = Vector2(10, 680)
	selection_info.size = Vector2(500, 30)
	selection_info.text = ""
	selection_info.add_theme_font_size_override("font_size", 14)
	selection_info.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	add_child(selection_info)


func _build_construction_panel() -> void:
	build_panel = Panel.new()
	build_panel.name = "BuildPanel"
	build_panel.position = Vector2(1050, 40)
	build_panel.size = Vector2(220, 600)
	add_child(build_panel)
	
	var title = Label.new()
	title.name = "BuildTitle"
	title.position = Vector2(10, 10)
	title.text = "═ 建造菜单 ═"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1, 0.84, 0))
	build_panel.add_child(title)
	
	var BT = BuildingScript.BuildingType
	var buildings = [
		{"name": "建造场", "type": BT.CONSTRUCTION_YARD, "cost": 0},
		{"name": "发电厂", "type": BT.POWER_PLANT, "cost": 300},
		{"name": "矿场", "type": BT.REFINERY, "cost": 2000},
		{"name": "兵营", "type": BT.BARRACKS, "cost": 500},
		{"name": "战车工厂", "type": BT.WAR_FACTORY, "cost": 2000},
		{"name": "空指部", "type": BT.AIR_COMMAND, "cost": 1500},
		{"name": "作战实验室", "type": BT.BATTLE_LAB, "cost": 3000},
		{"name": "防御塔", "type": BT.DEFENSE_TOWER, "cost": 600},
	]
	
	for i in range(buildings.size()):
		var info = buildings[i]
		var btn = Button.new()
		btn.name = "BuildBtn_" + info["name"]
		btn.text = "%s ($%d)" % [info["name"], info["cost"]]
		btn.position = Vector2(10, 40 + i * 35)
		btn.size = Vector2(200, 30)
		btn.pressed.connect(_on_build_button_pressed.bind(info["type"], info["cost"]))
		build_panel.add_child(btn)
		build_buttons.append(btn)


func _on_build_button_pressed(type: int, cost: int) -> void:
	if not resource_system.can_afford(cost):
		print("[HUD] 资金不足: 需要 $%d" % cost)
		return
	
	building_manager.start_placing(type)


func _on_credits_changed(new_amount: float) -> void:
	if credits_label:
		credits_label.text = "$ " + str(int(new_amount))


func _on_power_changed(produced: int, consumed: int) -> void:
	if power_label:
		power_label.text = "⚡ %d/%d" % [produced, consumed]
		if produced >= consumed:
			power_label.add_theme_color_override("font_color", Color(0.3, 1, 0.3))
		else:
			power_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))


func _process(_delta: float) -> void:
	_update_selection_info()


func _update_selection_info() -> void:
	if not selection_info:
		return
	
	var selected = unit_manager.selected_units
	if selected.is_empty():
		selection_info.text = ""
		return
	
	var unit = selected[0]
	selection_info.text = "%s | HP: %d/%d | 速度: %d" % [
		unit.unit_name, int(unit.current_health), int(unit.max_health), int(unit.speed)
	]
