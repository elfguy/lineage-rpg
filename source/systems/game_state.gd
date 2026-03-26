extends Node

var player_position: Vector2 = Vector2.ZERO
var current_map_id: String = "town"
var player_data: Dictionary = {
	"name": "용사",
	"level": 1,
	"experience": 0,
	"experience_to_next": 100,
	"hp": 100,
	"max_hp": 100,
	"mp": 50,
	"max_mp": 50,
	"attack": 10,
	"defense": 5,
	"gold": 0,
}

func add_experience(amount: int) -> void:
	"""경험치 추가 및 레벨업 체크"""
	player_data["experience"] += amount
	EventBus.experience_gained.emit(amount)

	# 레벨업 체크
	while player_data["experience"] >= player_data["experience_to_next"]:
		_level_up()

func _level_up() -> void:
	"""레벨업 처리"""
	player_data["experience"] -= player_data["experience_to_next"]
	player_data["level"] += 1
	player_data["experience_to_next"] = int(player_data["experience_to_next"] * 1.5)

	# 스탯 증가
	player_data["max_hp"] += 10
	player_data["hp"] = player_data["max_hp"]  # HP 회복
	player_data["max_mp"] += 5
	player_data["mp"] = player_data["max_mp"]
	player_data["attack"] += 2
	player_data["defense"] += 1

	EventBus.level_up.emit(player_data["level"])
	EventBus.health_changed.emit(player_data["hp"], player_data["max_hp"])

