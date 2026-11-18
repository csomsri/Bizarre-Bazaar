extends Node3D
class_name InteractableObject

@export var prompt_text: String = "Interact"

# FUNC get_prompt_text: Text to display
func get_prompt_text() -> String:
	return prompt_text


# FUNC interact: Calls open_lid on parent object
func interact() -> void:
	var target = get_parent()
	
	if target.has_method("open_lid"):
		target.open_lid()
