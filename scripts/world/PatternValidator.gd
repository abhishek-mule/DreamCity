class_name PatternValidator
extends RefCounted

# Validates a sequence of center-to-center offsets (one per platform transition).
# Each offset must carry the next platform forward of the previous one by a real
# edge gap, stay laterally within the platform's landing width, and be reachable
# by the player's jump model.
static func validate_offsets(
	offsets: Array[Vector3],
	platform_width: float,
	platform_depth: float,
	run_speed: float,
	jump_velocity: float,
	gravity: float
) -> bool:
	if offsets.is_empty():
		return false
	for offset in offsets:
		var edge_gap := offset.x - platform_width
		if edge_gap <= 0.0:
			return false
		if absf(offset.z) >= platform_depth * 0.5:
			return false
		if not PlatformReachability.is_reachable(edge_gap, offset.y, run_speed, jump_velocity, gravity):
			return false
	return true