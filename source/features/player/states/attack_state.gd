extends State

var player: CharacterBody2D
var attack_duration: float = 0.4
var attack_timer: float = 0.0

func _ready() -> void:
	player = get_parent().get_parent()

func enter(_data: Dictionary) -> void:
	attack_timer = 0.0
	player.velocity = Vector2.ZERO
	if player.sprite and player.sprite.has_animation("attack"):
		player.sprite.play("attack")

func update(_delta: float) -> void:
	attack_timer += _delta
	if attack_timer >= attack_duration:
		state_machine.transition_to("idle")
