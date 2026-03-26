## 퀘스트 시스템 매니저
## 모든 퀘스트의 수락/진행/완료/보상을 관리합니다.

class_name QuestSystem
extends Node

## 등록된 퀘스트 템플릿 (quest_id -> QuestResource)
var quest_templates: Dictionary = {}

## 진행 중/완료된 퀘스트 (quest_id -> Quest)
var active_quests: Dictionary = {}

## 완료된 퀘스트 ID 목록
var completed_quest_ids: Array[String] = []

func _ready() -> void:
	_connect_event_bus_signals()

## 퀘스트 템플릿 등록
func register_quest(quest_data: QuestResource) -> void:
	quest_templates[quest_data.quest_id] = quest_data

## 퀘스트 수락 가능 여부
func can_accept_quest(quest_id: String) -> bool:
	if not quest_templates.has(quest_id):
		return false
	if active_quests.has(quest_id) or completed_quest_ids.has(quest_id):
		return false
	var data: QuestResource = quest_templates.get(quest_id)
	var player_level: int = GameState.player_data.get("level", 1)
	if player_level < data.required_level:
		return false
	# 선행 퀘스트 검사
	for prereq_id: String in data.prerequisite_quests:
		if not completed_quest_ids.has(prereq_id):
			return false
	return true

## 퀘스트 수락
func accept_quest(quest_id: String) -> bool:
	if not can_accept_quest(quest_id):
		return false
	var data: QuestResource = quest_templates.get(quest_id)
	var quest: Quest = Quest.new(data)
	quest.accept()
	active_quests[quest_id] = quest
	quest.completed.connect(_on_quest_completed)
	return true

## 퀘스트 목표 진행
func update_quest_progress(quest_id: String, amount: int = 1) -> void:
	if active_quests.has(quest_id):
		var quest: Quest = active_quests.get(quest_id)
		quest.update_progress(amount)

## 퀘스트 완료 처리 (보상 지급)
func complete_quest(quest_id: String) -> Dictionary:
	if not active_quests.has(quest_id):
		return {"success": false, "reason": "not_active"}
	var quest: Quest = active_quests.get(quest_id)
	if not quest.can_complete():
		return {"success": false, "reason": "incomplete"}
	quest.complete()
	var rewards: Dictionary = _grant_rewards(quest.quest_data)
	return {"success": true, "rewards": rewards}

## 특정 타겟 ID와 관련된 퀘스트 진행
func progress_quests_by_target(target_id: String, quest_type: QuestResource.QuestType) -> void:
	for quest_id: String in active_quests:
		var quest: Quest = active_quests.get(quest_id)
		if quest.quest_data.quest_type == quest_type and quest.quest_data.target_id == target_id:
			quest.update_progress()

## 사냥 목표 업데이트 (enemy_name 기반)
func on_enemy_killed(enemy_name: String) -> void:
	progress_quests_by_target(enemy_name, QuestResource.QuestType.HUNT)

func _grant_rewards(data: QuestResource) -> Dictionary:
	var rewards: Dictionary = {}
	# 경험치 보상
	if data.experience_reward > 0:
		EventBus.experience_gained.emit(data.experience_reward)
		rewards["experience"] = data.experience_reward
	# 골드 보상
	if data.gold_reward > 0:
		GameState.player_data["gold"] = GameState.player_data.get("gold", 0) + data.gold_reward
		rewards["gold"] = data.gold_reward
	return rewards

func _on_quest_completed(quest_id: String) -> void:
	if not completed_quest_ids.has(quest_id):
		completed_quest_ids.append(quest_id)
		active_quests.erase(quest_id)

func _connect_event_bus_signals() -> void:
	EventBus.enemy_died.connect(_on_enemy_died_for_quests)

func _on_enemy_died_for_quests(_enemy: Node, _position: Vector2) -> void:
	# Enemy 사망 시 사냥 퀘스트 진행 (적 이름 매칭 필요)
	# 실제 적 이름은 enemy.enemy_name에서 가져와야 함
	pass
