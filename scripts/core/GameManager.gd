class_name GameManager
extends Node3D

signal state_changed(state: int)

const RESULT_DELAY := 0.7

@onready var _timing: TimingSystem = $TimingSystem
@onready var _score: ScoreSystem = $ScoreSystem
@onready var _flow: FlowSystem = $FlowSystem
@onready var _fracture: HypnagogicFracture = $HypnagogicFracture
@onready var _dreamer: DreamerController = $PlayerRoot/Dreamer
@onready var _camera: CameraFollow = $Camera3D
@onready var _best: BestScores = $BestScores
@onready var _audio: AudioFeedback = $AudioFeedback
@onready var _hud: HudController = $UI/Hud
@onready var _feedback: FeedbackController = $UI/Feedback
@onready var _result: ResultScreen = $UI/ResultScreen
@onready var _menu: MenuOverlay = $UI/MenuOverlay
@onready var _visual_env: VisualEnvironment = $World/VisualEnvironment

var current_state: int = RunState.State.PLAYING

var _initial_platform_positions := {}
var _initial_dreamer_position := Vector3.ZERO
var _initial_camera_x := 0.0


func _ready() -> void:
	_capture_initial_state()
	_best.load_best()
	_wire_signals()
	_result.configure(self)
	_menu.configure(self)
	_restore_run()
	_apply_state(current_state)


func _capture_initial_state() -> void:
	for node in get_tree().get_nodes_in_group("platform"):
		if node is Platform:
			_initial_platform_positions[node.name] = (node as Platform).global_position
	_initial_dreamer_position = _dreamer.global_position
	_initial_camera_x = _camera.global_position.x


func _wire_signals() -> void:
	_timing.timing_result.connect(_score.on_timing_result)
	_timing.timing_result.connect(_flow.on_timing_result)
	_timing.timing_result.connect(_dreamer.handle_timing_result)
	_timing.timing_result.connect(_feedback.show_result)
	_timing.timing_perfect.connect(_audio.perfect)
	_timing.timing_good.connect(_audio.good)
	_timing.timing_miss.connect(_audio.miss)
	_timing.timing_miss.connect(_flow.on_miss)
	_score.score_changed.connect(_hud.on_score_changed)
	_score.streak_changed.connect(_hud.on_streak_changed)
	_score.run_distance_changed.connect(_hud.on_distance_changed)
	_flow.flow_changed.connect(_visual_env.on_flow_changed)
	_flow.flow_changed.connect(_camera.set_flow)
	_dreamer.player_died.connect(_on_player_died)
	_dreamer.player_died.connect(_audio.death)
	_dreamer.landed.connect(_audio.land)


func _restore_run() -> void:
	for node in get_tree().get_nodes_in_group("platform"):
		if node is Platform and _initial_platform_positions.has(node.name):
			(node as Platform).global_position = _initial_platform_positions[node.name]
	_fracture.reset()
	_timing.reset()
	_dreamer.reset_run(_initial_dreamer_position)
	_camera.reset()
	_feedback.reset()
	_visual_env.reset_run()
	_score.start_run(_initial_dreamer_position.x)
	_flow.reset()


func start_run() -> void:
	_restore_run()
	current_state = RunState.State.PLAYING
	_apply_state(current_state)


func retry() -> void:
	start_run()


func to_menu() -> void:
	current_state = RunState.State.MENU
	_apply_state(current_state)


func _on_player_died() -> void:
	if current_state != RunState.State.PLAYING:
		return
	current_state = RunState.State.GAME_OVER
	_apply_state(current_state)
	_feedback.death_feedback()
	_score.finish_run(_best)
	_delay_show_result()


func _delay_show_result() -> void:
	await get_tree().create_timer(RESULT_DELAY).timeout
	if current_state != RunState.State.GAME_OVER:
		return
	current_state = RunState.State.RESULT
	_apply_state(current_state)
	_result.show_result(_score.summary, _best)


func _apply_state(state: int) -> void:
	var playing := state == RunState.State.PLAYING
	_timing.accepting_input = playing
	_score.active = playing
	_result.visible = state == RunState.State.RESULT
	_menu.visible = state == RunState.State.MENU
	emit_signal("state_changed", state)