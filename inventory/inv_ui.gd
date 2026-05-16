extends Control

@export var inventory: InventoryNode

var grid: GridContainer = null
var slots: Array[InvUISlot] = []

var selected_slot_index: int = -1

func _ready() -> void:
	if inventory == null:
		inventory = Inventory

	if has_node("GridContainer"):
		grid = $GridContainer
	elif has_node("NinePatchRect/GridContainer"):
		grid = $NinePatchRect/GridContainer
	else:
		push_error("Inv_UI: Could not find GridContainer!")
		return

	slots.clear()
	for child in grid.get_children():
		if child is InvUISlot:
			slots.append(child)

	for i in range(slots.size()):
		slots[i].slot_index = i
		slots[i].set_selected(false)

	if inventory:
		inventory.inventory_changed.connect(update_slots)

	update_slots()
	set_process_unhandled_input(true)

func update_slots() -> void:
	if inventory == null:
		return

	for i in range(slots.size()):
		var item: InventoryItem = null
		var count := 0

		if i < inventory.items.size():
			item = inventory.items[i]

		if item != null:
			if item.item_name == "Battery":
				count = inventory.battery_count
			else:
				count = 1
			slots[i].set_item(item, count)
		else:
			slots[i].clear_item()

		slots[i].set_selected(i == selected_slot_index)

	_update_status_hint()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("slot_1"):
		_select_slot(0)
	elif event.is_action_pressed("slot_2"):
		_select_slot(1)
	elif event.is_action_pressed("slot_3"):
		_select_slot(2)
	elif event.is_action_pressed("slot_4"):
		_select_slot(3)
	elif event.is_action_pressed("slot_5"):
		_select_slot(4)
	elif event.is_action_pressed("slot_6"):
		_select_slot(5)
	elif event.is_action_pressed("use_item"):
		_use_selected_slot()

func _select_slot(index: int) -> void:
	if inventory == null:
		return

	if index < 0 or index >= slots.size() or index >= inventory.items.size():
		selected_slot_index = -1
	else:
		selected_slot_index = index

	for i in range(slots.size()):
		slots[i].set_selected(i == selected_slot_index)

	_update_status_hint()

func _use_selected_slot() -> void:
	if inventory == null:
		return

	if selected_slot_index < 0:
		return
	if selected_slot_index >= inventory.items.size():
		return

	print("Using slot:", selected_slot_index, " item:", inventory.items[selected_slot_index].item_name)
	inventory.use_item(selected_slot_index)

func _update_status_hint() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud == null or not hud.has_method("set_item_hint"):
		return

	if inventory == null:
		hud.set_item_hint("")
		return

	if selected_slot_index < 0 or selected_slot_index >= inventory.items.size():
		hud.set_item_hint("")
		return

	var item: InventoryItem = inventory.items[selected_slot_index]
	if item == null:
		hud.set_item_hint("")
		return

	match item.item_name:
		"Sword":
			hud.set_item_hint("Press F to attack")
		"Flashlight":
			hud.set_item_hint("Press E to use")
		"Battery":
			hud.set_item_hint("Used to power the flashlight")
		"good pills":
			hud.set_item_hint("Press E to use")
		"bad pills":
			hud.set_item_hint("Press E to use")
		"keysilver", "keygold", "keyemerald", "keyruby":
			hud.set_item_hint("Press E near the main door")
		_:
			hud.set_item_hint("Press E to use")
