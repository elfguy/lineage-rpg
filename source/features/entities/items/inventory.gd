## 인벤토리 매니저
## 아이템 추가/제거/사용을 관리합니다.

class_name Inventory
extends Node

signal inventory_updated()
signal item_added(item: ItemResource, index: int)
signal item_removed(item: ItemResource, index: int)
signal item_used(item: ItemResource)
signal inventory_full()

@export var capacity: int = 20

var slots: Array[InventorySlot] = []

func _ready() -> void:
	_initialize_slots()

func _initialize_slots() -> void:
	slots.clear()
	for i: int in range(capacity):
		slots.append(InventorySlot.new())

## 아이템 추가 — 성공 시 인덱스 반환, 실패 시 -1
func add_item(new_item: ItemResource, quantity: int = 1) -> int:
	var remaining: int = quantity
	var first_empty: int = -1

	# 기존 스택에 추가 시도
	for i: int in range(slots.size()):
		var slot: InventorySlot = slots[i]
		if slot.can_add(new_item) and not slot.is_empty():
			var can_add_amount: int = new_item.max_stack - slot.quantity
			var add_amount: int = mini(remaining, can_add_amount)
			slot.add_quantity(add_amount)
			remaining -= add_amount
			item_added.emit(new_item, i)
			EventBus.item_picked_up.emit({"item_id": new_item.item_id, "quantity": add_amount})
			if remaining <= 0:
				inventory_updated.emit()
				return i

	# 빈 슬롯에 추가
	for i: int in range(slots.size()):
		var slot: InventorySlot = slots[i]
		if slot.is_empty() and first_empty == -1:
			first_empty = i
			slot.item = new_item
			var add_amount: int = mini(remaining, new_item.max_stack)
			slot.quantity = add_amount
			remaining -= add_amount
			item_added.emit(new_item, i)
			EventBus.item_picked_up.emit({"item_id": new_item.item_id, "quantity": add_amount})
			if remaining <= 0:
				inventory_updated.emit()
				return i

	# 용량 초과
	if remaining > 0:
		inventory_full.emit()
	return -1

## 인덱스로 아이템 제거
func remove_item_at(index: int, quantity: int = 1) -> bool:
	if index < 0 or index >= slots.size():
		return false
	var slot: InventorySlot = slots[index]
	if slot.is_empty():
		return false
	var removed_item: ItemResource = slot.item
	slot.remove_quantity(quantity)
	item_removed.emit(removed_item, index)
	EventBus.item_used.emit(removed_item.item_id)
	inventory_updated.emit()
	return true

## 아이템 ID로 제거 (첫 번째 발견)
func remove_item_by_id(item_id: String, quantity: int = 1) -> bool:
	for i: int in range(slots.size()):
		var slot: InventorySlot = slots[i]
		if not slot.is_empty() and slot.item.item_id == item_id:
			return remove_item_at(i, quantity)
	return false

## 아이템 사용 (소비품)
func use_item_at(index: int) -> bool:
	if index < 0 or index >= slots.size():
		return false
	var slot: InventorySlot = slots[index]
	if slot.is_empty():
		return false
	var item: ItemResource = slot.item
	if item is ConsumableResource:
		var consumable: ConsumableResource = item as ConsumableResource
		_apply_consumable_effect(consumable)
		remove_item_at(index, 1)
		item_used.emit(item)
		return true
	return false

## 아이템 보유 여부 확인
func has_item(item_id: String, quantity: int = 1) -> bool:
	var total: int = 0
	for slot: InventorySlot in slots:
		if not slot.is_empty() and slot.item.item_id == item_id:
			total += slot.quantity
	return total >= quantity

## 아이템 총 수량
func get_item_count(item_id: String) -> int:
	var total: int = 0
	for slot: InventorySlot in slots:
		if not slot.is_empty() and slot.item.item_id == item_id:
			total += slot.quantity
	return total

## 현재 사용 중인 슬롯 수
func get_used_slot_count() -> int:
	var count: int = 0
	for slot: InventorySlot in slots:
		if not slot.is_empty():
			count += 1
	return count

## 빈 슬롯 수
func get_empty_slot_count() -> int:
	return capacity - get_used_slot_count()

func _apply_consumable_effect(consumable: ConsumableResource) -> void:
	match consumable.effect_type:
		ConsumableResource.EffectType.HEAL_HP:
			var new_hp: int = mini(
				GameState.player_data.get("hp", 0) + consumable.effect_value,
				GameState.player_data.get("max_hp", 100),
			)
			GameState.player_data["hp"] = new_hp
			EventBus.health_changed.emit(new_hp, GameState.player_data.get("max_hp", 100))
		ConsumableResource.EffectType.HEAL_MP:
			var new_mp: int = mini(
				GameState.player_data.get("mp", 0) + consumable.effect_value,
				GameState.player_data.get("max_mp", 50),
			)
			GameState.player_data["mp"] = new_mp
			EventBus.mana_changed.emit(new_mp, GameState.player_data.get("max_mp", 50))
