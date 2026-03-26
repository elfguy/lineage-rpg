extends State

var speed: float = 200.0
var player: CharacterBody2D

func _ready() -> void:
	player = get_parent().get_parent()

func enter(_data: Dictionary) -> void:
	player.velocity = Vector2.ZERO

func update(_delta: float) -> void:
	if player.sprite and player.sprite.has_animation("idle"):
		player.sprite.play("idle")

func physics_update(_delta: float) -> void:
	var direction: Vector2 = _get_input_direction()
	if direction != Vector2.ZERO:
		state_machine.transition_to("walk")
		return

	player.velocity = Vector2.ZERO
	player.move_and_slide()

func _get_input_direction() -> Vector2:
	var direction: Vector2 = Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_forward", "move_backward")
	return direction.normalized()
