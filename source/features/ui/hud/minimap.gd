class_name Minimap
extends Control

@export var map_size: Vector2i = Vector2i(32, 32)
@export var cell_size: int = 4

@onready var minimap_container: Control = $MinimapContainer

func update_player_position(global_pos: Vector2) -> void:
	var player_dot: Control = minimap_container.get_node_or_null("PlayerDot")
	if player_dot:
		var map_pos: Vector2 = global_pos / (Vector2(map_size) * Vector2(32, 32))
		player_dot.position = map_pos * minimap_container.size

func update_explored_cells(cells: Array[Vector2i]) -> void:
	for cell: Vector2i in cells:
		var pos: Vector2 = Vector2(cell.x / float(map_size.x), cell.y / float(map_size.y))
		pos *= minimap_container.size
		draw_explored_cell(pos)

func draw_explored_cell(pos: Vector2) -> void:
	var explored_dot: ColorRect = ColorRect.new()
	explored_dot.position = pos
	explored_dot.size = Vector2(cell_size, cell_size)
	explored_dot.color = Color(0.3, 0.6, 0.3, 0.8)
	explored_dot.name = "explored_%d_%d" % [int(pos.x), int(pos.y)]
	minimap_container.add_child(explored_dot)
