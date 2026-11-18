# TODO:
	# controls how the world looks like at any given point during the day or night
	# where the sun is
	# how bright it iw
	# what color the ligth iw
	# which sky is showing
	
# CONNECTS to DayNightCycleNode
extends Node3D

@export var enabled := false

# envs for diff part of the day
# DELETE
#@export var night_sky: Environment
#@export var sunset_sky:Environment 
#@export var day_sky: Environment 

# skies used to smooth transitions with shader
@export var night_sky: Texture2D 
@export var sunset_sky: Texture2D
@export var day_sky: Texture2D 


# sky color for diff part of the day
@export var day_energy :=1.0 # brigtness (max) at noon
@export var sunrise_color := Color(1.0, 0.6, 0.35)
@export var noon_color := Color(1.0, 0.97, 0.9)

@onready var sun:DirectionalLight3D = $DirectionalLight3D
@onready var world_env: WorldEnvironment =$SkyDayFair/WorldEnvironment

# sky shader+mat
var sky_mat: ShaderMaterial

#(start hour, end hour) * 4, one for each transition (e.g. night -> sunrise)
var windows:Array

# start: 8am, end: 5:30pm
var day_start_hour:float
var day_end_hour:float


func _ready() -> void:
	# get settings from the json file
	var json_windows:Array = GameSettings.get_value("day_night", "sky_windows")
	windows = [
		[json_windows[0]["start"], json_windows[0]["end"], night_sky, sunset_sky],
		[json_windows[1]["start"], json_windows[1]["end"], sunset_sky, day_sky],
		[json_windows[2]["start"], json_windows[2]["end"], day_sky, sunset_sky],
		[json_windows[3]["start"], json_windows[3]["end"], sunset_sky, night_sky],
	]
	day_start_hour = GameSettings.get_value("day_night", "full_day_start")
	day_end_hour = GameSettings.get_value("day_night", "full_day_end")
	
	
	if not enabled:
		return
	
	sky_mat = world_env.environment.sky.sky_material
	ShiftMgr.time_changed.connect(_on_time_changed)
	_on_time_changed(ShiftMgr.get_hour(), ShiftMgr.get_minute()) 
	
func _on_time_changed(hour:int, minute:int) -> void:
	set_time_of_day(hour + minute / 60.0)

	
func set_time_of_day(hour) -> void:
	if not enabled:
		return
	_update_sun(hour)
	_update_sky(hour)

# one full sun rotation per 24, update angle, brightness and color according to the time
func _update_sun(hour: float) -> void:
	# rotate sun from one to another hoizon
	var angle_deg := -(hour - 6.0) / 24.0 * 360.0
	sun.rotation.x = deg_to_rad(angle_deg)

	# height of the sun with 0(horizon), 1(noon) and neg(night)
	var height := sin((hour - 6.0) / 24.0 * TAU)
	var daylight := clampf(height, 0.0, 1.0)

	# brigtness (0 - 1), 1 is max at noon
	sun.light_energy = daylight * day_energy
	sun.light_color = sunrise_color.lerp(noon_color, daylight)
	
# set (swap) environments (day,sunset, night) based on the time of the day
# i picked the time cutoffs randomly, should/could be changed
func _update_sky(hour: float) -> void:
	windows.size() # DEBUG
	
	# when not in 'transition', i.e. it's 100% day or ngith
	var a: Texture2D 
	if hour >= day_start_hour and hour < day_end_hour:
		a = day_sky
	else:
		a =  night_sky
	var b: Texture2D = a
	
	# start with sky A, and gradually blend to sky b
	var blend := 0.0

	# match sky transition with the time
	# e.g. at 5am sky goes from night to sunrise (sunset)
	for w in windows:
		if hour >= w[0] and hour < w[1]:
			a = w[2]
			b = w[3]
			blend = (hour - w[0]) / (w[1] - w[0])
			break

	print("hour=%.2f  blend=%.2f  a=%s  b=%s" % [hour, blend, a.resource_path.get_file(), b.resource_path.get_file()]) # DEBUG

	# apply shader blens between two skies
	sky_mat.set_shader_parameter("sky_a", a)
	sky_mat.set_shader_parameter("sky_b", b)
	sky_mat.set_shader_parameter("blend", blend)

	
