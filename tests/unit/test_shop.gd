extends GutTest

var shop: ShopSystem
var inventory: Node

func before_each() -> void:
	shop = ShopSystem.new()
	inventory = preload("res://source/features/entities/items/inventory.gd").new()
	add_child_autofree(inventory)
	GameState.player_data["gold"] = 100

func test_add_shop_item() -> void:
	var potion: ItemResource = ItemResource.new()
	potion.item_id = "hp_pot"
	potion.value = 20
	shop.add_shop_item(potion)
	assert_eq(shop.get_shop_items().size(), 1)

func test_buy_item() -> void:
	var potion: ItemResource = ItemResource.new()
	potion.item_id = "hp_pot"
	potion.stackable = true
	potion.max_stack = 10
	potion.value = 20
	shop.add_shop_item(potion, 30)
	var result: bool = shop.buy_item("hp_pot", inventory)
	assert_true(result, "Should buy item")
	assert_eq(GameState.player_data["gold"], 70, "Gold should decrease")
	assert_true(inventory.has_item("hp_pot"), "Inventory should have item")

func test_buy_not_enough_gold() -> void:
	var sword: ItemResource = ItemResource.new()
	sword.item_id = "rare_sword"
	sword.value = 200
	shop.add_shop_item(sword, 200)
	var result: bool = shop.buy_item("rare_sword", inventory)
	assert_false(result, "Should fail without enough gold")
	assert_eq(GameState.player_data["gold"], 100, "Gold should not change")

func test_sell_item() -> void:
	var potion: ItemResource = ItemResource.new()
	potion.item_id = "hp_pot"
	potion.value = 20
	potion.stackable = true
	potion.max_stack = 10
	shop.add_shop_item(potion, 30)
	# 먼저 구매
	shop.buy_item("hp_pot", inventory)
	assert_eq(GameState.player_data["gold"], 70)
	# 판매 (30 * 0.5 = 15)
	var result: bool = shop.sell_item("hp_pot", inventory)
	assert_true(result, "Should sell item")
	assert_eq(GameState.player_data["gold"], 85, "Gold should increase by sell price")

func test_sell_nonexistent_item() -> void:
	var result: bool = shop.sell_item("nonexistent", inventory)
	assert_false(result, "Should fail to sell nonexistent item")

func test_buy_nonexistent_shop_item() -> void:
	var result: bool = shop.buy_item("nonexistent", inventory)
	assert_false(result, "Should fail for nonexistent shop item")

func test_sell_ratio() -> void:
	shop.sell_ratio = 0.5
	var item: ItemResource = ItemResource.new()
	item.item_id = "test"
	item.value = 100
	shop.add_shop_item(item, 100)
	var sell_price: int = shop._get_sell_price("test")
	assert_eq(sell_price, 50, "Sell price should be 50% of buy price")
