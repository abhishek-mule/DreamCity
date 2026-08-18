class_name MenuOverlay
extends Control

var _gm: GameManager


func configure(gm: GameManager) -> void:
	_gm = gm


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	var dim := ColorRect.new()
	dim.color = Color(VisualPalette.DEEP_INDIGO, 0.95)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var panel := VBoxContainer.new()
	panel.position = Vector2(120, 480)
	panel.size = Vector2(480, 320)
	panel.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_theme_constant_override("separation", 24)
	add_child(panel)

	var title := _make_label(52, VisualPalette.PALE_STARLIGHT, 8)
	title.text = "DREAM HOP CITY"
	panel.add_child(title)

	var subtitle := _make_label(28, VisualPalette.NEON_CYAN, 5)
	subtitle.text = "tap to start"
	panel.add_child(subtitle)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_start()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_start()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		_start()


func _start() -> void:
	if _gm != null and _gm.current_state == RunState.State.MENU:
		_gm.start_run()


func _make_label(font_size: int, color: Color, outline: int) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", VisualPalette.INK)
	label.add_theme_constant_override("outline_size", outline)
	return label