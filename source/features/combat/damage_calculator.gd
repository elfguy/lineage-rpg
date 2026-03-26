## 데미지 계산기
## 공격력 - 방어력 기반 데미지를 계산합니다.

class_name DamageCalculator
extends RefCounted

## 데미지 계산 (공격력 - 방어력, 최소 1)
static func calculate(attack: int, defense: int) -> int:
	var raw_damage: int = attack - defense
	return maxi(raw_damage, 1)

## 크리티컬 계산 (확률 기반)
static func calculate_critical(attack: int, defense: int, crit_rate: float = 0.1, crit_multiplier: float = 1.5) -> Dictionary:
	var base_damage: int = calculate(attack, defense)
	var is_critical: bool = randf() < crit_rate
	var final_damage: int = base_damage
	if is_critical:
		final_damage = int(float(base_damage) * crit_multiplier)
	return {
		"damage": final_damage,
		"is_critical": is_critical,
	}
