---
name: game-review
description: "다관점 게임 코드 리뷰 - MAR 패턴 기반 4가지 관점 품질 검증"
---

# Game Review Workflow

$ARGUMENTS — 리뷰할 대상 (파일/시스템/PR, 생략 시 최근 변경사항)

## Step 1: Identify Changes
```bash
git diff --name-only HEAD~1
gh issue list --label "review,todo" --state open
```

## Step 2: Run 4-Perspective Review
Use game-reviewer agent (MAR pattern):
- 🎮 Gameplay: 밸런스, UX, 리니지 RPG 느낌
- 🔧 Technical: Godot 4 베스트 프랙티스, 60fps, 메모리
- 🎨 Visual: z-index/y_sort, 스프라이트 순서, 애니메이션
- 🛡️ Stability: null 가드, 경합 조건, 에러 핸들링

## Step 3: Classify Issues
- BLOCKING: 머지 전 수정 필수 (크래시, 데이터 손실, 게임플레이 파괴)
- MINOR: 조속 수정 권장 (코드 품질, 성능, UX)
- SUGGESTION: 개선 제안 (스타일, 최적화)

## Step 4: Create Review Issue
If BLOCKING issues found:
```bash
gh issue create \
  --title "리뷰: $TARGET" \
  --label "review,blocking" \
  --body "### 관점별 결과
| 관점 | 판정 | 상세 |
|------|------|------|
| 🎮 게임플레이 | PASS/FAIL | |
| 🔧 기술 | PASS/FAIL | |
| 🎨 시각 | PASS/FAIL | |
| 🛡️ 안정성 | PASS/FAIL | |"
```

## Step 5: Approve or Request Fix
- All PASS: close review issue, approve related task
- Any BLOCKING: assign to gdscript-writer, keep issue open
