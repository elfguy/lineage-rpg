## 서버 전투 검증
## 클라이언트의 전투 요청을 서버에서 검증합니다.

class_name ServerCombat
extends Node

## 쿨다운 추적 (peer_id -> timestamp)
var attack_cooldowns: Dictionary = {}
var min_attack_interval: float = 0.8

func _ready() -> void:
	if multiplayer.is_server() == false:
		queue_free()
		return

## 클라이언트 → 서버: 공격 요청
@rpc("any_peer", "call_remote", "reliable")
func request_attack(target_peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	var attacker_peer: int = multiplayer.get_remote_sender_id()

	# 검증 1: 쿨다운
	var now: float = Time.get_ticks_msec() / 1000.0
	var last_attack: float = attack_cooldowns.get(attacker_peer, 0.0)
	if now - last_attack < min_attack_interval:
		_reject_attack.rpc_id(attacker_peer, "cooldown")
		return

	# 검증 2: 타겟 존재 확인
	var network_mgr: Node = get_node_or_null("/root/NetworkManager")
	if network_mgr == null or not network_mgr.connected_players.has(target_peer_id):
		_reject_attack.rpc_id(attacker_peer, "invalid_target")
		return

	# 검증 3: 자신을 공격 불가
	if attacker_peer == target_peer_id:
		_reject_attack.rpc_id(attacker_peer, "self_target")
		return

	# 쿨다운 업데이트
	attack_cooldowns[attacker_peer] = now

	# 데미지 계산 (서버 권위)
	var attacker_data: Dictionary = network_mgr.get_player_info(attacker_peer)
	var target_data: Dictionary = network_mgr.get_player_info(target_peer_id)
	var damage: int = DamageCalculator.calculate(10, 5)  # TODO: 실제 스탯 참조

	# 결과 브로드캐스트
	_broadcast_combat_result.rpc(attacker_peer, target_peer_id, damage, false)

## 서버 → 클라이언트: 공격 거부
@rpc("authority", "call_remote", "unreliable")
func _reject_attack(_reason: String) -> void:
	pass

## 서버 → 모든 클라이언트: 전투 결과
@rpc("authority", "call_remote", "unreliable")
func _broadcast_combat_result(attacker_peer: int, target_peer_id: int, damage: int, killed: bool) -> void:
	EventBus.enemy_died.emit(null, Vector2.ZERO)
	# TODO: UI에 데미지 표시

## 서버: 데미지 적용
func apply_damage_to_player(peer_id: int, damage: int) -> void:
	if not multiplayer.is_server():
		return
	var network_mgr: Node = get_node_or_null("/root/NetworkManager")
	if network_mgr and network_mgr.connected_players.has(peer_id):
		network_mgr.connected_players[peer_id]["hp"] = \
			network_mgr.connected_players[peer_id].get("hp", 100) - damage
