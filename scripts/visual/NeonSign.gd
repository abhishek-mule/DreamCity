class_name NeonSign
extends Node3D

@export var sign_text := "~"
@export var emission_color: Color = VisualPalette.NEON_MAGENTA
@export var intensity: float = 1.6

const GLYPH_SETS := [
	[[Vector3(0, 0, 0)], 0.5],
	[[Vector3(-0.18, 0, 0), Vector3(0.18, 0, 0)], 0.28],
	[[Vector3(0, 0, 0), Vector3(0, 0.2, 0), Vector3(0, -0.2, 0)], 0.24],
	[[Vector3(-0.16, 0.16, 0), Vector3(0.16, 0.16, 0), Vector3(-0.16, -0.16, 0), Vector3(0.16, -0.16, 0)], 0.2],
]


func _ready() -> void:
	_build()


func _build() -> void:
	var board := MeshInstance3D.new()
	board.name = "Board"
	var bb := BoxMesh.new()
	bb.size = Vector3(1.1, 0.6, 0.06)
	board.mesh = bb
	var board_mat := StandardMaterial3D.new()
	board_mat.albedo_color = Color(0.03, 0.03, 0.06)
	board_mat.roughness = 0.6
	board.material_override = board_mat
	board.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(board)

	var glyph_set: Array = GLYPH_SETS[absi(hash(sign_text)) % GLYPH_SETS.size()]
	var segments: Array = glyph_set[0]
	var segment_size: float = glyph_set[1]
	for i in segments.size():
		var seg := MeshInstance3D.new()
		seg.name = "Glyph%d" % i
		var sb := BoxMesh.new()
		sb.size = Vector3(segment_size, segment_size, 0.05)
		seg.mesh = sb
		seg.material_override = _make_neon_material()
		seg.position = segments[i]
		seg.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(seg)

	var glow := MeshInstance3D.new()
	glow.name = "Glow"
	var gp := PlaneMesh.new()
	gp.size = Vector2(2.2, 1.4)
	glow.mesh = gp
	var glow_mat := StandardMaterial3D.new()
	var grad := GradientTexture2D.new()
	var gradient := Gradient.new()
	gradient.set_color(0, Color(emission_color, 0.0))
	gradient.set_color(1, Color(emission_color, 0.55))
	grad.gradient = gradient
	grad.fill = GradientTexture2D.FILL_RADIAL
	grad.fill_from = Vector2(0.5, 0.5)
	grad.fill_to = Vector2(0.5, 0.5)
	grad.width = 128
	grad.height = 128
	glow_mat.albedo_texture = grad
	glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	glow.material_override = glow_mat
	glow.position = Vector3(0, 0, 0.05)
	glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(glow)

	var pole := MeshInstance3D.new()
	pole.name = "Pole"
	var pb := BoxMesh.new()
	pb.size = Vector3(0.08, 0.9, 0.08)
	pole.mesh = pb
	var pole_mat := StandardMaterial3D.new()
	pole_mat.albedo_color = VisualPalette.INK
	pole_mat.roughness = 0.9
	pole.material_override = pole_mat
	pole.position = Vector3(0, -0.45, -0.2)
	pole.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(pole)


func _make_neon_material() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.01, 0.01, 0.02)
	m.emission_enabled = true
	m.emission = emission_color
	m.emission_energy_multiplier = intensity
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m