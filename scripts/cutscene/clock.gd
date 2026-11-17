# TODO
	# display of game time/clock
	
class_name WallClock
extends Node3D

signal press_finished()

# TODOD: should be part of a spec file
const PRESS_DEPTH = 0.05

# to reset positions after press
var _rest_positions := {}

var clock_display:Label3D
var clock_in_button:MeshInstance3D
var clock_out_button:MeshInstance3D

func _ready() -> void:
	clock_display = $Display
	clock_in_button = $InButton
	clock_out_button = $OutButton
	
	ShiftMgr.time_changed.connect(_on_time_changed)
	_on_time_changed(ShiftMgr.get_hour(), ShiftMgr.get_minute()) 
	
	_rest_positions[clock_in_button] = clock_in_button.position
	_rest_positions[clock_out_button] = clock_out_button.position
	

	
# display time on the clock
func _on_time_changed(_hour:int, _minute:int) -> void:
	clock_display.text = ShiftMgr.get_time_str()

# for pressed button, smoothly move/change its x position
func press(btn:String) -> void:
	var button := _get_button(btn)
	var rest:Vector3 = _rest_positions[button]
	var pushed := rest - Vector3(-PRESS_DEPTH, 0, 0, )

	# smooth press
	var tween := create_tween()
	tween.tween_property(button, "position", pushed, 0.25)
	tween.tween_property(button, "position", rest, 0.3)
	await tween.finished

	press_finished.emit()
	
# move x cord of the button
func set_pressed_state(btn: String) -> void:
	var button := _get_button(btn)
	button.position = _rest_positions[button]

# maps string to an actual button, maybe do via Dict
func _get_button(btn: String) -> MeshInstance3D:
	if btn == "OUT":
		return clock_out_button
	return clock_in_button
	
