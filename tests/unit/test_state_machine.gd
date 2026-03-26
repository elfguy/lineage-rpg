extends GutTest

var state_machine: Node
var player: CharacterBody2D

func before_each() -> void:
	var player_scene: PackedScene = load("res://source/features/player/player.tscn")
	player = player_scene.instantiate()
	add_child_autofree(player)
	state_machine = player.get_node("StateMachine")

func test_transition_from_idle_to_walk() -> void:
	assert_eq(state_machine.current_state.name, "Idle", "Should start in Idle")
	state_machine.transition_to("walk")
	assert_eq(state_machine.current_state.name, "Walk", "Should transition to Walk")

func test_transition_from_walk_to_idle() -> void:
	state_machine.transition_to("walk")
	assert_eq(state_machine.current_state.name, "Walk", "Should be in Walk")
	state_machine.transition_to("idle")
	assert_eq(state_machine.current_state.name, "Idle", "Should transition back to Idle")

func test_transition_to_attack() -> void:
	state_machine.transition_to("attack")
	assert_eq(state_machine.current_state.name, "Attack", "Should transition to Attack")

func test_transition_to_invalid_state() -> void:
	assert_eq(state_machine.current_state.name, "Idle", "Should start in Idle")
	state_machine.transition_to("nonexistent")
	assert_eq(state_machine.current_state.name, "Idle", "Should remain in Idle for invalid transition")

func test_states_register_in_dictionary() -> void:
	var states: Dictionary = state_machine.states
	assert_true(states.has("idle"), "States dict should have idle key")
	assert_true(states.has("walk"), "States dict should have walk key")
	assert_true(states.has("attack"), "States dict should have attack key")
