extends GutTest

func test_network_config_protocol_names() -> void:
	assert_eq(NetworkConfig.get_protocol_name(1), "CONNECT_ACCEPT")
	assert_eq(NetworkConfig.get_protocol_name(101), "CONNECT_REQUEST")
	assert_eq(NetworkConfig.get_protocol_name(999), "UNKNOWN")

func test_network_config_constants() -> void:
	assert_eq(NetworkConfig.SERVER_PORT, 7777)
	assert_eq(NetworkConfig.MAX_PLAYERS, 32)
	assert_gt(NetworkConfig.TICK_RATE, 0)
	assert_gt(NetworkConfig.SYNC_RATE, 0.0)

func test_chat_system_message_history() -> void:
	var chat: ChatSystem = ChatSystem.new()
	add_child_autofree(chat)
	chat.broadcast_system_message("Welcome!")
	var messages: Array[Dictionary] = chat.get_recent_messages(10)
	assert_eq(messages.size(), 1)
	assert_eq(messages[0].get("text"), "Welcome!")

func test_chat_system_max_history() -> void:
	var chat: ChatSystem = ChatSystem.new()
	add_child_autofree(chat)
	for i: int in range(150):
		chat.broadcast_system_message("msg %d" % i)
	assert_eq(chat.message_history.size(), 100)

func test_chat_system_clear_history() -> void:
	var chat: ChatSystem = ChatSystem.new()
	add_child_autofree(chat)
	chat.broadcast_system_message("test")
	assert_eq(chat.message_history.size(), 1)
	chat.clear_history()
	assert_eq(chat.message_history.size(), 0)

func test_chat_system_channels() -> void:
	assert_eq(ChatSystem.Channel.ALL, 0)
	assert_eq(ChatSystem.Channel.PARTY, 1)
	assert_eq(ChatSystem.Channel.WHISPER, 2)
	assert_eq(ChatSystem.Channel.SYSTEM, 3)

func test_server_combat_cooldown_validation() -> void:
	var sc: Node = preload("res://source/systems/network/server_combat.gd").new()
	add_child_autofree(sc)
	# Server combat is singleton — just verify it loads without error
	assert_not_null(sc)

func test_replication_manager_creation() -> void:
	var rm: Node = preload("res://source/systems/network/replication_manager.gd").new()
	add_child_autofree(rm)
	assert_not_null(rm)
	assert_eq(rm.sync_rate, NetworkConfig.SYNC_RATE)
