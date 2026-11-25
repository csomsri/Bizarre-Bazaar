extends Node3D

@export var item_id: String
@export var shelf : Shelf
@export var store_manager: StoreManager
#@export var initial_items: String
@export var collision_shape: CollisionShape3D 

# UI/Interactions: products need access to inventory node
@onready var inventory: Inventory = get_tree().current_scene.get_node("Inventory")



# Called when the node enters the scene tree for the first time.
func pickup() -> void:
	if(shelf.take_item(item_id,1)):
		# Adding Inventory Access
		if inventory != null:
			inventory.add_item(item_id, 1)
		
		var quantity = shelf.shelf_items.get(item_id,0)
		print("Items Remaining: ", quantity)
		
		if(quantity <= 0):
			hide_product()
			

func hide_product():
	hide()
	collision_shape.set_deferred("disabled", true)

func restock():
	pass

func _ready() -> void:
	call_deferred("initial_stock")

func initial_stock() -> void:
	if store_manager == null or shelf == null:
		print("missing",get_path())
		return
	var quantity = store_manager.get_stock(item_id)
	
	print("Product: ", item_id)
	print("Backroom quantity: ", quantity)
	print("Shelf ID: ", shelf.shelf_id)
	print("Shelf found: ", store_manager.find_shelf(shelf.shelf_id))
	print("Shelf capacity: ", shelf.shelf_capacity)
	print("Items on shelf: ", shelf.items_on_shelf)
	
	if store_manager.player_restock(item_id, quantity, shelf.shelf_id):
		print("Initial stock: ", item_id, " = ", quantity)
	else:
		hide_product()
		print("Failed to stock: ", item_id)
		
	
