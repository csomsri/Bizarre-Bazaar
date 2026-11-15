# TODO: 
# 	base command class which will be extended by all commands used in the cutscen
class_name CutsceneCommand
extends RefCounted

func execute(ctx: CutsceneContext) -> void:
	pass
	
func skip(ctx: CutsceneContext) -> void:
	pass
