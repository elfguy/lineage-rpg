class_name HealthBar
extends Control

@export var max_value: int = 100
var current_value: int = 100

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var value_label: Label = $ValueLabel

func _ready() -> void:
	progress_bar.max_value = max_value
	progress_bar.value = current_value
	value_label.text = "%d / %d" % [current_value, max_value]

func set_values(current: int, max_val: int) -> void:
	max_value = max_val
	current_value = current
	progress_bar.max_value = max_value
	progress_bar.value = current_value
	value_label.text = "%d / %d" % [current, max_value]
