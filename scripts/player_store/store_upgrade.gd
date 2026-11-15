class_name StoreUpgrade
extends Node

# Store JSON
var store_upgrades

func _ready() -> void:
	var path = "res://json/store_upgrade.json"
	if not FileAccess.file_exists(path):
		push_error("Grocery items file not found: " + path)
		return

	store_upgrades = JSON.parse_string(
		FileAccess.get_file_as_string(path)
	)

	if store_upgrades == null:
		push_error("Failed to parse grocery items JSON.")

func upgrade_bought():
	return
	
