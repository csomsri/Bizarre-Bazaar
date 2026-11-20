extends Node

# populated from json
var shift_total:int
var shift_hours:int
var shift_start_hour:int
var shift_duration_seconds:float # real life

var current_shift:int = 0
var current_shift_elapsed:float = 0.0

var clock_running:bool = false

# player stats displayed in on the shift report (placeholder for now)
var player_stats:Dictionary = {
	"balance": 42,
	"thieves_caught":0,
	"robbers_defeated":0,
	"boss_trust":0
}

# add singals for end of night
# start night
# end night
signal shift_started(shift_no:int)
signal shift_ended(shift_no:int)

signal time_changed(hour: int, minute:int)

# nothing listens for GAME ending signal
signal game_ended()
signal game_lost()

func _ready() -> void:
	shift_total = GameSettings.get_value("shift", "total_shifts")
	shift_hours = GameSettings.get_value("shift", "length_hours")
	shift_start_hour = GameSettings.get_value("shift", "start_hour")
	shift_duration_seconds = GameSettings.get_value("shift", "length_seconds")
	
	start_shift(1)

	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_end_shift"):
		print("debugging")
		end_shift()
		
	if not clock_running:
		return
			
	current_shift_elapsed += delta
	time_changed.emit(get_hour(), get_minute()) 
	
	if current_shift_elapsed >= shift_duration_seconds:
		end_shift()
	
func start_shift(shift_no:int) -> void:
	clock_running = true
	player_stats["thieves_caught"] = 0
	player_stats["robbers_defeated"] = 0
	current_shift = shift_no
	current_shift_elapsed = 0
	
	shift_started.emit(shift_no)
	
func end_shift() -> void:
	if not clock_running:
		return 
		
	clock_running = false
	if current_shift != shift_total:
		shift_ended.emit(current_shift)
		return
	
	# end of the game 
	game_ended.emit()
	
	
func get_minute() -> int:
	return get_minutes_of_day() %60
	
func get_hour() -> int:
	return floori(get_minutes_of_day()/60.0)
	
# helper: % progress of the shift, 0.0 i start, 1.0 is edn of the shift
func get_progress()-> float:
	return clampf(current_shift_elapsed/shift_duration_seconds, 0.0, 1.0)
	
# helper: minuts since midnight
func get_minutes_of_day() -> int:
	var game_minutes = int(get_progress()*shift_hours*60)
	return (shift_start_hour*60 + game_minutes) %(24*60)
	
# convert to 12 hour clock, defined period AM/PM, return formatted string
# will be used by the wall clock
func get_time_str() -> String:
	var hour := get_hour()
	var hour_12 := hour %12
	if hour_12==0:
		hour_12 = 12

	var period
	if hour < 12:
		period = "AM"
	else:
		period = "PM"
	return "%d:%02d %s" % [hour_12,get_minute(),period]

func get_player_stats() -> Dictionary:
	return player_stats.duplicate()
