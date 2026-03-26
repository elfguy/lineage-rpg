## 맵 매니저
## 타일맵 관리 및 맵 전환을 담당합니다.

class_name MapManager
extends Node2D

signal map_changed(new_map_id: String)

@export var map_id: String = "town"
@export var map_size: Vector2i = Vector2i(32, 32)
@export var tile_size: Vector2i = Vector2i(32, 32)

@onready var ground_layer: TileMapLayer = $GroundLayer
@onready var wall_layer: TileMapLayer = $WallLayer
@onready var overlay_layer: TileMapLayer = $OverlayLayer

func _ready() -> void:
	EventBus.map_entered.emit(map_id)

## 전역 위치를 맵 셀 좌표로 변환
func get_cell_at(global_pos: Vector2) -> Vector2i:
	var local_pos: Vector2 = to_local(global_pos)
	return ground_layer.local_to_map(local_pos)

## 해당 셀이 보행 가능한지 확인
func is_walkable(cell: Vector2i) -> bool:
	var source_id: int = wall_layer.get_cell_source_id(cell)
	return source_id == -1

## 중심 주변의 보행 가능한 셀 목록 반환
func get_walkable_cells_around(center: Vector2i, radius: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for x: int in range(center.x - radius, center.x + radius + 1):
		for y: int in range(center.y - radius, center.y + radius + 1):
			var cell: Vector2i = Vector2i(x, y)
			if is_walkable(cell):
				cells.append(cell)
	return cells

## 맵 전환 요청
func request_map_change(target_map_id: String, spawn_point: Vector2 = Vector2.ZERO) -> void:
	GameState.current_map_id = target_map_id
	GameState.player_position = spawn_point
	map_changed.emit(target_map_id)
	EventBus.map_entered.emit(target_map_id)

## 현재 맵 ID 반환
func get_current_map_id() -> String:
	return map_id

## 월드 좌표를 타일 좌표로 변환
func world_to_cell(world_pos: Vector2) -> Vector2i:
	var local_pos: Vector2 = to_local(world_pos)
	return ground_layer.local_to_map(local_pos)

## 타일 좌표를 월드 좌표로 변환
func cell_to_world(cell: Vector2i) -> Vector2:
	var local_pos: Vector2 = ground_layer.map_to_local(cell)
	return to_global(local_pos)
