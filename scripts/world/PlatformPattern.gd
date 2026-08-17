class_name PlatformPattern
extends RefCounted

const STANDARD: Array[Vector3] = [
	Vector3(4.0, 0.0, 0.0),
	Vector3(4.0, 0.0, 0.0),
	Vector3(4.0, 0.0, 0.0),
]

const SHIFT_LEFT: Array[Vector3] = [
	Vector3(3.6, -0.25, -0.4),
	Vector3(3.6, -0.25, -0.4),
	Vector3(3.6, -0.25, -0.4),
]

const SHIFT_RIGHT: Array[Vector3] = [
	Vector3(4.2, 0.3, 0.4),
	Vector3(4.2, 0.3, 0.4),
	Vector3(4.2, 0.3, 0.4),
]

const STAIRS: Array[Vector3] = [
	Vector3(4.0, 0.25, 0.0),
	Vector3(4.0, 0.25, 0.0),
	Vector3(4.0, 0.25, 0.0),
]


static func get_all_patterns() -> Dictionary:
	return {
		"STANDARD": STANDARD,
		"SHIFT_LEFT": SHIFT_LEFT,
		"SHIFT_RIGHT": SHIFT_RIGHT,
		"STAIRS": STAIRS,
	}