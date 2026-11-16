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

const SHIFT_TOTAL = 4
var shift_current = 0
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
signal game_ended()
signal game_lost()

func _ready() -> void:
	start_shift(1)
	
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_end_shift"):
		print("debugging")
		end_shift()

	
func start_shift(shift_no:int) -> void:
	clock_running = true
	player_stats["thieves_caught"] = 0
	player_stats["robbers_defeated"] = 0
	shift_current = shift_no
	shift_started.emit(shift_no)
	
func end_shift() -> void:
	if not clock_running:
		return 
		
	clock_running = false
	if shift_current != SHIFT_TOTAL:
		shift_ended.emit(shift_current)
		return
	
	# end of the game 
	game_ended.emit()
	
	
