# feat-001: 项目骨架与引擎集成 — 实施计划

> **For Hermes:** 一项一项执行，验证后再推进。

**Goal:** 创建完整的 Godot 4.x 项目骨架，可运行、可验证、可 Git 管理。

**Architecture:** Godot 4.x 项目，使用 GDScript。主场景为 Main.tscn，包含 GameWorld 作为游戏容器。

**Tech Stack:** Godot 4.4 (GDScript)

---

### Task 1: 创建 Godot 项目

**Objective:** 在 src/ 下初始化 Godot 项目

**Step 1: 创建项目结构**

```bash
mkdir -p ~/Projects/ra2-tech-age/src/scenes/GameWorld
mkdir -p ~/Projects/ra2-tech-age/src/scripts/{Map,Units,Buildings,Systems,AI,Network,UI}
mkdir -p ~/Projects/ra2-tech-age/assets/{sprites,tilesets,sounds,fonts}
```

**Step 2: 创建 project.godot**

在 `src/project.godot` 中：

```ini
; Engine configuration file.
; It's best edited using the editor UI and not directly,
; since the parameters that go here are not all obvious.

config_version=5

[application]
config/name="RA2 科技时代"
config/version="0.1.0"
run/main_scene="res://scenes/Main.tscn"
config/features=PackedStringArray("4.4")
config/icon="res://icon.svg"
```

**Step 3: 创建默认图标 icon.svg**

在 `src/icon.svg` 中：

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128">
  <rect width="128" height="128" rx="16" fill="#1a1a2e"/>
  <text x="64" y="72" text-anchor="middle" font-size="48" font-family="Arial Black" fill="#e94560" font-weight="900">RA</text>
  <text x="64" y="104" text-anchor="middle" font-size="18" font-family="Arial" fill="#0f3460">科技</text>
</svg>
```

**验证:** `ls src/project.godot src/icon.svg` 两个文件存在

---

### Task 2: 创建 Main 主场景

**Objective:** 创建根场景 Main.tscn，作为游戏入口

**Step 1: 创建 Main.gd 脚本**

`src/scenes/Main.gd`:

```gdscript
extends Node2D

func _ready():
	print("RA2 科技时代 v0.1.0 启动")
	print("引擎版本: ", Engine.get_version_info())
	get_tree().set_auto_accept_quit(false)
	# TODO: 加载主菜单
```

**Step 2: 创建 Main.tscn 场景文件**

`src/scenes/Main.tscn`:

```ini
[gd_scene load_steps=2 format=3 uid="uid://main001"]

[ext_resource type="Script" path="res://scenes/Main.gd" id="1_main"]

[node name="Main" type="Node2D"]
script = ExtResource("1_main")
```

**验证:** `godot --path src/ --headless --quit` 无报错退出

---

### Task 3: 创建 GameWorld 基础场景

**Objective:** 创建游戏世界的空容器

**Step 1: 创建 GameWorld.gd**

`src/scenes/GameWorld/GameWorld.gd`:

```gdscript
extends Node2D
class_name GameWorld

## 游戏世界根节点，管理地图、单位、建筑等所有游戏实体

func _ready():
	print("[GameWorld] 游戏世界初始化")
```

**Step 2: 创建 GameWorld.tscn**

`src/scenes/GameWorld/GameWorld.tscn`:

```ini
[gd_scene load_steps=2 format=3 uid="uid://gameworld001"]

[ext_resource type="Script" path="res://scenes/GameWorld/GameWorld.gd" id="1_gw"]

[node name="GameWorld" type="Node2D"]
script = ExtResource("1_gw")
```

**Step 3: 在 Main.gd 中加载 GameWorld**

修改 `src/scenes/Main.gd`:

```gdscript
extends Node2D

var game_world: GameWorld

func _ready():
	print("RA2 科技时代 v0.1.0 启动")
	print("引擎版本: ", Engine.get_version_info())
	get_tree().set_auto_accept_quit(false)
	
	# 加载游戏世界
	var gw_scene = load("res://scenes/GameWorld/GameWorld.tscn")
	game_world = gw_scene.instantiate()
	add_child(game_world)
	print("[Main] GameWorld 已加载")
```

**验证:** `godot --path src/ --headless --quit` 输出包含 "[Main] GameWorld 已加载"

---

### Task 4: 创建 .gitignore

**Objective:** 排除不需要版本控制的文件

**文件:** `src/.gitignore`

```
# Godot-specific ignores
.godot/
*.import
*.translation
export/
export_presets.cfg

# Imported assets (re-imported from source)
.import/

# Mono
.mono/

# System files
.DS_Store
Thumbs.db
```

**验证:** `git status` 不包含 .godot/ 目录

---

### Task 5: 验证 + Git 提交

**Objective:** 跑通完整验证流程并提交

**Step 1: 运行验证**

```bash
cd ~/Projects/ra2-tech-age && bash init.sh
```

期望输出: 所有检查项 ✓

**Step 2: 写变更报告**

`docs/change-report-2026-06-25-feat-001-project-skeleton.md`

**Step 3: 提交**

```bash
cd ~/Projects/ra2-tech-age
git add src/ AGENTS.md feature_list.json progress.md init.sh docs/
git commit -m "feat: 项目骨架 — Godot 项目初始化、Main 场景、GameWorld"
```

---

### 验收标准

- [x] AGENTS.md 存在
- [x] feature_list.json 存在
- [x] progress.md 存在
- [x] init.sh 可执行
- [ ] Godot 已安装
- [ ] project.godot 存在
- [ ] Main.tscn 可无头运行
- [ ] GameWorld 在启动时加载
- [ ] .gitignore 生效
- [ ] Git 已提交
