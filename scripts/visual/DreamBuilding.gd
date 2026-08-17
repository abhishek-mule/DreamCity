class_name DreamBuilding
extends Node3D

@export var building_seed: int = 1
@export var height: float = 8.0
@export var width: float = 3.0
@export_range(0.0, 1.0) var outline_strength: float = 0.3

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = building_seed
	_build()


func _build() -> void:
	var w := width
	var h := height
	var d := width * _rng.randf_range(0.6, 1.1)

	var body_mat := _make_building_material(_body_color())
	var main := _add_box(Vector3(0, h * 0.5, 0), Vector3(w, h, d), body_mat)

	if outline_strength > 0.01:
		var outline := MeshInstance3D.new()
		outline.name = "Outline"
		var ob := BoxMesh.new()
		ob.size = Vector3(w * 1.05, h * 1.05, d * 1.05)
		outline.mesh = ob
		var om := StandardMaterial3D.new()
		om.albedo_color = Color(VisualPalette.INK, outline_strength)
		om.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		om.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		om.cull_mode = BaseMaterial3D.CULL_FRONT
		outline.material_override = om
		outline.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(outline)

	var floors := _rng.randi_range(1, 2)
	var y := h
	for i in floors:
		var bw := w * _rng.randf_range(0.45, 0.75)
		var bh := h * _rng.randf_range(0.35, 0.6)
		var bd := d * _rng.randf_range(0.45, 0.75)
		var bx := _rng.randf_range(-w * 0.25, w * 0.25)
		_add_box(Vector3(bx, y + bh * 0.5, 0), Vector3(bw, bh, bd), _make_building_material(_body_color()))
		y += bh

	var roof := MeshInstance3D.new()
	roof.name = "TiltedRoof"
	var rb := BoxMesh.new()
	rb.size = Vector3(w * 1.1, 0.12, d * 0.8)
	roof.mesh = rb
	var roof_mat := StandardMaterial3D.new()
	roof_mat.albedo_color = _body_color()
	roof_mat.roughness = 0.9
	roof.material_override = roof_mat
	roof.position = Vector3(_rng.randf_range(-0.3, 0.3), y + 0.06, 0)
	roof.rotation_degrees = Vector3(_rng.randf_range(-12.0, -4.0), 0, _rng.randf_range(-6.0, 6.0))
	add_child(roof)

	var floating := MeshInstance3D.new()
	floating.name = "FloatingFacade"
	var fb := BoxMesh.new()
	fb.size = Vector3(w * 0.5, 0.1, d * 0.5)
	floating.mesh = fb
	floating.material_override = _make_building_material(_body_color())
	floating.position = Vector3(_rng.randf_range(-0.6, 0.6), y + _rng.randf_range(1.2, 2.0), 0)
	add_child(floating)

	var windows := _rng.randi_range(1, 3)
	for i in windows:
		var window := MeshInstance3D.new()
		window.name = "Window%d" % i
		var wb := BoxMesh.new()
		wb.size = Vector3(w * 0.35, h * 0.12, 0.04)
		window.mesh = wb
		window.material_override = _make_window_material()
		window.position = Vector3(
			_rng.randf_range(-w * 0.3, w * 0.3),
			h * _rng.randf_range(0.35, 0.85),
			d * 0.5 + 0.03
		)
		window.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(window)


func _make_building_material(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.metallic = 0.0
	m.roughness = 0.9
	m.albedo_color = color
	m.emission_enabled = true
	m.emission = VisualPalette.PRUSSIAN_BLUE
	m.emission_energy_multiplier = 0.06
	return m


func _make_window_material() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.01, 0.01, 0.02)
	m.emission_enabled = true
	m.emission = VisualPalette.NEON_CYAN if _rng.randi_range(0, 1) == 0 else VisualPalette.MIDNIGHT_VIOLET
	m.emission_energy_multiplier = _rng.randf_range(0.8, 1.6)
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m


func _body_color() -> Color:
	var roll := _rng.randf()
	if roll < 0.4:
		return VisualPalette.DEEP_INDIGO
	if roll < 0.8:
		return VisualPalette.MIDNIGHT_VIOLET
	return VisualPalette.PRUSSIAN_BLUE


func _add_box(position: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var box := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	box.mesh = bm
	box.material_override = material
	box.position = position
	add_child(box)
	return box