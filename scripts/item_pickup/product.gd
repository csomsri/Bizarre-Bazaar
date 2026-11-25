extends Node3D

@export var item_id: String
@export var shelf : Shelf
@export var store_manager: StoreManager
#@export var initial_items: String
@export var collision_shape: CollisionShape3D 
# Called when the node enters the scene tree for the first time.
func pickup() -> void:
	if(shelf.take_item(item_id,1)):
		var quantity = shelf.shelf_items.get(item_id,0)
		print("items remaining", quantity)
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
	

	
	if store_manager.player_restock(item_id, quantity, shelf.shelf_id):
		print("Initial stock: ", item_id, " = ", quantity)
	else:
		hide_product()
		print("Failed to stock: ", item_id)
		
	
