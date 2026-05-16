extends CharacterBody2D

var can_move = false
const SPEED: float = 100.0
var current_dir: String = "none"
var is_attacking = false

var enemy_inattack_range = false
var enemy_attack_cooldown = true

@export var drain_seconds: float = 60.0
@export var min_light_mult: float = 0.10
@export var low_battery_threshold: float = 0.20
@export var flicker_strength: float = 0.15

# Start flashlight dead/off
# flashlight state is stored globally in Inventory now
var base_energy_2: float
var battery_textures: Array[Texture2D]

@onready var light2: PointLight2D = $PointLight2D2
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var battery_ui: TextureRect = get_tree().get_root().get_node_or_null("Level/CanvasLayer/BatteryUI")
@onready var inventory: InventoryNode = Inventory

@onready var deal_attack_timer: Timer = get_node_or_null("PlayerHitbox/DealAttackTimer")
@onready var attack_cooldown_timer: Timer = $AttackCooldown

func _ready() -> void:
	can_move = true
	anim.play("idle_down")
	base_energy_2 = light2.energy

	if inventory:
		if not inventory.item_used.is_connected(_on_item_used):
			inventory.item_used.connect(_on_item_used)
		# restore flashlight state from global inventory
		apply_flashlight_energy()
	else:
		print("Inventory not found")

	if deal_attack_timer == null:
		print("WARNING: DealAttackTimer not found")
	if attack_cooldown_timer == null:
		print("WARNING: AttackCooldown not found")

	battery_textures = [
		preload("res://Art/flashlight/1.png"),
		preload("res://Art/flashlight/2.png"),
		preload("res://Art/flashlight/3.png"),
		preload("res://Art/flashlight/4.png"),
		preload("res://Art/flashlight/5.png"),
		preload("res://Art/flashlight/6.png")
	]

func _physics_process(delta):
	if is_attacking:
		move_and_slide()
		return

	if Input.is_action_just_pressed("attack"):
		lightsaber_attack()
		move_and_slide()
		return

	if !can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	player_movement()
	enemy_attack()
	update_flashlight_cycle(delta)
	apply_flashlight_energy()
	# update_battery_ui()

func player_movement() -> void:
	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		play_anim(1)
		velocity = Vector2(SPEED, 0.0)

	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		play_anim(1)
		velocity = Vector2(-SPEED, 0.0)

	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		play_anim(1)
		velocity = Vector2(0.0, SPEED)

	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		play_anim(1)
		velocity = Vector2(0.0, -SPEED)

	else:
		play_anim(0)
		velocity = Vector2.ZERO

	move_and_slide()
	update_light_direction()

func player():
	pass

func update_light_direction() -> void:
	var dir_vector: Vector2 = Vector2.ZERO

	match current_dir:
		"right":
			dir_vector = Vector2.RIGHT
		"left":
			dir_vector = Vector2.LEFT
		"down":
			dir_vector = Vector2.DOWN
		"up":
			dir_vector = Vector2.UP

	if dir_vector != Vector2.ZERO:
		var angle: float = dir_vector.angle()
		light2.global_rotation = angle

func update_flashlight_cycle(delta: float) -> void:
	if inventory == null:
		return

	if inventory.flashlight_draining:
		if drain_seconds > 0.0:
			inventory.flashlight_charge -= delta / drain_seconds
		else:
			inventory.flashlight_charge = 0.0

		if inventory.flashlight_charge <= 0.01:
			inventory.flashlight_charge = 0.0
			inventory.flashlight_draining = false
			print("Flashlight dead")
	

func apply_flashlight_energy() -> void:
	if inventory == null:
		return

	var mult: float = lerpf(min_light_mult, 1.0, inventory.flashlight_charge)

	if inventory.flashlight_draining and inventory.flashlight_charge <= low_battery_threshold and flicker_strength > 0.0:
		var t: float = float(Time.get_ticks_msec()) / 1000.0
		var flicker: float = 1.0 - (sin(t * 20.0) * 0.5 + 0.5) * flicker_strength
		mult *= flicker

	light2.energy = base_energy_2 * mult

