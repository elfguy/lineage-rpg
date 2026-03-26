## 퀘스트 단일 객체
## 진행 중인 퀘스트의 상태를 관리합니다.

class_name Quest
extends RefCounted

signal progress_updated(quest_id: String, objective: String, progress: int)
signal completed(quest_id: String)

var quest_data: QuestResource
var status: QuestResource.QuestStatus = QuestResource.QuestStatus.NOT_STARTED
var current_progress: int = 0

func _init(data: QuestResource) -> void:
	quest_data = data
	status = QuestResource.QuestStatus.NOT_STARTED
	current_progress = 0

## 퀘스트 수락
func accept() -> void:
	status = QuestResource.QuestStatus.IN_PROGRESS
	current_progress = 0

## 진행도 업데이트
func update_progress(amount: int = 1) -> void:
	if status != QuestResource.QuestStatus.IN_PROGRESS:
		return
	current_progress = mini(current_progress + amount, quest_data.target_count)
	var objective: String = _get_objective_text()
	progress_updated.emit(quest_data.quest_id, objective, current_progress)
	EventBus.quest_updated.emit(quest_data.quest_id, objective, current_progress)
	if current_progress >= quest_data.target_count:
		complete()

## 퀘스트 완료
func complete() -> void:
	status = QuestResource.QuestStatus.COMPLETED
	completed.emit(quest_data.quest_id)
	EventBus.quest_completed.emit(quest_data.quest_id)

## 완료 가능 여부
func can_complete() -> bool:
	return status == QuestResource.QuestStatus.IN_PROGRESS and current_progress >= quest_data.target_count

## 진행률 퍼센트 (0.0 ~ 1.0)
func get_progress_percent() -> float:
	if quest_data.target_count <= 0:
		return 1.0
	return float(current_progress) / float(quest_data.target_count)

func _get_objective_text() -> String:
	match quest_data.quest_type:
		QuestResource.QuestType.HUNT:
			return "%s 처치 (%d/%d)" % [quest_data.target_id, current_progress, quest_data.target_count]
		QuestResource.QuestType.COLLECT:
			return "%s 수집 (%d/%d)" % [quest_data.target_id, current_progress, quest_data.target_count]
		QuestResource.QuestType.VISIT:
			return "%s 방문" % quest_data.target_id
		_:
			return "%s (%d/%d)" % [quest_data.target_id, current_progress, quest_data.target_count]
