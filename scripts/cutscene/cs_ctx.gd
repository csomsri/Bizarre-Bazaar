# TODO
	# bundles references that a command may need
	# will be passed into each command execute or skip
	
class_name CutsceneContext
extends RefCounted


var player # TODO: player should have a class 
var host:Node
var camera:Camera3D
var camera_shots:Dictionary 
var cutscene_ui:CanvasLayer
var clock:WallClock
