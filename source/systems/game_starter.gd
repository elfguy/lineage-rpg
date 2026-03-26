## 게임 시작 매니저
## 시작 시 데이터 로드 및 초기화

extends Node

func _ready() -> void:
	_load_game_data()
	_setup_player()

## .tres 데이터를 시스템에 등록
func _load_game_data() -> void:
	_load_items()
	_load_skills()
	_load_quests()

func _load_items() -> void:
	var item_paths: Array[String] = [
		"res://source/systems/data/items/hp_potion.tres",
		"res://source/systems/data/items/mp_potion.tres",
		"res://source/systems/data/items/iron_sword.tres",
		"res://source/systems/data/items/leather_armor.tres",
		"res://source/systems/data/items/slime_gel.tres",
	]
	for path: String in item_paths:
		var res: Resource = load(path)
		if res != null and res is ItemResource:
			print("Loaded item: ", (res as ItemResource).item_name)

func _load_skills() -> void:
	var skill_paths: Array[String] = [
		"res://source/systems/data/skills/power_strike.tres",
		"res://source/systems/data/skills/fireball.tres",
		"res://source/systems/data/skills/heal.tres",
	]
	var skill_sys: Node = get_node_or_null("/root/SkillSystem")
	if skill_sys == null:
		return
	for path: String in skill_paths:
		var res: Resource = load(path)
		if res != null and res is SkillResource:
			skill_sys.register_skill(res as SkillResource)
			print("Registered skill: ", (res as SkillResource).skill_name)

func _load_quests() -> void:
	var quest_paths: Array[String] = [
		"res://source/systems/data/quests/slime_hunt.tres",
		"res://source/systems/data/quests/collect_herbs.tres",
	]
	var quest_sys: Node = get_node_or_null("/root/QuestSystem")
	if quest_sys == null:
		return
	for path: String in quest_paths:
		var res: Resource = load(path)
		if res != null and res is QuestResource:
			quest_sys.register_quest(res as QuestResource)
			print("Registered quest: ", (res as QuestResource).quest_name)

func _setup_player() -> void:
	# 시작 시 체력 포션 3개 지급
	var inventory: Node = get_node_or_null("/root/Inventory")
	if inventory == null:
		return
	var hp_pot: Resource = load("res://source/systems/data/items/hp_potion.tres")
	if hp_pot != null and hp_pot is ItemResource:
		inventory.add_item(hp_pot as ItemResource, 3)
