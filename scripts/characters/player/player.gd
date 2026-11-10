extends CharacterBody3D

@export var mouse_sensitivity = 0.004

@onready var camera_move: Camera3D = get_node_or_null("Casual_3/CharacterArmature/Camera3D")
@onready var animation_player: AnimationPlayer = $Casual_3/AnimationPlayer
const SPEED = 20.0
const JUMP_VELOCITY = 4.5

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	print("Player children:")
	for child in get_children():
		print(child.name)
	print("Camera found: ", camera_move)
	print("Player path: ", get_path())
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			rotate_y(-event.relative.x * mouse_sensitivity)
			camera_move.rotate_x(event.relative.y * mouse_sensitivity)
			
			camera_move.rotation.x = clampf(camera_move.rotation.x,deg_to_rad(-64),deg_to_rad(56))
			
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
func _physics_process(delta: float) -> void:
	# Add the gravity.
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("right", "left", "backward", "forward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if(is_on_floor()):
		if input_dir.length() > 0:
			animation_player.play("Walk")
		else:
			animation_player.play("Idle")	
			
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	if Engine.get_physics_frames() % 60 == 0:
		print("On floor: ", is_on_floor())
		print("Player Y: ", global_position.y)
