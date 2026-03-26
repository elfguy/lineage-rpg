## 퀘스트 Resource 데이터 모델

class_name QuestResource
extends Resource

enum QuestType {
	HUNT,
	COLLECT,
	VISIT,
	ESCORT,
}

enum QuestStatus {
	NOT_STARTED,
	IN_PROGRESS,
	COMPLETED,
	FAILED,
}

@export var quest_id: String = ""
@export var quest_name: String = ""
@export var description: String = ""
@export var quest_type: QuestType = QuestType.HUNT
@export var target_id: String = ""
@export var target_count: int = 1
@export var experience_reward: int = 0
@export var gold_reward: int = 0
@export var item_rewards: Array[String] = []
@export var required_level: int = 1
@export var prerequisite_quests: Array[String] = []
