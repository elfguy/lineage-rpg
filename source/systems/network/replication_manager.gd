## 리플리케이션 매니저
## 엔티티 상태 동기화를 관리합니다.

class_name ReplicationManager
extends Node

signal entity_spawned(peer_id: int, scene_path: String)
signal entity_despawned(peer_id: int)

@export var player_scene: PackedScene = null
@export var sync_rate: float = NetworkConfig.SYNC_RATE

var remote_players: Dictionary = {}  # peer_id -> RemotePlayer
var sync_timer: float = 0.0

func _ready() -> void:
	EventBus.player_position_changed.connect(_on_local_player_moved)

func _process(delta: float) -> void:
	if not multiplayer.has_multiplayer_peer():
		return
	# 서버: 주기적 위치 브로드캐스트
	if multiplayer.is_server():
		sync_timer += delta
		if sync_timer >= sync_rate:
			sync_timer = 0.0
			_broadcast_all_positions()
	elif multiplayer.is_server() == false:
		# 클라이언트: 자신의 위치를 서버에 전송
		sync_timer += delta
		if sync_timer >= sync_rate:
			sync_timer = 0.0
			_send_local_position()

## 원격 플레이어 스폰
func spawn_remote_player(peer_id: int, player_name: String) -> void:
	if remote_players.has(peer_id):
		return
	if player_scene == null:
		return
	var instance: RemotePlayer = player_scene.instantiate() as RemotePlayer
	if instance == null:
		return
	instance.setup(peer_id, player_name)
	add_child(instance)
	remote_players[peer_id] = instance
	entity_spawned.emit(peer_id, player_scene.resource_path)

## 원격 플레이어 디스폰
func despawn_remote_player(peer_id: int) -> void:
	if not remote_players.has(peer_id):
		return
	var player: RemotePlayer = remote_players.get(peer_id)
	if is_instance_valid(player):
		player.queue_free()
	remote_players.erase(peer_id)
	entity_despawned.emit(peer_id)

## 서버: 모든 플레이어 위치 브로드캐스트
func _broadcast_all_positions() -> void:
	var network_mgr: Node = get_node_or_null("/root/NetworkManager")
	if network_mgr == null:
		return
	for peer_id: int in network_mgr.connected_players:
		if remote_players.has(peer_id):
			var player: RemotePlayer = remote_players.get(peer_id)
			if is_instance_valid(player):
				var pos: Vector2 = player.global_position
				network_mgr.connected_players[peer_id]["position"] = pos

## 클라이언트: 서버에 위치 전송
func _send_local_position() -> void:
	var local_player: CharacterBody2D = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if local_player == null:
		return
	_send_position.rpc_id(1, local_player.global_position)

@rpc("any_peer", "call_remote", "unreliable")
func _send_position(pos: Vector2) -> void:
	if not multiplayer.is_server():
		return
	var peer_id: int = multiplayer.get_remote_sender_id()
	var network_mgr: Node = get_node_or_null("/root/NetworkManager")
	if network_mgr and network_mgr.connected_players.has(peer_id):
		network_mgr.connected_players[peer_id]["position"] = pos

func _on_local_player_moved(pos: Vector2) -> void:
	if multiplayer.is_server() == false and is_connected_to_server():
		_send_position.rpc_id(1, pos)

func is_connected_to_server() -> bool:
	return multiplayer.has_multiplayer_peer() and not multiplayer.is_server()
