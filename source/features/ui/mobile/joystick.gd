## 터치 조이스틱

extends Node2D

@onready var base: Node2D = $Base
@onready var stick: Node2D = $Stick

var touch_index: int = -1
var joystick_active: bool = false
var output: Vector2 = Vector2.ZERO
var base_position: Vector2 = Vector2.ZERO

const DEADZONE: float = 10.0
const MAX_DISTANCE: float = 50.0

func _ready() -> void:
	visible = false
	base_position = position

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and event.position.x < get_viewport_rect().size.x / 2:
			_show_joystick(event.position)
			touch_index = event.index
		elif not event.pressed and event.index == touch_index:
			_hide_joystick()
			touch_index = -1
	
	elif event is InputEventScreenDrag:
		if event.index == touch_index:
			_update_joystick(event.position)

func _show_joystick(pos: Vector2) -> void:
	global_position = pos
	joystick_active = true
	visible = true
	stick.position = Vector2.ZERO

func _hide_joystick() -> void:
	joystick_active = false
	visible = false
	output = Vector2.ZERO

func _update_joystick(pos: Vector2) -> void:
	var relative: Vector2 = pos - global_position
	
	if relative.length() < DEADZONE:
		stick.position = Vector2.ZERO
		output = Vector2.ZERO
		return
	
	relative = relative.limit_length(MAX_DISTANCE)
	stick.position = relative
	output = relative / MAX_DISTANCE

func get_output() -> Vector2:
	return output
