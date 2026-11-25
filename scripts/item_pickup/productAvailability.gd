extends Node

var products: Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var file = FileAccess.open("res://json/grocery_items.json", FileAccess.READ)
	
	if file == null:
		return
	var data = JSON.parse_string(file.get_as_text())
	
	if(data == null):
		return
	
	for product in data["groceries"]:
		products[product["name"]] = product
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func get_product(product_name: String) -> Dictionary:
	return products.get(product_name, {})