func play_anim(movement: int) -> void:
	if is_attacking:
		return

	if current_dir == "right":
		anim.flip_h = false
		anim.play("sprinting_right" if movement == 1 else "idle_right")

	elif current_dir == "left":
		anim.flip_h = false
		anim.play("sprinting_left" if movement == 1 else "idle_left")

	elif current_dir == "down":
		anim.flip_h = false
		anim.play("sprinting_down" if movement == 1 else "idle_down")

	elif current_dir == "up":
		anim.flip_h = false
		anim.play("sprinting_up" if movement == 1 else "idle_up")

func lightsaber_attack():
	is_attacking = true
	velocity = Vector2.ZERO
	global.player_current_attack = true

	var dir = current_dir

	if dir == "right":
		anim.play("swing_single_right")
	elif dir == "left":
		anim.play("swing_single_left")
	elif dir == "up":
		anim.play("swing_single_up")
	else:
		anim.play("swing_single_down")

	if deal_attack_timer:
		deal_attack_timer.start()
	else:
		print("WARNING: cannot attack timer-start because DealAttackTimer is missing")

	await anim.animation_finished
	global.player_current_attack = false
	is_attacking = false
	
func die():
	can_move = false
	velocity = Vector2.ZERO
	
	
	
	get_tree().change_scene_to_file("res://gameover.tscn")

func _on_item_used(item, slot_index) -> void:
	print("PLAYER RECEIVED ITEM:", item.item_name)

	var item_name = String(item.item_name).to_lower()

	if item_name == "flashlight":
		if inventory == null:
			print("Inventory not found")
			_show_status_message("Inventory not found")
			return

		if inventory.has_battery():
			var used = inventory.consume_battery()
			if used:
				inventory.flashlight_charge = 1.0
				inventory.flashlight_draining = true
				print("Flashlight recharged with battery")
				_show_status_message("Flashlight recharged")
		else:
			print("You need batteries to use your flashlight")
			_show_status_message("Find batteries to use the flashlight")

	elif item_name == "good pills" or item_name == "good_pills":
		if inventory:
			inventory.heal(60)
			inventory.drop_item(slot_index)
			_show_status_message("Recovered health")
			print("Health after healing:", inventory.player_health)

	elif item_name == "bad pills" or item_name == "bad_pills":
		if inventory:
			inventory.apply_damage(100)
			inventory.drop_item(slot_index)
			_show_status_message("Maybe dont take random pills that can kill you")
			print("Health after bad pills:", inventory.player_health)

			if inventory.player_health <= 0:
				global.cause_of_death = "pills"
				die()


func _show_status_message(message: String) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("show_status_message"):
		hud.show_status_message(message)
	else:
		print(message)


func update_battery_ui() -> void:
	if inventory == null:
		return

	var index: int

	if inventory.flashlight_charge >= 0.83:
		index = 5
	elif inventory.flashlight_charge >= 0.66:
		index = 4
	elif inventory.flashlight_charge >= 0.5:
		index = 3
	elif inventory.flashlight_charge >= 0.33:
		index = 2
	elif inventory.flashlight_charge >= 0.16:
		index = 1
	else:
		index = 0

	# if battery_ui:
	# 	battery_ui.texture = battery_textures[index]

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = true

func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = false

func enemy_attack():
	if global.enemy_current_attack and enemy_attack_cooldown:
		enemy_attack_cooldown = false

		if attack_cooldown_timer:
			attack_cooldown_timer.start()
		else:
			print("WARNING: AttackCooldown timer missing")

		if inventory:
			inventory.apply_damage(20)

			if inventory.player_health <= 0:
				global.cause_of_death = "skeleton"
				die()


func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true

func _on_deal_attack_timer_timeout() -> void:
	if deal_attack_timer:
		deal_attack_timer.stop()
	global.player_current_attack = false
