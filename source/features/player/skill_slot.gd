## 스킬 슬롯
## 스킬의 현재 레벨과 쿨다운 상태를 추적합니다.

class_name SkillSlot
extends RefCounted

var skill_data: SkillResource
var current_level: int = 1
var current_cooldown: float = 0.0

func _init(data: SkillResource) -> void:
	skill_data = data
	current_level = 1
	current_cooldown = 0.0

func is_on_cooldown() -> bool:
	return current_cooldown > 0.0

func can_use() -> bool:
	return skill_data.skill_type == SkillResource.SkillType.ACTIVE and not is_on_cooldown()

func get_cooldown_percent() -> float:
	if skill_data.cooldown <= 0.0:
		return 0.0
	return current_cooldown / skill_data.cooldown

func tick_cooldown(delta: float) -> void:
	current_cooldown = maxf(current_cooldown - delta, 0.0)

func start_cooldown() -> void:
	current_cooldown = skill_data.get_cooldown_at(current_level)

func level_up() -> bool:
	if current_level >= skill_data.max_level:
		return false
	current_level += 1
	return true

func is_max_level() -> bool:
	return current_level >= skill_data.max_level
