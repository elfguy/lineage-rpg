extends Node

var _gut: Node
var _tests_done: bool = false
var _wait_frames: int = 0

func _ready() -> void:
	_gut = get_parent()
	if _gut == null:
		print("ERROR: GUT node not found")
		get_tree().quit(1)
		return
	var test_scripts: Array[String] = [
		"res://tests/unit/test_project_setup.gd",
		"res://tests/unit/test_event_bus.gd",
		"res://tests/unit/test_game_state.gd",
		"res://tests/unit/test_player.gd",
		"res://tests/unit/test_state_machine.gd",
		"res://tests/unit/test_save_load.gd",
		"res://tests/unit/test_inventory.gd",
		"res://tests/unit/test_combat.gd",
		"res://tests/unit/test_quest_system.gd",
		"res://tests/unit/test_resources.gd",
		"res://tests/unit/test_network.gd",
		"res://tests/unit/test_progression.gd",
		"res://tests/unit/test_equipment.gd",
		"res://tests/unit/test_shop.gd",
	]
	for test_path: String in test_scripts:
		_gut.add_script(test_path)
	_gut.test_running.connect(_on_tests_finished)
	_gut.start()

func _process(_delta: float) -> void:
	if _tests_done:
		return
	_wait_frames += 1
	if _wait_frames > 120 and not _gut.is_running():
		_tests_done = true
		_report_results()
		get_tree().quit(0 if _gut.get_summary().get_failing_count() == 0 else 1)
	if _wait_frames > 300:
		_tests_done = true
		_report_results()
		get_tree().quit(2)

func _on_tests_finished() -> void:
	_tests_done = true
	_report_results()
	get_tree().quit(0 if _gut.get_summary().get_failing_count() == 0 else 1)

func _report_results() -> void:
	var summary: Node = _gut.get_summary()
	var passed: int = summary.get_passing_count()
	var failed: int = summary.get_failing_count()
	var pending: int = summary.get_pending_count()
	print("\n========================================")
	print("  TEST RESULTS")
	print("  Passed:  %d" % passed)
	print("  Failed:  %d" % failed)
	print("  Pending: %d" % pending)
	print("========================================")
	if failed > 0:
		print("  STATUS: FAIL")
	else:
		print("  STATUS: ALL PASS")
