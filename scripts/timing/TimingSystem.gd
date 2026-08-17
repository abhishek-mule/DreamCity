class_name TimingSystem
extends Node

enum TimingResult {
	PERFECT,
	GOOD,
	MISS
}

signal timing_perfect
signal timing_good
signal timing_miss
signal timing_result(result: TimingResult)

@export var cycle_duration: float = 1.2
@export var perfect_window: float = 0.08
@export var good_window: float = 0.20
@export var debug_mode := false

var current_position: float = 0.5

const EPSILON := 0.000001

var _t: float = 0.25


func _process(delta: float) -> void:
	_t += delta / cycle_duration
	_t = fmod(_t, 1.0)
	current_position = _triangle(_t)
	if Input.is_action_just_pressed("jump"):
		_handle_tap()


func classify(position: float) -> TimingResult:
	var distance := absf(position - 0.5)
	if distance <= perfect_window + EPSILON:
		return TimingResult.PERFECT
	if distance <= good_window + EPSILON:
		return TimingResult.GOOD
	return TimingResult.MISS


func _handle_tap() -> void:
	var result := classify(current_position)
	emit_signal("timing_result", result)
	match result:
		TimingResult.PERFECT:
			emit_signal("timing_perfect")
			if debug_mode:
				print("TIMING PERFECT")
		TimingResult.GOOD:
			emit_signal("timing_good")
			if debug_mode:
				print("TIMING GOOD")
		TimingResult.MISS:
			emit_signal("timing_miss")
			if debug_mode:
				print("TIMING MISS")
	_t = 0.25
	current_position = 0.5


func _triangle(t: float) -> float:
	if t <= 0.5:
		return t * 2.0
	return (1.0 - t) * 2.0