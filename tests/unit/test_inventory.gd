extends GutTest

var inventory: Node

func before_each() -> void:
	inventory = preload("res://source/features/entities/items/inventory.gd").new()
	add_child_autofree(inventory)

func test_inventory_initialization() -> void:
	assert_eq(inventory.capacity, 20, "Default capacity should be 20")
	assert_eq(inventory.slots.size(), 20, "Should have 20 slots")
	assert_eq(inventory.get_empty_slot_count(), 20, "All slots should be empty")

func test_add_item() -> void:
	var item: ItemResource = ItemResource.new()
	item.item_id = "health_potion"
	item.item_name = "Health Potion"
	item.stackable = true
	item.max_stack = 10
	var result: int = inventory.add_item(item, 3)
	assert_ne(result, -1, "Should successfully add item")
	assert_eq(inventory.get_item_count("health_potion"), 3, "Should have 3 items")

func test_add_stackable_item() -> void:
	var item: ItemResource = ItemResource.new()
	item.item_id = "arrow"
	item.item_name = "Arrow"
	item.stackable = true
	item.max_stack = 99
	inventory.add_item(item, 50)
	inventory.add_item(item, 30)
	assert_eq(inventory.get_item_count("arrow"), 80, "Should stack to 80")

func test_has_item() -> void:
	var item: ItemResource = ItemResource.new()
	item.item_id = "sword"
	item.item_name = "Sword"
	inventory.add_item(item, 1)
	assert_true(inventory.has_item("sword"), "Should have sword")
	assert_false(inventory.has_item("shield"), "Should not have shield")

func test_remove_item() -> void:
	var item: ItemResource = ItemResource.new()
	item.item_id = "potion"
	item.item_name = "Potion"
	item.stackable = true
	item.max_stack = 10
	inventory.add_item(item, 5)
	var result: bool = inventory.remove_item_by_id("potion", 2)
	assert_true(result, "Should successfully remove")
	assert_eq(inventory.get_item_count("potion"), 3, "Should have 3 remaining")

func test_remove_nonexistent_item() -> void:
	var result: bool = inventory.remove_item_by_id("nonexistent", 1)
	assert_false(result, "Should fail to remove nonexistent item")

func test_inventory_full() -> void:
	var item: ItemResource = ItemResource.new()
	item.item_id = "rock"
	item.item_name = "Rock"
	item.stackable = false
	item.max_stack = 1
	for i: int in range(20):
		inventory.add_item(item, 1)
	# 21번째 아이템은 실패해야 함
	var result: int = inventory.add_item(item, 1)
	assert_eq(result, -1, "Should fail when inventory is full")
	assert_eq(inventory.get_used_slot_count(), 20, "All 20 slots should be used")
