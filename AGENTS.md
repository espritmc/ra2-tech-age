# AGENTS.md — RA2 科技时代

## 项目概览

红色警戒2：科技时代 — 跨平台 2D 即时战略游戏。支持单机 AI 对战和局域网联机。

- **引擎**: Godot 4.x (GDScript)
- **平台**: macOS / Windows / Linux
- **仓库**: git@github.com:espritmc/ra2-tech-age.git

## 技术栈

| 层 | 技术 |
|---|---|
| 引擎 | Godot 4.x |
| 脚本 | GDScript |
| 网络 | ENet (Godot 内置) |
| 资源 | 2D sprites, tilemap |
| 构建 | Godot export templates |

## 目录结构

```
ra2-tech-age/
├── src/
│   ├── Main.tscn              # 主场景入口
│   ├── GameWorld/             # 游戏世界
│   │   ├── GameWorld.tscn
│   │   └── GameWorld.gd
│   ├── Map/                   # 地图系统
│   │   ├── TileMap.gd
│   │   └── MapGenerator.gd
│   ├── Units/                 # 单位系统
│   │   ├── Unit.gd            # 基类
│   │   ├── Infantry.gd
│   │   ├── Vehicle.gd
│   │   └── Aircraft.gd
│   ├── Buildings/             # 建筑系统
│   │   ├── Building.gd        # 基类
│   │   ├── ConstructionYard.gd
│   │   ├── Barracks.gd
│   │   ├── WarFactory.gd
│   │   └── Refinery.gd
│   ├── Systems/               # 游戏系统
│   │   ├── ResourceSystem.gd
│   │   ├── CombatSystem.gd
│   │   ├── ProductionSystem.gd
│   │   ├── Pathfinding.gd
│   │   └── FogOfWar.gd
│   ├── AI/                    # AI 系统
│   │   └── AIController.gd
│   ├── Network/               # 网络系统
│   │   ├── NetworkManager.gd
│   │   ├── Lobby.gd
│   │   └── SyncManager.gd
│   └── UI/                    # 界面系统
│       ├── HUD.gd
│       ├── Minimap.gd
│       ├── BuildMenu.gd
│       └── MainMenu.gd
├── assets/                    # 资源文件
│   ├── sprites/
│   ├── tilesets/
│   ├── sounds/
│   └── fonts/
├── docs/                      # 文档
│   ├── game-design.md
│   └── change-report-*.md
├── AGENTS.md                  # 本文件
├── feature_list.json          # 功能清单
├── progress.md                # 进度追踪
└── init.sh                    # 验证脚本
```

## 保护边界

以下区域需要谨慎修改：
- 网络同步逻辑（SyncManager.gd）—— 改动可能导致联机不同步
- 战斗伤害计算（CombatSystem.gd）—— 涉及平衡性
- 资源系统（ResourceSystem.gd）—— 影响经济平衡

## 开发命令

```bash
# 运行游戏
godot --path src/ --editor   # 编辑器模式
godot --path src/            # 运行游戏

# 验证
bash init.sh                 # 项目完整性检查
godot --path src/ --headless --quit  # 无头模式快速验证
```

## Git 工作流

```bash
# 修改 → 验证 → 文档 → 提交
bash init.sh
# 写 docs/change-report-YYYY-MM-DD-描述.md
git add <本次修改的文件>
git commit -m "feat: 描述"
git push
```

## 安全规则

- 不要提交包含绝对路径的配置
- 资源文件使用相对路径
- 不要提交 Godot 的 .import/ 目录（由导入系统自动生成）
