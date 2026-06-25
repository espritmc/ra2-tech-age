extends CanvasLayer

## RA2 风格 HUD
## 顶部资源栏 + 右侧建造侧边栏 + 左下小地图

const BT = preload("res://scripts/Buildings/Building.gd").BuildingType

var resource_system; var building_manager; var unit_manager

# ── 顶部栏 ──
var top_panel: Panel
var credits_label: Label
var power_label: Label

# ── 侧边栏 ──
var sidebar: Panel
var sidebar_w = 180
var tab_buttons: Array = []
var active_tab: String = "structures"
var build_item_buttons: Array = []
var portrait_rect: ColorRect
var unit_name_label: Label
var unit_info_label: Label
var build_queue_label: Label

# ── 建造数据 ──
var build_items = {
	"structures": [
		{"name":"发电厂","type":BT.POWER_PLANT,"cost":300,"icon":"⚡"},
		{"name":"矿场","type":BT.REFINERY,"cost":2000,"icon":"💰"},
		{"name":"兵营","type":BT.BARRACKS,"cost":500,"icon":"👤"},
		{"name":"战车工厂","type":BT.WAR_FACTORY,"cost":2000,"icon":"🏭"},
		{"name":"空指部","type":BT.AIR_COMMAND,"cost":1500,"icon":"🛩️"},
		{"name":"作战实验室","type":BT.BATTLE_LAB,"cost":3000,"icon":"🔬"},
		{"name":"防御塔","type":BT.DEFENSE_TOWER,"cost":600,"icon":"🏰"},
		{"name":"超级武器","type":BT.SUPER_WEAPON,"cost":5000,"icon":"☢️"},
	],
	"infantry": [
		{"name":"GI 大兵","type":"inf_gi","cost":200,"icon":"🔫"},
		{"name":"工程师","type":"inf_engineer","cost":500,"icon":"🔧"},
		{"name":"海豹突击队","type":"inf_seal","cost":1000,"icon":"💣"},
	],
	"vehicles": [
		{"name":"灰熊坦克","type":"veh_grizzly","cost":700,"icon":"🚛"},
		{"name":"光棱坦克","type":"veh_prism","cost":1200,"icon":"💎"},
		{"name":"幻影坦克","type":"veh_mirage","cost":1000,"icon":"👻"},
	],
}

# ── RA2 配色 ──
const SIDEBAR_BG = Color(0.12, 0.12, 0.12, 0.92)
const TOPBAR_BG = Color(0.08, 0.08, 0.08, 0.95)
const GOLD = Color(1.0, 0.84, 0.0)
const GREEN = Color(0.3, 1.0, 0.3)
const RED_ALERT = Color(0.9, 0.15, 0.1)
const TAB_ACTIVE = Color(0.25, 0.25, 0.35)
const TAB_INACTIVE = Color(0.15, 0.15, 0.18)


func _ready() -> void:
	_build_top_bar()
	_build_sidebar()
	_build_minimap_placeholder()


func init(res, bm, um) -> void:
	resource_system = res; building_manager = bm; unit_manager = um
	resource_system.credits_changed.connect(_on_credits_changed)
	resource_system.power_changed.connect(_on_power_changed)


# ── 顶部栏 ──

func _build_top_bar() -> void:
	top_panel = Panel.new()
	top_panel.position = Vector2(0, 0)
	top_panel.size = Vector2(1280, 36)
	top_panel.self_modulate = TOPBAR_BG
	add_child(top_panel)
	
	# 资金 — 金黄色
	credits_label = Label.new()
	credits_label.position = Vector2(12, 8)
	credits_label.add_theme_color_override("font_color", GOLD)
	credits_label.add_theme_font_size_override("font_size", 18)
	credits_label.text = "$10000"
	top_panel.add_child(credits_label)
	
	# 电力
	power_label = Label.new()
	power_label.position = Vector2(180, 8)
	power_label.add_theme_color_override("font_color", GREEN)
	power_label.add_theme_font_size_override("font_size", 14)
	power_label.text = "⚡ 充足"
	top_panel.add_child(power_label)
	
	# 标题
	var title = Label.new()
	title.position = Vector2(500, 8)
	title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	title.add_theme_font_size_override("font_size", 14)
	title.text = "RA2 科技时代"
	top_panel.add_child(title)


# ── 侧边栏 ──

func _build_sidebar() -> void:
	sidebar = Panel.new()
	sidebar.position = Vector2(1100, 36)
	sidebar.size = Vector2(sidebar_w, 684)
	sidebar.self_modulate = SIDEBAR_BG
	add_child(sidebar)
	
	# 标签页按钮
	var tabs = ["建筑", "步兵", "载具"]
	var tab_keys = ["structures", "infantry", "vehicles"]
	for i in range(3):
		var btn = Button.new()
		btn.text = tabs[i]
		btn.position = Vector2(4 + i * 59, 4)
		btn.size = Vector2(55, 28)
		btn.flat = true
		btn.pressed.connect(_on_tab_changed.bind(tab_keys[i]))
		_update_tab_style(btn, tab_keys[i] == active_tab)
		sidebar.add_child(btn)
		tab_buttons.append({"btn": btn, "key": tab_keys[i]})
	
	# 建造列表区域
	_refresh_build_list()
	
	# 选择信息区（底部）
	portrait_rect = ColorRect.new()
	portrait_rect.position = Vector2(10, 510)
	portrait_rect.size = Vector2(160, 80)
	portrait_rect.color = Color(0.08, 0.08, 0.12)
	sidebar.add_child(portrait_rect)
	
	unit_name_label = Label.new()
	unit_name_label.position = Vector2(14, 516)
	unit_name_label.add_theme_color_override("font_color", Color.WHITE)
	unit_name_label.add_theme_font_size_override("font_size", 13)
	sidebar.add_child(unit_name_label)
	
	unit_info_label = Label.new()
	unit_info_label.position = Vector2(14, 536)
	unit_info_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	unit_info_label.add_theme_font_size_override("font_size", 11)
	sidebar.add_child(unit_info_label)
	
	# 生产队列
	build_queue_label = Label.new()
	build_queue_label.position = Vector2(10, 600)
	build_queue_label.size = Vector2(160, 60)
	build_queue_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	build_queue_label.add_theme_font_size_override("font_size", 10)
	sidebar.add_child(build_queue_label)


