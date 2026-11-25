extends Node3D
class_name InteractableObject

@export var prompt_text: String = "Interact"
@export var interaction_target: Node
@export var interaction_method: String = "open_lid"

# FUNC get_prompt_text: Text to display
func get_prompt_text() -> String:
	return prompt_text

# FUNC can_interact: is player within range to interact with object
func can_interact() -> bool:
	if interaction_target == null: return false
	
	if interaction_target.get("player_nearby") != null:
		return interaction_target.player_nearby
	
	return true


# FUNC interact: interact with object
# NOTE: this might only work with dumpster right now. We have no other interactions
# to test with right now.
func interact() -> void:
	if interaction_target != null and interaction_target.has_method(interaction_method):
		interaction_target.call(interaction_method)
