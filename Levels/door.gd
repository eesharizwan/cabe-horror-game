extends Area2D

@export var inventory: InventoryNode

var required_keys: Array[String] = [
	"keysilver",
	"keygold",
	"keyemerald",
    "keyruby"
]

var player_in_area: bool = false

func _ready() -> void:
	if inventory == null:
		inventory = Inventory

	# Make sure all required keys exist in the global delivered_keys dictionary
	for k in required_keys:
		if not inventory.delivered_keys.has(k):
			inventory.delivered_keys[k] = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if inventory and not inventory.item_used.is_connected(_on_item_used):
		inventory.item_used.connect(_on_item_used)

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_in_area = true

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_in_area = false

func _on_item_used(item: InventoryItem, slot_index: int) -> void:
	if not player_in_area:
		return

	var key_name := item.item_name

	if not required_keys.has(key_name):
		return

	# Already turned in before
	if inventory.delivered_keys.get(key_name, false):
		return

	inventory.delivered_keys[key_name] = true
	inventory.drop_item(slot_index)

	inventory.keys_delivered_count = _count_keys_turned_in()
	inventory.objective_updated.emit()

	print("Turned in key: ", key_name, " (", inventory.keys_delivered_count, "/4)")

	if _all_keys_turned_in():
		_on_all_keys_delivered()

func _count_keys_turned_in() -> int:
	var cnt := 0
	for k in required_keys:
		if inventory.delivered_keys.get(k, false):
			cnt += 1
	return cnt

func _all_keys_turned_in() -> bool:
	for k in required_keys:
		if not inventory.delivered_keys.get(k, false):
			return false
	return true

func _on_all_keys_delivered() -> void:
	print("Door unlocked!")

	$CollisionShape2D.disabled = true
	visible = false

	# Load ending screen
	get_tree().change_scene_to_file("res://EndingScreen.tscn")
