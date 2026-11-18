# TODO
	# display of game time/clock
	
class_name WallClock
extends Node3D

signal press_finished
signal receipt_printed

# TODOD: should be part of a spec file
const PRESS_DEPTH = 0.05

# duration of single print, pause after single print, and read pause at the end of print recipt
const RECEIPT_LINE_TIME := 0.8 
const RECEIPT_LINE_PAUSE := 0.5
const RECEIPT_READ_TIME := 4.0



# to reset positions after press
var _rest_positions := {}

var clock_display:Label3D
var clock_in_button:MeshInstance3D
var clock_out_button:MeshInstance3D
var receipt:Node3D
var receipt_text:Label3D

func _ready() -> void:
	clock_display = $Display
	clock_in_button = $InButton
	clock_out_button = $OutButton
	
	ShiftMgr.time_changed.connect(_on_time_changed)
	_on_time_changed(ShiftMgr.get_hour(), ShiftMgr.get_minute()) 
	
	# store initial clock in/out button positions
	_rest_positions[clock_in_button] = clock_in_button.position
	_rest_positions[clock_out_button] = clock_out_button.position
	
	receipt = $Receipt
	receipt_text = $Receipt/Text
	_rest_positions[receipt] = receipt.position
	
	hide_receipt()

	
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
	
func print_receipt(text: Array[String]) ->void:
	# reset
	hide_receipt()
	receipt.visible = true
	
	# calculate the slide step based on the heigh of the recipt paper
	var paper_height:float = ($Receipt/Paper.mesh as BoxMesh).size.y
	var down: Vector3 = receipt.transform.basis.y * -1.0
	var slide_step := down * paper_height / text.size()
	
	# in reverse order (bottom up) add and print lines to the receipt and 'print' it out
	for i in range(text.size() -1, -1, -1):
		receipt_text.text = text[i] + "\n" + receipt_text.text
		var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(receipt, "position", receipt.position + slide_step, RECEIPT_LINE_TIME)
		tween.tween_interval(RECEIPT_LINE_PAUSE)
		await tween.finished
	
	# instant didnt work, added time to read
	await get_tree().create_timer(RECEIPT_READ_TIME).timeout
	receipt_printed.emit()
	hide_receipt()
	
	
func hide_receipt() -> void:
	receipt.visible = false
	receipt.position = _rest_positions[receipt]
	receipt_text.text =""
