## 스킬 Resource 데이터 모델

class_name SkillResource
extends Resource

enum SkillType {
	ACTIVE,
	PASSIVE,
}

@export var skill_id: String = ""
@export var skill_name: String = ""
@export var description: String = ""
@export var icon: Texture2D = null
@export var skill_type: SkillType = SkillType.ACTIVE
@export var mp_cost: int = 0
@export var cooldown: float = 1.0
@export var required_level: int = 1
@export var max_level: int = 5
@export var prerequisite_skills: Array[String] = []
@export var base_damage: int = 0
@export var damage_per_level: int = 0
@export var stats: Dictionary = {}

## 레벨별 MP 비용
func get_mp_cost_at(level: int) -> int:
	return mp_cost + (level - 1)

## 레벨별 쿨다운
func get_cooldown_at(level: int) -> float:
	return maxf(cooldown - float(level - 1) * 0.1, 0.5)

## 레벨별 데미지
func get_damage_at(level: int) -> int:
	return base_damage + damage_per_level * (level - 1)
