# GAME_AGENTS.md — 게임 도메인 지식

이 파일은 AI 에이전트가 개발 과정에서 학습한 패턴, 함정, 아키텍처 결정을 누적하는 곳입니다.
각 개발 사이클에서 에이전트가 자동으로 업데이트합니다.

---

## 학습된 패턴 (Learned Patterns)

### autoload 스크립트에 class_name 사용 금지
- **상황**: `class_name EventBus`를 선언한 autoload 스크립트를 `project.godot [autoload]`에 등록 시 "Class 'EventBus' hides an autoload singleton" 에러 발생
- **해결**: autoload으로 등록된 스크립트에서 `class_name` 선언 제거. autoload 이름만으로 전역 접근 가능하므로 `class_name` 불필요
- **적용 대상**: EventBus, GameState, SaveManager 등 모든 autoload 스크립트
- **참고**: Phase 2 #2 Godot 프로젝트 초기화, 커밋 `fc80217`

### .tscn에서 Script는 instance 불가
- **상황**: `ExtResource`로 스크립트를 로드하고 `instance=ExtResource()`로 노드 생성 시 "Scene instance is missing" 에러
- **원인**: 스크립트(.gd)는 씬 인스턴스가 아님. `class_name`이 없으면 노드 생성 불가
- **해결**: `script=ExtResource("id")` 형태로 타입 있는 노드에 스크립트를 부착. `instance=`는 PackedScene(.tscn)에만 사용
- **적용 대상**: 모든 .tscn 파일
- **참고**: Phase 2 #2 main.tscn 수정

### project.godot input 이벤트 — 닫는 중괄호 필수
- **상황**: `attack` input 이벤트에 `"events": [...]` 배열만 있고 닫는 `}`가 누락 → "Expected '}' or ','" 에러
- **원인**: Godot CFG에서 input action은 `{ "events": [...], "deadzone": 0.5 }` 형태여야 함
- **해결**: 각 input action의 events 배열 뒤에 반드시 닫는 `}` 추가
- **적용 대상**: project.godot [input] 섹션
- **참고**: Phase 2 #2 project.godot 수정

### .tscn load_steps는 ext_resource 개수와 일치해야 함
- **상황**: `load_steps=2`인데 ext_resource가 4개 → 동작 불가
- **해결**: `load_steps` 값을 ext_resource 전체 개수와 동일하게 설정
- **적용 대상**: 모든 .tscn 파일
- **참고**: Phase 2 #2 main.tscn 수정

### Vector2i * Vector2 연산 불가
- **상황**: `map_size * Vector2(32, 32)` (Vector2i * Vector2) → "Invalid operands" 에러
- **해결**: `Vector2(map_size) * Vector2(32, 32)`처럼 Vector2로 변환 후 연산
- **적용 대상**: minimap.gd 등 타일 계산이 포함된 모든 코드
- **참고**: Phase 2 #10 minimap.gd 수정

### Dictionary/Array 접근 시 Variant 반환
- **상황**: `var x := dict["key"].size()` → "Cannot infer type" 에러 (CLAUDE.md에도 기록됨)
- **해결**: `: Type =` 명시적 타입 사용. `var x: int = dict["key"].size()`
- **적용 대상**: 모든 GDScript 코드 (AGENTS.md 규칙)
- **참고**: Phase 2 #5 player.gd 수정

---

## 피해야 할 함정 (Pitfalls to Avoid)

### Godot headless --headless-create-release-export 타임아웃
- **문제**: `--headless --create-release-export` 명령이 120초 타임아웃으로 완료 불가
- **원인**: Godot 4.6에서 해당 CLI 옵션이 에디터 초기화를 요구하며 시간이 오래감
- **해결**: project.godot를 수동으로 작성. `.tscn`는 Godot 에디터로 만들거나 포맷에 맞게 수동 작성
- **참고**: CLAUDE.md 엔진 관련 항목

### Godot headless에서 GUT 테스트 실행 불가
- **문제**: headless 모드에서 GUT 테스트가 무한 대기 (SceneTree.quit()가 무시됨)
- **원인**: GUT 9.6이 headless 환경에서 test runner를 정상 종료하지 못함
- **해결**: `--headless --import --quit`로 스크립트 문법/타입 검증. 실제 테스트 실행은 에디터 GUI 필요
- **참고**: Phase 추가작업

