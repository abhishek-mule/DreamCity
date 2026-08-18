class_name FlowSystem
extends Node

enum Flow {
	CALM,
	FLOW,
	DEEP_FLOW,
	FRACTURED
}

signal flow_changed(flow: int)

const THRESHOLD_FLOW := 3
const THRESHOLD_DEEP_FLOW := 5

var flow: int = Flow.CALM

var _score: ScoreSystem


func _ready() -> void:
	_score = get_node("../ScoreSystem") as ScoreSystem


func on_miss() -> void:
	_set_flow(Flow.FRACTURED)


func on_timing_result(result: TimingSystem.TimingResult) -> void:
	if result == TimingSystem.TimingResult.MISS:
		return
	_recompute()


func reset() -> void:
	_set_flow(Flow.CALM)


func _recompute() -> void:
	var streak := _score.current_streak if _score != null else 0
	var target := Flow.CALM
	if streak >= THRESHOLD_DEEP_FLOW:
		target = Flow.DEEP_FLOW
	elif streak >= THRESHOLD_FLOW:
		target = Flow.FLOW
	_set_flow(target)


func _set_flow(value: int) -> void:
	if value == flow:
		return
	flow = value
	flow_changed.emit(flow)