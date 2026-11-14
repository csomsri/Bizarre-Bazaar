class_name Shelf
extends Node3D

@export var shelf_id: int
@export var shelf_capacity: int = 30
@export var shelf_type: String = "two_shelf"

var grocery_items: Variant
var shelf_items: Dictionary[String, int] = {}
var items_on_shelf: int = 0


func _ready() -> void:
	var path := "res://json/grocery_items.json"

	if not FileAccess.file_exists(path):
		push_error("Grocery items file not found: " + path)
		return

	grocery_items = JSON.parse_string(
		FileAccess.get_file_as_string(path)
	)

	if grocery_items == null:
		push_error("Failed to parse grocery items JSON.")


func add_item(item_id: String, quantity: int = 1) -> bool:
	if item_id.is_empty() or quantity <= 0:
		return false

	if items_on_shelf + quantity > shelf_capacity:
		return false

	shelf_items[item_id] = shelf_items.get(item_id, 0) + quantity
	items_on_shelf += quantity
	return true


func take_item(item_id: String, quantity: int = 1) -> bool:
	if quantity <= 0 or shelf_items.get(item_id, 0) < quantity:
		return false

	shelf_items[item_id] -= quantity
	items_on_shelf -= quantity
	
	if shelf_items[item_id] == 0:
		shelf_items.erase(item_id)

	return true
