class_name VisualEnvironment
extends Node3D

const BG_PARALLAX := 0.1
const MG_PARALLAX := 0.3

const LAYER_MIN_X := -140.0
const LAYER_MAX_X := 220.0
const BUILDING_STEP := 28.0
const CLOUD_STEP := 22.0

@export var build_background := true
@export var build_midground := true

var _environment: WorldEnvironment
var _background: Node3D
var _midground: Node3D

var _paper_texture: NoiseTexture2D

var _env: Environment
var _env_glow_base := 0.6
var _env_ambient_base := 0.28
var _trail: CPUParticles3D
var _ambient: CPUParticles3D
var _rim_material: StandardMaterial3D


func _ready() -> void:
	_environment = get_node_or_null("../../WorldEnvironment") as WorldEnvironment
	if _environment != null:
		_setup_environment(_environment.environment)
	_background = get_node_or_null("../Background")
	_midground = get_node_or_null("../Midground")
	if build_background and _background != null:
		_build_background()
	if build_midground and _midground != null:
		_build_midground()
	_setup_trail()
	_setup_ambient()
	call_deferred("_assign_platform_variants")


func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var camera := get_viewport().get_camera_3d()
	var cam_x := camera.global_position.x if camera != null else 0.0
	var player_x: float = player.global_position.x
	if _background != null:
		_background.position.x = cam_x - BG_PARALLAX * player_x
	if _midground != null:
		_midground.position.x = cam_x - MG_PARALLAX * player_x
	if _ambient != null and camera != null:
		_ambient.global_position = (camera as Camera3D).global_position + Vector3(0, 0, 2)


func on_flow_changed(flow: int) -> void:
	_apply_flow(flow)


func reset_run() -> void:
	_apply_flow(FlowSystem.Flow.CALM)


func _apply_flow(flow: int) -> void:
	if _trail != null:
		_trail.emitting = flow == FlowSystem.Flow.FLOW or flow == FlowSystem.Flow.DEEP_FLOW
		_trail.amount = 120 if flow == FlowSystem.Flow.DEEP_FLOW else (60 if flow == FlowSystem.Flow.FLOW else 0)
	if _ambient != null:
		_ambient.emitting = flow == FlowSystem.Flow.DEEP_FLOW
	var glow := _env_glow_base
	var ambient := _env_ambient_base
	match flow:
		FlowSystem.Flow.FLOW:
			glow = _env_glow_base + 0.15
			ambient = _env_ambient_base + 0.06
		FlowSystem.Flow.DEEP_FLOW:
			glow = _env_glow_base + 0.3
			ambient = _env_ambient_base + 0.1
		FlowSystem.Flow.FRACTURED:
			glow = _env_glow_base + 0.25
	if _env != null:
		_env.glow_intensity = glow
		_env.ambient_light_energy = ambient
	if _rim_material == null:
		_find_rim_material()
	if _rim_material != null:
		_rim_material.emission_energy_multiplier = 1.2 + (0.8 if flow == FlowSystem.Flow.DEEP_FLOW else 0.0)
	for node in get_tree().get_nodes_in_group("platform"):
		var visual := node.get_node_or_null("Visual") as PlatformVisual
		if visual != null:
			visual.set_flow_level(flow)


func _setup_trail() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var visual := (player as Node3D).get_node_or_null("Visual") as Node3D
	if visual == null:
		return
	_trail = CPUParticles3D.new()
	_trail.name = "InkTrail"
	_trail.local_coords = false
	_trail.emitting = false
	_trail.amount = 60
	_trail.lifetime = 0.55
	_trail.direction = Vector3(-1, 0.1, 0)
	_trail.spread = 30.0
	_trail.gravity = Vector3(0, -3.0, 0)
	_trail.initial_velocity_min = 0.2
	_trail.initial_velocity_max = 1.0
	_trail.scale_amount_min = 0.06
	_trail.scale_amount_max = 0.16
	_trail.color = Color(VisualPalette.NEON_CYAN, 0.5)
	var quad := QuadMesh.new()
	quad.size = Vector2(0.2, 0.2)
	_trail.mesh = quad
	_trail.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	_trail.emission_sphere_radius = 0.2
	_trail.position = Vector3(0, 0.7, 0)
	visual.add_child(_trail)


