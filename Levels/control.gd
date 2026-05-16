extends Control

@onready var scroll = $Scroll
@onready var text = $StoryText
@onready var player = get_tree().get_first_node_in_group("player")

var typing_speed = 0.1
var typing_finished = false

func _ready():

	if global.game_first_loadin:
		scroll.play("open")
		text.visible_ratio = 0
		player.can_move = false
	else:
		hide()
		player.can_move = true


func _on_scroll_animation_finished():
	text.show()
	start_typewriter()


func start_typewriter():
	for i in range(100):
		text.visible_ratio = i / 100.0
		await get_tree().create_timer(typing_speed).timeout
	
	typing_finished = true


func _input(event):
	if event.is_action_pressed("ui_accept") and typing_finished:
		hide()
		player.can_move = true
		global.game_first_loadin = false
