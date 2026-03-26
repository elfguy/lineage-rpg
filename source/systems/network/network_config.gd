## 네트워크 프로토콜 정의

class_name NetworkConfig
extends RefCounted

## 프로토콜 ID
enum Protocol {
	## 서버 → 클라이언트
	CONNECT_ACCEPT = 1,
	CONNECT_REJECT = 2,
	PLAYER_JOINED = 3,
	PLAYER_LEFT = 4,
	PLAYER_STATE_SYNC = 5,
	COMBAT_RESULT = 6,
	CHAT_MESSAGE = 7,
	SYSTEM_MESSAGE = 8,
	## 클라이언트 → 서버
	CONNECT_REQUEST = 101,
	PLAYER_INPUT = 102,
	COMBAT_REQUEST = 103,
	CHAT_SEND = 104,
	DISCONNECT = 105,
}

## 서버 설정
const SERVER_PORT: int = 7777
const MAX_PLAYERS: int = 32
const TICK_RATE: int = 60
const SYNC_RATE: float = 1.0 / 30.0  # 30fps 동기화

## 프로토콜 이름 ↔ ID 매핑
static func get_protocol_name(id: int) -> String:
	var names: Dictionary = {
		NetworkConfig.Protocol.CONNECT_ACCEPT: "CONNECT_ACCEPT",
		NetworkConfig.Protocol.CONNECT_REJECT: "CONNECT_REJECT",
		NetworkConfig.Protocol.PLAYER_JOINED: "PLAYER_JOINED",
		NetworkConfig.Protocol.PLAYER_LEFT: "PLAYER_LEFT",
		NetworkConfig.Protocol.PLAYER_STATE_SYNC: "PLAYER_STATE_SYNC",
		NetworkConfig.Protocol.COMBAT_RESULT: "COMBAT_RESULT",
		NetworkConfig.Protocol.CHAT_MESSAGE: "CHAT_MESSAGE",
		NetworkConfig.Protocol.SYSTEM_MESSAGE: "SYSTEM_MESSAGE",
		NetworkConfig.Protocol.CONNECT_REQUEST: "CONNECT_REQUEST",
		NetworkConfig.Protocol.PLAYER_INPUT: "PLAYER_INPUT",
		NetworkConfig.Protocol.COMBAT_REQUEST: "COMBAT_REQUEST",
		NetworkConfig.Protocol.CHAT_SEND: "CHAT_SEND",
		NetworkConfig.Protocol.DISCONNECT: "DISCONNECT",
	}
	return names.get(id, "UNKNOWN")
