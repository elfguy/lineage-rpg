extends GutTest

func test_npc_resource_creation() -> void:
	var npc_data: NPCResource = NPCResource.new()
	npc_data.npc_id = "guard_01"
	npc_data.npc_name = "Guard"
	npc_data.dialogue = ["Welcome!", "How can I help?"]
	assert_eq(npc_data.npc_id, "guard_01")
	assert_eq(npc_data.dialogue.size(), 2)

func test_dialogue_line_creation() -> void:
	var line: DialogueLine = DialogueLine.new()
	line.speaker = "NPC"
	line.text = "Hello, adventurer!"
	assert_eq(line.speaker, "NPC")
	assert_eq(line.text, "Hello, adventurer!")
	assert_false(line.has_choices(), "Should have no choices by default")

func test_dialogue_line_with_choices() -> void:
	var choice: DialogueChoice = DialogueChoice.new()
	choice.text = "Accept quest"
	choice.next_line_index = 2
	var line: DialogueLine = DialogueLine.new()
	line.text = "Will you help?"
	line.choices = [choice]
	assert_true(line.has_choices(), "Should have choices")

func test_map_resource_creation() -> void:
	var map_data: MapResource = MapResource.new()
	map_data.map_id = "dungeon_01"
	map_data.map_name = "Dark Dungeon"
	map_data.map_size = Vector2i(64, 64)
	map_data.spawn_point = Vector2(100, 200)
	assert_eq(map_data.map_id, "dungeon_01")
	assert_eq(map_data.map_size, Vector2i(64, 64))

func test_portal_resource_fields() -> void:
	var portal: Portal = Portal.new()
	portal.target_map_id = "town"
	portal.target_spawn_point = Vector2(50, 50)
	portal.is_active = true
	assert_eq(portal.target_map_id, "town")
	assert_eq(portal.target_spawn_point, Vector2(50, 50))
	add_child_autofree(portal)

func test_item_resource_types() -> void:
	var potion: ItemResource = ItemResource.new()
	potion.item_id = "hp_pot"
	potion.item_type = ItemResource.ItemType.CONSUMABLE
	potion.stackable = true
	potion.max_stack = 10
	assert_eq(potion.item_type, ItemResource.ItemType.CONSUMABLE)
	assert_true(potion.stackable)

func test_equipment_resource() -> void:
	var sword: EquipmentResource = EquipmentResource.new()
	sword.item_id = "iron_sword"
	sword.equip_slot = EquipmentResource.EquipSlot.WEAPON
	sword.attack_bonus = 15
	sword.defense_bonus = 0
	assert_eq(sword.equip_slot, EquipmentResource.EquipSlot.WEAPON)
	assert_eq(sword.attack_bonus, 15)

func test_consumable_resource() -> void:
	var potion: ConsumableResource = ConsumableResource.new()
	potion.item_id = "mana_pot"
	potion.effect_type = ConsumableResource.EffectType.HEAL_MP
	potion.effect_value = 30
	assert_eq(potion.effect_type, ConsumableResource.EffectType.HEAL_MP)
	assert_eq(potion.effect_value, 30)
