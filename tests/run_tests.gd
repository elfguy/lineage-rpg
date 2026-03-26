## GUT 테스트 러너
## headless에서 테스트를 실행하고 결과를 출력합니다.

extends SceneTree

func _init() -> void:
	var gut: Node = load("res://addons/gut/gut.gd").new()
	root.add_child(gut)
	# 테스트 디렉토리 설정
	gut.add_script("res://tests/unit/test_project_setup.gd")
	gut.add_script("res://tests/unit/test_event_bus.gd")
	gut.add_script("res://tests/unit/test_game_state.gd")
	gut.add_script("res://tests/unit/test_player.gd")
	gut.add_script("res://tests/unit/test_state_machine.gd")
	gut.add_script("res://tests/unit/test_save_load.gd")
	gut.add_script("res://tests/unit/test_inventory.gd")
	gut.add_script("res://tests/unit/test_combat.gd")
	gut.add_script("res://tests/unit/test_quest_system.gd")
	gut.add_script("res://tests/unit/test_resources.gd")
	gut.add_script("res://tests/unit/test_network.gd")
	gut.add_script("res://tests/unit/test_progression.gd")
	gut.add_script("res://tests/unit/test_equipment.gd")
	gut.add_script("res://tests/unit/test_shop.gd")
	gut.test_running.connect(_on_tests_finished)
	gut.start()

func _on_tests_finished() -> void:
	var gut: Node = root.get_node_or_null("Gut")
	if gut == null:
		quit(1)
		return
	var summary: Node = gut.get_summary()
	var passed: int = summary.get_passing_count()
	var failed: int = summary.get_failing_count()
	var pending: int = summary.get_pending_count()
	print("\n========================================")
	print("  TEST RESULTS: %d passed, %d failed, %d pending" % [passed, failed, pending])
	if failed > 0:
		print("  STATUS: FAIL")
		quit(1)
	else:
		print("  STATUS: PASS")
		quit(0)
