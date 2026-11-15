class_name PettyThief
extends Customer


func finish_shopping() -> void:
	go_to(exit_position.global_position, State.LEAVING)


func confrontation() -> void:
	print("Thief: Fine, I'm leaving.")
	go_to(exit_position.global_position, State.LEAVING)
