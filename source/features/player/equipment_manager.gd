## 장비 매니저
## 장비 장착/해제/슬롯 관리/스탯 보정

class_name EquipmentManager
extends Node

signal equipment_changed(slot: EquipmentResource.EquipSlot, item: EquipmentResource)
signal equipment_removed(slot: EquipmentResource.EquipSlot)

## 장착 슬롯 (슬롯 -> 장비)
var equipped_items: Dictionary = {}

## 베이스 스탯 (장비 없는 순수 스탯)
var base_stats: Dictionary = {}

func _ready() -> void:
	_initialize_slots()

func _initialize_slots() -> void:
	for slot: int in EquipmentResource.EquipSlot.values():
		equipped_items[slot] = null

## 장비 장착
func equip_item(item: EquipmentResource) -> bool:
	if item == null:
		return false
	var slot: int = item.equip_slot
	# 기존 장비 있으면 먼저 해제
	if equipped_items.get(slot) != null:
		unequip_slot(slot as EquipmentResource.EquipSlot)
	equipped_items[slot] = item
	_apply_equipment_stats()
	equipment_changed.emit(slot as EquipmentResource.EquipSlot, item)
	return true

## 슬롯에서 장비 해제
func unequip_slot(slot: EquipmentResource.EquipSlot) -> EquipmentResource:
	var old_item: EquipmentResource = equipped_items.get(slot)
	if old_item == null:
		return null
	equipped_items[slot] = null
	_apply_equipment_stats()
	equipment_removed.emit(slot)
	return old_item

## 해당 슬롯의 장비 반환
func get_equipped(slot: EquipmentResource.EquipSlot) -> EquipmentResource:
	return equipped_items.get(slot)

## 전체 장비 보정 스탯 합산
func get_equipment_bonus_stats() -> Dictionary:
	var bonus: Dictionary = {"attack": 0, "defense": 0, "hp": 0, "mp": 0}
	for slot_key: int in equipped_items:
		var item: EquipmentResource = equipped_items.get(slot_key)
		if item != null:
			bonus["attack"] = bonus.get("attack", 0) + item.attack_bonus
			bonus["defense"] = bonus.get("defense", 0) + item.defense_bonus
			bonus["hp"] = bonus.get("hp", 0) + item.hp_bonus
			bonus["mp"] = bonus.get("mp", 0) + item.mp_bonus
	return bonus

## 장착된 아이템 ID 목록
func get_equipped_item_ids() -> Array[String]:
	var ids: Array[String] = []
	for slot_key: int in equipped_items:
		var item: EquipmentResource = equipped_items.get(slot_key)
		if item != null:
			ids.append(item.item_id)
	return ids

## 장비 스탯을 GameState에 반영
func _apply_equipment_stats() -> void:
	var bonus: Dictionary = get_equipment_bonus_stats()
	var player_data: Dictionary = GameState.player_data
	# 베이스 스탯 + 보정 = 최종 스탯
	player_data["attack"] = base_stats.get("attack", 10) + bonus.get("attack", 0)
	player_data["defense"] = base_stats.get("defense", 5) + bonus.get("defense", 0)
	player_data["max_hp"] = base_stats.get("max_hp", 100) + bonus.get("hp", 0)
	player_data["max_mp"] = base_stats.get("max_mp", 50) + bonus.get("mp", 0)
	EventBus.health_changed.emit(player_data.get("hp", 100), player_data.get("max_hp", 100))
	EventBus.mana_changed.emit(player_data.get("mp", 50), player_data.get("max_mp", 50))
