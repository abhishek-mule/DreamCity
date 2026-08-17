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


func _on_timing_result(result: TimingSystem.TimingResult) -> void:
	print("TIMING: ", TimingSystem.TimingResult.keys()[result])