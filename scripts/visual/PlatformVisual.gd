class_name PlatformVisual
extends Node3D

enum VisualVariant { A, B, C }

const OUTLINE_SCALE := 1.06
const BASE_EMISSION_MULTIPLIER := 0.18
const PULSE_EMISSION_MULTIPLIER := 0.9

@export var variant: VisualVariant = VisualVariant.A
@export var ink_outline := true
@export var accent_color: Color = VisualPalette.NEON_CYAN

var body_mesh: MeshInstance3D
var outline_mesh: MeshInstance3D
var accent: Node3D

var _body_material: StandardMaterial3D
var _pulse_tween: Tween
var _pulsing := false
var _flow_boost := 0.0


func _ready() -> void:
	_build()


func set_flow_level(flow: int) -> void:
	match flow:
		FlowSystem.Flow.FLOW:
			_flow_boost = 0.06
		FlowSystem.Flow.DEEP_FLOW:
			_flow_boost = 0.12
		_:
			_flow_boost = 0.0
	if _body_material != null and (_pulse_tween == null or not _pulse_tween.is_valid()):
		_body_material.emission_energy_multiplier = BASE_EMISSION_MULTIPLIER + _flow_boost


func apply_variant() -> void:
	_build()


func _process(_delta: float) -> void:
	var folding := absf(rotation_degrees.z) > 0.5
	if folding and not _pulsing:
		_pulsing = true
		_trigger_pulse()
	elif not folding and _pulsing:
		_pulsing = false
		_restore()


func _build() -> void:
	_clear_visual()
	var platform := get_parent() as Platform
	var w := platform.platform_width
	var h := platform.platform_height
	var d := platform.platform_depth

	body_mesh = MeshInstance3D.new()
	body_mesh.name = "Body"
	var box := BoxMesh.new()
	box.size = Vector3(w, h, d)
	body_mesh.mesh = box
	_body_material = _make_body_material()
	body_mesh.material_override = _body_material
	add_child(body_mesh)

	if ink_outline:
		outline_mesh = MeshInstance3D.new()
		outline_mesh.name = "Outline"
		var outline_box := BoxMesh.new()
		outline_box.size = Vector3(w * OUTLINE_SCALE, h * OUTLINE_SCALE, d * OUTLINE_SCALE)
		outline_mesh.mesh = outline_box
		var outline_mat := StandardMaterial3D.new()
		outline_mat.albedo_color = VisualPalette.INK
		outline_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		outline_mat.cull_mode = BaseMaterial3D.CULL_FRONT
		outline_mesh.material_override = outline_mat
		outline_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(outline_mesh)

	accent = Node3D.new()
	accent.name = "Accent"
	add_child(accent)
	_build_variant(w, h, d)


func _clear_visual() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	body_mesh = null
	outline_mesh = null
	accent = null
	_body_material = null
	if _pulse_tween != null and _pulse_tween.is_valid():
		_pulse_tween.kill()
		_pulse_tween = null


func _make_body_material() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.metallic = 0.05
	m.roughness = 0.85
	m.albedo_color = _body_color()
	m.emission_enabled = true
	m.emission = accent_color
	m.emission_energy_multiplier = BASE_EMISSION_MULTIPLIER
	return m


func _body_color() -> Color:
	match variant:
		VisualVariant.A:
			return Color(0.09, 0.07, 0.16)
		VisualVariant.B:
			return Color(0.08, 0.11, 0.22)
		VisualVariant.C:
			return Color(0.06, 0.05, 0.12)
	return VisualPalette.DEEP_INDIGO


func _build_variant(w: float, h: float, d: float) -> void:
	match variant:
		VisualVariant.B:
			_build_folded_roof(w, h, d)
		VisualVariant.C:
			_build_magenta_sign(w, h, d)
		_:
			_build_neon_strip(w, h, d)


func _make_neon_material(color: Color, energy: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.01, 0.01, 0.02)
	m.metallic = 0.0
	m.roughness = 0.4
	m.emission_enabled = true
	m.emission = color
	m.emission_energy_multiplier = energy
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m


func _build_neon_strip(w: float, h: float, d: float) -> void:
	var sign := MeshInstance3D.new()
	sign.name = "NeonStrip"
	var sign_box := BoxMesh.new()
	sign_box.size = Vector3(w * 0.5, 0.12, 0.05)
	sign.mesh = sign_box
	sign.material_override = _make_neon_material(accent_color, 2.2)
	sign.position = Vector3(0, h * 0.5 + 0.06, -d * 0.5 - 0.03)
	sign.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	accent.add_child(sign)


func _build_folded_roof(w: float, h: float, d: float) -> void:
	var fold := MeshInstance3D.new()
	fold.name = "FoldedRoof"
	var fold_box := BoxMesh.new()
	fold_box.size = Vector3(w, 0.06, d)
	fold.mesh = fold_box
	var fold_mat := StandardMaterial3D.new()
	fold_mat.albedo_color = Color(0.14, 0.1, 0.22)
	fold_mat.roughness = 0.7
	fold.material_override = fold_mat
	fold.position = Vector3(0, h * 0.5 - 0.04, 0)
	fold.rotation_degrees = Vector3(9.0, 0, 0)
	accent.add_child(fold)

	var edge := MeshInstance3D.new()
	edge.name = "CyanEdge"
	var edge_box := BoxMesh.new()
	edge_box.size = Vector3(w, 0.05, 0.05)
	edge.mesh = edge_box
	edge.material_override = _make_neon_material(accent_color, 2.0)
	edge.position = Vector3(0, h * 0.5 + 0.02, -d * 0.5 + 0.03)
	edge.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	accent.add_child(edge)


func _build_magenta_sign(w: float, h: float, d: float) -> void:
	var sign := MeshInstance3D.new()
	sign.name = "MagentaSign"
	var sign_box := BoxMesh.new()
	sign_box.size = Vector3(w * 0.35, 0.18, 0.05)
	sign.mesh = sign_box
	sign.material_override = _make_neon_material(accent_color, 2.4)
	sign.position = Vector3(0, h * 0.3, -d * 0.5 - 0.03)
	sign.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	accent.add_child(sign)

	var lamp := MeshInstance3D.new()
	lamp.name = "RoofLamp"
	var lamp_box := BoxMesh.new()
	lamp_box.size = Vector3(0.3, 0.08, 0.3)
	lamp.mesh = lamp_box
	lamp.material_override = _make_neon_material(accent_color, 1.8)
	lamp.position = Vector3(w * 0.25, h * 0.5 + 0.05, 0)
	lamp.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	accent.add_child(lamp)


func _trigger_pulse() -> void:
	if _pulse_tween != null and _pulse_tween.is_valid():
		_pulse_tween.kill()
	_pulse_tween = create_tween().set_parallel(true)
	_pulse_tween.tween_property(_body_material, "emission_energy_multiplier", PULSE_EMISSION_MULTIPLIER, 0.12) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_pulse_tween.tween_property(self, "scale", Vector3.ONE * 1.03, 0.12) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _restore() -> void:
	if _pulse_tween != null and _pulse_tween.is_valid():
		_pulse_tween.kill()
	_pulse_tween = create_tween().set_parallel(true)
	_pulse_tween.tween_property(_body_material, "emission_energy_multiplier", BASE_EMISSION_MULTIPLIER + _flow_boost, 0.35) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.tween_property(self, "scale", Vector3.ONE, 0.35) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)