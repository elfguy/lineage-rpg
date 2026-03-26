## HP 바 UI 컴포넌트

extends Node2D

@onready var background: ColorRect = $Background
@onready var fill: ColorRect = $Fill

var max_health: int = 100
var current_health: int = 100
var bar_width: float = 32.0
var bar_height: float = 4.0

func _ready() -> void:
	update_display()

func setup(max_hp: int, current_hp: int) -> void:
	max_health = max_hp
	current_health = current_hp
	update_display()

func set_health(hp: int) -> void:
	current_health = hp
	update_display()

func update_display() -> void:
	if not fill:
		return
	
	var health_percent: float = float(current_health) / float(max_health) if max_health > 0 else 0.0
	fill.size.x = bar_width * health_percent
	
	# 색상: 녹색→노랑→빨강
	if health_percent > 0.6:
		fill.color = Color.GREEN
	elif health_percent > 0.3:
		fill.color = Color.YELLOW
	else:
		fill.color = Color.RED
