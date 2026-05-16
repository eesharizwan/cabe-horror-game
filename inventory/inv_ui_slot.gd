extends Control
class_name InvUISlot

@onready var background: TextureRect = $Background
@onready var icon: TextureRect = $Icon
@onready var count_label: Label = $CountLabel

var slot_index: int = -1
var current_item: InventoryItem = null

func set_item(item: InventoryItem, count: int) -> void:
	current_item = item

	if item == null:
		icon.texture = null
		icon.visible = false
		count_label.visible = false
		return

	icon.texture = item.icon
	icon.visible = true

	if count > 1:
		count_label.text = str(count)
		count_label.visible = true
	else:
		count_label.visible = false

func clear_item() -> void:
	set_item(null, 0)

func set_selected(selected: bool) -> void:
	if selected:
		background.modulate = Color(2.0, 2.0, 2.0)  # very bright white
		background.self_modulate = Color(1.5, 1.5, 1.5)
	else:
		background.modulate = Color(1, 1, 1)
		background.self_modulate = Color(1, 1, 1)
