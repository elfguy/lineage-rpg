extends Node

const SAVE_PATH: String = "user://save_data.json"

func save_game(game_state: Dictionary, player_position: Vector2, map_id: String) -> bool:
	var save_data: Dictionary = {
		"timestamp": Time.get_datetime_string_from_system(),
		"game_state": game_state,
		"player_position": {"x": player_position.x, "y": player_position.y},
		"current_map_id": map_id,
	}
	var json_string: String = JSON.stringify(save_data, "\t")
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file: ", SAVE_PATH)
		return false
	file.store_string(json_string)
	file.close()
	EventBus.game_saved.emit()
	return true

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file: ", SAVE_PATH)
		return {}
	var json_string: String = file.get_as_text()
	file.close()
	var json: JSON = JSON.new()
	var parse_result: Variant = json.parse(json_string)
	if parse_result == null:
		push_error("Failed to parse save data")
		return {}
	var save_data: Dictionary = parse_result
	var player_pos: Dictionary = save_data.get("player_position", {"x": 0, "y": 0})
	EventBus.game_loaded.emit()
	return {
		"game_state": save_data.get("game_state", {}),
		"player_position": Vector2(player_pos.get("x", 0), player_pos.get("y", 0)),
		"current_map_id": save_data.get("current_map_id", "town"),
	}

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
