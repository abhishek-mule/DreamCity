class_name HypnagogicFracture
extends Node

enum FractureState { IDLE, FRACTURING }

signal fracture_completed

const DEFAULT_RUN_SPEED := 4.0
const DEFAULT_GRAVITY := 22.0
const GOOD_JUMP_VELOCITY := 8.0

@export var fracture_duration: float = 0.45
@export_range(0.0, 1.0) var fracture_intensity: float = 0.5
@export var fracture_rotation_degrees: float = 12.0
@export var random_seed: int = 12345
@export var debug_mode := false

var state: FractureState = FractureState.IDLE
var last_pattern_name: String = "STANDARD"
var last_applied_offsets: Array[Vector3] = []
var fracture_count: int = 0

var _rng := RandomNumberGenerator.new()
var _fold_tween: Tween
var _unfold_tween: Tween


func _ready() -> void:
	_rng.seed = random_seed


func _on_timing_result(result: TimingSystem.TimingResult) -> void:
	if result != TimingSystem.TimingResult.MISS:
		return
	if state != FractureState.IDLE:
		return
	var game_manager := get_parent() as GameManager
	if game_manager != null and game_manager.current_state == GameManager.GameState.GAME_OVER:
		return
	_fracture()


func _fracture() -> void:
	var platforms := _get_platforms()
	if platforms.is_empty():
		return
	var current := _find_current_platform(platforms)
	if current == null:
		return
	var upcoming := _get_upcoming_platforms(platforms, current, 3)
	if upcoming.is_empty():
		return

	var chosen_name := ""
	var chosen_offsets: Array[Vector3] = []
	for pattern_name in _build_candidates():
		var offsets := _resolve_offsets(pattern_name, current, upcoming)
		if not offsets.is_empty():
			chosen_name = pattern_name
			chosen_offsets = offsets
			break
	if chosen_name.is_empty():
		if debug_mode:
			print("FRACTURE ABORT: no valid pattern")
		return

	last_pattern_name = chosen_name
	last_applied_offsets = chosen_offsets
	fracture_count += 1
	state = FractureState.FRACTURING
	_apply_fracture(current, upcoming, chosen_offsets)


func _build_candidates() -> Array[String]:
	var names: Array[String] = []
	for pattern_name in PlatformPattern.get_all_patterns().keys():
		if pattern_name != last_pattern_name:
			names.append(pattern_name)
	for i in range(names.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var tmp := names[i]
		names[i] = names[j]
		names[j] = tmp
	return names


func _resolve_offsets(pattern_name: String, current: Platform, upcoming: Array[Platform]) -> Array[Vector3]:
	var pattern: Array = PlatformPattern.get_all_patterns()[pattern_name]
	var count := mini(pattern.size(), upcoming.size())
	var blended: Array[Vector3] = []
	for i in count:
		var p: Vector3 = pattern[i]
		var s: Vector3 = PlatformPattern.STANDARD[i]
		blended.append(s + (p - s) * fracture_intensity)
	var run_speed := _get_dreamer_property("run_speed", DEFAULT_RUN_SPEED)
	var gravity := _get_dreamer_property("gravity", DEFAULT_GRAVITY)
	if not PatternValidator.validate_offsets(
		blended, current.get_platform_width(), current.platform_depth, run_speed, GOOD_JUMP_VELOCITY, gravity
	):
		return []
	return blended


func _get_dreamer_property(property: String, fallback: float) -> float:
	var dreamer := get_tree().get_first_node_in_group("player")
	if dreamer == null:
		return fallback
	var value = dreamer.get(property)
	if typeof(value) != TYPE_FLOAT and typeof(value) != TYPE_INT:
		return fallback
	return value


func _apply_fracture(current: Platform, upcoming: Array[Platform], offsets: Array[Vector3]) -> void:
	if _unfold_tween != null and _unfold_tween.is_valid():
		_unfold_tween.kill()
		_unfold_tween = null
	if debug_mode:
		print("FRACTURE START: pattern=%s intensity=%.2f count=%d" % [last_pattern_name, fracture_intensity, fracture_count])
		for i in offsets.size():
			print("  %s offset=%s edge_gap=%.2f vertical=%.2f" % [upcoming[i].name, offsets[i], offsets[i].x - current.get_platform_width(), offsets[i].y])
	_fold_tween = create_tween().set_parallel(true)
	var position := current.global_position
	var fold_degrees := fracture_rotation_degrees * fracture_intensity
	for i in upcoming.size():
		position += offsets[i]
		var platform := upcoming[i]
		_fold_tween.tween_property(platform, "global_position", position, fracture_duration) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		var visual := platform.get_node("Visual")
		_fold_tween.tween_property(visual, "rotation_degrees", Vector3(0, 0, fold_degrees), fracture_duration) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_fold_tween.finished.connect(_on_fracture_finished)


func _on_fracture_finished() -> void:
	state = FractureState.IDLE
	emit_signal("fracture_completed")
	if debug_mode:
		print("FRACTURE COMPLETE: count=%d" % fracture_count)
	_unfold_tween = create_tween().set_parallel(true)
	for node in get_tree().get_nodes_in_group("platform"):
		var visual := node.get_node_or_null("Visual")
		if visual != null and not visual.rotation_degrees.is_zero_approx():
			_unfold_tween.tween_property(visual, "rotation_degrees", Vector3.ZERO, 0.3) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _get_platforms() -> Array[Platform]:
	var result: Array[Platform] = []
	for node in get_tree().get_nodes_in_group("platform"):
		if node is Platform:
			result.append(node as Platform)
	return result


func _find_current_platform(platforms: Array[Platform]) -> Platform:
	var player_x := 0.0
	var dreamer := get_tree().get_first_node_in_group("player")
	if dreamer != null:
		player_x = dreamer.global_position.x
	var current: Platform = null
	var best_x := -INF
	for platform in platforms:
		if platform.global_position.x <= player_x + 0.001 and platform.global_position.x > best_x:
			best_x = platform.global_position.x
			current = platform
	return current


func _get_upcoming_platforms(platforms: Array[Platform], current: Platform, count: int) -> Array[Platform]:
	var ahead: Array[Platform] = []
	for platform in platforms:
		if platform.global_position.x > current.global_position.x + 0.001:
			ahead.append(platform)
	ahead.sort_custom(func(a: Platform, b: Platform) -> bool: return a.global_position.x < b.global_position.x)
	var result: Array[Platform] = []
	for i in mini(count, ahead.size()):
		result.append(ahead[i])
	return result