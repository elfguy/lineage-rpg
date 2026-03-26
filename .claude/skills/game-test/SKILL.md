---
name: game-test
description: "게임 시스템 자동 테스트 - 단위/통합 테스트 생성 및 회귀 방지"
---

# Game Test Workflow

$ARGUMENTS — 테스트할 대상 시스템 (생략 시 전체 테스트)

## Step 1: Identify Target
1. Check AGENTS.md and GAME_AGENTS.md for context
2. Determine target system from arguments or recent changes
3. Check existing tests: `tests/unit/`, `tests/integration/`

## Step 2: Generate Unit Tests
Use qa-tester agent. Create `tests/unit/test_<system>.gd`:
```gdscript
extends GutTest

func test_<behavior>():
    # Arrange, Act, Assert
    assert_<method>(actual, expected, "description")
```

Coverage targets:
- Core systems (combat, inventory, quest): ≥ 80%
- Supporting systems (map, NPC, UI): ≥ 60%

## Step 3: Generate Integration Tests
Create `tests/integration/test_<system>_flow.gd`:
- System interactions (combat + inventory + UI)
- State transitions (idle → walk → attack → idle)
- Save/load cycles

## Step 4: Run All Tests
```bash
# Run all existing + new tests
# Check for regressions (previously passing → now failing)
```

## Step 5: Handle Regressions
If a previously passing test fails:
1. Report immediately in GitHub Issue (label: `bug`)
2. Identify root cause
3. Propose fix or recommend revert
4. Never delete a failing test to "pass"
