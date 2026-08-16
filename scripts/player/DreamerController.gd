extends CharacterBody3D

signal jumped
signal player_died

@export var run_speed: float = 4.0
@export var jump_velocity: float = 8.0
@export var gravity: float = 22.0
@export var fall_death_y: float = -8.0
@export var debug_mode := false

var _was_airborne := false
var _dead := false


func _physics_process(delta: float) -> void:
	if not _dead and global_position.y < fall_death_y:
		_dead = true
		emit_signal("player_died")
		if debug_mode:
			print("Dreamer: death")

	velocity.x = run_speed
	velocity.z = 0.0

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		_was_airborne = true
		emit_signal("jumped")
		if debug_mode:
			print("Dreamer: jump")

	move_and_slide()

	if is_on_floor() and _was_airborne:
		_was_airborne = false
		if debug_mode:
			print("Dreamer: landing")
	elif not is_on_floor():
		_was_airborne = true