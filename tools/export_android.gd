@tool
extends EditorPlugin

func _enter_tree() -> void:
	await get_tree().create_timer(3.0).timeout
	var ei: EditorInterface = get_editor_interface()
	var result: int = ei.export_project("Android", "Android", true, "/Users/elfguy/alba/games/lineage-rpg/build/lineagerpg.apk")
	print("Export result: ", result)
	get_tree().quit(result)
