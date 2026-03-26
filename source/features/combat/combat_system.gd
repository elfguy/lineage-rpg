## 전투 시스템
## 플레이어-적 간 전투를 관리합니다.

class_name CombatSystem
extends Node

signal combat_started(enemy: Enemy)
signal combat_ended()
signal enemy_killed(enemy: Enemy, rewards: Dictionary)

var is_in_combat: bool = false
var active_enemies: Array[Enemy] = []

func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)

func enter_combat(enemy: Enemy) -> void:
	if not is_in_combat:
		is_in_combat = true
		combat_started.emit(enemy)
	if not active_enemies.has(enemy):
		active_enemies.append(enemy)

func exit_combat() -> void:
	is_in_combat = false
	active_enemies.clear()
	combat_ended.emit()

## 플레이어가 적을 공격
func player_attack(target: Enemy) -> Dictionary:
	var player_attack: int = GameState.player_data.get("attack", 10)
	var enemy_defense: int = target.defense
	var result: Dictionary = DamageCalculator.calculate_critical(player_attack, enemy_defense)
	var damage: int = result.get("damage", 1) as int
	var is_critical: bool = result.get("is_critical", false) as bool
	var died: bool = target.take_damage(damage)
	enter_combat(target)
	if died:
		var rewards: Dictionary = _generate_rewards(target)
		enemy_killed.emit(target, rewards)
		_apply_rewards(rewards)
		active_enemies.erase(target)
		if active_enemies.is_empty():
			exit_combat()
	return {
		"damage": damage,
		"is_critical": is_critical,
		"enemy_killed": died,
		"rewards": {} if not died else _generate_rewards(target),
	}

## 적이 플레이어를 공격
func enemy_attack_player(enemy: Enemy) -> int:
	var enemy_attack: int = enemy.attack_power
	var player_defense: int = GameState.player_data.get("defense", 5)
	var damage: int = DamageCalculator.calculate(enemy_attack, player_defense)
	var new_hp: int = GameState.player_data.get("hp", 100) - damage
	GameState.player_data["hp"] = maxi(new_hp, 0)
	EventBus.health_changed.emit(
		GameState.player_data.get("hp", 0),
		GameState.player_data.get("max_hp", 100),
	)
	if GameState.player_data.get("hp", 0) <= 0:
		EventBus.player_died.emit()
		exit_combat()
	return damage

func _generate_rewards(enemy: Enemy) -> Dictionary:
	var rewards: Dictionary = {"experience": enemy.experience_reward}
	if enemy.drop_item_id != "" and randf() < enemy.drop_item_chance:
		rewards["item_id"] = enemy.drop_item_id
	return rewards

func _apply_rewards(rewards: Dictionary) -> void:
	var exp: int = rewards.get("experience", 0)
	if exp > 0:
		EventBus.experience_gained.emit(exp)

func _on_enemy_died(_enemy: Node, _position: Vector2) -> void:
	if active_enemies.is_empty():
		exit_combat()
