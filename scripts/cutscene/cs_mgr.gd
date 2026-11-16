# TODO: 
	# listen fo the signal for the end of the shift
	# connects to the shift manager
	# determine which cutscene to play: beginnign of the game, end of the night, end of the game (win/lose)
class_name CutsceneManager
extends Node3D

var runner:CutsceneRunner
var camera:Camera3D

@export var player: CharacterBody3D 
@export var clock_shot:Marker3D

func _ready() -> void:
	runner = $CutsceneRunner
	camera = $CutsceneCamera
	ShiftMgr.shift_ended.connect(_on_shift_ended)
	
	
func _on_shift_ended(shift_no:int) -> void:
	
	# init cutscne context
	var ctx := CutsceneContext.new()
	ctx.host = self
	ctx.camera = camera
	ctx.player = player
	ctx.camera_shots ={
		"ClockShot":clock_shot,
	}
	
	# set the cutscene commands
	var commands:Array[CutsceneCommand]= [
		LockPlayerCommand.new(true),
		MoveCameraCommand.new("ClockShot"),
		StubCommand.new("receipt"),
		StubCommand.new("timelapse", 2.0),
		StubCommand.new("title"),
		StubCommand.new("clock in"),
		LockPlayerCommand.new(false),
	]
	
	# wait for cutscene commadns to complet
	await runner.run(commands, ctx)
	
	ShiftMgr.start_shift(shift_no + 1)
