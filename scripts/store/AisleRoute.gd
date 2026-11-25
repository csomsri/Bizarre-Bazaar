class_name AisleRoute
extends Node3D


@export var waypoints: Array[Marker3D] = []

# Aisles
@export var aisle_start: Marker3D
@export var aisle_end: Marker3D


func is_browsing_leg(destination_index: int) -> bool:
	if destination_index <= 0 or destination_index >= waypoints.size():
		return false

	if aisle_start == null or aisle_end == null:
		return false

	return (
		waypoints[destination_index - 1] == aisle_start
		and waypoints[destination_index] == aisle_end
	)
