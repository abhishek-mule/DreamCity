class_name HudController
extends Control

const SCORE_LABEL_FONT := 64
const STREAK_LABEL_FONT := 28
const DISTANCE_LABEL_FONT := 22

var _score_label: Label
var _streak_label: Label
var _distance_label: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_score_label = _make_label(SCORE_LABEL_FONT, VisualPalette.PALE_STARLIGHT, 8)
	_score_label.text = "0"
	_score_label.position = Vector2(0, 36)
	_score_label.size = Vector2(720, 84)
	add_child(_score_label)

	_streak_label = _make_label(STREAK_LABEL_FONT, VisualPalette.NEON_CYAN, 5)
	_streak_label.position = Vector2(0, 118)
	_streak_label.size = Vector2(720, 40)
	_streak_label.visible = false
	add_child(_streak_label)

	_distance_label = _make_label(DISTANCE_LABEL_FONT, VisualPalette.NEON_MAGENTA, 5)
	_distance_label.text = "0 m"
	_distance_label.position = Vector2(560, 48)
	_distance_label.size = Vector2(140, 36)
	add_child(_distance_label)


func on_score_changed(value: int) -> void:
	_score_label.text = str(value)


func on_streak_changed(value: int) -> void:
	_streak_label.text = "STREAK %d" % value
	_streak_label.visible = value > 0


func on_distance_changed(value: float) -> void:
	_distance_label.text = "%d m" % int(value)


func _make_label(font_size: int, color: Color, outline: int) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", VisualPalette.INK)
	label.add_theme_constant_override("outline_size", outline)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label