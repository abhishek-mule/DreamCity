class_name GameManager
extends Node3D

enum GameState {
	MENU,
	PLAYING,
	GAME_OVER
}

var current_state: GameState = GameState.MENU


func _ready() -> void:
	var timing := get_node_or_null("TimingSystem") as TimingSystem
	if timing != null:
		timing.timing_result.connect(_on_timing_result)
	var dreamer := get_node_or_null("PlayerRoot/Dreamer") as DreamerController
	if dreamer != null:
		timing.timing_result.connect(dreamer.handle_timing_result)
		dreamer.player_died.connect(_on_player_died)
		_sync_dreamer_game_state()


func _on_timing_result(result: TimingSystem.TimingResult) -> void:
	print("TIMING: ", TimingSystem.TimingResult.keys()[result])


func _on_player_died() -> void:
	current_state = GameState.GAME_OVER
	_sync_dreamer_game_state()


func _sync_dreamer_game_state() -> void:
	var dreamer := get_node_or_null("PlayerRoot/Dreamer") as DreamerController
	if dreamer != null:
		dreamer.set_game_state(current_state)