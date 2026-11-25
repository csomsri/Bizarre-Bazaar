# UI/Input: Adaluz Henriquez Zetino
# inventory_ui.gd
extends Control

@onready var inventory: Inventory = get_tree().current_scene.get_node("Inventory")


func _ready() -> void:
	inventory.inventory_changed.connect(_on_inventory_changed)

# Keep track of when inventory is updated
func _on_inventory_changed() -> void:
	print("Inventory Updated")
