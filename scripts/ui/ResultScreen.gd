class_name ResultScreen
extends Control

const PANEL_SIZE := Vector2(480, 620)
const PANEL_POSITION := Vector2(120, 340)

var _gm: GameManager
var _score_value: Label
var _best_label: Label
var _distance_value: Label
var _streak_value: Label
var _retry_button: Button


func configure(gm: GameManager) -> void:
	_gm = gm


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	var dim := ColorRect.new()
	dim.color = Color(VisualPalette.DEEP_INDIGO, 0.88)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var panel := VBoxContainer.new()
	panel.position = PANEL_POSITION
	panel.size = PANEL_SIZE
	panel.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_theme_constant_override("separation", 16)
	add_child(panel)

	var title := _make_label(44, VisualPalette.PALE_STARLIGHT, 6)
	title.text = "DREAM ENDED"
	panel.add_child(title)

	var score_caption := _make_label(22, VisualPalette.NEON_CYAN, 4)
	score_caption.text = "SCORE"
	panel.add_child(score_caption)

	_score_value = _make_label(72, VisualPalette.NEON_CYAN, 8)
	panel.add_child(_score_value)

	_best_label = _make_label(22, VisualPalette.PALE_STARLIGHT, 4)
	panel.add_child(_best_label)

	_distance_value = _make_label(30, VisualPalette.NEON_MAGENTA, 5)
	panel.add_child(_distance_value)

	_streak_value = _make_label(30, VisualPalette.NEON_CYAN, 5)
	panel.add_child(_streak_value)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	panel.add_child(spacer)

	_retry_button = _make_button("RETRY", VisualPalette.NEON_CYAN)
	_retry_button.pressed.connect(_on_retry)
	panel.add_child(_retry_button)

	var menu_button := _make_button("MENU", VisualPalette.MIDNIGHT_VIOLET)
	menu_button.pressed.connect(_on_menu)
	panel.add_child(menu_button)


func show_result(summary: Dictionary, best: BestScores) -> void:
	_score_value.text = str(summary["score"])
	_best_label.text = "BEST  %d  |  %d m" % [best.best_score, int(best.best_distance)]
	_distance_value.text = "DISTANCE  %d m" % int(summary["distance"])
	_streak_value.text = "BEST STREAK  %d" % summary["best_streak"]
	visible = true
	_retry_button.grab_focus()


func _make_label(font_size: int, color: Color, outline: int) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", VisualPalette.INK)
	label.add_theme_constant_override("outline_size", outline)
	return label


func _make_button(text: String, color: Color) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(260, 64)
	button.add_theme_font_size_override("font_size", 26)
	button.add_theme_color_override("font_color", VisualPalette.INK)
	button.add_theme_color_override("font_hover_color", VisualPalette.INK)
	button.add_theme_color_override("font_pressed_color", VisualPalette.INK)
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.corner_radius_top_left = 10
	normal.corner_radius_top_right = 10
	normal.corner_radius_bottom_left = 10
	normal.corner_radius_bottom_right = 10
	button.add_theme_stylebox_override("normal", normal)
	var pressed := normal.duplicate()
	pressed.bg_color = color.darkened(0.25)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("hover", normal)
	return button


func _on_retry() -> void:
	if _gm != null:
		_gm.retry()


func _on_menu() -> void:
	if _gm != null:
		_gm.to_menu()