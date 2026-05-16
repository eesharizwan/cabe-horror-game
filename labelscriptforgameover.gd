extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if global.cause_of_death == "pills":
		text = "Maybe don't take unlabeled pills …"
	elif global.cause_of_death == "skeleton":
		text = "Your swordsmanship needs some work …"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