func _setup_ambient() -> void:
	var vfx := get_node_or_null("../VFX") as Node3D
	if vfx == null:
		return
	_ambient = CPUParticles3D.new()
	_ambient.name = "FlowAmbient"
	_ambient.local_coords = false
	_ambient.emitting = false
	_ambient.amount = 60
	_ambient.lifetime = 2.4
	_ambient.direction = Vector3(0, -0.3, 0)
	_ambient.spread = 40.0
	_ambient.gravity = Vector3.ZERO
	_ambient.initial_velocity_min = 0.1
	_ambient.initial_velocity_max = 0.5
	_ambient.scale_amount_min = 0.04
	_ambient.scale_amount_max = 0.1
	_ambient.color = Color(VisualPalette.NEON_CYAN, 0.4)
	var quad := QuadMesh.new()
	quad.size = Vector2(0.14, 0.14)
	_ambient.mesh = quad
	_ambient.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	_ambient.emission_box_extents = Vector3(8.0, 6.0, 1.0)
	vfx.add_child(_ambient)


func _find_rim_material() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var rim := (player as Node3D).get_node_or_null("Visual/RimShell") as MeshInstance3D
	if rim != null:
		_rim_material = rim.material_override as StandardMaterial3D


func _assign_platform_variants() -> void:
	var platforms: Array[Platform] = []
	for node in get_tree().get_nodes_in_group("platform"):
		if node is Platform:
			platforms.append(node as Platform)
	platforms.sort_custom(func(a: Platform, b: Platform) -> bool: return a.global_position.x < b.global_position.x)
	for i in platforms.size():
		var visual := (platforms[i].get_node_or_null("Visual") as PlatformVisual)
		if visual == null:
			continue
		var cycle := i % 4
		match cycle:
			1:
				visual.variant = PlatformVisual.VisualVariant.B
			2:
				visual.variant = PlatformVisual.VisualVariant.C
				visual.accent_color = VisualPalette.NEON_MAGENTA
			3:
				visual.accent_color = VisualPalette.NEON_CYAN
		visual.apply_variant()


func _setup_environment(env: Environment) -> void:
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = VisualPalette.DEEP_INDIGO
	sky_mat.sky_horizon_color = VisualPalette.MIDNIGHT_VIOLET
	sky_mat.sky_curve = 9.0
	sky_mat.sky_energy_multiplier = 0.6
	sky_mat.ground_bottom_color = VisualPalette.INK
	sky_mat.ground_horizon_color = VisualPalette.MIDNIGHT_VIOLET
	sky_mat.ground_curve = 4.0
	sky_mat.ground_energy_multiplier = 0.4
	sky.sky_material = sky_mat
	env.background_mode = Environment.BG_SKY
	env.sky = sky

	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = VisualPalette.MIDNIGHT_VIOLET
	env.ambient_light_energy = 0.28

	env.fog_enabled = true
	env.fog_light_color = Color(0.06, 0.05, 0.16)
	env.fog_light_energy = 1.0
	env.fog_density = 0.002
	env.fog_sky_affect = 0.35
	env.fog_aerial_perspective = 0.3

	env.glow_enabled = true
	env.glow_normalized = true
	env.glow_intensity = 0.6
	env.glow_strength = 0.8
	env.glow_bloom = 0.05
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	env.glow_hdr_threshold = 1.0
	for level in range(1, 8):
		env.set("glow_levels/%d" % level, level == 3 or level == 5)

	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	_env = env
	_env_glow_base = env.glow_intensity
	_env_ambient_base = env.ambient_light_energy


func _build_background() -> void:
	_add_moon(Vector3(-8, 13, -90))
	_add_paper_wash(Vector3(0, 2, -85))

	var x := LAYER_MIN_X
	while x <= LAYER_MAX_X:
		var cloud := _make_cloud()
		cloud.position = Vector3(x + randf_range(-8.0, 8.0), randf_range(6.0, 14.0), randf_range(-75.0, -45.0))
		cloud.scale = Vector3(randf_range(0.7, 1.6), 0.4, 1.0)
		_background.add_child(cloud)
		var building := _make_distant_building(x + randf_range(-10.0, 10.0))
		_background.add_child(building)
		x += BUILDING_STEP


func _build_midground() -> void:
	var x := LAYER_MIN_X
	while x <= LAYER_MAX_X:
		var building := _make_midground_building(x + randf_range(-9.0, 9.0))
		_midground.add_child(building)
		var wash := _make_wash()
		wash.position = Vector3(x + randf_range(-14.0, 14.0), randf_range(3.0, 9.0), randf_range(-30.0, -16.0))
		_midground.add_child(wash)
		var float_box := _make_floating_platform(x + randf_range(-12.0, 12.0))
		_midground.add_child(float_box)
		x += BUILDING_STEP


