class_name FadeCommand
extends CutsceneCommand

var to_black: bool
var duration: float

func _init(black: bool, dur: float = 0.5) -> void:
	to_black = black
	duration = dur

# fade in/out full black screen	
func execute(ctx: CutsceneContext) -> void:
	var fade: ColorRect = ctx.cutscene_ui.get_node("Fade")
	
	var target 
	if to_black:
		target = 1.0
	else:
		target =  0.0

	var tween := ctx.host.create_tween()
	tween.tween_property(fade, "modulate:a", target, duration)
	await tween.finished


# will be used once skip input is added
func skip(ctx: CutsceneContext) -> void:
	var fade: ColorRect = ctx.cutscene_ui.get_node("Fade")
	if to_black:
		fade.modulate.a = 1.0
	else:
		fade.modulate.a = 0.0
