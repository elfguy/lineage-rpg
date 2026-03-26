extends GutTest

var equipment_manager: Node

func before_each() -> void:
	equipment_manager = preload("res://source/features/player/equipment_manager.gd").new()
	add_child_autofree(equipment_manager)

func test_equip_item() -> void:
	var sword: EquipmentResource = EquipmentResource.new()
	sword.item_id = "iron_sword"
	sword.equip_slot = EquipmentResource.EquipSlot.WEAPON
	sword.attack_bonus = 15
	var result: bool = equipment_manager.equip_item(sword)
	assert_true(result, "Should equip item")
	assert_eq(equipment_manager.get_equipped(EquipmentResource.EquipSlot.WEAPON).item_id, "iron_sword")

func test_unequip_item() -> void:
	var sword: EquipmentResource = EquipmentResource.new()
	sword.item_id = "iron_sword"
	sword.equip_slot = EquipmentResource.EquipSlot.WEAPON
	sword.attack_bonus = 15
	equipment_manager.equip_item(sword)
	var removed: EquipmentResource = equipment_manager.unequip_slot(EquipmentResource.EquipSlot.WEAPON)
	assert_not_null(removed, "Should return removed item")
	assert_eq(removed.item_id, "iron_sword")
	assert_eq(equipment_manager.get_equipped(EquipmentResource.EquipSlot.WEAPON), null)

func test_equip_replaces_existing() -> void:
	var sword1: EquipmentResource = EquipmentResource.new()
	sword1.item_id = "sword_1"
	sword1.equip_slot = EquipmentResource.EquipSlot.WEAPON
	var sword2: EquipmentResource = EquipmentResource.new()
	sword2.item_id = "sword_2"
	sword2.equip_slot = EquipmentResource.EquipSlot.WEAPON
	equipment_manager.equip_item(sword1)
	equipment_manager.equip_item(sword2)
	var equipped: EquipmentResource = equipment_manager.get_equipped(EquipmentResource.EquipSlot.WEAPON)
	assert_eq(equipped.item_id, "sword_2", "Should replace with new item")

func test_equipment_bonus_stats() -> void:
	var helmet: EquipmentResource = EquipmentResource.new()
	helmet.equip_slot = EquipmentResource.EquipSlot.HEAD
	helmet.defense_bonus = 5
	helmet.hp_bonus = 20
	equipment_manager.equip_item(helmet)
	var bonus: Dictionary = equipment_manager.get_equipment_bonus_stats()
	assert_eq(bonus.get("defense"), 5, "Defense bonus should be 5")
	assert_eq(bonus.get("hp"), 20, "HP bonus should be 20")

func test_multiple_equipment_bonus() -> void:
	var armor: EquipmentResource = EquipmentResource.new()
	armor.equip_slot = EquipmentResource.EquipSlot.BODY
	armor.defense_bonus = 10
	var sword: EquipmentResource = EquipmentResource.new()
	sword.equip_slot = EquipmentResource.EquipSlot.WEAPON
	sword.attack_bonus = 15
	equipment_manager.equip_item(armor)
	equipment_manager.equip_item(sword)
	var bonus: Dictionary = equipment_manager.get_equipment_bonus_stats()
	assert_eq(bonus.get("attack"), 15)
	assert_eq(bonus.get("defense"), 10)

func test_all_slots() -> void:
	for slot: int in EquipmentResource.EquipSlot.values():
		assert_eq(equipment_manager.get_equipped(slot), null, "Slot %d should be empty" % slot)
