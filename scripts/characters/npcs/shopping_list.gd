class_name ShoppingList
extends RefCounted

var _remaining_items: Array[String] = []


func generate(store_manager: StoreManager, max_items: int = 3) -> void:
	_remaining_items.clear()

	if store_manager == null or max_items <= 0:
		return

	var candidates: Array[String] = []
	for key in store_manager.stock:
		var item_id := str(key)
		if not item_id.is_empty() and store_manager.get_stock(item_id) > 0:
			candidates.append(item_id)

	if candidates.is_empty():
		return

	candidates.shuffle()
	var count := randi_range(1, mini(max_items, candidates.size()))

	for index in range(count):
		_remaining_items.append(candidates[index])


func find_match(shelf_items: Dictionary[String, int]) -> String:
	for item_id in _remaining_items:
		if shelf_items.get(item_id, 0) > 0:
			return item_id

	return ""


func mark_collected(item_id: String) -> void:
	_remaining_items.erase(item_id)


func is_complete() -> bool:
	return _remaining_items.is_empty()


func get_remaining_items() -> Array[String]:
	return _remaining_items.duplicate()
