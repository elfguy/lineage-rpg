## 채팅 시스템
## 실시간 메시지 교환

class_name ChatSystem
extends Node

signal message_received(sender_name: String, message: String, channel: String)
signal system_message_received(message: String)

enum Channel {
	ALL,
	PARTY,
	WHISPER,
	SYSTEM,
}

## 메시지 이력
var message_history: Array[Dictionary] = []
const MAX_HISTORY: int = 100

func _ready() -> void:
	pass

## 클라이언트 → 서버: 채팅 전송
@rpc("any_peer", "call_remote", "reliable")
func send_chat(text: String, target_peer: int = 0) -> void:
	if text.strip_edges().is_empty():
		return
	if not multiplayer.has_multiplayer_peer():
		return
	var sender_peer: int = multiplayer.get_remote_sender_id() if multiplayer.is_server() else multiplayer.get_unique_id()
	if multiplayer.is_server():
		var network_mgr: Node = get_node_or_null("/root/NetworkManager")
		var sender_name: String = "Unknown"
		if network_mgr and network_mgr.connected_players.has(sender_peer):
			sender_name = network_mgr.connected_players[sender_peer].get("name", "Unknown")
		elif sender_peer == 1:
			sender_name = "Server"

		var channel: Channel = Channel.ALL
		var message: Dictionary = {
			"sender": sender_name,
			"text": text,
			"channel": str(channel),
		}

		if target_peer > 0 and network_mgr.connected_players.has(target_peer):
			# 귓속말
			message["channel"] = str(Channel.WHISPER)
			_receive_message.rpc_id(target_peer, sender_name, text, str(Channel.WHISPER))
			_receive_message.rpc_id(sender_peer, sender_name, "(귓속말) " + text, str(Channel.WHISPER))
		else:
			# 전체 채팅
			_receive_message.rpc(sender_name, text, str(channel))

		_add_to_history(message)

## 서버 → 클라이언트: 메시지 수신
@rpc("authority", "call_remote", "reliable")
func _receive_message(sender_name: String, text: String, channel: String) -> void:
	var message: Dictionary = {
		"sender": sender_name,
		"text": text,
		"channel": channel,
	}
	_add_to_history(message)
	message_received.emit(sender_name, text, channel)

## 시스템 메시지 (로컬)
func broadcast_system_message(text: String) -> void:
	_broadcast_system.rpc(text)
	_add_to_history({
		"sender": "System",
		"text": text,
		"channel": str(Channel.SYSTEM),
	})

@rpc("authority", "call_remote", "reliable")
func _broadcast_system(text: String) -> void:
	system_message_received.emit(text)
	_add_to_history({
		"sender": "System",
		"text": text,
		"channel": str(Channel.SYSTEM),
	})

## 채팅 메시지 전송 (클라이언트 호출)
func send_message(text: String) -> void:
	send_chat.rpc_id(1, text)

## 귓속말 전송
func send_whisper(text: String, target_peer: int) -> void:
	send_chat.rpc_id(1, text, target_peer)

## 메시지 이력 관리
func _add_to_history(message: Dictionary) -> void:
	message_history.append(message)
	if message_history.size() > MAX_HISTORY:
		message_history.pop_front()

func get_recent_messages(count: int = 20) -> Array[Dictionary]:
	var start: int = maxi(message_history.size() - count, 0)
	var result: Array[Dictionary] = []
	for i: int in range(start, message_history.size()):
		result.append(message_history[i])
	return result

func clear_history() -> void:
	message_history.clear()
