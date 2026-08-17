class_name Platform
extends AnimatableBody3D

@export var platform_width: float = 2.2
@export var platform_depth: float = 1.5
@export var platform_height: float = 0.4

@onready var _collision_shape: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	add_to_group("platform")
	var shape := BoxShape3D.new()
	shape.size = Vector3(platform_width, platform_height, platform_depth)
	_collision_shape.shape = shape


func get_platform_top_y() -> float:
	return global_position.y + platform_height * 0.5


func get_landing_position() -> Vector3:
	return Vector3(global_position.x, get_platform_top_y(), global_position.z)


func get_platform_width() -> float:
	return platform_width