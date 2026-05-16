extends CanvasLayer

@onready var objective_label: Label = get_node_or_null("ObjectiveLabel")
@onready var status_label: Label = get_node_or_null("StatusLabel")
@onready var health_bar: ProgressBar = get_node_or_null("HealthBar")

var current_hint: String = ""

func _ready() -> void:
	add_to_group("hud")

	if objective_label != null:
		_update_objective_text()

	if not Inventory.objective_updated.is_connected(_update_objective_text):
		Inventory.objective_updated.connect(_update_objective_text)

	if status_label != null:
		status_label.text = ""
		status_label.visible = true

	if health_bar != null:
		health_bar.min_value = 0
		health_bar.max_value = Inventory.player_max_health
		health_bar.value = Inventory.player_health

	if not Inventory.health_updated.is_connected(_update_health_bar):
		Inventory.health_updated.connect(_update_health_bar)

func _update_objective_text() -> void:
	if objective_label == null:
		return

	var delivered := Inventory.keys_delivered_count

	if delivered >= 4:
		objective_label.text = "All keys delivered\nThe main door is unlocked"
	else:
		objective_label.text = "Keys Delivered: %d / 4\nBring the remaining keys to the main door" % delivered

func _update_health_bar() -> void:
	if health_bar == null:
		return

	health_bar.max_value = Inventory.player_max_health
	health_bar.value = Inventory.player_health

func set_item_hint(message: String) -> void:
	current_hint = message

	if status_label != null:
		status_label.text = current_hint

func show_status_message(message: String) -> void:
	if status_label == null:
		print(message)
		return

	status_label.text = message

	var timer := get_tree().create_timer(2.0)
	timer.timeout.connect(func():
		if status_label != null:
			status_label.text = current_hint)
