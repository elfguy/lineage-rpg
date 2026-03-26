# 🎮 Lineage RPG — CLAUDE.md

## 프로젝트 개요
리니지(Lineage) 스타일의 2D MMORPG를 AI 에이전트가 자율적으로 개발하는 프로젝트.
하네스 엔지니어링 기반으로 에이전트가 기획→설계→구현→검증→리뷰→학습 단계를 반복하며 고도화합니다.

## 기술 스택
- **게임 엔진**: Godot 4.x (GDScript, strict type hints)
- **AI 프레임워크**: OpenCode (OhMyOpenCode)
- **에이전트 모델**: GLM-5-turbo (모든 에이전트)
- **버전 관리**: Git + GitHub
- **이슈 관리**: GitHub Issues

## 에이전트 팀 구성

| 에이전트 | 역할 | 도구 |
|----------|------|------|
| **Sisyphus** | 오케스트레이터 | Ultrawork Loop, 병렬 위임 |
| **Prometheus** | 기획 | 작업 분해, 마일스톤 관리 |
| **Oracle** | 아키텍처 자문 | 복잡한 결정, 설계 검토 |
| **Metis** | 기획 검토 | 요구사항 갭 분석 |
| **Momus** | 품질 리뷰어 | 최종 품질 평가 |
| **Game Architect** | 시스템 설계 | `.claude/agents/game-architect.md` |
| **GDScript Writer** | 코드 생성 | `.claude/agents/gdscript-writer.md` |
| **Game Reviewer** | 4관점 리뷰 | `.claude/agents/game-reviewer.md` (MAR 패턴) |
| **QA Tester** | 테스트 자동화 | `.claude/agents/qa-tester.md` |

## GDScript 코딩 규칙

### 필수 (Mandatory)
- **Type hints**: 모든 변수, 파라미터, 반환값에 타입 명시
- **이름 규칙**: snake_case (파일/함수/변수), PascalCase (클래스/노드), SCREAMING_SNAKE_CASE (상수)
- **@onready**: 노드 참조용 (절대 `_process`에서 `get_node()` 사용 금지)
- **타입 배열**: `Array[T]` 사용 (비타입 `Array` 금지)
- **코드 순서**: 아래 11단계 준수

### 코드 순서 (GDScript 공식 가이드)
1. `@tool` / `@icon` 지시어
2. `class_name` / `extends`
3. `##` 문서 주석
4. `signal` 선언
5. `enum` 정의
6. `const` 상수
7. `@export` 변수
8. 일반 변수
9. `@onready` 변수
10. `_init()` / `_ready()`
11. 가상 메서드 (`_process`, `_physics_process`)
12. 커스텀 메서드

### GDScript 함정 (Godogen 연구 기반)
| 함정 | 해결책 |
|------|--------|
| Dictionary/Array 접근 시 Variant 반환 | `:=` 대신 `: Type =` 사용 |
| Python 스타일 리스트 컴프리헨션 | GDScript에서 미지원 — for 루프 사용 |
| `class Resource` 사용 | `extends Resource` 사용 |
| `name = Signal()` 사용 | `signal name(type)` 사용 |
| `@onready`가 `_ready()` 전에 초기화된다고 오해 | `_ready()` 이후에만 유효 |

### 엔진 관련
- `Engine.time_scale` 변경 시 UI 애니메이션은 `Time.get_ticks_msec()` 사용
- `.gd.uid` 파일은 수동 생성 금지 — `Godot --headless --import`로 재생성
- `export_presets.cfg`는 커밋 금지, `export_presets.cfg.templ`만 커밋

## 프로젝트 구조 원칙
- **Feature-oriented**: 기능별 폴더 구성 (타입별 X)
- **Composition over inheritance**: 재사용 컴포넌트 조합
- **Resource-driven**: 모든 데이터 `.tres` Resource 파일로 관리
- **Minimal autoloads**: 순수 데이터는 Static Class, 글로벌 상태만 Autoload
- **Server-authoritative**: 네트워크 시 서버 권위적 아키텍처

## AI 에이전트 워크플로우
```
기획 → 설계 → 구현 → 검증 → 리뷰 → 학습 → 다음 이슈
```
1. GitHub Issue에서 작업 조회 (`label:"phase-N,todo"`)
2. Prometheus가 작업 분해 → 개별 이슈 생성
3. Game Architect가 설계 → Oracle 검토
4. GDScript Writer가 구현 (테스트 포함)
5. QA Tester가 검증 (단위 + 통합 + 회귀)
6. Game Reviewer가 4관점 리뷰 (BLOCKING/MINOR/SUGGESTION)
7. BLOCKING 있으면 수정 후 4-6 재실행
8. 패턴 발견 시 GAME_AGENTS.md 업데이트
9. 이슈 코멘트에 결과 기록 후 종료
