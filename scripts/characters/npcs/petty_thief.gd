class_name PettyThief
extends Customer

@export var is_complacent: bool = false


func finish_shopping() -> void:
	go_to(exit_position.global_position, State.LEAVING)


func confrontation() -> void:
	if is_complacent:
		complacent_thief()
	else:
		aggresive_thief()
	go_to(exit_position.global_position, State.LEAVING)

func complacent_thief() -> void:
	print("Chill Choom, it's only a KitKat")
	# DIALOGUE BOX:
	return
	
func aggresive_thief() -> void:
	print("These hot fries mean everything to me!!")
	return
