extends GutTest

var quest_system: Node
var test_quest_data: QuestResource

func before_each() -> void:
	quest_system = preload("res://source/features/quest/quest_system.gd").new()
	add_child_autofree(quest_system)

	test_quest_data = QuestResource.new()
	test_quest_data.quest_id = "kill_slimes"
	test_quest_data.quest_name = "Kill 5 Slimes"
	test_quest_data.quest_type = QuestResource.QuestType.HUNT
	test_quest_data.target_id = "Slime"
	test_quest_data.target_count = 5
	test_quest_data.experience_reward = 50
	quest_system.register_quest(test_quest_data)

func test_register_quest() -> void:
	assert_true(quest_system.quest_templates.has("kill_slimes"), "Quest should be registered")

func test_accept_quest() -> void:
	var result: bool = quest_system.accept_quest("kill_slimes")
	assert_true(result, "Should accept quest")
	assert_true(quest_system.active_quests.has("kill_slimes"), "Quest should be active")

func test_accept_quest_twice_fails() -> void:
	quest_system.accept_quest("kill_slimes")
	var result: bool = quest_system.accept_quest("kill_slimes")
	assert_false(result, "Should not accept same quest twice")

func test_update_quest_progress() -> void:
	quest_system.accept_quest("kill_slimes")
	quest_system.update_quest_progress("kill_slimes", 2)
	var quest: Quest = quest_system.active_quests.get("kill_slimes")
	assert_eq(quest.current_progress, 2, "Progress should be 2")

func test_quest_completion() -> void:
	quest_system.accept_quest("kill_slimes")
	quest_system.update_quest_progress("kill_slimes", 5)
	var quest: Quest = quest_system.active_quests.get("kill_slimes")
	assert_eq(quest.status, QuestResource.QuestStatus.COMPLETED, "Quest should be completed")

func test_quest_progress_percent() -> void:
	quest_system.accept_quest("kill_slimes")
	quest_system.update_quest_progress("kill_slimes", 3)
	var quest: Quest = quest_system.active_quests.get("kill_slimes")
	assert_eq(quest.get_progress_percent(), 0.6, "Progress should be 60%")

func test_quest_with_prerequisites() -> void:
	var main_quest: QuestResource = QuestResource.new()
	main_quest.quest_id = "main_quest"
	main_quest.quest_name = "Main Quest"
	quest_system.register_quest(main_quest)

	var follow_up: QuestResource = QuestResource.new()
	follow_up.quest_id = "follow_up"
	follow_up.quest_name = "Follow Up"
	follow_up.prerequisite_quests = ["main_quest"]
	quest_system.register_quest(follow_up)

	# 선행 퀘스트 미완료 → 수락 불가
	assert_false(quest_system.can_accept_quest("follow_up"), "Should not accept without prerequisite")

	# 선행 퀘스트 완료
	quest_system.accept_quest("main_quest")
	quest_system.update_quest_progress("main_quest", 1)
	# 완료 처리
	quest_system.complete_quest("main_quest")

	assert_true(quest_system.can_accept_quest("follow_up"), "Should accept after prerequisite done")

func test_level_requirement() -> void:
	var hard_quest: QuestResource = QuestResource.new()
	hard_quest.quest_id = "hard_quest"
	hard_quest.quest_name = "Hard Quest"
	hard_quest.required_level = 10
	quest_system.register_quest(hard_quest)

	# 기본 레벨 1 → 수락 불가
	assert_false(quest_system.can_accept_quest("hard_quest"), "Should not accept at level 1")

	# 레벨 올리기
	GameState.player_data["level"] = 10
	assert_true(quest_system.can_accept_quest("hard_quest"), "Should accept at level 10")
	GameState.player_data["level"] = 1
