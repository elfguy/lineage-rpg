## 드랍된 아이템

class_name DroppedItem
extends Area2D

@export var item_id: String = "gold"
@export var item_name: String = "골드"
@export var amount: int = 10
@export var pickup_range: float = 30.0

@onready var sprite: ColorRect = $ColorRect

var player_ref: Node = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	# 플레이어 참조
	await get_tree().process_frame
	player_ref = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	# 플레이어 근처면 끌려감
	if player_ref:
		var dist: float = global_position.distance_to(player_ref.global_position)
		if dist < pickup_range * 2:
			var dir: Vector2 = (player_ref.global_position - global_position).normalized()
			global_position += dir * 3

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_pickup()

func _pickup() -> void:
	"""아이템 획득"""
	match item_id:
		"gold":
			GameState.player_data["gold"] += amount
		"health_potion":
			GameState.player_data["hp"] = min(
				GameState.player_data["hp"] + amount,
				GameState.player_data["max_hp"]
			)
			EventBus.health_changed.emit(
				GameState.player_data["hp"],
				GameState.player_data["max_hp"]
			)
	
	EventBus.item_picked_up.emit({
		"id": item_id,
		"name": item_name,
		"amount": amount
	})
	
	queue_free()
