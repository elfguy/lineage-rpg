extends GutTest

func test_game_state_has_player_data() -> void:
	var state: Node = Engine.get_singleton("GameState")
	assert_true(state.player_data.has("name"), "player_data should have name")
	assert_true(state.player_data.has("level"), "player_data should have level")
	assert_true(state.player_data.has("hp"), "player_data should have hp")
	assert_true(state.player_data.has("max_hp"), "player_data should have max_hp")
	assert_true(state.player_data.has("mp"), "player_data should have mp")
	assert_true(state.player_data.has("max_mp"), "player_data should have max_mp")

func test_game_state_default_values() -> void:
	var state: Node = Engine.get_singleton("GameState")
	assert_eq(state.player_data.get("hp"), 100, "Default HP should be 100")
	assert_eq(state.player_data.get("max_hp"), 100, "Default max HP should be 100")
	assert_eq(state.player_data.get("mp"), 50, "Default MP should be 50")
	assert_eq(state.player_data.get("max_mp"), 50, "Default max MP should be 50")
	assert_eq(state.player_data.get("level"), 1, "Default level should be 1")
	assert_eq(state.current_map_id, "town", "Default map should be town")

func test_game_state_position_defaults() -> void:
	var state: Node = Engine.get_singleton("GameState")
	assert_eq(state.player_position, Vector2.ZERO, "Default position should be Vector2.ZERO")
