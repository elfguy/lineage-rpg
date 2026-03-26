## NPC

class_name NPC
extends Area2D

@export var npc_name: String = "마을 사람"
@export_multiline var dialogue_lines: Array[String] = [
	"안녕하세요, 용사님!",
	"마을에 오신 것을 환영합니다."
]

@onready var sprite: ColorRect = $ColorRect
@onready var interaction_label: Label = $InteractionLabel

var player_in_range: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if interaction_label:
		interaction_label.visible = false

func _input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		_start_dialogue()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		if interaction_label:
			interaction_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if interaction_label:
			interaction_label.visible = false

func _start_dialogue() -> void:
	"""대화 시작"""
	EventBus.npc_dialogue_started.emit(npc_name, dialogue_lines)
