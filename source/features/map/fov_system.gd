class_name FOVSystem
extends Node2D

@export var radius: int = 8
@export var map_size: Vector2i = Vector2i(32, 32)
@export var wall_layer: TileMapLayer = null

var visible_cells: Array[Vector2i] = []
var explored_cells: Array[Vector2i] = []

func _ready() -> void:
	explored_cells.clear()
	compute_visibility(Vector2i.ZERO)

func compute_visibility(origin: Vector2i) -> void:
	visible_cells.clear()
	visible_cells.append(origin)
	_mark_explored(origin)

	var corners: Array[Vector2i] = [
		origin, Vector2i(origin.x, origin.y),
		Vector2i(origin.x + radius, origin.y - radius),
		Vector2i(origin.x + radius, origin.y + radius),
		Vector2i(origin.x - radius, origin.y + radius),
		Vector2i(origin.x - radius, origin.y - radius),
	]
	_cast_light(origin, corners)

func _cast_light(origin: Vector2i, corners: Array[Vector2i]) -> void:
	for i: int in range(corners.size()):
		_cast_ray(origin, corners[i], i, corners[(i + 1) % corners.size()])

func _cast_ray(start: Vector2i, target: Vector2i, start_angle: int, end_angle: int) -> void:
	var dx: float = target.x - start.x
	var dy: float = target.y - start.y
	var distance: float = sqrt(dx * dx + dy * dy)
	if distance <= 0.001:
		return

	var angle: float = atan2(dy, dx)
	var s_angle: float = start_angle
	var e_angle: float = end_angle

	if s_angle <= e_angle:
		while angle >= s_angle and angle <= e_angle:
			_process_angle(origin, angle, radius)
			angle += 0.01
	else:
		while angle <= e_angle:
			_process_angle(origin, angle, radius)
			angle += 0.01
		angle = -3.14159265359
		while angle <= e_angle:
			_process_angle(origin, angle, radius)
			angle += 0.01

func _process_angle(origin: Vector2i, angle: float, max_radius: int) -> void:
	var x: int = round(origin.x + cos(angle) * max_radius)
	var y: int = round(origin.y + sin(angle) * max_radius)
	var cell: Vector2i = Vector2i(x, y)
	if cell.x < 0 or cell.x >= map_size.x or cell.y < 0 or cell.y >= map_size.y:
		return
	if is_wall(cell):
		return
	if cell not in visible_cells:
		visible_cells.append(cell)
		_mark_explored(cell)

func is_wall(cell: Vector2i) -> bool:
	if wall_layer == null:
		return false
	return wall_layer.get_cell_source_id(cell) != -1

func is_visible(cell: Vector2i) -> bool:
	return cell in visible_cells

func is_explored(cell: Vector2i) -> bool:
	return cell in explored_cells

func _mark_explored(cell: Vector2i) -> void:
	if cell not in explored_cells:
		explored_cells.append(cell)
