class_name StateMachine
extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_machine = self
	if initial_state:
		current_state = initial_state
		current_state.enter({})

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func transition_to(state_name: String, data: Dictionary = {}) -> void:
	var new_state: State = states.get(state_name.to_lower())
	if new_state == null:
		push_error("State not found: ", state_name)
		return
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter(data)
