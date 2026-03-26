#!/bin/bash
# Godot Build Check - Validate Godot project integrity
# Called by Stop hook before session ends

PROJECT_DIR="/Users/elfguy/alba/games/lineage-rpg"

if [ ! -f "$PROJECT_DIR/project.godot" ]; then
    echo '{"ok": true, "reason": "Godot project not initialized yet"}'
    exit 0
fi

if ! command -v godot &> /dev/null; then
    echo '{"ok": true, "reason": "Godot not installed, skipping build check"}'
    exit 0
fi

echo "🔧 Running Godot build check..."
cd "$PROJECT_DIR"

# Run headless import to validate project
godot --headless --import 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "{\"ok\": false, \"reason\": \"Godot build check failed with exit code $EXIT_CODE\"}"
    exit 1
fi

echo '{"ok": true, "reason": "Godot build check passed"}'
exit 0
