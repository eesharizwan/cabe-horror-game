extends Node2D

func _process(delta: float) -> void:
	change_scenes()

func _on_level_2_stair_transition_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		global.transition_scene = true

func _on_level_2_stair_transition_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		global.transition_scene = false

func change_scenes():
	if global.transition_scene == true:
		if global.current_scene == "level_2":
			global.current_scene = "level"
			global.transition_scene = false
			get_tree().change_scene_to_file("res://Levels/level.tscn")
