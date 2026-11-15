# inventory.gd
class_name Inventory
extends Node

signal inventory_changed

var items: Dictionary[String, int] = {}


func add_item(item_id: String, quantity: int = 1) -> bool:
	if item_id.is_empty() or quantity <= 0:
		return false

	items[item_id] = items.get(item_id, 0) + quantity
	inventory_changed.emit()
	return true
