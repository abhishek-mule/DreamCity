class_name RunState
extends RefCounted

enum State {
	MENU,
	PLAYING,
	GAME_OVER,
	RESULT
}

const STATE_NAMES := ["MENU", "PLAYING", "GAME_OVER", "RESULT"]


static func name_of(state: int) -> String:
	if state >= 0 and state < STATE_NAMES.size():
		return STATE_NAMES[state]
	return "UNKNOWN"