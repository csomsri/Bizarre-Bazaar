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

var follow_route_command: FollowRouteCommand = FollowRouteCommand.new()
var browse_command: BrowseCommand = BrowseCommand.new()
var checkout_command: CheckoutCommand = CheckoutCommand.new()

@onready var navigation: NavigationAgent3D = $NavigationAgent3D
@onready var resources: ResourceManager = $ResourceManager

var state: State = State.WAITING
var state_before_confrontation: State = State.WAITING
var waypoint_index: int = 0
var browse_pending: bool = false
var browse_trigger_distance: float = 0.0
var wait_remaining: float = 0.0


func _ready() -> void:
	if route == null or route.waypoints.is_empty():
		_stop_with_error("ENTER WAY POINTS")
		return

	if checkout_position == null or exit_position == null:
		_stop_with_error("ENTER EXIT MARKERS")
		return
		
	# Give the navigation map time to sync before setting the first target.
	await get_tree().physics_frame
	await get_tree().physics_frame
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


func _go_to_waypoint() -> void:
	var marker := follow_route_command.get_waypoint(route, waypoint_index)
	if marker == null:
		_stop_with_error("Customer route is missing waypoint %d." % waypoint_index)
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
				"Customer could not reach %s." % navigation.target_position
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
