class_name Customer
extends CharacterBody3D

# Maybe add a Confrontation State
enum State {
	WAITING,
	WALKING_TO_SHELF,
	BROWSING,
	WALKING_TO_CHECKOUT,
	CHECKING_OUT,
	LEAVING,
	CONFRONTED
}

@export var movement_speed: float = 3.0
@export var browse_time: float = 2.0
@export var checkout_time: float = 2.0

@export var target_shelf: Shelf
@export var shelf_position: Marker3D
@export var checkout_position: Marker3D
@export var exit_position: Marker3D

# I asked ChatGPT how to make a navigation agent
# I'll remove this later but im setting this as a
# reminder; DW i code myself
# Store (Node3D)
# ├── NavigationRegion3D
# │   ├── Floor
# │   ├── Walls
# │   └── Shelves
# ├── Customer
# │   ├── CollisionShape3D
# │   ├── MeshInstance3D
# │   ├── NavigationAgent3D
# │   └── ResourceManager
# │       └── Inventory
# ├── ShelfPosition (Marker3D)
# ├── CheckoutPosition (Marker3D)
# └── ExitPosition (Marker3D)

@onready var navigation: NavigationAgent3D = $NavigationAgent3D
@onready var resources: ResourceManager = $ResourceManager

var state: State = State.WAITING
var wait_remaining: float = 0.0


func _ready() -> void:
	navigation.target_desired_distance = 0.5
	navigation.path_desired_distance = 0.5

	if (
		target_shelf == null
		or shelf_position == null
		or checkout_position == null
		or exit_position == null
	):
		push_error("MISSING Configs")
		set_physics_process(false)
		return

	# Allow the navigation map to synchronize?
	await get_tree().physics_frame
	await get_tree().physics_frame

	go_to(shelf_position.global_position, State.WALKING_TO_SHELF)


func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO

	match state:
		State.WALKING_TO_SHELF, State.WALKING_TO_CHECKOUT, State.LEAVING:
			update_movement()

		State.BROWSING:
			wait_remaining -= delta

			if wait_remaining <= 0.0:
				take_shelf_item()
				finish_shopping()

		State.CHECKING_OUT:
			wait_remaining -= delta

			if wait_remaining <= 0.0:
				# REMINDER: Go through all resource
				#			then remove money
				go_to(exit_position.global_position, State.LEAVING)

	move_and_slide()


func go_to(destination: Vector3, next_state: State) -> void:
	state = next_state
	navigation.target_position = destination


func update_movement() -> void:
	if navigation.is_navigation_finished():
		if navigation.is_target_reached():
			on_destination_reached()
		return

	var next_position: Vector3 = navigation.get_next_path_position()
	var direction: Vector3 = next_position - global_position
	direction.y = 0.0

	velocity = direction.normalized() * movement_speed

# Switch Case of when you reach
func on_destination_reached() -> void:
	match state:
		State.WALKING_TO_SHELF:
			state = State.BROWSING
			wait_remaining = browse_time

		State.WALKING_TO_CHECKOUT:
			state = State.CHECKING_OUT
			wait_remaining = checkout_time

		State.LEAVING:
			queue_free()


func take_shelf_item() -> void:
	if target_shelf.shelf_items.is_empty():
		return
	
	 
	var available_items: Array = target_shelf.shelf_items.keys()
	var item_id: String = available_items.pick_random()

	if target_shelf.take_item(item_id, 1):
		if not resources.inventory.add_item(item_id, 1):
			target_shelf.add_item(item_id, 1)

func finish_shopping() -> void:
	go_to(
		checkout_position.global_position,
		State.WALKING_TO_CHECKOUT
	)

func confront() -> void:
	if state == State.CONFRONTED:
		return

	state = State.CONFRONTED
	velocity = Vector3.ZERO
	confrontation()


# Default response
func confrontation() -> void:
	print("Customer: I'm just shopping.")
