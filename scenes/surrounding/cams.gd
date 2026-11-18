extends Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	zoom()
	
	
func zoom() -> void:
	
	var  zoom_direction: float = 0.0
	#print("in zoom")
	
	if Input.is_action_pressed("zoom_in"):
		#print("forward")
		zoom_direction += 1.0
	elif Input.is_action_just_released("zoom_out"):
		#print("backwrd")
		zoom_direction -= 1.0
	
	global_position -= global_transform.basis.z * zoom_direction
	return
