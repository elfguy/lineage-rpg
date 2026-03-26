extends GutTest

var progression: Node

func before_each() -> void:
	progression = preload("res://source/features/player/progression_system.gd").new()
	add_child_autofree(progression)
	# 매 테스트 전 초기화
	GameState.player_data = {
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

func test_add_experience() -> void:
	progression.add_experience(50)
	assert_eq(GameState.player_data["experience"], 50, "Should have 50 exp")

func test_level_up_at_100_exp() -> void:
	var levels: int = progression.add_experience(100)
	assert_eq(levels, 1, "Should gain 1 level")
	assert_eq(GameState.player_data["level"], 2, "Should be level 2")
	assert_eq(GameState.player_data["experience"], 0, "Exp should reset")
	assert_gt(GameState.player_data["max_hp"], 100, "Max HP should increase")
	assert_gt(GameState.player_data["attack"], 10, "Attack should increase")

func test_stat_gains_on_level_up() -> void:
	progression.add_experience(100)
	assert_eq(GameState.player_data["max_hp"], 120, "HP +20 per level")
	assert_eq(GameState.player_data["max_mp"], 60, "MP +10 per level")
	assert_eq(GameState.player_data["attack"], 13, "Attack +3 per level")
	assert_eq(GameState.player_data["defense"], 7, "Defense +2 per level")

func test_level_up_full_heal() -> void:
	GameState.player_data["hp"] = 30
	progression.add_experience(100)
	assert_eq(GameState.player_data["hp"], 120, "Should fully heal on level up")

func test_exp_to_next_increases() -> void:
	var first: int = progression.get_exp_to_next(1)
	var second: int = progression.get_exp_to_next(2)
	assert_gt(second, first, "Level 2 should need more exp than level 1")

func test_multi_level_up() -> void:
	var levels: int = progression.add_experience(350)
	assert_eq(levels, 2, "Should gain 2 levels")
	assert_eq(GameState.player_data["level"], 3, "Should be level 3")

func test_experience_percent() -> void:
	progression.add_experience(50)
	var percent: float = progression.get_experience_percent()
	assert_eq(percent, 0.5, "Should be 50%")
