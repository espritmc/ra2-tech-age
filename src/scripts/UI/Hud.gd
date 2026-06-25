extends CanvasLayer

## RA2 风格 HUD — 完整重写
## 顶部栏(资金/电力/雷达) + 右侧建造面板(标签/队列/肖像)

const BuildingScript = preload("res://scripts/Buildings/Building.gd")
const BT = BuildingScript.BuildingType

var rs; var bm; var um

# ── 配色 ──
const GOLD = Color(0.95, 0.78, 0.05)
const GREEN = Color(0.2, 0.9, 0.2)
const RED = Color(0.9, 0.15, 0.08)
const DARK = Color(0.08, 0.08, 0.1)
const PANEL = Color(0.1, 0.1, 0.13, 0.94)
const TAB_ON = Color(0.18, 0.18, 0.25)
const TAB_OFF = Color(0.1, 0.1, 0.14)
const BTN_NORMAL = Color(0.14, 0.14, 0.18)
const BTN_HOVER = Color(0.2, 0.2, 0.28)
const BTN_DISABLED = Color(0.08, 0.08, 0.1)

var act_tab = "structures"
var build_btns: Array = []

# ── 建造数据（含图标文字）──
var items = {
	"structures": [
		{"n":"发电厂","t":BT.POWER_PLANT,"c":300,"i":"🏭"},
		{"n":"矿场","t":BT.REFINERY,"c":2000,"i":"⛏"},
		{"n":"兵营","t":BT.BARRACKS,"c":500,"i":"🏕"},
		{"n":"战车工厂","t":BT.WAR_FACTORY,"c":2000,"i":"🔧"},
		{"n":"空指部","t":BT.AIR_COMMAND,"c":1500,"i":"🛩"},
		{"n":"作战实验室","t":BT.BATTLE_LAB,"c":3000,"i":"🧪"},
		{"n":"防御塔","t":BT.DEFENSE_TOWER,"c":600,"i":"🗼"},
		{"n":"超级武器","t":BT.SUPER_WEAPON,"c":5000,"i":"☢"},
	],
	"infantry": [
		{"n":"GI 大兵","t":"gi","c":200,"i":"🔫"},
		{"n":"工程师","t":"eng","c":500,"i":"🔧"},
		{"n":"海豹","t":"seal","c":1000,"i":"💣"},
	],
	"vehicles": [
		{"n":"灰熊坦克","t":"grizzly","c":700,"i":"⬡"},
		{"n":"犀牛坦克","t":"rhino","c":900,"i":"⏣"},
		{"n":"光棱坦克","t":"prism","c":1200,"i":"✦"},
		{"n":"幻影坦克","t":"mirage","c":1000,"i":"◈"},
	],
}

# ── UI 控件 ──
var cred_label: Label
var pow_label: Label
var info_name: Label
var info_stat: Label
var queue_label: Label


func init(_rs, _bm, _um):
	rs = _rs; bm = _bm; um = _um
	rs.credits_changed.connect(func(v): cred_label.text = "$%d" % int(v))
	rs.power_changed.connect(func(p, c): _upd_power(p, c))


func _ready():
	# DEBUG: 醒目测试块 — 如果HUD加载，屏幕左上角会有大红块
	var test = ColorRect.new()
	test.name = "HUD_LOADED_TEST"
	test.color = Color(1, 0, 0, 0.8)
	test.position = Vector2(0, 0)
	test.size = Vector2(100, 40)
	add_child(test)
	var tl = Label.new()
	tl.text = "HUD OK"
	tl.position = Vector2(10, 10)
	tl.add_theme_color_override("font_color", Color.WHITE)
	tl.add_theme_font_size_override("font_size", 16)
	test.add_child(tl)
	
	_build_top()
	_build_sidebar()
	_build_info_panel()


# ═══════════ 顶部栏 ═══════════

func _build_top():
	var bar = Panel.new()
	bar.position = Vector2.ZERO
	bar.size = Vector2(1280, 38)
	bar.self_modulate = Color(0.05, 0.05, 0.07, 0.96)
	add_child(bar)
	
	# 左下角装饰线
	var line = ColorRect.new()
	line.color = GOLD.darkened(0.4)
	line.position = Vector2(0, 36)
	line.size = Vector2(1280, 2)
	bar.add_child(line)
	
	# 资金
	cred_label = _make_label("$10000", 12, 10, 20, GOLD)
	bar.add_child(cred_label)
	
	# 电力
	pow_label = _make_label("⚡ —", 180, 12, 14, GREEN)
	bar.add_child(pow_label)
	
	# 标题
	var t = _make_label("RA2 科技时代", 500, 10, 15, Color(0.5, 0.5, 0.55))
	bar.add_child(t)


func _upd_power(p, c):
	pow_label.text = "⚡ %d/%d" % [p, c]
	pow_label.add_theme_color_override("font_color", GREEN if p >= c else RED)


# ═══════════ 右侧面板 ═══════════

