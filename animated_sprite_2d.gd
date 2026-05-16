

# Called when the node enters the scene tree for the first time.
extends AnimatedSprite2D

@export var speed: float = 120
@export var amplitude: float = 40
@export var frequency: float = 3

var direction: int = 1
var time: float = 0

func _ready():
	play("move")

func _process(delta):
	time += delta
	
	# Horizontal movement
	position.x += speed * direction * delta
	
	# Wavy vertical movement
	position.y += sin(time * frequency) * amplitude * delta
	
	# Flip sprite based on direction
	flip_h = direction < 0
	
	# Screen edge detection
	if position.x > 1200:
		direction = -1
	elif position.x < -50:
		direction = 1


func _on_button_pressed():
	get_tree().change_scene_to_file("res://mainmenu.tscn") # Replace with function body.
