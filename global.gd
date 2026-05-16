extends Node

var player_current_attack = false
var enemy_current_attack = false

var cause_of_death = ""

var current_scene = "level"
var transition_scene = false

var player_start_posx = -87.0
var player_start_posy = 321.0
var player_exit_stairs_posx = 345.0
var player_exit_stairs_posy = -16.0

var game_first_loadin = true

func reset_global_state() -> void:
	player_current_attack = false
	enemy_current_attack = false

	current_scene = "level"
	transition_scene = false

	game_first_loadin = true

	print("Global state reset")
