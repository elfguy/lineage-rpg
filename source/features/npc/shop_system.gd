## 상점 시스템
## NPC 상점에서 아이템 구매/판매를 관리합니다.

class_name ShopSystem
extends RefCounted

signal item_bought(item_id: String, price: int)
signal item_sold(item_id: String, price: int)
signal not_enough_gold()
signal inventory_full()

var shop_items: Array[Dictionary] = []  # [{item: ItemResource, price: int}]
var sell_ratio: float = 0.5  # 판매 가격 = 구매가 * sell_ratio

func _init() -> void:
	shop_items.clear()

## 상점에 아이템 추가
func add_shop_item(item: ItemResource, price: int = -1) -> void:
	var actual_price: int = price if price >= 0 else item.value
	shop_items.append({"item": item, "price": actual_price})

## 아이템 구매
func buy_item(item_id: String, inventory: Node) -> bool:
	var entry: Dictionary = _find_shop_entry(item_id)
	if entry.is_empty():
		return false
	var item: ItemResource = entry.get("item")
	var price: int = entry.get("price", 0)
	# 골드 검사
	var gold: int = GameState.player_data.get("gold", 0)
	if gold < price:
		not_enough_gold.emit()
		return false
	# 인벤토리에 추가
	var result: int = inventory.add_item(item, 1)
	if result == -1:
		inventory_full.emit()
		return false
	# 골드 차감
	GameState.player_data["gold"] = gold - price
	item_bought.emit(item_id, price)
	return true

## 아이템 판매
func sell_item(item_id: String, inventory: Node) -> bool:
	if not inventory.has_item(item_id):
		return false
	var sell_price: int = _get_sell_price(item_id)
	inventory.remove_item_by_id(item_id, 1)
	GameState.player_data["gold"] = GameState.player_data.get("gold", 0) + sell_price
	item_sold.emit(item_id, sell_price)
	return true

## 상점 아이템 목록 반환
func get_shop_items() -> Array[Dictionary]:
	return shop_items.duplicate(true)

## 판매 가격 계산
func _get_sell_price(item_id: String) -> int:
	var entry: Dictionary = _find_shop_entry(item_id)
	if not entry.is_empty():
		var price: int = entry.get("price", 0)
		return int(float(price) * sell_ratio)
	return 0

func _find_shop_entry(item_id: String) -> Dictionary:
	for entry: Dictionary in shop_items:
		var item: ItemResource = entry.get("item")
		if item != null and item.item_id == item_id:
			return entry
	return {}
