extends MeshInstance3D

var lid_rotation: float
var lid_tween: Tween
var player_nearby: bool

# FOR: Open/Close addition
var is_open: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lid_rotation = rotation.x


func open_lid() -> void:
	if lid_tween:
		lid_tween.kill()
	
	is_open = not is_open
	
	lid_tween = create_tween()
	
	var target_rotation = lid_rotation + deg_to_rad(90) if is_open else lid_rotation
	
	lid_tween.tween_property(self, "rotation:x", target_rotation, 0.5)
	
func _on_area_3d_body_entered(body: Node3D) ->void:
	if body is CharacterBody3D:
		player_nearby = true
		print("entered")
func _on_area_3d_body_exited(body: Node3D) ->void:
	if body is CharacterBody3D:
		player_nearby = false
		print("exited")
