# TODO:
	# T/F for clock in and clock out
	# Press the clock in/out machine
	
class_name ClockPressCommand
extends CutsceneCommand

var button_name:String
func _init(btn:String) -> void:
	button_name = btn

func execute(ctx: CutsceneContext) -> void:
	ctx.clock.press(button_name)
	await ctx.clock.press_finished
	
func skip(ctx: CutsceneContext) -> void:
	ctx.clock.set_pressed_state(button_name)