### Godot headless에서 Android 빌드 템플릿 설치 불가
- **문제**: CLI로 "Cannot export: Android 빌드 템플릿 미설치" 에러 해결 불가
- **원인**: Android Build Template은 에디터 UI의 "Project > Install Android Build Template..." 메뉴에서만 설치 가능
- **해결**: Godot 에디터를 열고 메뉴에서 수동 설치 후 에디터 종료, 이후 CLI 빌드 가능
- **참고**: Phase 추가작업

### export_presets.cfg 포맷 — Godot 4.6 최신
- **문제**: 4.5/초기 4.6 포맷과 다름. `name`, `package/name`, `package/unique_name` 필수. trailing `"` 금지
- **원인**: Godot 4.6에서 export_presets.cfg이 INI 기반에서 Godot ConfigFile 포맷으로 변경
- **해결**: chromablocks 등 최신 Godot 프로젝트의 export_presets.cfg 참조. `name`, `package/unique_name`, `package/name` 키 반드시 포함
- **참고**: Phase 추가작업

### project.godot에 공백 있는 이름은 안 됨 (Android)
- **문제**: `config/name="Lineage RPG"` → "프로젝트 이름이 패키지 이름 형식 요구사항에 맞지 않음"
- **해결**: 공백 제거. `config/name="LineageRPG"` 사용
- **적용 대상**: project.godot [application]
- **참고**: Phase 추가작업

---

## 시스템 아키텍처 결정 (Architecture Decisions)

### EventBus, GameState, SaveManager를 autoload 싱글톤으로 관리
- **결정**: `project.godot [autoload]`에 등록하여 글로벌 싱글톤으로 사용
- **대안**: 씬 노드에 자식으로 배치, `get_node("/root/Main/EventBus")`로 참조
- **이유**: autoload이 Godot 표준 패턴이며, `EventBus` 직접 접근이 간결해짐. `class_name`과 충돌하므로 autoload 등록 시 `class_name` 제거
- **영향**: 모든 시스템 파일 (event_bus.gd, game_state.gd, save_manager.gd)의 구조
- **날짜**: 2026-03-27

### Resource 기반 데이터 모델 사용
- **결정**: 아이템/스킬/퀘스트/NPC/맵 데이터를 모두 `extends Resource` 클래스 + `.tres` 파일로 관리
- **대안**: JSON 기반 데이터, Dictionary 내장
- **이유**: Godot 에디터에서 인스펙션 가능, 직렬화 지원, 에디터에서 씬에 드래그앤드롭 가능
- **영향**: source/systems/data/ 전체 디렉토리 구조
- **날짜**: 2026-03-27

### 상태머신 패턴 — 계층구조
- **결정**: StateMachine(Node) > State(Node) > 구체 상태(IdleState, WalkState, AttackState) 구조
- **대안**: Enum 기반 상태 머신 (int 상태값)
- **이유**: 확장 가능성 (새 상태 추가 = 새 스크립트 파일), 상태 전이 로직이 각 상태에 캡슐화
- **영향**: source/features/player/states/ 전체
- **날짜**: 2026-03-27

### 데미지 계산을 RefCounted static 클래스로 분리
- **결정**: `DamageCalculator`를 `extends RefCounted` static 클래스로, 인스턴스화 없이 `DamageCalculator.calculate()` 호출
- **대안**: Node에 포함, autoload으로 등록
- **이유**: 데미지 계산은 상태 없는 순수 함수. 싱글톤/노드 불필요
- **영향**: source/features/combat/damage_calculator.gd
- **날짜**: 2026-03-27

### 상점 시스템은 RefCounted 클래스로 분리
- **결정**: ShopSystem, InventorySlot 등 상태가 필요 없는 것은 `extends RefCounted`
- **대안**: 모든 것을 Node 확장
- **이유**: 메모리 관리 명확. 노드는 트리에 추가해야 하므로 일시적인 객체에 부적합
- **영향**: source/features/npc/shop_system.gd, source/features/entities/items/inventory_slot.gd
- **날짜**: 2026-03-27

### Mobile 렌더러 사용 (Android 대응)
- **결정**: `config/features`를 `"Forward Plus"` → `"Mobile"`로 변경
- **대안**: Forward Plus 유지 (데스크톱이면 성능 좋음)
- **이유**: Android 디바이스에서 가장 안정적이며, 이 게임은 2D라 Mobile이면 충분
- **영향**: project.godot [application]
- **날짜**: 2026-03-27

---

## 버전 관리

| 버전 | 일자 | 내용 |
|------|------|------|
| v1 | 2026-03-27 | Phase 2~5 전체 구현, 추가작업 완료 |
