extends Node3D

@onready var left_door = %PivotLeft
@onready var right_door = %PivotRight
@onready var detection_area: Area3D = $DetectionArea

var is_open = false
var duration = 0.8
var tween: Tween

func open_door():
	if is_open:
		return

	is_open = true

	if tween:
		tween.kill()

	tween = create_tween().set_parallel(true)

	tween.tween_property(left_door, "rotation:y", deg_to_rad(-90), duration)
	tween.tween_property(right_door, "rotation:y", deg_to_rad(90), duration)

func close_door():
	if not is_open:
		return

	is_open = false

	if tween:
		tween.kill()

	tween = create_tween().set_parallel(true)

	tween.tween_property(left_door, "rotation:y", 0.0, duration)
	tween.tween_property(right_door, "rotation:y", 0.0, duration)

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("interact"):
		for body in detection_area.get_overlapping_bodies():
			if body.is_in_group("entity"):
				if is_open:
					close_door()
				else:
					open_door()
				break
