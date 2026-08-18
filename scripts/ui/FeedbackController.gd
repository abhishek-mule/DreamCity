class_name FeedbackController
extends Control

const FEEDBACK_FONT := 76
const FEEDBACK_OUTLINE := 8

var _label: Label
var _flash: ColorRect
var _vfx: Node3D
var _tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vfx = get_node_or_null("../../World/VFX") as Node3D

	_flash = ColorRect.new()
	_flash.color = Color(VisualPalette.INK, 0.0)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_flash)

	_label = Label.new()
	_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", FEEDBACK_FONT)
	_label.add_theme_color_override("font_color", VisualPalette.PALE_STARLIGHT)
	_label.add_theme_color_override("font_outline_color", VisualPalette.INK)
	_label.add_theme_constant_override("outline_size", FEEDBACK_OUTLINE)
	_label.modulate.a = 0.0
	add_child(_label)


func show_result(result: int) -> void:
	match result:
		TimingSystem.TimingResult.PERFECT:
			_show_feedback("PERFECT", VisualPalette.NEON_CYAN, 0.12)
			_burst(VisualPalette.NEON_CYAN, 28)
		TimingSystem.TimingResult.GOOD:
			_show_feedback("GOOD", VisualPalette.PALE_STARLIGHT, 0.0)
			_burst(VisualPalette.PALE_STARLIGHT, 12)
		TimingSystem.TimingResult.MISS:
			_show_feedback("FRACTURE", VisualPalette.NEON_MAGENTA, 0.32)
			_burst(VisualPalette.NEON_MAGENTA, 20)


func death_feedback() -> void:
	_show_feedback("DREAM ENDED", VisualPalette.NEON_MAGENTA, 0.45)
	_burst(VisualPalette.NEON_MAGENTA, 30)


func reset() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
		_tween = null
	if _label != null:
		_label.text = ""
		_label.modulate.a = 0.0
		_label.scale = Vector2.ONE
	if _flash != null:
		_flash.color = Color(VisualPalette.INK, 0.0)


func _show_feedback(text: String, color: Color, flash: float) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_label.text = text
	_label.add_theme_color_override("font_color", color)
	_label.pivot_offset = _label.size * 0.5
	_label.scale = Vector2(0.5, 0.5)
	_label.modulate.a = 1.0
	_tween = create_tween()
	_tween.tween_property(_label, "scale", Vector2(1.15, 1.15), 0.1) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_label, "modulate:a", 0.0, 0.35) \
		.set_delay(0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	if flash > 0.0:
		_flash.color = Color(VisualPalette.INK, 0.0)
		var flash_tween := create_tween()
		flash_tween.tween_property(_flash, "color:a", flash, 0.06)
		flash_tween.tween_property(_flash, "color:a", 0.0, 0.3).set_delay(0.05)


func _burst(color: Color, amount: int) -> void:
	if _vfx == null:
		return
	var particles := CPUParticles3D.new()
	particles.one_shot = true
	particles.emitting = true
	particles.amount = amount
	particles.lifetime = 0.45
	particles.direction = Vector3.UP
	particles.spread = 70.0
	particles.gravity = Vector3(0, -5.0, 0)
	particles.initial_velocity_min = 0.8
	particles.initial_velocity_max = 3.2
	particles.scale_amount_min = 0.04
	particles.scale_amount_max = 0.12
	particles.color = color
	var quad := QuadMesh.new()
	quad.size = Vector2(0.18, 0.18)
	particles.mesh = quad
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 0.3
	var player := get_tree().get_first_node_in_group("player")
	if player != null:
		particles.global_position = (player as Node3D).global_position + Vector3(0, 0.8, 0)
	_vfx.add_child(particles)
	particles.finished.connect(particles.queue_free)