func _on_tab_changed(tab_key: String) -> void:
	active_tab = tab_key
	for tb in tab_buttons:
		_update_tab_style(tb["btn"], tb["key"] == active_tab)
	_refresh_build_list()


func _update_tab_style(btn: Button, active: bool) -> void:
	if active:
		btn.self_modulate = TAB_ACTIVE
		btn.add_theme_color_override("font_color", Color.WHITE)
	else:
		btn.self_modulate = TAB_INACTIVE
		btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))


func _refresh_build_list() -> void:
	# 清除旧按钮
	for b in build_item_buttons:
		if is_instance_valid(b): b.queue_free()
	build_item_buttons.clear()
	
	var items = build_items.get(active_tab, [])
	var y_start = 40
	
	for i in range(items.size()):
		var item = items[i]
		var btn = Button.new()
		btn.text = "%s $%d" % [item["name"], item["cost"]]
		btn.position = Vector2(6, y_start + i * 52)
		btn.size = Vector2(sidebar_w - 14, 46)
		btn.flat = true
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_font_size_override("font_size", 11)
		btn.self_modulate = Color(0.18, 0.18, 0.22)
		btn.pressed.connect(_on_build_item_pressed.bind(item))
		sidebar.add_child(btn)
		build_item_buttons.append(btn)


func _on_build_item_pressed(item: Dictionary) -> void:
	if not resource_system.can_afford(item["cost"]):
		return
	
	var type_str = item["type"]
	if typeof(type_str) == TYPE_STRING and type_str.begins_with("inf_"):
		_spawn_infantry(type_str, item["cost"])
	elif typeof(type_str) == TYPE_STRING and type_str.begins_with("veh_"):
		_spawn_vehicle(type_str, item["cost"])
	else:
		building_manager.start_placing(type_str)


func _spawn_infantry(type_str: String, cost: int) -> void:
	if not resource_system.can_afford(cost): return
	
	var Inf = load("res://scripts/Units/Infantry.gd")
	var pos = _get_spawn_pos()
	if pos == Vector2.ZERO: return
	
	var u = Inf.new()
	match type_str:
		"inf_gi": u.setup_as_gi()
		"inf_engineer": u.setup_as_engineer()
		"inf_seal": u.setup_as_gi(); u.unit_name = "海豹突击队"; u.attack_damage = 50; u.max_health = 150; u.current_health = 150
	
	u.global_position = pos
	get_parent().add_child(u)
	unit_manager.register_unit(u)
	resource_system.spend(cost)


func _spawn_vehicle(type_str: String, cost: int) -> void:
	if not resource_system.can_afford(cost): return
	
	var Veh = load("res://scripts/Units/Vehicle.gd")
	var pos = _get_spawn_pos()
	if pos == Vector2.ZERO: return
	
	var v = Veh.new()
	match type_str:
		"veh_grizzly": v.setup_as_grizzly()
		"veh_prism": v.setup_as_grizzly(); v.unit_name = "光棱坦克"; v.attack_damage = 60; v.attack_range = 320; v.max_health = 250; v.current_health = 250
		"veh_mirage": v.setup_as_grizzly(); v.unit_name = "幻影坦克"; v.attack_damage = 55; v.max_health = 200; v.current_health = 200
	
	v.global_position = pos
	get_parent().add_child(v)
	unit_manager.register_unit(v)
	resource_system.spend(cost)


func _get_spawn_pos() -> Vector2:
	for b in building_manager.all_buildings:
		if b.building_type == BT.WAR_FACTORY and b.faction == "allied":
			return b.global_position + Vector2(100, -100)
	for b in building_manager.all_buildings:
		if b.building_type == BT.CONSTRUCTION_YARD and b.faction == "allied":
			return b.global_position + Vector2(150, -80)
	return Vector2.ZERO


func _on_credits_changed(new_amount: float) -> void:
	credits_label.text = "$" + str(int(new_amount))


func _on_power_changed(produced: int, consumed: int) -> void:
	power_label.text = "⚡ %d/%d" % [produced, consumed]
	power_label.add_theme_color_override("font_color", GREEN if produced >= consumed else RED_ALERT)


func _process(_delta: float) -> void:
	_update_selection_info()


func _update_selection_info() -> void:
	var selected = unit_manager.selected_units
	if selected.is_empty():
		unit_name_label.text = ""
		unit_info_label.text = ""
		return
	
	var u = selected[0]
	unit_name_label.text = u.unit_name
	var faction_name = {"allied":"盟军","soviet":"苏联","china":"中国","neutral":"中立"}.get(u.faction, u.faction)
	unit_info_label.text = "%s | HP:%d/%d\n攻:%d 速:%d" % [faction_name, int(u.current_health), int(u.max_health), int(u.attack_damage), int(u.speed)]


func _build_minimap_placeholder() -> void:
	pass  # Minimap 由单独的 Minimap 节点渲染
