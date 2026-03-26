extends GutTest

var player_scene: PackedScene

func before_all() -> void:
	player_scene = load("res://source/features/player/player.tscn")

func test_player_scene_loads() -> void:
	assert_not_null(player_scene, "Player scene should load")

func test_player_scene_has_script() -> void:
	assert_not_null(player_scene.get_state().get_node_owner_count(), "Scene should have nodes")

func test_event_bus_autoload_exists() -> void:
	assert_not_null(Engine.get_singleton("EventBus"), "EventBus autoload should exist")

func test_game_state_autoload_exists() -> void:
	assert_not_null(Engine.get_singleton("GameState"), "GameState autoload should exist")

func test_save_manager_autoload_exists() -> void:
	assert_not_null(Engine.get_singleton("SaveManager"), "SaveManager autoload should exist")

func test_main_scene_loads() -> void:
	var main_scene: PackedScene = load("res://source/main.tscn")
	assert_not_null(main_scene, "Main scene should load")
