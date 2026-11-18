extends Camera3D

@export var zoom_speed:= 15.0
@export var min_fov := 10.0
@export var max_fov := 120.0


func zoom(direction: float) -> void:
	fov = clampf(fov - direction * zoom_speed, min_fov, max_fov)
	print(fov)
