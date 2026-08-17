class_name CameraFollow
extends Camera3D

@export var follow_speed: float = 6.0
@export var lead_x: float = 2.0

var _target_x: float = 0.0


func _ready() -> void:
	_target_x = global_position.x


func _process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player != null:
		_target_x = player.global_position.x + lead_x
	var t := clampf(follow_speed * delta, 0.0, 1.0)
	global_position.x = lerpf(global_position.x, _target_x, t)