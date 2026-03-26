## 아이템 데이터 모델

class_name ItemResource
extends Resource

## 아이템 종류
enum ItemType {
	CONSUMABLE,
	EQUIPMENT,
	MATERIAL,
	KEY,
}

@export var item_id: String = ""
@export var item_name: String = ""
@export var description: String = ""
@export var icon: Texture2D = null
@export var item_type: ItemType = ItemType.MATERIAL
@export var stackable: bool = false
@export var max_stack: int = 1
@export var value: int = 0
@export var stats: Dictionary = {}
