class_name CinemaBarsCommand
extends CutsceneCommand

var show_bars:bool
var duration:float

func _init(show:bool=true, dur:float=0.4) -> void:
	show_bars=show
	duration = dur

func execute(ctx: CutsceneContext) -> void:
	var top: ColorRect= ctx.cutscene_ui.get_node("TopBar")
	var bottom: ColorRect =ctx.cutscene_ui.get_node("BottomBar")
	var target_pos = [0,0]
	var screen_h := ctx.host.get_viewport().get_visible_rect().size.y
	
	# get position for the top and bottom cinema bar
	if show_bars:
		target_pos = [0.0, screen_h - bottom.size.y]
	else:
		target_pos = [-top.size.y-80, screen_h+80] 
	
	#smoothly move bars into view (top goes down, bottom goes up)
	var tween :=ctx.host.create_tween().set_parallel(true)
	tween.tween_property(top, "position:y", target_pos[0],duration)
	tween.tween_property(bottom,"position:y", target_pos[1], duration)
	await tween.finished
	
func skip(ctx: CutsceneContext) -> void:
	var top: ColorRect= ctx.cutscene_ui.get_node("TopBar")
	var bottom: ColorRect =ctx.cutscene_ui.get_node("BottomBar")
	
	var screen_h := ctx.host.get_viewport().get_visible_rect().size.y
	
	# get position for the top and bottom cinema bar based on viewport
	# move instantly
	if show_bars:
		top.position.y = 0.0
		bottom.position.y = screen_h - bottom.size.y
	else:
		top.position.y = -top.size.y
		bottom.position.y = screen_h
	
	
	
