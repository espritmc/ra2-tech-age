# 变更报告 — 2026-06-25 feat-001: 项目骨架

## 概述

创建 RA2 科技时代游戏项目的完整骨架，包括 Godot 项目初始化、主场景、游戏世界基础架构。

## 变更文件

### 新建
| 文件 | 说明 |
|------|------|
| `AGENTS.md` | 项目指令：架构、保护边界、开发命令、Git 工作流 |
| `feature_list.json` | 12 个功能的完整清单，P0-P2 优先级 |
| `progress.md` | 当前进度追踪 |
| `init.sh` | 项目验证脚本 |
| `docs/game-design.md` | 完整游戏设计文档（阵营/单位/建筑/科技树） |
| `docs/plan-feat-001-project-skeleton.md` | feat-001 实施计划 |
| `src/project.godot` | Godot 项目配置，包含键盘映射 |
| `src/icon.svg` | 游戏图标 |
| `src/scenes/Main.gd` | 主场景脚本（启动入口、状态管理） |
| `src/scenes/Main.tscn` | 主场景文件 |
| `src/scenes/GameWorld/GameWorld.gd` | 游戏世界容器（相机 WASD/QE 缩放） |
| `src/scenes/GameWorld/GameWorld.tscn` | 游戏世界场景文件 |
| `src/.gitignore` | Godot + IDE 忽略规则 |

## 架构

```
Main.tscn (根场景)
  └── GameWorld.tscn (游戏世界容器)
        ├── Camera2D (WASD 移动, Q/E 缩放)
        ├── MapSystem (占位)
        ├── UnitManager (占位)
        └── BuildingManager (占位)
```

## 验证

⚠️ Godot 引擎仍在安装中（brew install --cask godot），无法执行无头验证。

文件结构验证通过：7 个 src/ 文件，4 个根目录 harness 文件，2 个 docs/ 文件。

引擎安装完成后运行 `bash init.sh` 和 `godot --path src/ --headless --quit` 完成最终验证。

## 下一步

- feat-002: 地图系统（Tilemap + 地形 + 相机边界）
