class_name StoreManager
extends Node3D

signal stock_changed(item_id: String, quantity: int)

@export var stock_path: String = "res://json/grocery_item.json"
@export var shelves: Array[Shelf] = []

var stock: Dictionary = {}


func _ready() -> void:
	if not FileAccess.file_exists(stock_path):
		push_error("Stock file not found: " + stock_path)
		return

	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(stock_path)
	)

	if not parsed is Dictionary:
		push_error("Stock file must contain a JSON object.")
		return

	var groceries: Variant = parsed.get("groceries")

	if not groceries is Array:
		push_error("Stock file must contain a groceries array.")
		return

	for grocery in groceries:
		if not grocery is Dictionary:
			continue

		var item_name: String = str(grocery.get("name", ""))
		var item_id: String = item_name.strip_edges().to_lower().replace(" ", "_")
		var quantity: int = int(grocery.get("quantity", 0))

		if item_id.is_empty() or quantity < 0:
			continue

		stock[item_id] = quantity

func find_shelf(shelf_id: int) -> Shelf:
	for current_shelf in shelves:
		if is_instance_valid(current_shelf):
			if current_shelf.shelf_id == shelf_id:
				return current_shelf

	return null


func get_stock(item_id: String) -> int:
	return stock.get(item_id, 0)


# Adds items to backroom stock.
func add_stock(item_id: String, amount: int = 1) -> bool:
	if item_id.is_empty() or amount <= 0:
		return false

	stock[item_id] = get_stock(item_id) + amount
	stock_changed.emit(item_id, stock[item_id])
	return true


# Removes items from backroom stock.
func take_item(item_id: String, amount: int = 1) -> bool:
	if amount <= 0 or get_stock(item_id) < amount:
		return false

	stock[item_id] -= amount
	stock_changed.emit(item_id, stock[item_id])
	return true


# Transfers items from backroom stock to a shelf.
func player_restock(
	item_id: String,
	amount: int,
	shelf_id: int
) -> bool:
	if amount <= 0 or get_stock(item_id) < amount:
		return false

	var target_shelf: Shelf = find_shelf(shelf_id)
	if target_shelf == null:
		return false

	if not target_shelf.add_item(item_id, amount):
		return false

	stock[item_id] -= amount
	stock_changed.emit(item_id, stock[item_id])
	return true
