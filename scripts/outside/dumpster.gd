extends MeshInstance3D

var lid_rotation: float
var lid_tween: Tween
var player_nearby: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lid_rotation = rotation.x



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if(Input.is_action_just_pressed("interact") and player_nearby):
		open_lid()

func open_lid() -> void:
	if lid_tween:
		lid_tween.kill()
	lid_tween = create_tween()
	
	lid_tween.tween_property(self, "rotation:x", lid_rotation + deg_to_rad(90), 0.5)
	lid_tween.tween_interval(2.0)
	lid_tween.tween_property(self, "rotation:x", lid_rotation, 0.5)
	
func _on_area_3d_body_entered(body: Node3D) ->void:
	if body is CharacterBody3D:
		player_nearby = true
		print("entered")
func _on_area_3d_body_exited(body: Node3D) ->void:
	if body is CharacterBody3D:
		player_nearby = false
		print("exited")
