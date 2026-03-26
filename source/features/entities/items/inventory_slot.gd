## 인벤토리 슬롯 데이터

class_name InventorySlot
extends Resource

@export var item: ItemResource = null
@export var quantity: int = 0

func is_empty() -> bool:
	return item == null or quantity <= 0

func can_add(target_item: ItemResource) -> bool:
	if is_empty():
		return true
	return item == target_item and item.stackable and quantity < item.max_stack

func add_quantity(amount: int) -> void:
	if item == null:
		return
	quantity = mini(quantity + amount, item.max_stack)

func remove_quantity(amount: int) -> void:
	quantity = maxi(quantity - amount, 0)
	if quantity <= 0:
		item = null
