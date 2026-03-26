class_name Player
extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine

const SPEED: float = 200.0

var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	EventBus.player_position_changed.emit(global_position)

func _process(delta: float) -> void:
	state_machine.update(delta)

func _physics_process(delta: float) -> void:
	state_machine.physics_update(delta)

func take_damage(amount: int) -> void:
	GameState.player_data.hp = max(GameState.player_data.hp - amount, 0)
	EventBus.health_changed.emit(
		GameState.player_data.hp,
		GameState.player_data.max_hp,
	)
	if GameState.player_data.hp <= 0:
		EventBus.player_died.emit()
