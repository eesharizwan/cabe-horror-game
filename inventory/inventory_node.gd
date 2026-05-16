extends Node
class_name InventoryNode

signal inventory_changed
signal item_used(item, slot_index)
signal item_dropped(item, slot_index)
signal objective_updated
signal health_updated

@export var max_slots: int = 6

var items: Array[InventoryItem] = []
var battery_count: int = 0
var collected_pickups: Dictionary = {}
var keys_delivered_count: int = 0
var delivered_keys: Dictionary = {}

var player_max_health: int = 100
var player_health: int = 100

var flashlight_charge: float = 0.0
var flashlight_draining: bool = false

func add_item(item: InventoryItem) -> bool:
	# Stack batteries
	if item.item_name == "Battery":
		battery_count += 1

		for existing in items:
			if existing == item:
				inventory_changed.emit()
				print("Battery added. Total:", battery_count)
				return true

		if items.size() >= max_slots:
			print("Battery added (no slot). Total:", battery_count)
			return true

		items.append(item)
		inventory_changed.emit()
		print("Battery added. Total:", battery_count)
		return true

	# Normal items
	if items.size() >= max_slots:
		return false

	items.append(item)
	inventory_changed.emit()
	return true

func has_battery() -> bool:
	return battery_count > 0

func consume_battery() -> bool:
	if battery_count <= 0:
		return false

	battery_count -= 1

	if battery_count == 0:
		for i in range(items.size()):
			var item := items[i]
			if item != null and item.item_name == "Battery":
				items.remove_at(i)
				break

	inventory_changed.emit()
	print("Battery consumed. Remaining:", battery_count)
	return true

func apply_damage(amount: int) -> void:
	player_health = max(player_health - amount, 0)
	health_updated.emit()
	print("Player health:", player_health)

func heal(amount: int) -> void:
	player_health = min(player_health + amount, player_max_health)
	health_updated.emit()
	print("Player health:", player_health)

func use_item(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= items.size():
		return

	var item = items[slot_index]
	item_used.emit(item, slot_index)

func drop_item(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= items.size():
		return

	var item = items[slot_index]
	item_dropped.emit(item, slot_index)
	items.remove_at(slot_index)
	inventory_changed.emit()
	
func reset_game_state() -> void:
	items.clear()
	battery_count = 0
	collected_pickups.clear()
	keys_delivered_count = 0
	delivered_keys.clear()

	player_health = player_max_health

	flashlight_charge = 0.0
	flashlight_draining = false

	inventory_changed.emit()
	objective_updated.emit()
	health_updated.emit()

	print("Game state reset")
