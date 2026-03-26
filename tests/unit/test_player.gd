extends GutTest

var player: CharacterBody2D
var state_machine: Node

func before_each() -> void:
	var player_scene: PackedScene = load("res://source/features/player/player.tscn")
	player = player_scene.instantiate()
	add_child_autofree(player)
	state_machine = player.get_node("StateMachine")

func test_player_has_required_nodes() -> void:
	assert_not_null(player, "Player should exist")
	assert_not_null(player.get_node_or_null("AnimatedSprite2D"), "Player should have AnimatedSprite2D")
	assert_not_null(player.get_node_or_null("CollisionShape2D"), "Player should have CollisionShape2D")
	assert_not_null(player.get_node_or_null("StateMachine"), "Player should have StateMachine")

func test_state_machine_has_all_states() -> void:
	assert_not_null(state_machine, "StateMachine should exist")
	assert_not_null(state_machine.get_node_or_null("Idle"), "Should have Idle state")
	assert_not_null(state_machine.get_node_or_null("Walk"), "Should have Walk state")
	assert_not_null(state_machine.get_node_or_null("Attack"), "Should have Attack state")

func test_state_machine_initial_state() -> void:
	assert_eq(state_machine.current_state.name, "Idle", "Initial state should be Idle")

func test_player_character_body2d() -> void:
	assert_true(player is CharacterBody2D, "Player should be a CharacterBody2D")
