## 원격 플레이어
## 다른 클라이언트의 플레이어를 화면에 표시합니다.

class_name RemotePlayer
extends CharacterBody2D

@export var sync_interval: float = 0.05  # 50ms (20Hz)

var peer_id: int = -1
var player_name: String = ""
var sync_timer: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var name_label: Label = $NameLabel

func _ready() -> void:
	if name_label:
		name_label.text = player_name

func _process(delta: float) -> void:
	# 클라이언트: 서버에서 받은 위치로 보간
	if not multiplayer.is_server() and peer_id > 0:
		var info: Dictionary = _get_network_manager().get_player_info(peer_id)
		if not info.is_empty():
			var target_pos: Vector2 = info.get("position", Vector2.ZERO)
			global_position = global_position.lerp(target_pos, 0.3)

func setup(peer: int, p_name: String) -> void:
	peer_id = peer
	player_name = p_name
	if name_label:
		name_label.text = player_name

## 서버에서 호출: 플레이어 위치 업데이트
func set_remote_position(pos: Vector2) -> void:
	if multiplayer.is_server():
		global_position = pos
		connected_players_position_update.rpc(pos)

@rpc("authority", "call_remote", "unreliable")
func connected_players_position_update(pos: Vector2) -> void:
	global_position = pos

func _get_network_manager() -> Node:
	return get_node_or_null("/root/NetworkManager")
