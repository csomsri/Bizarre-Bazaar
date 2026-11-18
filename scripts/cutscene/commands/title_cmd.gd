# TODO:
	# prints the end of the day tile (DAY 2 10:00 PM)

class_name TitleCommand
extends CutsceneCommand

var hold_dur:float

func _init(hold_time:float=1.0) -> void:
	hold_dur = hold_time

func execute(ctx: CutsceneContext) -> void:
	var title:Label = ctx.cutscene_ui.get_node("TitleCard")
	title.text = "NIGHT %d" % (ctx.shift +1)
	
	#fade-in, hold, and fade-out the title
	var tween := ctx.host.create_tween()
	tween.tween_property(title, "modulate:a", 1.0, 0.5)
	tween.tween_interval(hold_dur)
	tween.tween_property(title, "modulate:a", 0.0, 0.5)
	
	await tween.finished

	
func skip(ctx: CutsceneContext) -> void:
	var title:Label = ctx.cutscene_ui.get_node("TitleCard")
	title.text = "NIGHT %d" % (ctx.shift +1)
	title.modulate.a = 0.0
