## 스킬 시스템 매니저
## 스킬 배움/사용/쿨다운/레벨업을 관리합니다.

class_name SkillSystem
extends Node

signal skill_learned(skill_id: String)
signal skill_used(skill_id: String)
signal skill_leveled_up(skill_id: String, new_level: int)

## 등록된 스킬 템플릿
var skill_templates: Dictionary = {}

## 배운 스킬 (skill_id -> SkillSlot)
var learned_skills: Dictionary = {}

func _ready() -> void:
	EventBus.experience_gained.connect(_on_experience_gained)
	EventBus.level_up.connect(_on_level_up)

## 스킬 템플릿 등록
func register_skill(skill_data: SkillResource) -> void:
	skill_templates[skill_data.skill_id] = skill_data

## 스킬 배움 가능 여부
func can_learn_skill(skill_id: String) -> bool:
	if not skill_templates.has(skill_id):
		return false
	if learned_skills.has(skill_id):
		return false
	var data: SkillResource = skill_templates.get(skill_id)
	var player_level: int = GameState.player_data.get("level", 1)
	if player_level < data.required_level:
		return false
	# 선행 스킬 검사
	for prereq_id: String in data.prerequisite_skills:
		if not learned_skills.has(prereq_id):
			return false
	return true

## 스킬 배우기
func learn_skill(skill_id: String) -> bool:
	if not can_learn_skill(skill_id):
		return false
	var data: SkillResource = skill_templates.get(skill_id)
	var slot: SkillSlot = SkillSlot.new(data)
	learned_skills[skill_id] = slot
	skill_learned.emit(skill_id)
	return true

## 스킬 사용
func use_skill(skill_id: String) -> bool:
	if not learned_skills.has(skill_id):
		return false
	var slot: SkillSlot = learned_skills.get(skill_id)
	if not slot.can_use():
		return false
	# MP 검사
	var mp_cost: int = slot.skill_data.get_mp_cost_at(slot.current_level)
	var current_mp: int = GameState.player_data.get("mp", 0)
	if current_mp < mp_cost:
		return false
	# MP 소비
	GameState.player_data["mp"] = current_mp - mp_cost
	EventBus.mana_changed.emit(
		GameState.player_data.get("mp", 0),
		GameState.player_data.get("max_mp", 50),
	)
	slot.start_cooldown()
	skill_used.emit(skill_id)
	return true

## 스킬 레벨업
func level_up_skill(skill_id: String) -> bool:
	if not learned_skills.has(skill_id):
		return false
	var slot: SkillSlot = learned_skills.get(skill_id)
	var result: bool = slot.level_up()
	if result:
		skill_leveled_up.emit(skill_id, slot.current_level)
	return result

## 보유 스킬 목록 반환
func get_learned_skill_ids() -> Array[String]:
	var ids: Array[String] = []
	for skill_id: String in learned_skills:
		ids.append(skill_id)
	return ids

func _process(delta: float) -> void:
	for skill_id: String in learned_skills:
		var slot: SkillSlot = learned_skills.get(skill_id)
		slot.tick_cooldown(delta)

func _on_experience_gained(_amount: int) -> void:
	pass

func _on_level_up(_new_level: int) -> void:
	# 레벨업 시 배울 수 있는 스킬 알림 등
	pass
