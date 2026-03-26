## 장비 아이템 Resource

class_name EquipmentResource
extends ItemResource

enum EquipSlot {
	HEAD,
	BODY,
	WEAPON,
	SHIELD,
	BOOTS,
	RING,
}

@export var equip_slot: EquipSlot = EquipSlot.WEAPON
@export var attack_bonus: int = 0
@export var defense_bonus: int = 0
@export var hp_bonus: int = 0
@export var mp_bonus: int = 0
