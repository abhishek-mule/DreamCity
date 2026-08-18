class_name CameraFollow
extends Camera3D

@export var follow_speed: float = 6.0
@export var lead_x: float = 2.0

var _target_x: float = 0.0
var _initial_x := 0.0
var _base_fov := 0.0
var _flow_scale := 0.0


func _ready() -> void:
	_initial_x = global_position.x
	_base_fov = fov
	_target_x = global_position.x


func reset() -> void:
	_target_x = _initial_x
	global_position.x = _initial_x
	_flow_scale = 0.0
	fov = _base_fov


func set_flow(flow: int) -> void:
	match flow:
		FlowSystem.Flow.DEEP_FLOW:
			_flow_scale = 1.0
		FlowSystem.Flow.FLOW:
			_flow_scale = 0.5
		_:
			_flow_scale = 0.0


func _process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player != null:
		_target_x = player.global_position.x + lead_x
	var t := clampf(follow_speed * delta, 0.0, 1.0)
	global_position.x = lerpf(global_position.x, _target_x, t)
	fov = lerpf(fov, _base_fov + _flow_scale * 2.0, minf(3.0 * delta, 1.0))