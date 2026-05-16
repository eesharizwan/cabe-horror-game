extends CharacterBody2D

@export var player: Node2D
@export var speed: float = 320.0
@export var attack_range: float = 14.0
@export var attack_cooldown: float = 0.6

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var agent: NavigationAgent2D = $NavigationAgent2D

var is_attacking := false
var can_attack := true

func _ready() -> void:
	sprite.animation_finished.connect(_on_sprite_animation_finished)

	# Match what you set in inspector (safe to force here too)
	agent.path_desired_distance = 1.0
	agent.target_desired_distance = 1.0
	agent.path_max_distance = 2000.0

	sprite.play("idle")

func _physics_process(_delta: float) -> void:
	if player == null or not is_instance_valid(player):
		velocity = Vector2.ZERO
		sprite.play("idle")
		move_and_slide()
		return

	agent.target_position = player.global_position

	# If no path, you won't chase correctly
	if agent.is_navigation_finished() and global_position.distance_to(player.global_position) > attack_range:
		# This line helps you confirm if the agent thinks it can't path
		# (If you see it often, navmesh isn't covering both positions or layers mismatch)
		# print("[Skeleton] navigation finished early / no path?")
		pass

	_face_player(player.global_position)

	var dist := global_position.distance_to(player.global_position)
	if dist <= attack_range:
		velocity = Vector2.ZERO
		if not is_attacking and can_attack:
			_attack()
		else:
			if not is_attacking:
				sprite.play("idle")
		move_and_slide()
		return

	if not is_attacking:
		var next_pos := agent.get_next_path_position()
		var dir := next_pos - global_position

		if dir.length() > 0.5:
			velocity = dir.normalized() * speed
			sprite.play("run")
		else:
			velocity = Vector2.ZERO
			sprite.play("idle")
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func _face_player(target_pos: Vector2) -> void:
	var dx := target_pos.x - global_position.x
	if abs(dx) > 1.0:
		sprite.flip_h = dx < 0

func _attack() -> void:
	is_attacking = true
	can_attack = false
	sprite.play("attack")
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _on_sprite_animation_finished() -> void:
	if sprite.animation == "attack":
		is_attacking = false
