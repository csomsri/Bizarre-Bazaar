# TODO
	# used for testing
	# for evaluating state change after an executed command 

class_name StubCommand
extends CutsceneCommand

var label:String
var duration:float

func _init(lbl:String ="receipt", dur:float=2.0) -> void:
	label = lbl
	duration = dur

func execute(ctx: CutsceneContext) -> void:
	print("[cutscene] %s" % label)
	await ctx.host.get_tree().create_timer(duration).timeout # TODO: host not set yet
	print("[cutscene] end %s" % label)

	
func skip(_ctx: CutsceneContext) -> void:
	pass