func _make_distant_building(x: float) -> Node3D:
	var building := DreamBuilding.new()
	building.building_seed = int(x * 7.13)
	building.height = randf_range(5.0, 12.0)
	building.width = randf_range(2.5, 4.5)
	building.outline_strength = 0.1
	building.position = Vector3(x, 0, randf_range(-55.0, -38.0))
	building.scale = Vector3.ONE * randf_range(0.55, 0.9)
	return building


func _make_midground_building(x: float) -> Node3D:
	var building := DreamBuilding.new()
	building.building_seed = int(x * 3.31)
	building.height = randf_range(7.0, 15.0)
	building.width = randf_range(2.0, 4.0)
	building.outline_strength = 0.3
	building.position = Vector3(x, 0, randf_range(-22.0, -10.0))
	building.scale = Vector3.ONE * randf_range(0.9, 1.4)
	return building


func _make_floating_platform(x: float) -> Node3D:
	var holder := Node3D.new()
	var box := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(2.0, 0.25, 1.4)
	box.mesh = bm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = VisualPalette.PRUSSIAN_BLUE
	mat.roughness = 0.85
	mat.emission_enabled = true
	mat.emission = VisualPalette.NEON_CYAN
	mat.emission_energy_multiplier = 0.2
	box.material_override = mat
	holder.add_child(box)
	holder.position = Vector3(x, randf_range(4.0, 10.0), randf_range(-16.0, -9.0))
	var sign := NeonSign.new()
	sign.emission_color = VisualPalette.NEON_CYAN if randi() % 2 == 0 else VisualPalette.NEON_MAGENTA
	sign.intensity = randf_range(1.2, 2.0)
	sign.position = Vector3(0, -0.4, 0)
	sign.scale = Vector3.ONE * 0.5
	holder.add_child(sign)
	return holder


func _make_cloud() -> Node3D:
	var cloud := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(6.0, 0.9, 1.2)
	cloud.mesh = bm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(VisualPalette.MIDNIGHT_VIOLET, randf_range(0.06, 0.14))
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	cloud.material_override = mat
	cloud.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return cloud


func _make_wash() -> Node3D:
	var wash := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(randf_range(8.0, 16.0), randf_range(6.0, 10.0))
	wash.mesh = pm
	var mat := StandardMaterial3D.new()
	var wash_color := VisualPalette.PRUSSIAN_BLUE if randi() % 2 == 0 else VisualPalette.MIDNIGHT_VIOLET
	mat.albedo_color = Color(wash_color, randf_range(0.08, 0.16))
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	wash.material_override = mat
	wash.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	wash.rotation_degrees = Vector3(randf_range(-14.0, 14.0), 0, randf_range(-18.0, 18.0))
	return wash


func _add_moon(position: Vector3) -> void:
	var moon := MeshInstance3D.new()
	moon.name = "Moon"
	var pm := PlaneMesh.new()
	pm.size = Vector2(6.0, 6.0)
	moon.mesh = pm
	var mat := StandardMaterial3D.new()
	var grad := GradientTexture2D.new()
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.85, 0.92, 1.0, 0.0))
	gradient.set_color(1, Color(0.9, 0.95, 1.0, 1.0))
	grad.gradient = gradient
	grad.fill = GradientTexture2D.FILL_RADIAL
	grad.fill_from = Vector2(0.5, 0.5)
	grad.fill_to = Vector2(0.5, 1.0)
	grad.width = 128
	grad.height = 128
	mat.albedo_texture = grad
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	moon.material_override = mat
	moon.position = position
	moon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_background.add_child(moon)


func _add_paper_wash(position: Vector3) -> void:
	_paper_texture = NoiseTexture2D.new()
	var noise := FastNoiseLite.new()
	noise.seed = 12345
	noise.frequency = 0.02
	_paper_texture.noise = noise
	_paper_texture.width = 256
	_paper_texture.height = 256
	var paper := MeshInstance3D.new()
	paper.name = "PaperWash"
	var pm := PlaneMesh.new()
	pm.size = Vector2(320.0, 40.0)
	paper.mesh = pm
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = _paper_texture
	mat.albedo_color = Color(1.0, 1.0, 1.0, 0.05)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	paper.material_override = mat
	paper.position = position
	paper.rotation_degrees = Vector3(0, 0, 0)
	paper.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_background.add_child(paper)