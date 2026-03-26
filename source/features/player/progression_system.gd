## 성장 시스템
## 경험치 획득, 레벨업, 스탯 증가를 관리합니다.

class_name ProgressionSystem
extends Node

## 레벨업에 필요한 경험치 공식
const BASE_EXP: int = 100
const EXP_GROWTH: float = 1.5

## 레벨업 시 스탯 증가량
const HP_PER_LEVEL: int = 20
const MP_PER_LEVEL: int = 10
const ATTACK_PER_LEVEL: int = 3
const DEFENSE_PER_LEVEL: int = 2

signal experience_gained(amount: int, total: int)
signal level_up(new_level: int)

func _ready() -> void:
	EventBus.experience_gained.connect(_on_experience_gained)

## 경험치 추가 — 레벨업 처리 포함
func add_experience(amount: int) -> int:
	var player_data: Dictionary = GameState.player_data
	var current_exp: int = player_data.get("experience", 0)
	var current_level: int = player_data.get("level", 1)
	current_exp += amount
	var levels_gained: int = 0
	# 다중 레벨업 가능
	while current_exp >= get_exp_to_next(current_level):
		current_exp -= get_exp_to_next(current_level)
		current_level += 1
		levels_gained += 1
		_apply_level_up_stats(player_data, current_level)
		EventBus.level_up.emit(current_level)
	player_data["experience"] = current_exp
	player_data["level"] = current_level
	player_data["experience_to_next"] = get_exp_to_next(current_level)
	experience_gained.emit(amount, current_exp)
	return levels_gained

## 레벨 N에서 N+1로 갈 때 필요한 경험치
func get_exp_to_next(level: int) -> int:
	return int(float(BASE_EXP) * pow(EXP_GROWTH, float(level - 1)))

## 현재 경험치 퍼센트 (0.0 ~ 1.0)
func get_experience_percent() -> float:
	var player_data: Dictionary = GameState.player_data
	var current_exp: int = player_data.get("experience", 0)
	var level: int = player_data.get("level", 1)
	var needed: int = get_exp_to_next(level)
	if needed <= 0:
		return 1.0
	return float(current_exp) / float(needed)

## 레벨업 시 스탯 증가 적용
func _apply_level_up_stats(player_data: Dictionary, new_level: int) -> void:
	player_data["max_hp"] = player_data.get("max_hp", 100) + HP_PER_LEVEL
	player_data["hp"] = player_data.get("max_hp", 100)  # 레벨업 시 풀 회복
	player_data["max_mp"] = player_data.get("max_mp", 50) + MP_PER_LEVEL
	player_data["mp"] = player_data.get("max_mp", 50)
	player_data["attack"] = player_data.get("attack", 10) + ATTACK_PER_LEVEL
	player_data["defense"] = player_data.get("defense", 5) + DEFENSE_PER_LEVEL
	EventBus.health_changed.emit(player_data.get("hp", 100), player_data.get("max_hp", 100))
	EventBus.mana_changed.emit(player_data.get("mp", 50), player_data.get("max_mp", 50))

func _on_experience_gained(amount: int) -> void:
	add_experience(amount)
