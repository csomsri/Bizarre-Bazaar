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
@export var timelapse_shot: Marker3D
@export var clock: WallClock
@export var day_night: Node3D

	#"cutscene": {
		#"bars_slide_time": 0.4,
		#"fade_time": 0.5,
		#"title_fade_time": 0.5,
		#"title_hold_time": 3.0,
		#"timelapse_from_hour": 6.0,
		#"timelapse_to_hour": 22.0,
		#"timelapse_seconds": 5.0
	#},
var bars_slide_time:float
var fade_time:float
var title_fade_time:float
var title_hold_time:float
var timelapse_seconds:float
var timelapse_from_hour:float
var timelapse_to_hour:float

func _ready() -> void:
	runner = $CutsceneRunner
	camera = $CutsceneCamera
	cutscene_ui = $CutsceneUI
	ShiftMgr.shift_ended.connect(_on_shift_ended)
	
	# load from json settings fole
	bars_slide_time = GameSettings.get_value("cutscene", "bars_slide_time")
	fade_time = GameSettings.get_value("cutscene", "fade_time")
	title_fade_time = GameSettings.get_value("cutscene", "title_fade_time")
	title_hold_time = GameSettings.get_value("cutscene", "title_hold_time")
	timelapse_seconds = GameSettings.get_value("cutscene", "timelapse_seconds")
	timelapse_from_hour = fmod(GameSettings.get_value("shift", "start_hour") + GameSettings.get_value("shift", "length_hours"),24)
	timelapse_to_hour = GameSettings.get_value("shift", "start_hour")
	
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
	ctx.day_night = day_night
	ctx.camera_shots ={
		"ClockShot":clock_shot,
		"TimeLapseShot":timelapse_shot,
	}
	
	# set the cutscene commands
	var commands:Array[CutsceneCommand]= [
		LockPlayerCommand.new(true),
		CinemaBarsCommand.new(true, bars_slide_time),
		MoveCameraCommand.new("ClockShot"),
		ClockPressCommand.new("OUT"),
		PrintReceiptCommand.new(),
		FadeCommand.new(true, fade_time),
		MoveCameraCommand.new("TimeLapseShot"),
		FadeCommand.new(false, fade_time),
		TimeLapseCommand.new(timelapse_from_hour, timelapse_to_hour, timelapse_seconds),
		FadeCommand.new(true, fade_time),
		TitleCommand.new(title_hold_time, title_fade_time),
		FadeCommand.new(false, 0),
		MoveCameraCommand.new("ClockShot"),
		ClockPressCommand.new("IN"),
		CinemaBarsCommand.new(false, bars_slide_time),
		MoveCameraCommand.new("Player"),
		LockPlayerCommand.new(false),
	]
	
	# wait for cutscene commadns to complet
	await runner.run(commands, ctx)
	
	ShiftMgr.start_shift(shift_no + 1)
