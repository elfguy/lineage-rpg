## 네트워크 매니저
## ENet 기반 서버/클라이언트 관리

class_name NetworkManager
extends Node

signal server_started()
signal server_stopped()
signal client_connected(peer_id: int)
signal client_disconnected(peer_id: int)
signal connection_failed()
signal connected_to_server()
signal disconnected_from_server()

var enet_peer: ENetMultiplayerPeer = null
var is_server: bool = false
var is_connected: bool = false
var connected_players: Dictionary = {}  # peer_id -> player_info

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)

## 서버 생성
func start_server(port: int = NetworkConfig.SERVER_PORT) -> bool:
	stop_network()
	enet_peer = ENetMultiplayerPeer.new()
	var result: Error = enet_peer.create_server(port, NetworkConfig.MAX_PLAYERS)
	if result != OK:
		push_error("Failed to create server: ", result)
		return false
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	is_server = true
	is_connected = true
	server_started.emit()
	return true

## 서버 접속
func connect_to_server(host: String, port: int = NetworkConfig.SERVER_PORT) -> bool:
	stop_network()
	enet_peer = ENetMultiplayerPeer.new()
	var result: Error = enet_peer.create_client(host, port)
	if result != OK:
		push_error("Failed to connect to server: ", result)
		return false
	multiplayer.multiplayer_peer = enet_peer
	is_server = false
	return true

## 네트워크 정리
func stop_network() -> void:
	if enet_peer != null:
		enet_peer.close()
		enet_peer = null
	multiplayer.multiplayer_peer = null
	is_server = false
	is_connected = false
	connected_players.clear()

## 서버 전용 RPC: 클라이언트 접속 처리
@rpc("authority", "call_remote", "reliable")
func register_player(peer_id: int, player_name: String) -> void:
	if multiplayer.is_server():
		connected_players[peer_id] = {
			"id": peer_id,
			"name": player_name,
			"position": Vector2.ZERO,
		}
		# 모든 클라이언트에 새 플레이어 알림
		for pid: int in connected_players:
			if pid != peer_id:
				_notify_player_joined.rpc_id(pid, peer_id, player_name)

## 서버 전용 RPC: 클라이언트에 새 플레이어 알림
@rpc("authority", "call_remote", "reliable")
func _notify_player_joined(new_peer_id: int, player_name: String) -> void:
	connected_players[new_peer_id] = {
		"id": new_peer_id,
		"name": player_name,
		"position": Vector2.ZERO,
	}
	client_connected.emit(new_peer_id)
	EventBus.enemy_spawned.emit(null)  # 재사용: 시스템 이벤트

## 서버 전용 RPC: 클라이언트 퇴장 처리
@rpc("any_peer", "call_remote", "reliable")
func unregister_player(_peer_id: int) -> void:
	if multiplayer.is_server():
		var peer_id: int = multiplayer.get_remote_sender_id()
		connected_players.erase(peer_id)
		# 모든 클라이언트에 퇴장 알림
		_notify_player_left.rpc(peer_id)

@rpc("authority", "call_remote", "reliable")
func _notify_player_left(left_peer_id: int) -> void:
	connected_players.erase(left_peer_id)
	client_disconnected.emit(left_peer_id)

## 플레이어 정보 반환
func get_player_info(peer_id: int) -> Dictionary:
	return connected_players.get(peer_id, {})

## 현재 접속 인원
func get_player_count() -> int:
	return connected_players.size()

## 서버 여부
func is_host() -> bool:
	return is_server

## 연결 상태
func is_online() -> bool:
	return is_connected and multiplayer.has_multiplayer_peer()

## 자신의 peer_id
func get_my_peer_id() -> int:
	return multiplayer.get_unique_id()

func _on_peer_connected(peer_id: int) -> void:
	if multiplayer.is_server():
		client_connected.emit(peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	if multiplayer.is_server():
		connected_players.erase(peer_id)
		client_disconnected.emit(peer_id)

func _on_connection_failed() -> void:
	connection_failed.emit()
	is_connected = false

func _on_connected_to_server() -> void:
	is_connected = true
	connected_to_server.emit()
