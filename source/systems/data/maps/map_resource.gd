## 맵 Resource 데이터 모델

class_name MapResource
extends Resource

@export var map_id: String = ""
@export var map_name: String = ""
@export var map_size: Vector2i = Vector2i(32, 32)
@export var scene_path: String = ""
@export var spawn_point: Vector2 = Vector2.ZERO
@export var music_path: String = ""
@export var is_pvp_zone: bool = false
