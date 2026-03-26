## 세이브 매니저
## 전체 게임 상태 저장/복원

extends Node

const SAVE_PATH: String = "user://save_data.json"
const SAVE_VERSION: int = 2

## 전체 게임 상태 저장
func save_game() -> bool:
	var save_data: Dictionary = {
		"version": SAVE_VERSION,
		"timestamp": Time.get_datetime_string_from_system(),
		"player": _collect_player_data(),
		"inventory": _collect_inventory_data(),
		"equipment": _collect_equipment_data(),
		"quests": _collect_quest_data(),
		"skills": _collect_skill_data(),
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

## 전체 게임 상태 로드
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file: ", SAVE_PATH)
		return false
	var json_string: String = file.get_as_text()
	file.close()
	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_string)
	if parse_result != OK:
		push_error("Failed to parse save data: ", json.get_error_message())
		return false
	var save_data: Dictionary = json.get_data() as Dictionary
	if save_data.is_empty():
		push_error("Save data is empty")
		return false
	var version: int = save_data.get("version", 1)
	if version < SAVE_VERSION:
		_migrate_save_data(save_data, version)
	_restore_player_data(save_data.get("player", {}))
	_restore_inventory_data(save_data.get("inventory", {}))
	_restore_quest_data(save_data.get("quests", {}))
	_restore_skill_data(save_data.get("skills", {}))
	EventBus.game_loaded.emit()
	return true

## 세이브 파일 존재 여부
func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

## 세이브 삭제
func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

## — 데이터 수집 —

func _collect_player_data() -> Dictionary:
	var pd: Dictionary = GameState.player_data
	return {
		"player_data": pd.duplicate(true),
		"player_position": {
			"x": GameState.player_position.x,
			"y": GameState.player_position.y,
		},
		"current_map_id": GameState.current_map_id,
	}

func _collect_inventory_data() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var inventory: Node = get_node_or_null("/root/Inventory")
	if inventory == null:
		return result
	for slot: InventorySlot in inventory.slots:
		if slot.is_empty():
			result.append({"item_id": "", "quantity": 0})
		else:
			result.append({
				"item_id": slot.item.item_id,
				"quantity": slot.quantity,
			})
	return result

func _collect_equipment_data() -> Dictionary:
	var result: Dictionary = {}
	var equip_mgr: Node = get_node_or_null("/root/EquipmentManager")
	if equip_mgr == null:
		return result
	for slot: int in equip_mgr.equipped_items:
		var item: EquipmentResource = equip_mgr.equipped_items.get(slot)
		if item != null:
			result[str(slot)] = item.item_id
		else:
			result[str(slot)] = ""
	return result

func _collect_quest_data() -> Dictionary:
	var result: Dictionary = {}
	var quest_sys: Node = get_node_or_null("/root/QuestSystem")
	if quest_sys == null:
		return result
	var completed: Array[String] = []
	for quest_id: String in quest_sys.completed_quest_ids:
		completed.append(quest_id)
	result["completed"] = completed
	var active: Dictionary = {}
	for quest_id: String in quest_sys.active_quests:
		var quest: Quest = quest_sys.active_quests.get(quest_id)
		active[quest_id] = {
			"status": quest.status,
			"progress": quest.current_progress,
		}
	result["active"] = active
	return result

func _collect_skill_data() -> Dictionary:
	var result: Dictionary = {}
	var skill_sys: Node = get_node_or_null("/root/SkillSystem")
	if skill_sys == null:
		return result
	for skill_id: String in skill_sys.learned_skills:
		var slot: SkillSlot = skill_sys.learned_skills.get(skill_id)
		result[skill_id] = slot.current_level
	return result

## — 데이터 복원 —

func _restore_player_data(data: Dictionary) -> void:
	if data.is_empty():
		return
	var pd: Dictionary = data.get("player_data", {})
	for key: String in pd:
		GameState.player_data[key] = pd[key]
	var pos: Dictionary = data.get("player_position", {"x": 0, "y": 0})
	GameState.player_position = Vector2(pos.get("x", 0), pos.get("y", 0))
	GameState.current_map_id = data.get("current_map_id", "town")

func _restore_inventory_data(data: Array) -> void:
	if data.is_empty():
		return
	var inventory: Node = get_node_or_null("/root/Inventory")
	if inventory == null:
		return
	# 인벤토리 초기화
	for i: int in range(inventory.slots.size()):
		inventory.slots[i].item = null
		inventory.slots[i].quantity = 0
	# TODO: 실제 아이템 로드는 ItemResource 레지스트리 필요

func _restore_quest_data(data: Dictionary) -> void:
	if data.is_empty():
		return
	var quest_sys: Node = get_node_or_null("/root/QuestSystem")
	if quest_sys == null:
		return
	var completed: Array = data.get("completed", [])
	for quest_id: String in completed:
		quest_sys.completed_quest_ids.append(quest_id)

func _restore_skill_data(data: Dictionary) -> void:
	if data.is_empty():
		return
	var skill_sys: Node = get_node_or_null("/root/SkillSystem")
	if skill_sys == null:
		return
	for skill_id: String in data:
		var level: int = data.get(skill_id, 1)
		if skill_sys.can_learn_skill(skill_id):
			skill_sys.learn_skill(skill_id)
			for _i: int in range(level - 1):
				skill_sys.level_up_skill(skill_id)

func _migrate_save_data(_data: Dictionary, _from_version: int) -> void:
	# 향후 세이브 버전 마이그레이션용
	pass
