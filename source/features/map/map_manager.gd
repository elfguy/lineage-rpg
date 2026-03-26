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

# 간단한 색상 타일셋 (프로시저럴)
var _tile_set: TileSet

func _ready() -> void:
	_create_tileset()
	_generate_map()
	EventBus.map_entered.emit(map_id)

## 기본 타일셋 생성 (프로시저럴)
func _create_tileset() -> void:
	_tile_set = TileSet.new()
	_tile_set.tile_size = tile_size
	
	# 그라운드 타일 (ID: 0) - 초록색
	var ground_texture: ImageTexture = _create_color_texture(Color(0.2, 0.4, 0.2))
	var ground_source: TileSetAtlasSource = TileSetAtlasSource.new()
	ground_source.texture = ground_texture
	ground_source.texture_region_size = Vector2i(32, 32)
	_tile_set.add_source(ground_source, 0)
	ground_source.create_tile(Vector2i(0, 0))
	
	# 벽 타일 (ID: 1) - 회색
	var wall_texture: ImageTexture = _create_color_texture(Color(0.3, 0.3, 0.3))
	var wall_source: TileSetAtlasSource = TileSetAtlasSource.new()
	wall_source.texture = wall_texture
	wall_source.texture_region_size = Vector2i(32, 32)
	_tile_set.add_source(wall_source, 1)
	wall_source.create_tile(Vector2i(0, 0))
	
	ground_layer.tile_set = _tile_set
	wall_layer.tile_set = _tile_set

## 색상 텍스처 생성
func _create_color_texture(color: Color) -> ImageTexture:
	var image := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(color)
	var texture := ImageTexture.create_from_image(image)
	return texture

## 맵 생성 (간단한 테스트 맵)
func _generate_map() -> void:
	# 전체 그라운드
	for x in range(map_size.x):
		for y in range(map_size.y):
			ground_layer.set_cell(Vector2i(x, y), 0, Vector2i.ZERO)
	
	# 벽 테두리
	for x in range(map_size.x):
		wall_layer.set_cell(Vector2i(x, 0), 1, Vector2i.ZERO)
		wall_layer.set_cell(Vector2i(x, map_size.y - 1), 1, Vector2i.ZERO)
	for y in range(map_size.y):
		wall_layer.set_cell(Vector2i(0, y), 1, Vector2i.ZERO)
		wall_layer.set_cell(Vector2i(map_size.x - 1, y), 1, Vector2i.ZERO)
	
	# 랜덤 장애물 몇 개
	for i in range(10):
		var x := randi() % (map_size.x - 4) + 2
		var y := randi() % (map_size.y - 4) + 2
		wall_layer.set_cell(Vector2i(x, y), 1, Vector2i.ZERO)

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
