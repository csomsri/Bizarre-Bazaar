# UI/Input: Adaluz Henriquez Zetino
extends CanvasLayer
class_name GameplayHUD

# HUD Labels and Progress Bar 
@onready var day_label: Label = $HUDRoot/MarginContainer/MainLayout/TopBar/DayPanel/DayLabel
@onready var time_label: Label = $HUDRoot/MarginContainer/MainLayout/TopBar/TimePanel/TimeLabel
@onready var money_label: Label = $HUDRoot/MarginContainer/MainLayout/TopBar/MoneyPanel/MoneyLabel

@onready var trust_value: Label = $HUDRoot/MarginContainer/MainLayout/BottomBar/TrustPanel/TrustLayout/TrustHeader/TrustValue
@onready var trust_bar: ProgressBar = $HUDRoot/MarginContainer/MainLayout/BottomBar/TrustPanel/TrustLayout/TrustProgressBar

@onready var thieves_caught_label: Label = $HUDRoot/MarginContainer/MainLayout/BottomBar/StatsPanel/StatsLayout/ThievesCaughtLabel

@onready var interaction_prompt: Label = $HUDRoot/InteractionPrompt

# FUNCTIONS: Use these in scripts to update HUD
func _ready() -> void:
	# Temp values (for testing)
	set_night(ShiftMgr.current_shift)
	set_time(ShiftMgr.get_time_str())
	set_money(420)
	set_boss_trust(87)
	set_thieves_caught(0)
	
	ShiftMgr.time_changed.connect(_on_time_changed)
	ShiftMgr.shift_started.connect(_on_shift_started)


# FUNC set_day: Updates current in-game day
func set_night(night_number: int) -> void:
	day_label.text = "NIGHT %02d" % night_number

# FUNC set_time: Updates in-game clock
func set_time(time_text: String) -> void:
	time_label.text = time_text

# FUNC set_money: Updates player's money
func set_money(amount: int) -> void:
	money_label.text = "$" + str(amount)

# FUNC set_boss_trust: Updates boss trust level and progress bar
func set_boss_trust(amount: int) -> void:
	# Make sure trust stays between 0,100
	var trust: int = clampi(amount, 0, 100)
	
	trust_value.text = str(trust) + " / 100"
	trust_bar.value = trust

# FUNC set_thieves_caught: Updates number of thieves caught
func set_thieves_caught(amount: int) -> void:
	var total: int = maxi(amount, 0)
	thieves_caught_label.text = "THIEVES CAUGHT: " + str(total)


# INTERACTION PROMPTS
# FUNC show_interaction_prompt AND hide_interction_prompt: show/hide prompt
func show_interaction_prompt(prompt_text: String) -> void:
	interaction_prompt.text = "E - " + prompt_text
	interaction_prompt.show()

func hide_interaction_prompt() -> void:
	interaction_prompt.hide()

# SHIFT MANAGER UPDATES
# FUNC _on_time_chaned: HUD updates whenever ShiftMgr emits time_changed
func _on_time_changed(hour: int, minute: int) -> void:
	var hour_12 := hour % 12
	if hour_12 == 0:
		hour_12 = 12
	
	var period := "AM" if hour < 12 else "PM"
	set_time("%d:%02d %s" % [hour_12, minute, period])

func _on_shift_started(shift_no: int) -> void:
	set_night(shift_no)
