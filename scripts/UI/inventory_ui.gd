# UI/Input: Adaluz Henriquez Zetino
# inventory_ui.gd
extends Control

@onready var inventory: Inventory = get_tree().current_scene.get_node("Inventory")
@onready var item_list: VBoxContainer = $InventoryPanel/ItemList

func _ready() -> void:
	inventory.inventory_changed.connect(_on_inventory_changed)
	update_inventory()
	hide()


# FUNC _on_inventory_changed: Update displayed inventory
func _on_inventory_changed() -> void:
	update_inventory()


# FUNC update_inventory
func update_inventory() -> void:
	# Remove previous item entries
	for child in item_list.get_children():
		child.queue_free()
	
	# Add entry for each item
	for item_id in inventory.items:
		var item_label = Label.new()
		item_label.text = "%s x%d" % [item_id, inventory.items[item_id]]
		item_list.add_child(item_label)

# FUNC _process: Toggles inventory when player presses I
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		visible = not visible
