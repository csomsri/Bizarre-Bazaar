class_name Customer
extends CharacterBody3D

enum State {
	WAITING,
	FOLLOWING_ROUTE,
	BROWSING,
	WALKING_TO_CHECKOUT,
	CHECKING_OUT,
	LEAVING,
	CONFRONTED
}

@export var route: AisleRoute
@export var checkout_position: Marker3D
@export var exit_position: Marker3D
@export var movement_speed: float = 3.0
@export var turn_speed: float = 10.0


# GET RID LATER: WOBBLE FOR SWOMAN
@export var walk_wobble_degrees: float = 5.0
@export var walk_wobble_cycles_per_meter: float = 0.8

@onready var customer_mesh: Node3D = $MeshInstance3D
@onready var mesh_rest_roll: float = customer_mesh.rotation.z

var walk_phase: float = 0.0

var follow_route_command: FollowRouteCommand = FollowRouteCommand.new()
var browse_command: BrowseCommand = BrowseCommand.new()
var checkout_command: CheckoutCommand 
# END OF WOBBLE

@onready var navigation: NavigationAgent3D = $NavigationAgent3D
@onready var resources: ResourceManager = $ResourceManager

var state: State = State.WAITING
var state_before_confrontation: State = State.WAITING
var waypoint_index: int = 0
var browse_pending: bool = false
var browse_trigger_distance: float = 0.0
var wait_remaining: float = 0.0

@export var store_manager: StoreManager
var shopping_list := ShoppingList.new()


func _ready() -> void:
	if route == null or route.waypoints.is_empty():
		_stop_with_error("ENTER WAY POINTS")
		return

	if checkout_position == null or exit_position == null:
		_stop_with_error("ENTER EXIT MARKERS")
		return
	
	# 
	#shopping_list.generate()
	#print(name, " wants: ", shopping_list.get_remaining_items())
		
	# Give the navigation map time to sync before setting the first target.
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	if is_instance_valid(store_manager):
		shopping_list.generate(store_manager)
		print(name, " wants: ", shopping_list.get_remaining_items())
	else:
		push_warning("Assign Store Manager on the customer to generate a shopping list.")
	
	_go_to_waypoint()


func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO

	match state:
		State.FOLLOWING_ROUTE:
			_follow_route()

		State.WALKING_TO_CHECKOUT, State.LEAVING:
			update_movement()

		State.BROWSING:
			wait_remaining -= delta
			if wait_remaining <= 0.0:
				state = State.FOLLOWING_ROUTE

		State.CHECKING_OUT:
			wait_remaining -= delta
			if wait_remaining <= 0.0:
				go_to(exit_position.global_position, State.LEAVING)

	move_and_slide()
	_update_facing(delta)
	_update_walk_wobble(delta)


# Can be command?
func _go_to_waypoint() -> void:
	var marker := follow_route_command.get_waypoint(route, waypoint_index)
	if marker == null:
		_stop_with_error("Waypoint Missing Index: %d." % waypoint_index)
		return

	browse_pending = follow_route_command.should_browse(route, waypoint_index)
	browse_trigger_distance = follow_route_command.get_browse_trigger_distance(
		global_position, marker.global_position
	)
	go_to(marker.global_position, State.FOLLOWING_ROUTE)


func _follow_route() -> void:
	if browse_pending:
		var offset := navigation.target_position - global_position
		offset.y = 0.0
		if offset.length() <= browse_trigger_distance:
			browse_pending = false
			wait_remaining = browse_command.execute()
			state = State.BROWSING
			return

	update_movement()


func go_to(destination: Vector3, next_state: State) -> void:
	navigation.target_position = destination
	state = next_state


func update_movement() -> void:
	var next_position := navigation.get_next_path_position()
	if navigation.is_navigation_finished():
		if state == State.CONFRONTED:
			return

		if navigation.is_target_reached():
			on_destination_reached()
		else:
			_stop_with_error(
				"Could Not Reach Position %s." % navigation.target_position
			)
		return

	var direction := next_position - global_position
	direction.y = 0.0
	velocity = direction.normalized() * movement_speed


func on_destination_reached() -> void:
	match state:
		State.FOLLOWING_ROUTE:
			waypoint_index += 1
			if waypoint_index < route.waypoints.size():
				_go_to_waypoint()
			else:
				finish_shopping()

		State.WALKING_TO_CHECKOUT:
			wait_remaining = checkout_command.execute()
			state = State.CHECKING_OUT

		State.LEAVING:
			queue_free()


func finish_shopping() -> void:
	go_to(checkout_position.global_position, State.WALKING_TO_CHECKOUT)


func confront() -> void:
	if state == State.CONFRONTED:
		return

	state_before_confrontation = state
	state = State.CONFRONTED
	velocity = Vector3.ZERO
	confrontation()


func confrontation() -> void:
	print("Customer: Just shopping choom")
	state = state_before_confrontation


func _stop_with_error(message: String) -> void:
	push_warning(message)
	velocity = Vector3.ZERO
	state = State.WAITING
	
func _update_facing(delta: float) -> void:
	var travel := get_real_velocity()
	travel.y = 0.0

	if travel.length_squared() < 0.01:
		return

	# Godot uses local -Z as forward.
	var target_yaw := atan2(-travel.x, -travel.z)
	var turn_weight := 1.0 - exp(-turn_speed * delta)
	global_rotation.y = lerp_angle(global_rotation.y, target_yaw, turn_weight)
	
func _update_walk_wobble(delta: float) -> void:
	var travel := get_real_velocity()
	travel.y = 0.0
	var speed := travel.length()

	var target_roll := mesh_rest_roll
	if speed > 0.1:
		walk_phase += speed * delta * walk_wobble_cycles_per_meter * TAU
		target_roll += sin(walk_phase) * deg_to_rad(walk_wobble_degrees)
	else:
		walk_phase = 0.0

	var blend := 1.0 - exp(-12.0 * delta)
	customer_mesh.rotation.z = lerp_angle(
		customer_mesh.rotation.z, target_roll, blend
	)
