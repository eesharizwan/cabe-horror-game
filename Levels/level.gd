extends Node2D

func _ready():
	if global.game_first_loadin == true:
		$Player.position.x = global.player_start_posx
		$Player.position.y = global.player_start_posy
	else:
		$Player.position.x = global.player_exit_stairs_posx
		$Player.position.y = global.player_exit_stairs_posy

func _process(delta: float) -> void:
	change_scenes()

func _on_stair_transition_point_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		global.transition_scene = true

func _on_stair_transition_point_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		global.transition_scene = false

func change_scenes():
	if global.transition_scene == true:
		if global.current_scene == "level":
			global.current_scene = "level_2"
			global.game_first_loadin = false
			global.transition_scene = false
			get_tree().change_scene_to_file("res://Levels/level_2.tscn")

			
