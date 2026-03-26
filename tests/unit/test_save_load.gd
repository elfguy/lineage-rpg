extends GutTest

func test_save_game() -> void:
	var sm: Node = Engine.get_singleton("SaveManager")
	assert_true(sm.has_method("save_game"), "Should have save_game method")
	var result: bool = sm.save_game()
	assert_true(result, "save_game should return true")
	assert_true(sm.has_save(), "Should have save file after saving")

func test_load_game() -> void:
	var sm: Node = Engine.get_singleton("SaveManager")
	sm.save_game()
	var result: bool = sm.load_game()
	assert_true(result, "load_game should return true")

func test_delete_save() -> void:
	var sm: Node = Engine.get_singleton("SaveManager")
	sm.save_game()
	assert_true(sm.has_save())
	sm.delete_save()
	assert_false(sm.has_save(), "Should not have save after delete")

func test_load_without_save() -> void:
	var sm: Node = Engine.get_singleton("SaveManager")
	sm.delete_save()
	var result: bool = sm.load_game()
	assert_false(result, "Should return false when no save exists")

func test_save_data_persists_player_position() -> void:
	var sm: Node = Engine.get_singleton("SaveManager")
	GameState.player_position = Vector2(42, 99)
	GameState.current_map_id = "dungeon"
	sm.save_game()
	GameState.player_position = Vector2.ZERO
	GameState.current_map_id = "town"
	sm.load_game()
	assert_eq(GameState.player_position, Vector2(42, 99), "Position should be restored")
	assert_eq(GameState.current_map_id, "dungeon", "Map ID should be restored")
