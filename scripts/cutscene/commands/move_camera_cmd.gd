# TODO
	# move camera theough each of the camera positions for the cutscene
class_name MoveCameraCommand
extends CutsceneCommand

var cam_shot:String

func _init(shot:String) -> void:
	cam_shot = shot

func execute(ctx: CutsceneContext) -> void:
	# swithc to the player camera
	if cam_shot == "Player":
		ctx.player.view_camera.make_current()
		return
		
	# move the camera to the position, and switch to it
	var marker = ctx.camera_shots[cam_shot]
	ctx.camera.global_transform = marker.global_transform
	ctx.camera.make_current()
	
	
func skip(ctx: CutsceneContext) -> void:
	execute(ctx)
