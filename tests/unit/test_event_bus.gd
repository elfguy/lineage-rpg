extends GutTest

func test_event_bus_signals_exist() -> void:
	var bus: Node = Engine.get_singleton("EventBus")
	assert_has_signal(bus, "player_position_changed")
	assert_has_signal(bus, "player_direction_changed")
	assert_has_signal(bus, "health_changed")
	assert_has_signal(bus, "mana_changed")
	assert_has_signal(bus, "experience_gained")
	assert_has_signal(bus, "level_up")
	assert_has_signal(bus, "item_picked_up")
	assert_has_signal(bus, "item_used")
	assert_has_signal(bus, "inventory_changed")
	assert_has_signal(bus, "quest_completed")
	assert_has_signal(bus, "quest_updated")
	assert_has_signal(bus, "player_died")
	assert_has_signal(bus, "map_entered")
	assert_has_signal(bus, "game_saved")
	assert_has_signal(bus, "game_loaded")
	assert_has_signal(bus, "enemy_spawned")
	assert_has_signal(bus, "enemy_died")

func test_event_bus_player_position_signal_emits() -> void:
	var bus: Node = Engine.get_singleton("EventBus")
	var emitted: bool = false
	var received_pos: Vector2 = Vector2.ZERO
	bus.player_position_changed.connect(func(pos: Vector2) -> void:
		emitted = true
		received_pos = pos
	)
	bus.player_position_changed.emit(Vector2(100, 200))
	assert_true(emitted, "Signal should have been emitted")
	assert_eq(received_pos, Vector2(100, 200), "Should receive correct position")
	bus.player_position_changed.disconnect(func(_pos: Vector2) -> void: pass)
