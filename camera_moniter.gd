class_name Cam_moniter
extends Area3D

@export var cameras: Array[Camera3D]= []
@export var max_pan := 45.0		#max cam movement
@export var pan_speed := 30.0	#cam move ment speed

var _player: Node = null
var _active := false
var _index := 0
var _base_y: Array[float] = []	#init cam pos
var _pan_offset: Array[float] = [] #savinig movement



func _ready() -> void:
	body_entered.connect(_on_body_enter)
	body_exited.connect(_on_body_exit)
	for cam in cameras:
		_base_y.append(cam.rotation.y)
		_pan_offset.append(0.0)
		

#player is within interact range of monniter 
func _on_body_enter(body:Node) -> void:
	if body.is_in_group("player"):
		_player=body
		
func _on_body_exit(body: Node)-> void:
	if body == _player and not _active:
		_player = null
		
#reads inputs and does thier function within cams only
func _unhandled_input(event: InputEvent) -> void:
	
	#interact with moniter to enter/exit
	if event.is_action_pressed("interact"):
		

		if _active:
			_exit_moniter()
			get_viewport().set_input_as_handled()
		elif _player !=null:
			_enter_moniter()
			get_viewport().set_input_as_handled()
	
	if not _active:
		return
		
	#push w/s to inc/dec current cam we are on
	if event.is_action_pressed("forward"):
		_swap_cam(_index+1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(("backward")):
		_swap_cam(_index -1)
		get_viewport().set_input_as_handled()
		
			
func _process(delta: float) -> void:
	if not _active:
		return
	
	# a/d move cam left/right
	var cam_move := Input.get_axis("left", "right")
	
	if cam_move == 0.0:
		return
	
	#pan the camer and save it
	var offset := clampf(_pan_offset[_index] + cam_move* pan_speed *delta,
						-max_pan,max_pan)
	_pan_offset[_index] = offset
	
	cameras[_index].rotation.y = _base_y[_index] - deg_to_rad((offset))
	

#freeze player, hides body, puts pov to camera
func _enter_moniter() -> void :
	_active = true
	_player.set_controls_enabled(false)
	_player.set_body_visible(false)
	_swap_cam(_index)

#rebinds movement adn makes body visible 
func _exit_moniter() -> void:
	_active = false
	_player.set_body_visible(true)
	_player.set_controls_enabled(true)
	_player.view_camera.make_current()
	
#swaps the cameras and wraps from start to end 
func _swap_cam(i: int) -> void:
	if cameras.is_empty():
		return
	
	_index = wrapi(i,0,cameras.size())
	cameras[_index].make_current()
	
	
