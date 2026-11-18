# TODO: 
	# executes the command list in order
	# handles skipping (press space)
class_name CutsceneRunner
extends Node

signal cutscene_ended()

var skipping := false

func run(commands:Array[CutsceneCommand], ctx:CutsceneContext)->void:
	# run or skip the cutscene commands
	for cmd in commands:
		if not skipping:
			await cmd.execute(ctx)
		else:
			cmd.skip(ctx)
			
	skipping =false
	cutscene_ended.emit()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("skip_cutscene"):
		skipping = true

	
