extends CharacterBody3D

@export var mouse_sensitivity = 0.004

@onready var camera_move: Camera3D = $Camera3D
@onready var gun_holder: Marker3D = $Casual_2/CharacterArmature/Camera3D/GunHolder

@onready var animation_player: AnimationPlayer = $Casual_2/AnimationPlayer

#for camera system
@onready var body_mesh: Node3D = $Casual_2
@onready var view_camera: Camera3D = $Camera3D
var controls_enabled := true




var equipped_gun: RigidBody3D = null

const SPEED = 20.0
const JUMP_VELOCITY = 4.5

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	


func _unhandled_input(event: InputEvent) -> void:
	
	if not controls_enabled:
		return
	
	
	
	if event is InputEventMouseMotion:
		if(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
			rotate_y(-event.relative.x * mouse_sensitivity)
			camera_move.rotate_x(event.relative.y * mouse_sensitivity)
			
			camera_move.rotation.x = clampf(camera_move.rotation.x,deg_to_rad(-64),deg_to_rad(56))
			
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
func _physics_process(delta: float) -> void:
	
	if not controls_enabled:
		return
	# Add the gravity.
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("interact"):
		animation_player.play("Interact")

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("right", "left", "backward", "forward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#
	if(is_on_floor()):
		if animation_player.current_animation != "Interact" or not animation_player.is_playing():
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
	
	#if Engine.get_physics_frames() % 60 == 0:
		#print("On floor: ", is_on_floor())
		#print("Player Y: ", global_position.y)
		

#unbind the player movement and sets body invisible for when they enter cams
func set_controls_enabled( enabled: bool) ->void:
	controls_enabled = enabled
	velocity = Vector3.ZERO
	
func set_body_visible( can_see: bool) -> void:
	body_mesh.visible = can_see
