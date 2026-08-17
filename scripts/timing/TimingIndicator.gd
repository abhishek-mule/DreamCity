extends Control

@onready var _background: ColorRect = $TimingBar/Background
@onready var _good_zone: ColorRect = $TimingBar/GoodZone
@onready var _perfect_zone: ColorRect = $TimingBar/PerfectZone
@onready var _indicator: ColorRect = $TimingBar/Indicator

var timing_system: TimingSystem


func _ready() -> void:
	timing_system = get_node_or_null("../TimingSystem")
	if timing_system != null:
		_update_zones()


func _process(_delta: float) -> void:
	if timing_system == null:
		return
	_update_indicator(timing_system.current_position)


func _update_zones() -> void:
	var bar_width := _background.size.x
	var good_width := timing_system.good_window * 2.0 * bar_width
	var perfect_width := timing_system.perfect_window * 2.0 * bar_width
	_good_zone.size.x = good_width
	_good_zone.position.x = (bar_width - good_width) * 0.5
	_perfect_zone.size.x = perfect_width
	_perfect_zone.position.x = (bar_width - perfect_width) * 0.5


func _update_indicator(position_normalized: float) -> void:
	_indicator.position.x = position_normalized * _background.size.x - _indicator.size.x * 0.5