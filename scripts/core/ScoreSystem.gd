class_name ScoreSystem
extends Node

signal score_changed(score: int)
signal streak_changed(streak: int)
signal run_distance_changed(distance: float)

const SCORE_PERFECT := 100
const SCORE_GOOD := 50
const SCORE_MISS := 0

var score: int = 0
var distance: float = 0.0
var current_streak: int = 0
var best_streak: int = 0
var active := false

var _run_start_x := 0.0


func start_run(player_start_x: float) -> void:
	score = 0
	distance = 0.0
	current_streak = 0
	best_streak = 0
	_run_start_x = player_start_x
	active = true
	score_changed.emit(score)
	streak_changed.emit(current_streak)
	run_distance_changed.emit(distance)


func on_timing_result(result: TimingSystem.TimingResult) -> void:
	if not active:
		return
	if not _is_player_on_floor():
		return
	match result:
		TimingSystem.TimingResult.PERFECT:
			score += SCORE_PERFECT
			current_streak += 1
			best_streak = maxi(best_streak, current_streak)
		TimingSystem.TimingResult.GOOD:
			score += SCORE_GOOD
		TimingSystem.TimingResult.MISS:
			current_streak = 0
	score_changed.emit(score)
	streak_changed.emit(current_streak)


func finish_run(best: BestScores) -> void:
	active = false
	best.update(score, distance, best_streak)


var summary: Dictionary:
	get:
		return {"score": score, "distance": distance, "best_streak": best_streak}


func _process(_delta: float) -> void:
	if not active:
		return
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var new_distance := maxf(0.0, (player as Node3D).global_position.x - _run_start_x)
	if absf(new_distance - distance) > 0.001:
		distance = new_distance
		run_distance_changed.emit(distance)


func _is_player_on_floor() -> bool:
	var player := get_tree().get_first_node_in_group("player")
	return player is CharacterBody3D and (player as CharacterBody3D).is_on_floor()