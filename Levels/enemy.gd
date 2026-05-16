extends CharacterBody2D

@export var speed: float = 80.0
@export var stop_distance: float = 8.0
@export var chase_radius: float = 100.0
@export var attack_distance: float = 25.0
@export var target: Node2D

var health = 100
var player_inattack_range = false
var player_attack_cooldown = true
var enemy_attack_cooldown = true

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	# Sanity checks
	if anim.sprite_frames == null:
		push_error("Enemy AnimatedSprite2D has NO SpriteFrames assigned.")
		return

	print("Enemy animations available: ", anim.sprite_frames.get_animation_names())

func _physics_process(delta):
	deal_with_damage()
	
	if target == null:
		velocity = Vector2.ZERO
		_play("idle")
		move_and_slide()
		return

	var diff = target.global_position - global_position
	var distance = diff.length()

	# Face the player
	if abs(diff.x) > 0.01:
		anim.flip_h = diff.x < 0

	# Priority: attack > walk > idle
	if distance <= attack_distance:
		#global.enemy_current_attack = true
		velocity = Vector2.ZERO
		_play("attack")
		if enemy_attack_cooldown:
			global.enemy_current_attack = true
			enemy_attack_cooldown = false
			$AttackCooldown.start()
		#$AttackCooldown.start()
	elif distance <= chase_radius and distance > stop_distance:
		velocity = diff.normalized() * speed
		_play("walk")
	else:
		velocity = Vector2.ZERO
		_play("idle")
		

	move_and_slide()

func _play(name: String) -> void:
	if anim.sprite_frames == null:
		return

	if not anim.sprite_frames.has_animation(name):
		
		return

	if anim.animation != name:
		anim.play(name)
		# Debug:
		# print("Playing: ", name)

func enemy():
	pass


func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_range = true
		print("player detected")


func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_range = false
		
func deal_with_damage():
	if player_inattack_range and global.player_current_attack:
		if player_attack_cooldown:
			health = health - 20
			$TakeDamageCooldown.start()
			player_attack_cooldown = false
			print("skeleton health: ", health)
			if health <= 0:
				global.enemy_current_attack = false
				self.queue_free()


func _on_take_damage_cooldown_timeout() -> void:
	player_attack_cooldown = true


func _on_attack_cooldown_timeout() -> void:
	global.enemy_current_attack = false
	enemy_attack_cooldown = true
