#!/bin/bash
# RA2 Tech Age — 项目验证脚本
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "=== RA2 科技时代 项目验证 ==="
echo ""

# 1. Godot 引擎检查
if command -v godot &>/dev/null; then
    echo "✓ Godot 已安装: $(godot --version 2>/dev/null || echo 'version unknown')"
else
    echo "✗ Godot 未安装 — 请运行: brew install --cask godot"
fi

# 2. 核心文件检查
echo ""
echo "--- Harness 文件 ---"
for f in AGENTS.md feature_list.json progress.md init.sh; do
    if [ -f "$PROJECT_DIR/$f" ]; then
        echo "✓ $f"
    else
        echo "✗ $f 缺失"
    fi
done

# 3. Godot 项目检查
echo ""
echo "--- Godot 项目 ---"
if [ -f "$PROJECT_DIR/src/project.godot" ]; then
    echo "✓ src/project.godot 存在"
    # 无头模式快速验证
    echo "  运行无头验证..."
    godot --path "$PROJECT_DIR/src" --headless --quit 2>&1 | tail -5
else
    echo "✗ src/project.godot 缺失 — Godot 项目尚未初始化"
fi

# 4. Git 状态
echo ""
echo "--- Git ---"
if [ -d "$PROJECT_DIR/.git" ]; then
    echo "✓ Git 仓库已初始化"
else
    echo "✗ Git 仓库未初始化"
fi

echo ""
echo "=== 验证完成 ==="