func _build_sidebar():
	var sx = 1104  # 1280 - 176
	var sy = 38
	var sw = 176
	var sh = 682
	
	var panel = Panel.new()
	panel.position = Vector2(sx, sy)
	panel.size = Vector2(sw, sh)
	panel.self_modulate = PANEL
	add_child(panel)
	
	# 边框
	var border = ColorRect.new()
	border.color = Color(0.2, 0.2, 0.25, 0.6)
	border.position = Vector2(sx - 1, sy - 1)
	border.size = Vector2(sw + 2, sh + 2)
	add_child(border)
	move_child(border, panel.get_index())
	
	# ── 标签栏 ──
	var tabs = [["建筑", "structures"], ["步兵", "infantry"], ["载具", "vehicles"]]
	var tab_w = 56
	for i in 3:
		var b = Button.new()
		b.text = tabs[i][0]; b.flat = true
		b.position = Vector2(sx + 2 + i * tab_w, sy + 3)
		b.size = Vector2(tab_w - 2, 26)
		b.add_theme_font_size_override("font_size", 12)
		b.add_theme_color_override("font_color", Color.WHITE)
		b.self_modulate = TAB_ON if tabs[i][1] == act_tab else TAB_OFF
		var key = tabs[i][1]
		b.pressed.connect(_on_tab.bind(key, b))
		add_child(b)
	
	# ── 建造列表 ──
	_render_build_list(sx, sy)
	
	# ── 队列区 ──
	queue_label = Label.new()
	queue_label.position = Vector2(sx + 6, sy + 380)
	queue_label.size = Vector2(sw - 12, 80)
	queue_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	queue_label.add_theme_font_size_override("font_size", 10)
	add_child(queue_label)


func _on_tab(key, btn):
	act_tab = key
	for c in get_children():
		if c is Button and c.text in ["建筑","步兵","载具"]:
			c.self_modulate = TAB_OFF
	btn.self_modulate = TAB_ON
	_render_build_list(1104, 38)


func _render_build_list(sx, sy):
	for b in build_btns:
		if is_instance_valid(b): b.queue_free()
	build_btns.clear()
	
	var list = items.get(act_tab, [])
	for i in list.size():
		var it = list[i]
		var btn = Button.new()
		btn.text = " %s %s  $%d" % [it["i"], it["n"], it["c"]]
		btn.flat = true
		btn.position = Vector2(sx + 4, sy + 34 + i * 44)
		btn.size = Vector2(168, 40)
		btn.add_theme_font_size_override("font_size", 11)
		btn.add_theme_color_override("font_color", Color.WHITE if rs.can_afford(it["c"]) else Color(0.5, 0.3, 0.3))
		btn.self_modulate = BTN_NORMAL if rs.can_afford(it["c"]) else BTN_DISABLED
		var data = it.duplicate()
		btn.pressed.connect(_on_build.bind(data))
		add_child(btn)
		build_btns.append(btn)


func _on_build(it):
	if not rs.can_afford(it["c"]): return
	
	if typeof(it["t"]) == TYPE_STRING:
		# 生产单位
		var pos = _spawn_point()
		if it["t"] == "gi":
			var u = load("res://scripts/Units/Infantry.gd").new(); u.setup_as_gi()
			u.global_position = pos; add_child(u); um.register_unit(u)
		elif it["t"] == "eng":
			var u = load("res://scripts/Units/Infantry.gd").new(); u.setup_as_engineer()
			u.global_position = pos; add_child(u); um.register_unit(u)
		elif it["t"] == "seal":
			var u = load("res://scripts/Units/Infantry.gd").new(); u.setup_as_gi()
			u.unit_name = "海豹"; u.attack_damage = 50; u.max_health = 150; u.current_health = 150
			u.global_position = pos; add_child(u); um.register_unit(u)
		elif it["t"] == "grizzly":
			var v = load("res://scripts/Units/Vehicle.gd").new(); v.setup_as_grizzly()
			v.global_position = pos; add_child(v); um.register_unit(v)
		elif it["t"] == "rhino":
			var v = load("res://scripts/Units/Vehicle.gd").new(); v.setup_as_rhino()
			v.global_position = pos; add_child(v); um.register_unit(v)
		elif it["t"] == "prism":
			var v = load("res://scripts/Units/Vehicle.gd").new(); v.setup_as_grizzly()
			v.unit_name = "光棱坦克"; v.attack_damage = 60; v.attack_range = 320
			v.max_health = 250; v.current_health = 250
			v.global_position = pos; add_child(v); um.register_unit(v)
		elif it["t"] == "mirage":
			var v = load("res://scripts/Units/Vehicle.gd").new(); v.setup_as_grizzly()
			v.unit_name = "幻影坦克"; v.attack_damage = 55
			v.max_health = 200; v.current_health = 200
			v.global_position = pos; add_child(v); um.register_unit(v)
		rs.spend(it["c"])
	else:
		bm.start_placing(it["t"])


func _spawn_point():
	for b in bm.all_buildings:
		if b.faction == "allied" and b.building_type in [BT.BARRACKS, BT.WAR_FACTORY]:
			return b.global_position + Vector2(120, -80)
	return Vector2(2600, 4800)


# ═══════════ 选中信息 ═══════════

func _build_info_panel():
	var sx = 1104; var sy = 38
	
	info_name = _make_label("", sx + 8, sy + 470, 12, Color.WHITE)
	add_child(info_name)
	
	info_stat = _make_label("", sx + 8, sy + 486, 10, Color(0.6, 0.6, 0.6))
	add_child(info_stat)


func _process(_d):
	var sel = um.selected_units
	if sel.is_empty():
		info_name.text = ""
		info_stat.text = ""
	else:
		var u = sel[0]
		info_name.text = u.unit_name
		info_stat.text = "HP %d/%d  攻%d  速%d" % [int(u.current_health), int(u.max_health), int(u.attack_damage), int(u.speed)]


func _make_label(text, x, y, sz, col):
	var l = Label.new()
	l.text = text; l.position = Vector2(x, y)
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", col)
	return l
