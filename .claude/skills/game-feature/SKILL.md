---
name: game-feature
description: "새 게임 기능 개발 워크플로우 - 기획→설계→구현→검증→리뷰 전체 사이클"
---

# Game Feature Development Workflow

$ARGUMENTS — 개발할 기능 설명

## Step 1: Plan
1. Read AGENTS.md and GAME_AGENTS.md for project context
2. Consult Prometheus to decompose the feature into atomic tasks
3. Create GitHub Issues for each task with label `phase-N,todo`
4. Identify dependencies on existing systems

## Step 2: Design
1. Use game-architect agent to design the system
2. Define Scene Tree structure, Resources, Signals
3. Get Oracle review for architectural decisions
4. Document design in docs/ directory

## Step 3: Implement
1. Use gdscript-writer agent to generate code
2. Follow GDScript conventions strictly (AGENTS.md)
3. Implement GUT tests alongside code
4. Each test file: `test_<system>.gd`

## Step 4: Verify
1. Run all tests (existing + new): `godot --headless -s tests/test_all.gd`
2. Run Godot build check
3. Verify no regressions from previously passing tests
4. Comment results on GitHub Issue

## Step 5: Review
1. Use game-reviewer agent for 4-perspective review
2. Fix any BLOCKING issues
3. Re-verify after fixes
4. Update GAME_AGENTS.md with learned patterns

## Step 6: Report
1. Summarize what was built
2. Report test status
3. Note any patterns learned
4. Close GitHub Issue
