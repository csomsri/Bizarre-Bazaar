extends CanvasLayer
class_name GameplayHUD

# Use these functions in other scripts if you need to update the HUD

# HUD Labels and Progress Bar 
@onready var day_label: Label = $HUDRoot/MarginContainer/MainLayout/TopBar/DayPanel/DayLabel
@onready var time_label: Label = $HUDRoot/MarginContainer/MainLayout/TopBar/TimePanel/TimeLabel
@onready var money_label: Label = $HUDRoot/MarginContainer/MainLayout/TopBar/MoneyPanel/MoneyLabel

@onready var trust_value: Label = $HUDRoot/MarginContainer/MainLayout/BottomBar/TrustPanel/TrustLayout/TrustHeader/TrustValue
@onready var trust_bar: ProgressBar = $HUDRoot/MarginContainer/MainLayout/BottomBar/TrustPanel/TrustLayout/TrustProgressBar

@onready var thieves_caught_label: Label = $HUDRoot/MarginContainer/MainLayout/BottomBar/StatsPanel/StatsLayout/ThievesCaughtLabel

# FUNCTIONS: Use these in scripts to update HUD
func _ready() -> void:
	# Temp values (for testing)
	set_day(3)
	set_time("8:10 AM")
	set_money(420)
	set_boss_trust(87)
	set_thieves_caught(2)


# FUNC set_day: Updates current in-game day
func set_day(day_number: int) -> void:
	day_label.text = "DAY %02d" % day_number

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
