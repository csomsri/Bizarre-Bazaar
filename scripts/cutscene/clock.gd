# TODO
	# display of game time/clock
	
class_name WallClock
extends Node3D

signal press_finished
signal receipt_printed

# TODOD: should be part of a spec file
#const PRESS_DEPTH = 0.05

var press_depth:float

# duration of single print, pause after single print, and read pause at the end of print recipt
#const RECEIPT_LINE_TIME := 0.5 
#const RECEIPT_LINE_PAUSE := 0.3
#const RECEIPT_READ_TIME := 3
var receipt_line_time:float
var receipt_line_pause:float
var receipt_read_time:float

# to reset positions after press
var _rest_positions := {}

#clock
var clock_display:Label3D
var clock_in_button:MeshInstance3D
var clock_out_button:MeshInstance3D

#receipt
var receipt:Node3D
var receipt_text:Label3D

#sounds
var punch_sound: AudioStreamPlayer3D 
var printer_sound: AudioStreamPlayer3D


	#"clock": {
		#"press_depth": 0.05,
		#"press_in_time": 0.25,
		#"press_hold_time": 0.2,
		#"press_out_time": 0.3,
		#"receipt_line_time": 0.8,
		#"receipt_line_pause": 0.5,
		#"receipt_hold_time": 4.0,
	#},

func _ready() -> void:
	clock_display = $Display
	clock_in_button = $InButton
	clock_out_button = $OutButton
	punch_sound = $PunchSound
	printer_sound = $PrinterSound
	
	ShiftMgr.time_changed.connect(_on_time_changed)
	_on_time_changed(ShiftMgr.get_hour(), ShiftMgr.get_minute()) 
	
	# store initial clock in/out button positions
	_rest_positions[clock_in_button] = clock_in_button.position
	_rest_positions[clock_out_button] = clock_out_button.position
	
	receipt = $Receipt
	receipt_text = $Receipt/Text
	_rest_positions[receipt] = receipt.position
	
	# read settings from the json file
	press_depth = GameSettings.get_value("clock", "press_depth")
	receipt_line_time = GameSettings.get_value("clock", "receipt_line_time")
	receipt_line_pause = GameSettings.get_value("clock", "receipt_line_pause")
	receipt_read_time = GameSettings.get_value("clock","receipt_hold_time")
	
	hide_receipt()

	
# display time on the clock
func _on_time_changed(_hour:int, _minute:int) -> void:
	clock_display.text = ShiftMgr.get_time_str()

# for pressed button, smoothly move/change its x position
func press(btn:String) -> void:
	var button := _get_button(btn)
	var rest:Vector3 = _rest_positions[button]
	var pushed := rest - Vector3(-press_depth, 0, 0, )

	punch_sound.play()
	
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
	
func print_receipt(text: Array[String]) ->void:
	# reset
	hide_receipt()
	receipt_text.text = "\n".join(text) 
	receipt.visible = true
	
	# calculate the slide step based on the heigh of the recipt paper
	var paper_height:float = ($Receipt/Paper.mesh as BoxMesh).size.y
	var down: Vector3 = receipt.transform.basis.y * -1.0
	var slide_step := down * paper_height / text.size()
	
	printer_sound.play()
	# in reverse order (bottom up) add and print lines to the receipt and 'print' it out
	for i in range(text.size() -1, -1, -1):
		#receipt_text.text = text[i] + "\n" + receipt_text.text
		var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(receipt, "position", receipt.position + slide_step, receipt_line_time)
		tween.tween_interval(receipt_line_pause)
		await tween.finished
	
	printer_sound.stop()
	
	# instant didnt work, added time to read
	await get_tree().create_timer(receipt_read_time).timeout
	receipt_printed.emit()
	hide_receipt()
	
	
func hide_receipt() -> void:
	receipt.visible = false
	receipt.position = _rest_positions[receipt]
	receipt_text.text =""
	
	printer_sound.stop()
