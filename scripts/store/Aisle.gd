class_name Aisle
extends Node3D

@export var start_marker: Marker3D
@export var end_marker: Marker3D


func get_sideways_direction() -> Vector3:
	var along_aisle := end_marker.global_position - start_marker.global_position
	along_aisle.y = 0.0
	return along_aisle.normalized().cross(Vector3.UP)
