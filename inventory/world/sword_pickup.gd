extends Area2D

@export var item: InventoryItem
@export var pickup_id: String = ""

var inventory: InventoryNode

func _ready() -> void:
	inventory = Inventory

	print("Pickup ready:", name, " id=", pickup_id)
	print("Collected pickups right now:", inventory.collected_pickups)

	if pickup_id != "" and inventory.collected_pickups.has(pickup_id):
		print("Pickup already collected, removing:", pickup_id)
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if inventory and item:
			var added := inventory.add_item(item)

			print("Pickup add_item returned:", added, " id=", pickup_id)

			if added:
				if pickup_id != "":
					inventory.collected_pickups[pickup_id] = true
					print("Stored collected pickup:", pickup_id)
				queue_free()
