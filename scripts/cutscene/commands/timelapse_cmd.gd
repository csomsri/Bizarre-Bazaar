# TODO
	# time lapse from 6am - 10pm
	# from an outside angle looking at the store
	
class_name TimeLapseCommand
extends CutsceneCommand

var from_hour:float
var to_hour:float
var duration:float

func _init(from:float=6, to:float=22, dur:float=8) -> void:
	from_hour = from
	to_hour = to
	duration = dur
	
func execute(ctx: CutsceneContext) -> void:
	# sound effect for timelapse
	var timelapse_sound: AudioStreamPlayer = ctx.host.get_node("Sounds/TimeLapseSound")
	timelapse_sound.play()
	
	# timelapse
	var tween := ctx.host.create_tween()
	tween.tween_method(ctx.day_night.set_time_of_day, from_hour, to_hour, duration)	
	await tween.finished
	
	timelapse_sound.stop()
	
func skip(ctx: CutsceneContext) -> void:
	ctx.day_night.set_time_of_day(to_hour)
