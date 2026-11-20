# TODO
	# lock player at the beginning of the cutscene
	# unlock the player at the beginning of the cutscene
	
class_name LockPlayerCommand
extends CutsceneCommand

var locked:bool

func _init(lock:bool=true) -> void:
	locked = lock

func execute(ctx: CutsceneContext) -> void:
	ctx.player.set_controls_enabled(not locked)
	
func skip(ctx: CutsceneContext) -> void:
	execute(ctx)
