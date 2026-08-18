class_name AudioFeedback
extends Node

@export var debug_mode := false


func perfect() -> void:
	_debug("perfect")


func good() -> void:
	_debug("good")


func miss() -> void:
	_debug("miss")


func land() -> void:
	_debug("land")


func death() -> void:
	_debug("death")


func button() -> void:
	_debug("button")


func _debug(name: String) -> void:
	if debug_mode:
		print("AUDIO: ", name)