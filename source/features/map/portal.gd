## 포털
## 플레이어가 접촉하면 다른 맵으로 전환합니다.

class_name Portal
extends Area2D

signal portal_entered(target_map_id: String, spawn_point: Vector2)

@export var target_map_id: String = ""
@export var target_spawn_point: Vector2 = Vector2.ZERO
@export var is_active: bool = true
@export var requires_quest_id: String = ""

var player_inside: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if not is_active:
		return
	if body is CharacterBody2D and body.is_in_group("player"):
		player_inside = true
		_activate_portal()

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group("player"):
		player_inside = false

func _activate_portal() -> void:
	if not is_active:
		return
	# 퀘스트 조건 검사
	if requires_quest_id != "":
		var quest_system: Node = get_node_or_null("/root/QuestSystem")
		if quest_system and not quest_system.completed_quest_ids.has(requires_quest_id):
			return
	EventBus.map_entered.emit(target_map_id)
	portal_entered.emit(target_map_id, target_spawn_point)
	GameState.player_position = target_spawn_point
	GameState.current_map_id = target_map_id
