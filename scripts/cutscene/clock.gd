# TODO
	# display of game time/clock
	
class_name WallClock
extends Node3D

var clock_display:Label3D

func _ready() -> void:
	clock_display = $Display
	ShiftMgr.time_changed.connect(_on_time_changed)
	_on_time_changed(ShiftMgr.get_hour(), ShiftMgr.get_minute()) 

func _on_time_changed(_hour:int, _minute:int) -> void:
	clock_display.text = ShiftMgr.get_time_str()
