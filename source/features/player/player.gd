class_name Player
extends CharacterBody2D

@onready var sprite: ColorRect = $ColorRect
@onready var state_machine: StateMachine = $StateMachine

const SPEED: float = 200.0

var facing: String = "down"  # up, down, left, right
var direction: Vector2 = Vector2.ZERO

# 방향별 색상
const COLORS := {
	"up": Color.GREEN,
	"down": Color.BLUE,
	"left": Color.RED,
	"right": Color.YELLOW
}

func _ready() -> void:
	add_to_group("player")
	_update_sprite_color()
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

func update_facing(new_direction: Vector2) -> void:
	"""방향 업데이트 및 스프라이트 색상 변경"""
	if new_direction == Vector2.ZERO:
		return
	
	# 우선순위: 수평 > 수직
	if abs(new_direction.x) > abs(new_direction.y):
		facing = "right" if new_direction.x > 0 else "left"
	else:
		facing = "down" if new_direction.y > 0 else "up"
	
	_update_sprite_color()

func _update_sprite_color() -> void:
	"""스프라이트 색상 업데이트"""
	if sprite:
		sprite.color = COLORS.get(facing, Color.WHITE)
