extends State

var speed: float = 200.0
var player: CharacterBody2D

func _ready() -> void:
	player = get_parent().get_parent()

func enter(_data: Dictionary) -> void:
	if player.sprite and player.sprite.has_animation("walk"):
		player.sprite.play("walk")

func update(_delta: float) -> void:
	var direction: Vector2 = _get_input_direction()
	if direction == Vector2.ZERO:
		state_machine.transition_to("idle")
		return
	elif Input.is_action_just_pressed("attack"):
		state_machine.transition_to("attack")
		return

	# 방향 업데이트
	player.update_facing(direction)
	
	player.velocity = direction * speed
	player.move_and_slide()
	EventBus.player_position_changed.emit(player.global_position)
	EventBus.player_direction_changed.emit(direction)

func physics_update(_delta: float) -> void:
	pass

func _get_input_direction() -> Vector2:
	var direction: Vector2 = Vector2.ZERO
	
	# 키보드 입력
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_forward", "move_backward")
	
	# 조이스틱 입력 (모바일)
	if direction == Vector2.ZERO:
		var joystick: Node = get_tree().get_first_node_in_group("joystick")
		if joystick and joystick.has_method("get_output"):
			direction = joystick.get_output()
	
	return direction.normalized()
