class_name BestScores
extends Node

const SAVE_PATH := "user://dream_city_scores.cfg"

var best_score: int = 0
var best_distance: float = 0.0
var best_streak: int = 0


func load_best() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	best_score = cfg.get_value("best", "score", 0)
	best_distance = cfg.get_value("best", "distance", 0.0)
	best_streak = cfg.get_value("best", "streak", 0)


func update(score: int, distance: float, streak: int) -> void:
	var changed := false
	if score > best_score:
		best_score = score
		changed = true
	if distance > best_distance:
		best_distance = distance
		changed = true
	if streak > best_streak:
		best_streak = streak
		changed = true
	if changed:
		save_best()


func save_best() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("best", "score", best_score)
	cfg.set_value("best", "distance", best_distance)
	cfg.set_value("best", "streak", best_streak)
	cfg.save(SAVE_PATH)


func reset() -> void:
	best_score = 0
	best_distance = 0.0
	best_streak = 0