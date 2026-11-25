class_name BrowseCommand
extends Resource

@export var minimum_seconds: float = 0.8
@export var maximum_seconds: float = 2.0


func execute() -> float:
	var minimum := maxf(0.0, minimum_seconds)
	var maximum := maxf(minimum, maximum_seconds)
	return randf_range(minimum, maximum)
