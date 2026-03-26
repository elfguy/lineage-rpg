## 액션 버튼

extends TouchScreenButton

@export var action_name: String = "attack"

signal button_pressed()
signal button_released()

func _ready() -> void:
	pressed.connect(_on_pressed)
	released.connect(_on_released)

func _on_pressed() -> void:
	var event := InputEventAction.new()
	event.action = action_name
	event.pressed = true
	Input.parse_input_event(event)
	button_pressed.emit()

func _on_released() -> void:
	var event := InputEventAction.new()
	event.action = action_name
	event.pressed = false
	Input.parse_input_event(event)
	button_released.emit()
