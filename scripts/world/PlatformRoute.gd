extends Node3D

@export var debug_mode := false


func _ready() -> void:
	if not debug_mode:
		return
	var player := get_node_or_null("../PlayerRoot/Dreamer") as CharacterBody3D
	var run_speed := 4.0
	var jump_velocity := 8.0
	var gravity := 22.0
	if player != null:
		run_speed = player.run_speed
		jump_velocity = player.good_jump_velocity
		gravity = player.gravity
	var platforms := get_children().filter(func(child): return child is Platform)
	for i in platforms.size():
		var current := platforms[i] as Platform
		print("Platform %d: position=%s top_y=%.2f width=%.2f" % [
			i + 1, current.global_position, current.get_platform_top_y(), current.get_platform_width()
		])
		if i == 0:
			continue
		var previous := platforms[i - 1] as Platform
		var gap_x := (current.global_position.x - current.get_platform_width() * 0.5) - (previous.global_position.x + previous.get_platform_width() * 0.5)
		var gap_y := current.get_platform_top_y() - previous.get_platform_top_y()
		var reachable := PlatformReachability.is_reachable(gap_x, gap_y, run_speed, jump_velocity, gravity)
		print("  %d -> %d: horizontal_gap=%.2f vertical_diff=%.2f reachable=%s" % [i, i + 1, gap_x, gap_y, reachable])