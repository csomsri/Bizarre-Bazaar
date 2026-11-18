# TODO
	# single source of truth for game time, and end of shift stats
	# know which day/night it is
	# know what time it is (between 10pm and 6am)
	# state of the clock (whether it's ticking) should be off during cutscene
	# game stats
	# emit signal for:
		# shit starts (night)
		# shift ends (night)
		# time has changed
		
# TODO
	# how long is the shift in real time
	# how is time stored (maybe as integer then dynamically computed)
	
extends Node

const SHIFT_TOTAL := 4
const SHIFT_HOURS :=8 
const SHIFT_START_HOUR :=22
const SHIFT_DURATION_MINUTES := 60

# real life duration
@export var shift_duration_seconds := 60.0 

var current_shift = 0
var current_shift_elapsed:float = 0.0

var clock_running = false

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
signal game_ended
signal game_lost


func _ready() -> void:
	time_changed.connect(func(_h, _m): print(get_time_str()))   # TEMP: test the clock
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
	if current_shift != SHIFT_TOTAL:
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
	var game_minutes = int(get_progress()*SHIFT_HOURS*60)
	return (SHIFT_START_HOUR*60 + game_minutes) %(24*60)
	
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
