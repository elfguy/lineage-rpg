class_name MapManager
extends Node2D

@export var map_id: String = "town"
@export var map_size: Vector2i = Vector2i(32, 32)
@export var tile_size: Vector2i = Vector2i(32, 32)

@onready var ground_layer: TileMapLayer = $GroundLayer
@onready var wall_layer: TileMapLayer = $WallLayer
@onready var overlay_layer: TileMapLayer = $OverlayLayer

func _ready() -> void:
	EventBus.map_entered.emit(map_id)

func get_cell_at(global_pos: Vector2) -> Vector2i:
	var local_pos: Vector2 = to_local(global_pos)
	return ground_layer.local_to_map(local_pos)

func is_walkable(cell: Vector2i) -> bool:
	var source_id: int = wall_layer.get_cell_source_id(cell)
	return source_id == -1

func get_walkable_cells_around(center: Vector2i, radius: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for x: int in range(center.x - radius, center.x + radius + 1):
		for y: int in range(center.y - radius, center.y + radius + 1):
			var cell: Vector2i = Vector2i(x, y)
			if is_walkable(cell):
				cells.append(cell)
	return cells
