class_name DreamerController
extends CharacterBody3D

signal jumped
signal player_died

@export var run_speed: float = 4.0
@export var gravity: float = 22.0
@export var fall_death_y: float = -8.0
@export var debug_mode := false

@export var perfect_jump_velocity: float = 8.4
@export var good_jump_velocity: float = 8.0
@export var miss_jump_velocity: float = 6.4

const JUMP_QUALITY_NONE := -1

var current_jump_quality: int = JUMP_QUALITY_NONE

var _game_state: int = GameManager.GameState.PLAYING
var _was_airborne := false
var _dead := false


func set_game_state(state: int) -> void:
	_game_state = state


func handle_timing_result(result: TimingSystem.TimingResult) -> void:
	attempt_jump(result)


func attempt_jump(quality: TimingSystem.TimingResult) -> void:
	if _dead or not is_on_floor():
		current_jump_quality = JUMP_QUALITY_NONE
		return
	if _game_state == GameManager.GameState.GAME_OVER:
		current_jump_quality = JUMP_QUALITY_NONE
		return
	var jump_speed := good_jump_velocity
	match quality:
		TimingSystem.TimingResult.PERFECT:
			jump_speed = perfect_jump_velocity
		TimingSystem.TimingResult.MISS:
			jump_speed = miss_jump_velocity
	velocity.y = jump_speed
	current_jump_quality = quality
	_was_airborne = true
	emit_signal("jumped")
	if debug_mode:
		print("JUMP: ", TimingSystem.TimingResult.keys()[quality], " velocity=", jump_speed)


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

	move_and_slide()

	if is_on_floor() and _was_airborne:
		_was_airborne = false
		if debug_mode:
			print("Dreamer: landing")
	elif not is_on_floor():
		_was_airborne = true