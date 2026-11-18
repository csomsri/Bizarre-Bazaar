# TODO: 
	# listen fo the signal for the end of the shift
	# connects to the shift manager
	# determine which cutscene to play: beginnign of the game, end of the night, end of the game (win/lose)
class_name CutsceneManager
extends Node3D

var runner:CutsceneRunner
var camera:Camera3D
var cutscene_ui:CanvasLayer

@export var player: CharacterBody3D 
@export var clock_shot:Marker3D
@export var clock: WallClock

func _ready() -> void:
	runner = $CutsceneRunner
	camera = $CutsceneCamera
	cutscene_ui = $CutsceneUI
	ShiftMgr.shift_ended.connect(_on_shift_ended)
	
	
func _on_shift_ended(shift_no:int) -> void:
	
	# init cutscne context
	var ctx := CutsceneContext.new()
	ctx.host = self
	ctx.camera = camera
	ctx.player = player
	ctx.cutscene_ui = cutscene_ui
	ctx.clock = clock
	ctx.shift = shift_no
	ctx.stats = ShiftMgr.get_player_stats()
	ctx.camera_shots ={
		"ClockShot":clock_shot,
	}
	
	# set the cutscene commands
	var commands:Array[CutsceneCommand]= [
		LockPlayerCommand.new(true),
		CinemaBarsCommand.new(true),
		MoveCameraCommand.new("ClockShot"),
		ClockPressCommand.new("OUT"),
		PrintReceiptCommand.new(),
		StubCommand.new("timelapse", 2.0),
		StubCommand.new("title"),
		ClockPressCommand.new("IN"),
		CinemaBarsCommand.new(false),
		LockPlayerCommand.new(false),
	]
	
	# wait for cutscene commadns to complet
	await runner.run(commands, ctx)
	
	ShiftMgr.start_shift(shift_no + 1)
