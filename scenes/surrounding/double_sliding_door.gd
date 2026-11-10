
extends Node3D

@export var slide_distance: float = 1.5
@export var slide_duration: float = 1.0

@onready var left_door: AnimatableBody3D = $StaticBody3D
@onready var right_door: AnimatableBody3D = $StaticBody3D2
@onready var detection_area: Area3D = $DetectionArea
@onready var door_sound: AudioStreamPlayer3D = $AudioStreamPlayer3D

var left_closed: Vector3
var right_closed: Vector3
var is_open := false
var tween: Tween

func _ready():
	left_closed = left_door.position
	right_closed = right_door.position

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)


func open_doors():
	if is_open:
		return

	is_open = true
	if not door_sound.playing:
		door_sound.play(0.7)
	move_doors(true)


func close_doors():
	if not is_open:
		return

	is_open = false
	move_doors(false)


func move_doors(open: bool):
	if tween:
		tween.kill()

	var left_target = left_closed
	var right_target = right_closed

	if open:
		left_target += Vector3(0, 0, -slide_distance)
		right_target += Vector3(0, 0, slide_distance)

	tween = create_tween()
	tween.set_parallel(true)
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)

	tween.tween_property(left_door, "position", left_target, slide_duration)
	tween.tween_property(right_door, "position", right_target, slide_duration)


func _on_body_entered(body: Node3D):
	if body.is_in_group("entity"):
		open_doors()


func _on_body_exited(body: Node3D):
	if body.is_in_group("entity"):
		close_doors()
