#!/bin/bash
# GDScript Lint - Validate GDScript files after edit
# Called by PostToolUse hook when .gd files are written/edited

FILE_PATH="$1"

# Only check .gd files
if [[ "$FILE_PATH" != *.gd ]]; then
    exit 0
fi

if ! command -v godot &> /dev/null; then
    echo "⚠️ Godot not installed. Skipping GDScript lint for: $FILE_PATH"
    exit 0
fi

echo "🔍 Linting: $FILE_PATH"
# Godot 4 headless script check
godot --headless --check-only --script "$FILE_PATH" 2>&1
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "❌ GDScript lint FAILED for: $FILE_PATH"
    exit 1
fi

echo "✅ GDScript lint passed: $FILE_PATH"
exit 0
