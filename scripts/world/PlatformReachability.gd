class_name PlatformReachability
extends RefCounted


# Estimates whether a platform is theoretically reachable from a takeoff point
# with the given player physics.
#
# Assumptions:
# - Horizontal speed stays constant at `run_speed` for the whole jump.
# - `horizontal_distance` is measured edge-to-edge from takeoff to target.
# - `vertical_difference` is measured surface-to-surface; > 0 means the
#   target surface is higher than the takeoff surface.
# - The player can land on the target if, at the moment they have covered
#   `horizontal_distance`, their height is at least `vertical_difference`
#   above the takeoff surface.
# - This is a theoretical ceiling: it ignores reaction time, input timing,
#   and a margin for landing. The player must still jump near the edge.
static func is_reachable(
	horizontal_distance: float,
	vertical_difference: float,
	run_speed: float,
	jump_velocity: float,
	gravity: float
) -> bool:
	var max_height := (jump_velocity * jump_velocity) / (2.0 * gravity)
	if vertical_difference > max_height:
		return false
	var time_to_gap := horizontal_distance / run_speed
	var height_at_gap := jump_velocity * time_to_gap - 0.5 * gravity * time_to_gap * time_to_gap
	return height_at_gap >= vertical_difference