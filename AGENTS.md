# AGENTS.md — AI 에이전트 워크스페이스 규칙

이 프로젝트에서 AI 코딩 에이전트가 따라야 할 규칙입니다.

## Primary Objectives

1. Keep changes safe, reviewable, and atomic.
2. Follow GDScript and Godot 4.x best practices strictly.
3. Preserve behavior outside the target change.
4. Validate with focused GUT unit tests.
5. Track all work via GitHub Issues.

## Scope and Change Control

- Solve one system per task/issue.
- Keep edits minimal: touch only files required for the requested change.
- Do not make drive-by refactors, formatting sweeps, or opportunistic cleanups.
- Preserve existing public interfaces unless the task explicitly requires an interface change.
- If cross-system change is necessary, isolate it and justify in the PR/issue notes.

## GDScript Coding Standards

- Type hints on ALL variables, parameters, and return types.
- `snake_case` for files, functions, variables.
- `PascalCase` for class names and node names.
- `SCREAMING_SNAKE_CASE` for constants.
- `@onready` for node references (never `get_node()` in `_process`).
- `Array[T]` for typed arrays (never bare `Array`).
- Follow the 11-step code order convention (see CLAUDE.md).
- Never use Python-style list comprehensions.
- Never use `as any` or type suppressions.

## GDScript Variant Type Rule

Dictionary/Array access returns `Variant`. Using `:=` causes parse errors.

```gdscript
# ❌ NEVER
var w := dict["key"].size()
var x := array[0].size()

# ✅ ALWAYS
var w: int = dict["key"].size()
var first_row: Array = array[0]
var x: int = first_row.size()
```

**Rule: If RHS touches `[]` on Dictionary or untyped Array, use `: Type =` not `:=`**

## Testing Expectations

- Use GUT (Godot Unit Test) framework (`extends GutTest`).
- Add or update tests for every behavior change.
- Name test files as `test_*.gd`.
- Keep tests deterministic and fast.
- Include at minimum: one success-path test, one edge-case test.
- Run ALL existing tests on every change — detect regressions immediately.

## Feature Gating

- Do not expose unfinished or non-functional features.
- Gate WIP functionality behind explicit flags or disabled scenes.

## AI-Agent Workflow

1. **Understand**: Read AGENTS.md, GAME_AGENTS.md, CLAUDE.md. Define in-scope/out-of-scope.
2. **Plan**: Propose minimal patch plan before editing. Consult Prometheus if complex.
3. **Implement**: Write the smallest viable change with tests alongside.
4. **Test**: Run all tests (existing + new). Verify no regressions.
5. **Review**: Self-review changed hunks for regressions and scope creep.
6. **Document**: Update GAME_AGENTS.md if a new pattern/pitfall was discovered.
7. **Report**: Comment on the GitHub Issue with results and learned patterns.

## GitHub Issues Workflow

```bash
# Work on next task
gh issue list --label "phase-2,todo" --state open

# Start work
gh issue edit $ISSUE_ID --add-assignee "lineage-rpg-agent"

# Report completion
gh issue comment $ISSUE_ID -b "✅ 검증 완료 - 테스트: N/N PASS, 빌드: 에러 0"

# Close issue
gh issue close $ISSUE_ID

# Report learned pattern
gh issue create --title "학습: ..." --label "learned" --body "..."
```

## Commit Readiness Checklist

- [ ] Change is tightly scoped to one system.
- [ ] Non-target files are unchanged, or changes are explicitly justified.
- [ ] All tests pass (existing + new).
- [ ] No regressions from previously passing tests.
- [ ] Type hints present on all new/modified code.
- [ ] GDScript lint: 0 errors, 0 warnings.
- [ ] Code follows 11-step order convention.
- [ ] GAME_AGENTS.md updated if patterns learned.
