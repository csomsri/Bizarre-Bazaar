extends RigidBody3D
var equipped:bool = false
var player_nearby: CharacterBody3D = null
var world_parent:Node = null
var org_collision_layer:int
var org_collision_mask:int
var gunCamera: Camera3D
# Called when the node enters the scene tree for the first time.
func pickup_gun() -> void:
	if equipped or player_nearby == null:
		return
	var gun_holder = player_nearby.get_node("Camera3D/Gun")
	if gun_holder == null:
		print("Gun holder not found!")
		return

	print("BEFORE reparent: ", get_parent().name)
	freeze = true
	collision_layer = 0
	collision_mask = 0
	
	reparent(gun_holder, false)
	position = Vector3.ZERO
	rotation = Vector3.ZERO
	
	equipped = true
	print("Gun picked up!")
	print("Gun parent: ", get_parent().name)
	print("Gun position: ", position)
	print("Gun scale: ", scale)
	print("Gun visible: ", visible)
func drop_gun() -> void:

	if equipped == false:
		return
	
	reparent(world_parent, true)

	collision_layer = org_collision_layer
	collision_mask = org_collision_mask
	
	freeze = false
	
	
	
	
	equipped = false
func _ready() -> void:
	world_parent = get_parent() # Replace with function body.
	org_collision_mask = collision_mask
	org_collision_layer = collision_layer
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_nearby != null:
		pickup_gun()
	elif event.is_action_pressed("drop") and equipped:
		drop_gun()
func _on_pickup_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D: # Replace with function body.
		player_nearby = body
func _on_pickup_body_exited(body: Node3D) -> void:
	if(body == player_nearby): # Replace with function body.
		player_nearby = null # Replace with function body.
