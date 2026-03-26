extends GutTest

func test_save_manager_has_save_path() -> void:
	var sm: Node = Engine.get_singleton("SaveManager")
	assert_not_null(sm, "SaveManager should exist as autoload")

func test_save_manager_has_save_method() -> void:
	var sm: Node = Engine.get_singleton("SaveManager")
	assert_true(sm.has_method("save_game"), "Should have save_game method")
	assert_true(sm.has_method("load_game"), "Should have load_game method")
	assert_true(sm.has_method("has_save"), "Should have has_save method")
	assert_true(sm.has_method("delete_save"), "Should have delete_save method")

func test_save_and_load_roundtrip() -> void:
	var sm: Node = Engine.get_singleton("SaveManager")
	var test_data: Dictionary = {"test": true}
	var result: bool = sm.save_game(test_data, Vector2(50, 50), "town")
	assert_true(result, "save_game should return true")
	assert_true(sm.has_save(), "has_save should return true after saving")

	var loaded: Dictionary = sm.load_game()
	assert_not_null(loaded, "load_game should return non-null")
	assert_eq(loaded.get("current_map_id"), "town", "Should load correct map_id")

	sm.delete_save()
	assert_false(sm.has_save(), "has_save should return false after delete")
