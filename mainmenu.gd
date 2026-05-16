extends Control

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_start_pressed() -> void:
	Inventory.reset_game_state()
	global.reset_global_state()
	get_tree().change_scene_to_file("res://Levels/level.tscn")

func _on_settings_pressed() -> void:
	print("settings pressed")

func _on_quit_pressed() -> void:
	get_tree().quit()
