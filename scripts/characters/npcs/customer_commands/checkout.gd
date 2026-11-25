class_name CheckoutCommand
extends Resource

@export var wait_seconds: float = 2.0


func execute() -> float:
	return maxf(0.0, wait_seconds)
