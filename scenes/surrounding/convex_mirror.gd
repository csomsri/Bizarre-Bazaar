extends Node3D

@onready var viewport: SubViewport = $SubViewport
@onready var mirror_mesh: MeshInstance3D = $Mirror



#get shadeeer that i found online

func _ready() -> void:
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://scenes/surrounding/convex_mirror.gdshader")
	mat.set_shader_parameter("mirror_txt", viewport.get_texture())
	mirror_mesh.material_override = mat
	
	
	
	#var mat := StandardMaterial3D.new()
	#mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	#mat.albedo_texture = viewport.get_texture()
	#mirror_mesh.material_override = mat

#for subveiw port since even tho its a child node it doesnt have its position be based off the parent node positions
	var cam: Camera3D = $SubViewport/mirror_reflection
	cam.global_transform = global_transform.rotated_local(Vector3.UP, PI)
	cam.global_position += global_transform.basis.z.normalized() * 0.1

	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS



func _process(delta: float) -> void:
	pass
