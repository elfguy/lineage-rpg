## HP 컴포넌트
## 엔티티의 체력을 관리하는 재사용 컴포넌트

class_name HealthComponent
extends Node

signal health_changed(current: int, maximum: int)
signal died()

@export var max_health: int = 100
@export var current_health: int = 100

var is_dead: bool = false

func _ready() -> void:
	current_health = mini(current_health, max_health)

## 데미지를 받음. 사망 시 true 반환
func take_damage(amount: int) -> bool:
	if is_dead:
		return false
	var new_health: int = maxi(current_health - amount, 0)
	current_health = new_health
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		is_dead = true
		died.emit()
		return true
	return false

## 체력 회복
func heal(amount: int) -> void:
	if is_dead:
		return
	current_health = mini(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)

## 체력을 특정 값으로 설정
func set_health(value: int) -> void:
	current_health = clampi(value, 0, max_health)
	health_changed.emit(current_health, max_health)
	if current_health <= 0 and not is_dead:
		is_dead = true
		died.emit()

## 완전 회복
func full_heal() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)
	is_dead = false

## 퍼센트 반환 (0.0 ~ 1.0)
func get_health_percent() -> float:
	if max_health <= 0:
		return 0.0
	return float(current_health) / float(max_health)
